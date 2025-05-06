//
//  DownloadManager.swift
//  DownloadManager
//
//  Created by Hao Nguyen on 5/5/25.
//

import Foundation
import AVKit
import AVFoundation

class DownloadManager: NSObject, URLSessionDownloadDelegate {
    static let shared = DownloadManager()
    private var session: URLSession!
    private let downloadQueue = OperationQueue()
    
    override init() {
        super.init()
        let config = URLSessionConfiguration.background(withIdentifier: "com.yourapp.background")
        session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        downloadQueue.maxConcurrentOperationCount = 3
    }
    
    private func bindingNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func applicationDidEnterBackground() {
        downloadQueue.isSuspended = true
    }
    
    @objc private func applicationWillEnterForeground() {
        downloadQueue.isSuspended = false
    }
    
    // Play movie
    func playMovie(from url: URL, in viewController: UIViewController) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        viewController.present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    // Download movie
    func downloadMovies(_ urls: [URL]) {
        urls.forEach { url in
            let operation = BlockOperation {
                let task = self.session.downloadTask(with: url)
                task.resume()
            }
            downloadQueue.addOperation(operation)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent("movie_\(UUID().uuidString).mp4")
        
        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            print("Download did complete. File saved to: \(destinationURL)")
        } catch {
            print("Save file failed with error: \(error)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print("Downloading progress: \(progress * 100)%")
    }
}

extension DownloadManager {
    func pauseAllDownloads() {
        downloadQueue.isSuspended = true
    }
    
    func resumeAllDownloads() {
        downloadQueue.isSuspended = false
    }
}

// Usage
let movieURLs = [
    URL(string: "https://example.com/movie1.mp4")!,
    URL(string: "https://example.com/movie2.mp4")!
]

//MovieManager.shared.playMovie(from: URL(string: "https://example.com/playlist.m3u8")!, in: self)
//MovieManager.shared.downloadMovies(movieURLs)
