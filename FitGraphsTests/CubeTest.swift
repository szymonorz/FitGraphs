//
//  CubeTest.swift
//  FitGraphsTests
//
//  Created by b on 19/04/2024.
//

import XCTest
@testable import FitGraphs

final class CubeTest: XCTestCase {

    let dimensions = [
        CubeQuery.Aggregation(name: "Type", expression: "Type")
    ]
    
    let measures = [
        CubeQuery.Aggregation(name: "Activity", expression: "count(activity)")
    ]
    
    let inclusiveFilter = [
        CubeQuery.Filter(
            name: "Type",
            exclude: false,
            chosen: ["Run", "Swim"]
        )
    ]
    
    let exclusiveFilter = [
        CubeQuery.Filter(
            name: "Type",
            exclude: true,
            chosen: ["Run", "Swim"]
        )
    ]
    
    let inclusiveDateRangeFilter = [
        CubeQuery.Filter(
            name: "Date",
            exclude: false,
            chosen: ["2023-03-01","2024-03-01"]
        )
    ]
    
    let exclusiveDateRangeFilter = [
        CubeQuery.Filter(
            name: "Date",
            exclude: true,
            chosen: ["2023-03-01","2024-03-01"]
        )
    ]
    
    func testGenerateSQL() throws {
        var cubeQuery = CubeQuery()
        cubeQuery.dimensions = dimensions
        cubeQuery.measures = measures
        
        let genSQL = try Cube.generateSQL(cubeQuery: cubeQuery)
        let shouldBeSql = "SELECT CAST(Type as VARCHAR) as Type, CAST(count(activity) as INT) as Activity FROM olap_activities  GROUP BY Type"
     
        
        XCTAssertEqual(genSQL, shouldBeSql)
    }
    
    func testGenerateWhereClause() throws {
        var cubeQuery = CubeQuery()
        cubeQuery.dimensions = dimensions
        cubeQuery.measures = measures
        cubeQuery.filters = inclusiveFilter
        
        let genSQL = try Cube.generateSQL(cubeQuery: cubeQuery)
        let shouldBeSql = "SELECT CAST(Type as VARCHAR) as Type, CAST(count(activity) as INT) as Activity FROM olap_activities WHERE  ( Type IN ( 'Run','Swim' ) ) GROUP BY Type"
        
        XCTAssertEqual(genSQL, shouldBeSql)
    }
    
    func testGenerateExclusiveWhereClause() throws {
        var cubeQuery = CubeQuery()
        cubeQuery.dimensions = dimensions
        cubeQuery.measures = measures
        cubeQuery.filters = exclusiveFilter
        
        let genSQL = try Cube.generateSQL(cubeQuery: cubeQuery)
        let shouldBeSql = "SELECT CAST(Type as VARCHAR) as Type, CAST(count(activity) as INT) as Activity FROM olap_activities WHERE  ( Type NOT IN ( 'Run','Swim' ) ) GROUP BY Type"
        
        XCTAssertEqual(genSQL, shouldBeSql)
    }
    
    func testGenerateInclusiveDateRange() throws {
        var cubeQuery = CubeQuery()
        cubeQuery.dimensions = dimensions
        cubeQuery.measures = measures
        cubeQuery.filters = inclusiveDateRangeFilter
        
        let genSQL = try Cube.generateSQL(cubeQuery: cubeQuery)
        let shouldBeSql = "SELECT CAST(Type as VARCHAR) as Type, CAST(count(activity) as INT) as Activity FROM olap_activities WHERE  ( Date BETWEEN '2023-03-01' and '2024-03-01' ) GROUP BY Type"
        
        XCTAssertEqual(genSQL, shouldBeSql)
    }
    
    func testGenerateExclusiveDateRange() throws {
        var cubeQuery = CubeQuery()
        cubeQuery.dimensions = dimensions
        cubeQuery.measures = measures
        cubeQuery.filters = exclusiveDateRangeFilter
        
        let genSQL = try Cube.generateSQL(cubeQuery: cubeQuery)
        let shouldBeSql = "SELECT CAST(Type as VARCHAR) as Type, CAST(count(activity) as INT) as Activity FROM olap_activities WHERE  ( Date NOT BETWEEN '2023-03-01' and '2024-03-01' ) GROUP BY Type"
        
        XCTAssertEqual(genSQL, shouldBeSql)
    }
    
    func testMixedFilter() throws {
        var cubeQuery = CubeQuery()
        cubeQuery.dimensions = dimensions
        cubeQuery.measures = measures
        cubeQuery.filters = inclusiveFilter + exclusiveDateRangeFilter
        
        let genSQL = try Cube.generateSQL(cubeQuery: cubeQuery)
        let shouldBeSql = "SELECT CAST(Type as VARCHAR) as Type, CAST(count(activity) as INT) as Activity FROM olap_activities WHERE  ( Type IN ( 'Run','Swim' ) ) AND  ( Date NOT BETWEEN '2023-03-01' and '2024-03-01' ) GROUP BY Type"
        
        XCTAssertEqual(genSQL, shouldBeSql)
    }
    
    func testThrowErrorOnEmptyDimensions() throws {
        var cubeQuery = CubeQuery()
        cubeQuery.dimensions = []
        cubeQuery.measures = measures
        cubeQuery.filters = inclusiveFilter + exclusiveDateRangeFilter
        
        XCTAssertThrowsError(try Cube.generateSQL(cubeQuery: cubeQuery)) { error in
            XCTAssertEqual(error as! CubeQuery.QueryErrors, CubeQuery.QueryErrors.emptyDimensions)
        }
    }
    
    func testThrowErrorOnEmptyMeasures() throws {
        var cubeQuery = CubeQuery()
        cubeQuery.dimensions = dimensions
        cubeQuery.measures = []
        
        XCTAssertThrowsError(try Cube.generateSQL(cubeQuery: cubeQuery)) { error in
            XCTAssertEqual(error as! CubeQuery.QueryErrors, CubeQuery.QueryErrors.emptyMeasures)
        }
    }

}
