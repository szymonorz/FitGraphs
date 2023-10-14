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
    
    func query(dimensions: [String], measures: [String]) throws -> [ChartItem._ChartContent] {
        let dimensionString = dimensions.joined(separator: ",")
        let measuresString = measures.joined(separator: ",")
        
        let queryString = "SELECT \(dimensionString), \(measuresString) as count FROM activities GROUP BY \(dimensionString)"
        let result: ResultSet
        do {
            result = try conn!.query(queryString);
        } catch {
            debugPrint("Encountered an error \(error)")
            throw error
        }
        
        let dimensionColumn = result[0].cast(to: String.self)
        let countColumn = result[1].cast(to: Int.self)
        
        let df = DataFrame(
            columns: [
                TabularData.Column(dimensionColumn).eraseToAnyColumn(),
                TabularData.Column(countColumn).eraseToAnyColumn()
            ]
        )
        
        var chartContents: [ChartItem._ChartContent] = []
        let labelColumn = df.columns[0].assumingType(String.self).filled(with: "")
        let valueColumn = df.columns[1].assumingType(Int.self).filled(with: 0)
        
        for (activity, count) in zip(labelColumn, valueColumn) {
            chartContents.append(ChartItem._ChartContent(key: String(activity), value: Decimal(count)))
        }
        
        return chartContents
    }
}
