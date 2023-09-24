//
//  DataTransformer.swift
//  DataMobileUI
//
//  Created by b on 20/06/2023.
//

import Foundation
import Dependencies


struct DataTransformer {
    var saveToDevice: (Data) -> ()
}

extension DataTransformer: DependencyKey {
    static let liveValue = DataTransformer(
        saveToDevice: { data in
            let fileManager = FileManager.default
            if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let dataPth = dir.appendingPathComponent("data")
                
                do {
                    try fileManager.createDirectory(atPath: dataPth.path(), withIntermediateDirectories: true)
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
    )
}

extension DependencyValues {
    var dataTransformer: DataTransformer {
        get { self[DataTransformer.self] }
        set { self[DataTransformer.self] = newValue }
    }
}
