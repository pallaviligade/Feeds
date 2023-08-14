//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Pallavi on 08.08.23.
//

import CoreData

@objc(ManagedCache)
public final class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

extension ManagedCache
{
    var localFeed: [LocalFeedImage] {
        return feed.compactMap {
            ($0 as? ManagedFeedImage)?.local
        }
    }

public static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }

    public static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
}
