//
//  DataTransformer.swift
//  DataMobileUI
//
//  Created by b on 20/06/2023.
//

import Foundation
import CSVParser

class DataTransformer: ObservableObject {
    var fileManager: FileManager? = nil
    var api: StravaApi	
    
    init(api: StravaApi) {
        self.fileManager = FileManager.default
        self.api = api
    }
    
    func fetchFromStrava() {
        api.getUserActivities(with: { [weak self] activities in
            var json: Data
            do {
                json = try JSONEncoder().encode(activities)
            } catch {
                debugPrint("Encoding to JSON failed. \(error.localizedDescription) Aborting")
                return
            }
            var csv: String
            do {
                csv = try CSVParser.jsonToCSVString(jsonData: json)
            } catch {
                debugPrint("Parsing to CSV failed. \(error.localizedDescription) Aborting")
                return
            }
            
            self!.saveToDevice(data: csv)
        })
    }
    
    func saveToDevice(data: String) {
        if let dir = fileManager!.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dataPth = dir.appendingPathComponent("data")
            
            do {
                try fileManager!.createDirectory(atPath: dataPth.path(), withIntermediateDirectories: true)
            } catch let error as NSError{
                debugPrint("Failed to create directory at \(dataPth.absoluteString): \(error.localizedDescription)")
                return
            }
            
            let fileUrl = dataPth.appendingPathComponent("activities.csv")
            
            do {
                try data.write(toFile: fileUrl.path, atomically: false, encoding: .utf8)
            } catch {
                debugPrint("Failed to save file: \(error.localizedDescription)")
            }
        }
    }
    
    func loadDataFromFile() {
        if let dir = fileManager!.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = dir.appendingPathComponent("data").appendingPathComponent("activities.csv")
            
            do {
                let csv = try CSVParser(filePath: filePath.path)
                //csv[0] = Activity.CodingKeys.allCases.map { $0.stringValue }
                for row in csv {
                    debugPrint(row)
                }
            } catch {
                debugPrint("Error reading file. \(error.localizedDescription)")
            }
        }
    }
}
