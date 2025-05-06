//
//  ContentView.swift
//  DownloadManager
//
//  Created by Hao Nguyen on 5/5/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

extension ContentView {
    func loadData() {
        let movieURLs = [URL(string: "https://example.com/movie.mp4")!]
        DownloadManager.shared.downloadMovies(movieURLs)
    }
}

#Preview {
    ContentView()
}
