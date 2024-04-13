//
//  DataSource.swift
//  DataMobileUI
//
//  Created by b on 21/06/2023.
//

import Foundation
import DuckDB
import TabularData

class Cube {
    var db: Database? = nil
    var conn: Connection? = nil
    
    static let shared = Cube()
    static let timeDimensions = ["Date", "DateLocal"]
    
    static let dimsToChose: [CubeQuery.Aggregation] = [
        CubeQuery.Aggregation(name: "SportType", expression: "SportType"),
        CubeQuery.Aggregation(name:"LocationCountry",expression: "LocationCountry"),
        CubeQuery.Aggregation(name:"Date",expression: "DateLocal"),
        CubeQuery.Aggregation(name:"Weekday",expression: "WeekdayLocal"),
        CubeQuery.Aggregation(name:"Month",expression: "MonthLocal"),
        CubeQuery.Aggregation(name:"Year",expression: "YearLocal")]

    static let measuresToChose: [CubeQuery.Aggregation] = [
        CubeQuery.Aggregation(name: "Activity", expression: "SUM(Activity)"),
        CubeQuery.Aggregation(name: "DeviceWatts", expression: "SUM(DeviceWatts)"),
        CubeQuery.Aggregation(name: "MaxSpeed", expression: "SUM(MaxSpeed)"),
        CubeQuery.Aggregation(name: "Kilojoules", expression: "SUM(Kilojoules)"),
        CubeQuery.Aggregation(name: "MovingTime", expression: "SUM(MovingTime)"),
        CubeQuery.Aggregation(name: "Distance", expression: "SUM(Distance)"),
        CubeQuery.Aggregation(name: "TotalElevationGain", expression: "SUM(TotalElevationGain)")
    ]
    
    private let olapCubeQuery = """
                CREATE TABLE olap_activities AS(
                SELECT
                    sport_type as SportType,
                    location_country as LocationCountry,
                    start_date as Date,
                    dayname(start_date::DATE) as Weekday,
                    monthname(start_date::DATE) as Month,
                    year(start_date::DATE) as Year,
                    start_date_local as DateLocal,
                    dayname(start_date_local::DATE) as WeekdayLocal,
                    monthname(start_date_local::DATE) as MonthLocal,
                    year(start_date_local::DATE) as YearLocal,
                    COUNT(*) as Activity,
                    SUM(device_watts::DECIMAL) as DeviceWatts,
                    SUM(max_speed::DECIMAL) as MaxSpeed,
                    SUM(kilojoules::DECIMAL) as Kilojoules,
                    SUM(moving_time::DECIMAL) as MovingTime,
                    SUM(distance::DECIMAL) as Distance,
                    SUM(total_elevation_gain::DECIMAL) as TotalElevationGain
                FROM activities
                GROUP BY
                    sport_type,
                    type,
                    location_country,
                    start_date,
                    dayname(start_date::DATE),
                    monthname(start_date::DATE),
                    year(start_date::DATE),
                    start_date_local,
                    dayname(start_date_local::DATE),
                    monthname(start_date_local::DATE),
                    year(start_date_local::DATE)
                );
                """
    
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
                    );
                    \(self.olapCubeQuery)
                    DROP TABLE activities;
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
    private func backup(demoMode: Bool = false) throws {
        let fileManager = FileManager.default
        let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = dir!.appendingPathComponent("data").appendingPathComponent(demoMode ? "activities_demo.json" : "activities.json")
        let backupPath = dir!.appendingPathComponent("data").appendingPathComponent(demoMode ? "activities_demo.backup.json" : "activities.backup.json")
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
    private func rollback(demoMode: Bool = false) throws {
        let fileManager = FileManager.default
        let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = dir!.appendingPathComponent("data").appendingPathComponent(demoMode ? "activities_demo.json" : "activities.json")
        let backupPath = dir!.appendingPathComponent("data").appendingPathComponent(demoMode ? "activities_demo.backup.json" : "activities.backup.json")
        
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
    func reload(demoMode: Bool = false, with continueAfter: @escaping (Bool) -> ()) throws {
        do {
            try backup()
            let fileManager = FileManager.default
            let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            let filePath = dir!.appendingPathComponent("data").appendingPathComponent(demoMode ? "activities_demo.json" : "activities.json")
            let activityColumns: String = Activity.generateDuckDBSchema()
            let dbArgs: String = "columns=\(activityColumns)"
            // conn.execute is useless since duckdb doesn't return reason in case it errors
            // so always use .query and just ignore the result if it isn't needed just like in this case
            try conn!.query("""
                DROP TABLE activities;
                CREATE TABLE activities AS (
                        SELECT * FROM read_json('\(filePath.path)', \(dbArgs))
                );
                DROP TABLE olap_activities;
                \(self.olapCubeQuery)
                DROP TABLE activities;
            """)
            continueAfter(true)
        } catch {
            try! rollback()
            debugPrint("Failed to reload table: activities \(error)")
            continueAfter(false)
        }
    }
    
    func loadDemoData() throws {
        let fileManager = FileManager.default
        let bundlePath = Bundle.main.path(forResource: "activities_demo", ofType: "json")!
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationPath = documentsDirectory.appendingPathComponent("data").appendingPathComponent("activities_demo.json")
        if !fileManager.fileExists(atPath: destinationPath.path) {
                do {
                    try fileManager.copyItem(atPath: bundlePath, toPath: destinationPath.path)
                    print("File copied")
                } catch let error {
                    print("Error copying file: \(error.localizedDescription)")
                }
            }
        
        try reload(demoMode: true, with: {_ in })
    }
    
    func getUniqueValues(columnName: String) throws -> [String] {
        let query = "SELECT DISTINCT(\(columnName)) as dist FROM olap_activities"
        
        let result: ResultSet
        do {
            result = try conn!.query(query)
        } catch {
            debugPrint("\(error.localizedDescription)")
            throw error
        }
        
        let df = DataFrame(columns: [TabularData.Column(result[0].cast(to: String.self)).eraseToAnyColumn()])
        return result[0].cast(to: String.self).map { $0 ?? "" }
    }
    
    private let weekDayNumbers = [
        "Sunday": 0,
        "Monday": 1,
        "Tuesday": 2,
        "Wednesday": 3,
        "Thursday": 4,
        "Friday": 5,
        "Saturday": 6,
    ]
    
    private let monthNumbers = [
        "January": 0,
        "February": 1,
        "March": 2,
        "April": 3,
        "May": 4,
        "June": 5,
        "July": 6,
        "August": 7,
        "September": 8,
        "October": 9,
        "November": 10,
        "December": 11,
    ]
    
    private func sortWeekdays(first: (String, [ChartItem._ChartContent]), second: (String, [ChartItem._ChartContent])) -> Bool {
        return (weekDayNumbers[first.0] ?? 7) < (weekDayNumbers[second.0] ?? 7);
    }
    
    private func sortWeekdays(first: ChartItem._ChartContent, second: ChartItem._ChartContent) -> Bool {
        return (weekDayNumbers[first.key] ?? 7) < (weekDayNumbers[second.key] ?? 7);
    }
    
    private func sortMonths(first: (String, [ChartItem._ChartContent]), second: (String, [ChartItem._ChartContent])) -> Bool {
        return (monthNumbers[first.0] ?? 12) < (monthNumbers[second.0] ?? 12);
    }
    
    private func sortMonths(first: ChartItem._ChartContent, second: ChartItem._ChartContent) -> Bool {
        return (monthNumbers[first.key] ?? 12) < (monthNumbers[second.key] ?? 12);
    }
    
    private func sortDate(first: (String, [ChartItem._ChartContent]), second: (String, [ChartItem._ChartContent])) -> Bool {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let d1 = dateFormatter.date(from: String(first.0.prefix(10)))!
        let d2 = dateFormatter.date(from: String(second.0.prefix(10)))!	
        return d1.compare(d2) == .orderedAscending
    }
    
    private func sortDate(first: ChartItem._ChartContent, second: ChartItem._ChartContent) -> Bool {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let d1 = dateFormatter.date(from: String(first.key.prefix(10)))!
        let d2 = dateFormatter.date(from: String(second.key.prefix(10)))!
        return d1.compare(d2) == .orderedAscending
    }
    
    func query(cubeQuery: CubeQuery) throws -> [(String, [ChartItem._ChartContent])] {
        let dimensionString = cubeQuery.dimensions.map { "CAST(\($0.expression) as VARCHAR) as \($0.name)" }.joined(separator: ",")
        let measuresString = cubeQuery.measures.map { "CAST(\($0.expression) as INT) as \($0.name)" }.joined(separator: ",")
        
        let groupByClause = cubeQuery.dimensions.map { $0.expression }.joined(separator: ",")
        
        var whereClause = ""
        var conditions: [String] = []
        var _whereIN: String = ""
        if cubeQuery.filters.count > 0 {
            _whereIN = ""
            cubeQuery.filters.forEach {
                filter in
                _whereIN += filter.name
                if filter.exclude {
                    _whereIN += " NOT "
                }
                
                _whereIN += " IN ( \(filter.chosen.map{ "\'" + $0 + "\'" }.joined(separator: ",")) )"
                conditions.append(_whereIN)
            }
            whereClause = "WHERE \(conditions.joined(separator: " AND "))"
        }

        
        let queryString = "SELECT \(dimensionString), \(measuresString) FROM olap_activities \(whereClause) GROUP BY \(groupByClause)"
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
        
        // TODO: Needs to be sorted. Sorting depends dimension.
        let flatDimensions = cubeQuery.dimensions.map{ $0.name }
        
        let final = grouped.map {
            ($0.key, $0.value)
        }
        
        if flatDimensions.contains(where: {["Date", "DateLocal"].contains($0)}) {
            return grouped.map {
                ($0.key, $0.value.sorted(by: sortDate))
            }.sorted(by: sortDate)
        }
        
        if flatDimensions.contains(where: {["Month", "MonthLocal"].contains($0)}) {
            return grouped.map {
                ($0.key, $0.value.sorted(by: sortMonths))
            }.sorted(by: sortMonths)
        }
        
        if flatDimensions.contains(where: {["Weekday", "WeekdayLocal"].contains($0)}) {
            return grouped.map {
                ($0.key, $0.value.sorted(by: sortWeekdays))
            }.sorted(by: sortWeekdays)
        }
        
        return final.sorted(by: { $0.0.compare($1.0) == .orderedAscending})
    }
}
