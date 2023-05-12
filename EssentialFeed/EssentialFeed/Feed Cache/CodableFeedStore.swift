//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Pallavi on 12.05.23.
//

import Foundation

public class CodableFeedStore: FeedStore {
 
    private struct Cache: Codable {
        let item: [CodebaleFeedImage]
        let timespam: Date
       
       var localFeed: [LocalFeedImage] {
           return item.map {$0.local }
       }
       
    }
    
    private struct CodebaleFeedImage: Codable {
        private  let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image:LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }

    private let storeURL: URL
     
     public init (_ store:  URL) {
         self.storeURL = store
     }
    
   // private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    public func retrival(complectionHandler:@escaping FeedStore.RetrievalCompletion) {
        guard let data  =  try? Data(contentsOf: storeURL) else { return complectionHandler(.empty) }
        let decorder = JSONDecoder()
        do{
            let json = try decorder.decode(Cache.self, from: data)
            complectionHandler(.found(feed: json.localFeed, timestamp: json.timespam))
        }catch {
            complectionHandler(.failure(error))
        }
    }
    public func insertItem(_ item: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        
        do{
            let encoder = JSONEncoder()
             let caches = Cache(item: item.map(CodebaleFeedImage.init), timespam: timestamp)
            let encode = try encoder.encode(caches)
          //  guard let storeURL = storeURL else { return }
            try encode.write(to: storeURL)
             completion(nil)
        }catch {
            completion(error)
        }
      
        
    }
    public func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion){
        
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
           return completion(nil)
        }
        do{
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        }catch  {
            completion(error)
        }
      
       
    }
}
