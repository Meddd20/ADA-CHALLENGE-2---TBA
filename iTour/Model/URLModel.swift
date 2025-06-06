//
//  URLModel.swift
//  iTour
//
//  Created by Ramdan on 21/05/25.
//

import Foundation

func extractTagId(_ url: URL?) -> String? {
    guard let url = url else {
        print("URL is nil")
        return nil
    }
    
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
        print("Invalid URL")
        return nil
    }
    
    
    // Extract the path and query items from the URL
    let path = components.path
    let queryItems = components.queryItems
    
    // Example: Handle different paths and query parameters
    if path == "/details" {
        if let tagId = queryItems?.first(where: { $0.name == "id" })?.value {
            return tagId
        } else {
            print("Tag ID missing")
        }
    } else {
        print("Unknown path: \(path)")
    }
    
    return nil
}
