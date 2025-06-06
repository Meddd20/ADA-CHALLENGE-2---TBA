//
//  AnomalyView.swift
//  iTour
//
//  Created by Ramdan on 31/05/25.
//

import SwiftUI

struct AnomalyView: View {
    var tagId: String
    @StateObject var model = AnomalyModel()
    @StateObject var haptic = HapticModel()
    @EnvironmentObject var navManager: NavigationManager<Routes>
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var onComplete: (() -> Void)
    
    // Define table column layout
    let columns = [
        GridItem(.flexible(minimum: 100)), // Name
        GridItem(.flexible(minimum: 60)),  // Platform
        GridItem(.flexible(minimum: 50)),  // Year
        GridItem(.flexible(minimum: 80)),  // Genre
        GridItem(.flexible(minimum: 80)),  // Publisher
        GridItem(.flexible(minimum: 60))   // Sales
    ]
    let columnWidths: [CGFloat] = [160, 80, 60, 100, 120, 80]
    
    var body: some View {
        VStack {
            Text("Tap the row where you see an anomaly!")
            ScrollView(.vertical) {
                ScrollView(.horizontal) {
                    VStack(spacing: 0) {
                        // Header Row
                        HStack(spacing: 0) {
                            headerCell("Name", width: columnWidths[0])
                            headerCell("Platform", width: columnWidths[1])
                            headerCell("Year", width: columnWidths[2])
                            headerCell("Genre", width: columnWidths[3])
                            headerCell("Publisher", width: columnWidths[4])
                            headerCell("Sales", width: columnWidths[5])
                        }
                        Divider()
                        // Data Rows
                        ForEach(model.rows.indices, id: \.self) { index in
                            let row = model.rows[index]
                            HStack(spacing: 0) {
                                dataCell(row.name, width: columnWidths[0], alignment: .leading)
                                dataCell(row.platform, width: columnWidths[1])
                                dataCell("\(row.year)", width: columnWidths[2])
                                dataCell(row.genre, width: columnWidths[3])
                                dataCell(row.publisher, width: columnWidths[4])
                                dataCell(String(format: "%.2f", row.sales), width: columnWidths[5])
                            }
                            .frame(height: 44)
                            .background(Color.white)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if index == model.anomalyIndex {
                                    onComplete()
                                } else {
                                    alertTitle = "❌ Nope"
                                    alertMessage = "This row seems normal."
                                }
                                showAlert = true
                            }
                            
                            Divider()
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage))
            }
            .padding(.horizontal)
        }
    }
    
    // Header cell
    func headerCell(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .font(.headline)
            .frame(width: width, height: 44)
            .background(Color.gray.opacity(0.2))
            .border(Color.gray.opacity(0.3), width: 0.5)
    }

    // Data cell
    func dataCell(_ text: String, width: CGFloat, alignment: Alignment = .center) -> some View {
        HStack {
            Text(text)
                .font(.subheadline)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.horizontal, 5)
        .frame(width: width, height: 44, alignment: alignment)
        .border(Color.gray.opacity(0.2), width: 0.5)
    }
}

