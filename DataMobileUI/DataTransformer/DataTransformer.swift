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
    
    func fetchFromStrava(with complectionBlock: @escaping () -> () ) {
        api.getUserActivities(with: { [weak self] activities in
            var json: Data
            do {
                json = try JSONEncoder().encode(activities)
            } catch {
                debugPrint("Encoding to JSON failed. \(error.localizedDescription) Aborting")
                return
            }
            self!.saveToDevice(data: json)
            complectionBlock()
        })
    }
    
    func saveToDevice(data: Data) {
        if let dir = fileManager!.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dataPth = dir.appendingPathComponent("data")
            
            do {
                try fileManager!.createDirectory(atPath: dataPth.path(), withIntermediateDirectories: true)
            } catch let error as NSError{
                debugPrint("Failed to create directory at \(dataPth.absoluteString): \(error.localizedDescription)")
                return
            }
            
            let fileUrl = dataPth.appendingPathComponent("activities.json")
            
            do {
                debugPrint(data)
                try data.write(to: fileUrl)
            } catch {
                debugPrint("Failed to save file: \(error.localizedDescription)")
            }
        }
    }
}
