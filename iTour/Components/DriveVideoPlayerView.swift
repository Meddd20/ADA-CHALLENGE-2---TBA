//
//  DriveVideoPlayerView.swift
//  iTour
//
//  Created by Medhiko Biraja on 02/06/25.
//

import SwiftUI
import WebKit

struct DriveVideoPlayerView: UIViewRepresentable {
    let fileId: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let embedURL = "https://drive.google.com/file/d/\(fileId)/preview"
        let request = URLRequest(url: URL(string: embedURL)!)
        webView.load(request)
    }
}

struct YoutubePlayer: UIViewRepresentable {
    let videoId: String
    let youtubeBaseURL = "https://www.youtube.com/embed/"

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let fullURL = URL(string: youtubeBaseURL + videoId) else { return }
        let request = URLRequest(url: fullURL)
        uiView.load(request)
    }
}



