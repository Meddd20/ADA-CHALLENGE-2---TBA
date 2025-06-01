//
//  AnomalyModel.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 31/05/25.
//

import Foundation
import TabularData

struct VGSales: Identifiable {
    let id = UUID()
    var name: String
    var platform: String
    var year: Int
    var genre: String
    var publisher: String
    var sales: Double
}


class AnomalyModel: ObservableObject {
    @Published var rows: [VGSales] = []
    @Published var anomalyIndex: Int = 0
    
    init() {
        guard let csvUrl = Bundle.main.url(forResource: "vgsales", withExtension: "csv") else {
            fatalError("CSV file not found in resources.")
        }
        
        guard let df = try? DataFrame(
            contentsOfCSVFile: csvUrl,
            columns: ["Rank", "Name", "Platform", "Year", "Genre", "Publisher", "Global_Sales"],
            types: [
                "Rank": .integer,
                "Name": .string,
                "Platform": .string,
                "Year": .integer,
                "Genre": .string,
                "Publisher": .string,
                "Global_Sales": .double
            ],
        ) else {
            fatalError("Failed to load CSV file.")
        }
        
        let randomIndex = Int.random(in: 0..<100)
        anomalyIndex = randomIndex
        rows = []
        let selectedRows = df.rows.shuffled().prefix(100)
        var currentIndex = 0
        
        selectedRows.forEach { row in
            if
                let name = row["Name"] as? String,
                let platform = row["Platform"] as? String,
                let year = row["Year"] as? Int,
                let genre = row["Genre"] as? String,
                let publisher = row["Publisher"] as? String,
                var sales = row["Global_Sales"] as? Double
            {
                if currentIndex == randomIndex {
                    sales = 9999999999.99
                }
                
                rows.append(VGSales(
                    name: name,
                    platform: platform,
                    year: year,
                    genre: genre,
                    publisher: publisher,
                    sales: sales
                ))
                currentIndex += 1
            }
        }
    }
}

