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
    @State private var videoID: String?
    
    func getContent() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let newContent = tagContent[tagId] {
                let id = newContent.videoID
                
                DispatchQueue.main.async {
                    self.content = newContent
                    self.videoID = id
                }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if videoID != nil {
//                    DriveVideoPlayerView(fileId: videoID ?? "1u8S7BK_2KR49GmnbeQE5jVy5WjMGH84q")
//                        .frame(maxWidth: .infinity)
//                        .cornerRadius(12)
//                        .frame(height: 400)
//                        .overlay(Color.black.opacity(0.2))
//                        .clipped()
                    
                    YoutubePlayer(videoId: "vzNZrdimAYs")
                        .frame(height: 400)
                        .cornerRadius(12)
                } else {
                    ZStack {
                        Color.gray.opacity(0.3)
                        Image(systemName: "video.slash.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                    .frame(height: 400)
                    .overlay(Color.black.opacity(0.2))
                    .clipped()
                    .cornerRadius(12)
                }

                VStack(spacing: 12) {
                    Text(content?.title ?? "No title")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .fontWidth(.condensed)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)

                    Text(content?.description ?? "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent volutpat bibendum accumsan. Aenean risus enim, congue at augue et, luctus ornare dolor. Nam aliquam leo id ornare sagittis. Ut pharetra leo non enim mattis congue. Vivamus varius, est vitae dictum ornare, nibh ligula laoreet mauris, sed vulputate diam magna vel eros. Fusce suscipit nunc quis est finibus vestibulum. Pellentesque id ultricies libero. Praesent porta tempus lacus, non congue neque hendrerit eget. Sed semper eget felis vel lacinia. Nam congue porttitor orci, at tincidunt nunc maximus a. In id tellus urna. Nam pulvinar, augue at porta lacinia, sapien est ornare dolor, vitae ultrices orci metus nec magna. In congue pulvinar massa vitae luctus. Praesent vitae urna et massa auctor rutrum vitae non nisl.")
                        .font(.system(size: 16))
                        .fontWidth(.expanded)
                        .foregroundColor(.black)
                        .lineSpacing(6)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 40)
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, -80)
            }
        }
        .onAppear(perform: getContent)
    }
}

#Preview {
    DetailView(tagId: "32d14154-828b-4de1-9ce9-d7060afd7320")
}
