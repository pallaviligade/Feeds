//
//  FeedStoreSpec.swift
//  EssentialFeedTests
//
//  Created by Pallavi on 15.05.23.
//

import Foundation
protocol FeedStoreSpec {
    func test_retrive_deliveryEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
   // func test_retrive_hasNosideEffectsOnemptyCacheTwice()
   // func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues()
   
   
    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overidesPreviouslyInsertedCache()
   
    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()
    
    func test_storeSideEffect_RunSerily()
}
protocol FailableRetrivalFeedStoreSpecs: FeedStoreSpec {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}
protocol FailableInsertFeedStoreSpecs: FeedStoreSpec {
    func test_insert_deliveryErrorOnInsertionError()
    func test_insert_hasNoSideEffectInInsertionError()
}

protocol DeleteFeedStoreSpecs: FeedStoreSpec {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStoreSpecs = FailableRetrivalFeedStoreSpecs & FailableInsertFeedStoreSpecs & DeleteFeedStoreSpecs
