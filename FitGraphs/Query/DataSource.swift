//
//  DataSource.swift
//  DataMobileUI
//
//  Created by b on 21/06/2023.
//

import Foundation
import DuckDB
import TabularData

class DataSource {
    var db: Database? = nil
    var conn: Connection? = nil
    
    static let shared = DataSource()
    
    // Initiates a DataSource instance
    // Technically this looks like it should be a singleton but as of now
    // I have no idea what I'm doing/want to do
    // probably a TODO: Refactor when I know what to do
    init() {
        let fileManager = FileManager.default
       
        do {
            db = try? Database(store: .inMemory)
            conn = try? db!.connect()
            
            var filePath: URL
            let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            filePath = dir!.appendingPathComponent("data").appendingPathComponent("activities.json")
            debugPrint(filePath.path)
            if !fileManager.fileExists(atPath: filePath.path) {
                debugPrint("File doesn't exist. Creating empty file so DataSource doesn't shrimp itself...... ")
                if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let dataPth = dir.appendingPathComponent("data")
                    
                    do {
                        try fileManager.createDirectory(atPath: dataPth.path(), withIntermediateDirectories: true)
                    } catch let error as NSError{
                        debugPrint("Failed to create directory at \(dataPth.absoluteString): \(error.localizedDescription)")
                    }
                    
                    do {
                        try "[]".write(toFile: filePath.path, atomically: false, encoding: .utf8)
                    } catch {
                        debugPrint("Failed to save file: \(error.localizedDescription)")
                    }
                }
            }
            
            do {
                let activityColumns: String = Activity.generateDuckDBSchema()
                let dbArgs: String = "columns=\(activityColumns)"
                try conn!.query("""
                    CREATE TABLE activities AS (
                            SELECT * FROM read_json('\(filePath.path)', \(dbArgs))
                    )
                """)
            } catch {
                debugPrint("Create table failed: \(error) at filePath: \(filePath.path)")
                // This should literally never happen
                try fileManager.removeItem(atPath: filePath.path)
                throw error
            }
        } catch {
            debugPrint("Whoops")
        }
    }
    
    // Create a backup in case shit goes down
    private func backup() throws {
        let fileManager = FileManager.default
        let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = dir!.appendingPathComponent("data").appendingPathComponent("activities.json")
        let backupPath = dir!.appendingPathComponent("data").appendingPathComponent("activities.json.backup")
        do {
            if fileManager.fileExists(atPath: backupPath.path) {
                try fileManager.removeItem(at: backupPath)
            }
            try fileManager.copyItem(at: filePath, to: backupPath)
        } catch {
            debugPrint("Failed to create backup. Reason: \(error.localizedDescription). It is so over....")
            throw error
        }
    }
    
    // Rollback to the most recent backup
    // If it breaks then it is basically over and I'm an awful developer (true)
    private func rollback() throws {
        let fileManager = FileManager.default
        let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = dir!.appendingPathComponent("data").appendingPathComponent("activities.json")
        let backupPath = dir!.appendingPathComponent("data").appendingPathComponent("activities.json.backup")
        
        if fileManager.fileExists(atPath: filePath.path) {
            do {
                try fileManager.removeItem(at: filePath)
                try fileManager.copyItem(at: backupPath, to: filePath)
            } catch {
                debugPrint("Failed to rollback. Reason: \(error.localizedDescription). It is so over....")
                throw error
            }
        }
    }
    
    // Reload .inMemory database
    // should only be called after fetching new data
    // drops table and creates a new one
    // It is safe to do so since all data is kept inside JSON file
    func reload(with continueAfter: @escaping (Bool) -> ()) throws {
        do {
            try backup()
            let fileManager = FileManager.default
            let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            let filePath = dir!.appendingPathComponent("data").appendingPathComponent("activities.json")
            let activityColumns: String = Activity.generateDuckDBSchema()
            let dbArgs: String = "columns=\(activityColumns)"
            // conn.execute is useless since duckdb doesn't return reason in case it errors
            // so always use .query and just ignore the result if it isn't needed just like in this case
            try conn!.query("""
                DROP TABLE activities;
                CREATE TABLE activities AS (
                        SELECT * FROM read_json('\(filePath.path)', \(dbArgs))
                );
            """)
            continueAfter(true)
        } catch {
            try! rollback()
            debugPrint("Failed to relaod table: activities \(error.localizedDescription)")
            continueAfter(false)
        }
    }
    
    func query(cubeQuery: CubeQuery) throws -> [(String, [ChartItem._ChartContent])] {
        let dimensionString = cubeQuery.dimensions.map { "CAST(\($0.expression) as VARCHAR) as \($0.name)" }.joined(separator: ",")
        let measuresString = cubeQuery.measures.map { "CAST(\($0.expression) as VARCHAR) as \($0.name)" }.joined(separator: ",")
        
        let groupByClause = cubeQuery.dimensions.map { $0.expression }.joined(separator: ",")
        
        let queryString = "SELECT \(dimensionString), \(measuresString) FROM activities GROUP BY \(groupByClause)"
        let result: ResultSet
        do {
            result = try conn!.query(queryString);
        } catch {
            debugPrint("Encountered an error \(error)")
            throw error
        }
        var dimensionsColumns: [TabularData.AnyColumn] = []
        var valueColumns: [TabularData.AnyColumn] = []
        
        for dimension in cubeQuery.dimensions {
            guard let index = result.index(forColumnName: dimension.name) else {
                continue
            }
            let dimColumn = result[index].cast(to: String.self)
            dimensionsColumns.append(TabularData.Column(dimColumn).eraseToAnyColumn())
        }
        
        for measure in cubeQuery.measures {
            guard let index = result.index(forColumnName: measure.name) else {
                continue
            }
            let measureColumn = result[index].cast(to: Int.self)
            valueColumns.append(TabularData.Column(measureColumn).eraseToAnyColumn())
        }
        
//        let dimensionColumn = result[0].cast(to: String.self)
//        let countColumn = TabularData.Column(result[1]).eraseToAnyColumn()
//        
        let df = DataFrame(
            columns: dimensionsColumns + valueColumns
        )
        
        var grouped: [String: [ChartItem._ChartContent]] = [:]
        
        for row in df.rows {
            guard let split = row[cubeQuery.dimensions[0].name] as? String else {
                continue
            }
            
            var dim: String = split
            if cubeQuery.dimensions.count > 1 {
                guard let _dim = row[cubeQuery.dimensions[1].name] as? String else {
                    continue
                }
                dim = _dim
            }
            
            guard let meas = row[cubeQuery.measures[0].name] as? Int else {
                continue
            }
            
            let chartContent: ChartItem._ChartContent = ChartItem._ChartContent(key: split, value: Decimal(meas))
            grouped[dim, default: []].append(chartContent)
        }
        
//        var chartContents: [ChartItem._ChartContent] = []
//        
//        let labelColumn = df.columns[dimensions.count - 1].assumingType(String.self).filled(with: "")
//        let valueColumn = df.columns[measures.count - 1].assumingType(Int.self).filled(with: 0)
//        
//        for (label, count) in zip(labelColumn, valueColumn) {
//            chartContents.append(ChartItem._ChartContent(key: String(label), value: Decimal(count)))
//        }
        
        return grouped.map { ($0.key, $0.value) }
    }
}
