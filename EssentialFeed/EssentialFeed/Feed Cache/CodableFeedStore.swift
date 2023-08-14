//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Pallavi on 12.05.23.
//

import Foundation

public final class CodableFeedStore: FeedStore {
 
    public struct Cache: Codable {
        let item: [CodebaleFeedImage]
        let timespam: Date
       
       var localFeed: [LocalFeedImage] {
           return item.map {$0.local }
       }
       
    }
    
    public struct CodebaleFeedImage: Codable {
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
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    public func retrieve(completion complectionHandler:@escaping FeedStore.RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data  =  try? Data(contentsOf: storeURL) else { return complectionHandler(.success(.empty)) }
            let decorder = JSONDecoder()
            do{
                let json = try decorder.decode(Cache.self, from: data)
                complectionHandler(.success(.found(feed: json.localFeed, timestamp: json.timespam)))
            }catch {
                complectionHandler(.failure(error))
            }
        }
    }
    public func insert(_ item: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags:.barrier) {
            do{
                let encoder = JSONEncoder()
                let caches = Cache(item: item.map(CodebaleFeedImage.init), timespam: timestamp)
                let encode = try encoder.encode(caches)
                //  guard let storeURL = storeURL else { return }
                try encode.write(to: storeURL)
                completion(.success(()))
            }catch {
                completion(.failure(error))
            }
        }
        
    }
    public func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion){
        let storeURL = self.storeURL
        queue.async(flags:.barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(.success(()))
            }
            do{
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(()))
            }catch  {
                completion(.failure(error))
            }
        }
       
    }
}
