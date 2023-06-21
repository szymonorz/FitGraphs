//
//  DataSource.swift
//  DataMobileUI
//
//  Created by b on 21/06/2023.
//

import Foundation
import DuckDB
import TabularData

class DataSource: ObservableObject {
    let db: Database
    let conn: Connection
    
    static func create() throws -> DataSource {
        let db = try Database(store: .inMemory)
        let conn = try db.connect()
        var filePath: URL
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        filePath = dir!.appendingPathComponent("data").appendingPathComponent("activities.csv")
        
        try conn.execute("""
                CREATE TABLE activities AS (
                        SELECT * FROM read_csv_auto('\(filePath.path)')
                )
            """)
        
        return DataSource(db: db, conn: conn)
    }
    
    func getCount(measure: String, dimensions: String) throws -> DataFrame {
        let queryString = "SELECT \(dimensions), \(measure) as count FROM activities GROUP BY \(dimensions)"
        
        let result = try conn.query(queryString);
        
        let dimensionColumn = result[0].cast(to: String.self)
        let countColumn = result[1].cast(to: Int.self)
        
        return DataFrame(
            columns: [
                TabularData.Column(dimensionColumn).eraseToAnyColumn(),
                TabularData.Column(countColumn).eraseToAnyColumn()
            ]
        )
    }
    
    private init(db: Database, conn: Connection){
        self.db = db
        self.conn = conn
    }
    
}
