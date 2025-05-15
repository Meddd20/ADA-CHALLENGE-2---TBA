//
//  DetailView.swift
//  ADA-OpenHouse
//
//  Created by Ramdan on 14/05/25.
//
// aku aku aku

import SwiftUI

struct DetailView: View {
    var tagId: String
    
    var body: some View {
        ScrollView {
            VStack {
                Image("jensen_huang")
                    .resizable()
                    .frame(width: 300, height: 200)
                    .scaledToFit()
                    .cornerRadius(12)
                Text("tagId: \(tagId)")
                    .font(.headline)
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla dapibus ex et orci auctor vulputate. In erat elit, ultricies a egestas non, porttitor quis mi. Aliquam luctus dolor ut risus iaculis, quis suscipit enim lobortis. Phasellus ac commodo ligula. Aenean cursus leo sit amet lacinia sodales. Aliquam erat volutpat. Aenean non tincidunt lacus.\n\nQuisque diam leo, semper ac tristique non, molestie a arcu. Suspendisse pellentesque nunc in velit lobortis, at ornare massa semper. Vivamus vehicula non nibh sed scelerisque. Sed sit amet diam et augue dapibus suscipit sed ut quam. Nullam mattis congue tortor in maximus. Donec vel nunc imperdiet, suscipit magna vitae, varius turpis. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Pellentesque convallis eu lacus sed consequat.\n\nVivamus porta lacus sem, in lacinia orci ullamcorper ac. Phasellus eu nisi rutrum, laoreet sapien in, ultrices enim. Nulla eget ipsum dui. Phasellus et nulla lorem. Morbi sollicitudin enim quis mi laoreet tincidunt. Curabitur pretium augue ligula, in commodo justo volutpat vitae. Maecenas sem eros, vulputate at elit non, sagittis sollicitudin lorem. Donec sit amet sodales massa. Aliquam egestas odio ligula, sollicitudin aliquet quam pharetra vel. Mauris id imperdiet tortor. Fusce sit amet arcu velit. Nulla tortor augue, dictum in lobortis et, luctus ut odio. Maecenas vitae erat vitae leo lacinia volutpat.\n\nCurabitur eget turpis eu mi pulvinar dignissim. Aliquam erat volutpat. Mauris dictum, ante sed elementum auctor, purus libero sagittis tellus, non efficitur arcu risus vel mauris. Integer aliquet ipsum turpis, a mattis urna tincidunt et. Duis iaculis pharetra diam, nec bibendum enim scelerisque sed. Vestibulum aliquet molestie sem. Maecenas et magna nec eros ultrices condimentum.\n\nAliquam tellus nunc, faucibus non porta in, eleifend sollicitudin mi. Quisque et magna faucibus, varius urna nec, fringilla mauris. Maecenas in neque euismod, tempor nisi sit amet, elementum est. Nam lacus libero, blandit vitae eros sed, efficitur porta metus. Aenean arcu arcu, placerat nec ipsum luctus, aliquet pellentesque massa. Sed nibh enim, posuere vitae interdum at, ornare eget sem. Morbi id euismod lectus, ut ultricies tortor. Nunc at tortor vel velit vestibulum eleifend a id turpis. Fusce dignissim turpis ac sollicitudin efficitur. Fusce iaculis justo in sem efficitur malesuada. Nullam porttitor maximus lacus, in ultricies dui sagittis et. Sed sagittis augue nunc, nec iaculis purus tristique non. Morbi sit amet risus quis urna fermentum pulvinar ac quis turpis. Cras sollicitudin justo sed ante fermentum condimentum. Proin sed enim est. Maecenas vulputate, lacus eget sodales congue, lectus libero facilisis lorem, id sollicitudin tellus libero ac ex.")
            }
            .padding()
        }
        
    }
}

#Preview {
    DetailView(tagId: "123")
}
