//
//  SocialFeedView.swift
//  URCityAI
//
//  Created by Arjun Lamba on 17/04/25.
//

import SwiftUI

/// Horizontal search bar + vertical community/tweet feed
/// powered by the `dummyTweets` fixture.
struct SocialFeedView: View {
    
    // MARK: - Search
    @State private var searchText = ""
    
    /// Live‑filtered tweets based on search string
    private var filteredTweets: [Tweet] {
        guard !searchText.isEmpty else { return dummyTweets }
        return dummyTweets.filter {
            $0.content.localizedCaseInsensitiveContains(searchText) ||
            $0.username.localizedCaseInsensitiveContains(searchText) ||
            $0.handle.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Body ------------------------------------------------------------
    var body: some View {
        VStack {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search updates...", text: $searchText)
                    .foregroundColor(.primary)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Feed list
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredTweets) { tweet in
                        TweetCardView(tweet: tweet)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}
