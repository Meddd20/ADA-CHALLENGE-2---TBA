//
//  DetailView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 14/05/25.
//

import SwiftUI

struct DetailView: View {
    var tagId: String
    @State private var content: TagInfo?
    
    func getContent() {
        if let newContent = tagContent[tagId] {
            content = newContent
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: content?.icon ?? "questionmark.circle")
                .font(.system(size: 100))
                .foregroundStyle(.blue)
            Text(content?.title ?? "No title")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical)
            ScrollView {
                VStack(alignment: .leading) {
                    Text(content?.description ?? "No description")
                }
            }
        }
        .padding()
        .onAppear(perform: getContent)
        
    }
}

#Preview {
    DetailView(tagId: "32d14154-828b-4de1-9ce9-d7060afd7320")
}
