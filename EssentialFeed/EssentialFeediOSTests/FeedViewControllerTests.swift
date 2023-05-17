//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Pallavi on 16.05.23.
//

import UIKit
import XCTest
import EssentialFeed
import EssentialFeediOS


final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader(){
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
   
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
    
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3,"Expected yet another loading request once user initiates another reload")
        
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingloadingIndicator, "Expected loading indicator once view is loaded")
        
      
        loader.completeFeedloading(at: 0)
        XCTAssertFalse(sut.isShowingloadingIndicator,"Expected no loading indicator once loading is completed")
   
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingloadingIndicator,"Expected loading indicator once user initiates a reload")
        
        loader.completeFeedloading(at: 1)
         XCTAssertFalse(sut.isShowingloadingIndicator, "Expected no loading indicator once user initiated loading is completed")
    }
    func test_loadFeedCompletions_renderSuccessfullyLoaded()
    {
        let imageO  = makeFeedImage(description: "first item", location: "Berlin")
        let image1  = makeFeedImage(description: nil, location: "Berlin")
        let image2  = makeFeedImage(description: "first item", location: nil)
        let image3  = makeFeedImage(description: nil, location: nil)

        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.numberOfRenderFeedImageView(), 0)
        
        loader.completeFeedloading(with: [imageO], at: 0)        
        XCTAssertEqual(sut.numberOfRenderFeedImageView(), 1)
        
        let view = sut.feedImageView(at: 0) as?  FeedImageCell
        XCTAssertNotNil(view)
        XCTAssertEqual(view?.discrText,imageO.description)
        XCTAssertEqual(view?.locationText,imageO.location)
        XCTAssertEqual(view?.isShowinglocation, true)
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedloading(with: [imageO,image1,image2,image3], at: 1)
        XCTAssertEqual(sut.numberOfRenderFeedImageView(), 4)

    }
    
    
    func makeSUT(file: StaticString = #file, line: UInt = #line ) -> (sut:FeedViewController, loader: FeedViewSpy) {
        let loader = FeedViewSpy()
        let sut  = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    func makeFeedImage(description:String?, location:String?) ->  FeedImage
    {
        let feedImage =  FeedImage(id: UUID(), description: description, location: location, imageURL:URL(string: "https://any-url.com")!)
        return feedImage
        
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguartions image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line ) {
        
    }
    
    
    //MARK: - Helpers
    class FeedViewSpy: FeedLoader{
       
        
        private var completionHander = [(FeedLoader.Result) -> Void] ()
        var loadCallCount: Int {
            return completionHander.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completionHander.append(completion)
        }
        
        func completeFeedloading(with feedImage: [FeedImage] = [], at index:Int) {
            completionHander[index](.success(feedImage))
        }
         
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
            refreshControl?.simulatePullToRefresh()
        }
    
    var isShowingloadingIndicator:Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderFeedImageView() ->  Int {
        
        return tableView.numberOfRows(inSection: feedImageNumberOfSections())
    }
    
    private func feedImageNumberOfSections() -> Int {
        return 0
    }
    
    func feedImageView(at row:Int) -> UITableViewCell? {
        
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageNumberOfSections())
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

extension FeedImageCell {
    var discrText:String? {
        return discrptionLabel.text
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var isShowinglocation: Bool {
        return !locationContainer.isHidden
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
      allTargets.forEach { target in
                    actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                        (target as NSObject).perform(Selector($0))
                    }
                }
    }
}
