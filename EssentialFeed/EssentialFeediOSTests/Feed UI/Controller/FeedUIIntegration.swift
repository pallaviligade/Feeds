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
    
    func test_CheckTitleOfFeed() {
        let (sut, _) = makeSUT()
       
        sut.loadViewIfNeeded()
      
        XCTAssertEqual(sut.title,  localizeKey("Feed_VIEW_TITLE"))
    }
    
    func test_loadFeedActions_requestFeedFromLoader(){
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")
   
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
    
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3,"Expected yet another loading request once user initiates another reload")
        
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
        assertThat(sut, isRendering: []) // Check the count(0) only there is no values
        
        loader.completeFeedloading(with: [imageO], at: 0)
        assertThat(sut, isRendering: [imageO]) // Check the count (1)only there is  values too
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedloading(with: [imageO,image1,image2,image3], at: 1) // Check the count(4) only there is  values too
       assertThat(sut, isRendering: [imageO,image1,image2,image3])
       
       

    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeFeedImage()
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedloading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 0)
        assertThat(sut, isRendering: [image0])

        
    }
    
    func test_feedImageView_loadsImageUrlsWhenVisiable() {
        let image0 = makeFeedImage(imgurl: URL(string: "http://any0-url.com")!)
        let image1 = makeFeedImage(imgurl: URL(string: "http://any1-url.com")!)
        let (sut,  loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedloading(with: [image0, image1])
        
        XCTAssertEqual(loader.loadedImageUrls, [], "Expcted no image Urls until  view become visiable")
        
        sut.simulateFeedImageViewVisiable(at: 0) // 0 is row number
        XCTAssertEqual(loader.loadedImageUrls,[image0.imageURL], "Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewVisiable(at: 1)
        XCTAssertEqual(loader.loadedImageUrls,[image0.imageURL, image1.imageURL], "Expected second image URL request once second view also becomes visible")
        
        

    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisiableAnyMore() {
        let image0 = makeFeedImage(imgurl: URL(string: "http://any0-url.com")!)
        let image1 = makeFeedImage(imgurl: URL(string: "http://any1-url.com")!)
        let (sut,  loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedloading(with: [image0, image1])
        
        XCTAssertEqual(loader.cancelledImageURLs,[] ,"Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0) // 0 is row number
        XCTAssertEqual(loader.cancelledImageURLs,[image0.imageURL], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateFeedImageViewNotVisible(at: 1) // 0 is row number
        XCTAssertEqual(loader.cancelledImageURLs,[image0.imageURL, image1.imageURL], "Expected one cancelled image URL request once first image is not visible anymore")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let image0 = makeFeedImage(imgurl: URL(string: "http://any0-url.com")!)
        let image1 = makeFeedImage(imgurl: URL(string: "http://any1-url.com")!)
        let (sut,  loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedloading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewVisiable(at: 0)
        let view1 = sut.simulateFeedImageViewVisiable(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true,"Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true,"Expected loading indicator for second view while loading second image")
        
        loader.compeletImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }
    
    func test_feedImageView_RenderLoadedImageFromURL() {
       
        let (sut,  loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedloading(with: [makeFeedImage(), makeFeedImage()])
        let view0 = sut.simulateFeedImageViewVisiable(at: 0)
        let view1 = sut.simulateFeedImageViewVisiable(at: 1)
        
        XCTAssertEqual(view0?.renderImage, .none, "Expected no image for firstView whileloading first image")
        XCTAssertEqual(view1?.renderImage, .none, "Expected no image for firstView whileloading first image")

        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.compeletImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderImage, imageData0,"Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
         loader.compeletImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
         XCTAssertEqual(view1?.renderImage, imageData1, "Expected image for second view once second image loading completes successfully")
        
        
    }
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let image0 = makeFeedImage(imgurl: URL(string: "http://any0-url.com")!)
        let image1 = makeFeedImage(imgurl: URL(string: "http://any1-url.com")!)
        let (sut,  loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedloading(with: [image0, image1])

            let view0 = sut.simulateFeedImageViewVisiable(at: 0)
            let view1 = sut.simulateFeedImageViewVisiable(at: 1)
            XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
            XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")

            let imageData = UIImage.make(withColor: .red).pngData()!
            loader.compeletImageLoading(with: imageData, at: 0)
            XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
            XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")

            loader.completeImageLoadingWithError(at: 1)
            XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
            XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
        }
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
     
        let (sut,  loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedloading(with: [makeFeedImage()])
        
        let view0 = sut.simulateFeedImageViewVisiable(at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        let invlidaImage = Data("wrong data".utf8)
        loader.compeletImageLoading(with: invlidaImage,at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
        
     }
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image0 = makeFeedImage(imgurl: URL(string: "http://any0-url.com")!)
        let image1 = makeFeedImage(imgurl: URL(string: "http://any1-url.com")!)
        let (sut,  loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedloading(with: [image0, image1])
        let view0 = sut.simulateFeedImageViewVisiable(at: 0)
        let view1 = sut.simulateFeedImageViewVisiable(at: 1)
        XCTAssertEqual(loader.loadedImageUrls, [image0.imageURL, image1.imageURL],"Expected 2 image URL request for 2 visable views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageUrls, [image0.imageURL, image1.imageURL],"Expected 2 image URL requests before retry actions")
        
        view0?.simulateRetryActions()
        XCTAssertEqual(loader.loadedImageUrls, [image0.imageURL, image1.imageURL, image0.imageURL],"Expected third imageURL request after first view retry action")
        
        view1?.simulateRetryActions()
        XCTAssertEqual(loader.loadedImageUrls, [image0.imageURL, image1.imageURL, image0.imageURL, image1.imageURL],"Expected fourth imageURL request after second view retry action")
        
        
    }
    
    func test_feedImageView_PreloadsImageURLWhenNearVisiable() {
        let image0 = makeFeedImage(imgurl: URL(string: "http://any0-url.com")!)
        let image1 = makeFeedImage(imgurl: URL(string: "http://any1-url.com")!)
        let (sut,  loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedloading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageUrls, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateFeedImageViewVisiable(at: 0)
        XCTAssertEqual(loader.loadedImageUrls, [image0.imageURL], "Expected first image URL request once first image is near visible")

       sut.simulateFeedImageViewVisiable(at: 1)
       XCTAssertEqual(loader.loadedImageUrls, [image0.imageURL, image1.imageURL], "Expected second image URL request once second image is near visible")
        
    }
    func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let image0 = makeFeedImage(imgurl: URL(string: "http://any0-url.com")!)
        let image1 = makeFeedImage(imgurl: URL(string: "http://any1-url.com")!)
        let (sut,  loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedloading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.imageURL], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.imageURL, image1.imageURL], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
   
    private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage],file: StaticString = #file, line: UInt = #line ) {
        guard sut.numberOfRenderFeedImageView() == feed.count else {
            XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderFeedImageView()) instead.", file: file, line: line)
            return
        }
        
        feed.enumerated().forEach { index, item  in
            assertThat(sut, hasViewConfiguredFor: item, at: index,file: file,line: line)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
            let view = sut.feedImageView(at: index)

            guard let cell = view as? FeedImageCell else {
                return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
            }

            let shouldLocationBeVisible = (image.location != nil)
            XCTAssertEqual(cell.isShowinglocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)

            XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image  view at index (\(index))", file: file, line: line)

            XCTAssertEqual(cell.discrText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index)", file: file, line: line)
        }
    
    
    func makeSUT(file: StaticString = #file, line: UInt = #line ) -> (sut:FeedViewController, loader: FeedViewSpy) {
        let loader = FeedViewSpy()
        let sut  = FeedUIComposer.createFeedView(feedloader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    func makeFeedImage(description:String? = nil, location:String? = nil, imgurl: URL = URL(string: "https://any-url.com")!) ->  FeedImage
    {
        let feedImage =  FeedImage(id: UUID(), description: description, location: location, imageURL:imgurl)
        return feedImage
        
    }
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
            let (sut, loader) = makeSUT()
            sut.loadViewIfNeeded()
        loader.completeFeedloading(with: [makeFeedImage()])

            let view = sut.simulateFeedImageViewNotVisible(at: 0)
            loader.compeletImageLoading(with: anyImageData())

            XCTAssertNil(view?.renderImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
        }
    
    func test_loadFeedCompletion_dispatchFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp =  expectation(description: "Wait for background queue")
        
        DispatchQueue.global().async {
            loader.completeFeedloading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
            
    }
    
    private func anyImageData() -> Data {
            return UIImage.make(withColor: .red).pngData()!
        }
   
    //MARK: - Helpers
    class FeedViewSpy: FeedLoader, FeedImageDataLoader{
       
    private var feedRequest = [(FeedLoader.Result) -> Void] ()
     
        var loadFeedCallCount: Int {
            return feedRequest.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequest.append(completion)
        }
        
        func completeFeedloading(with feedImage: [FeedImage] = [], at index:Int = 0) {
            feedRequest[index](.success(feedImage))
        }
        
        func completeFeedLoadingWithError(at index:Int) {
            let error = NSError(domain: "any error", code: 1)
            feedRequest[index](.failure(error))
        }
        
        func compeletImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequest[index].completions(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "AnyError", code: 0)
            imageRequest[index].completions(.failure(error))
        }
        
        // MARK: - Helpers  FeedImageDataLoader
       
        private  var imageRequest = [(url: URL, completions:(FeedImageDataLoader.Result) -> Void)]()
        
        private(set) var cancelledImageURLs = [URL]()
        var loadedImageUrls:  [URL] {
            return imageRequest.map { $0.url }
        }
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallBack: () -> Void
            func cancel() {
                cancelCallBack()
            }
       }
    
        func loadImageData(from url: URL, completionHandler: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeediOS.FeedImageDataLoaderTask {
            imageRequest.append((url, completionHandler))
            return TaskSpy { [weak self]  in
                self?.cancelledImageURLs.append(url)
            }
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
    
    @discardableResult
    func simulateFeedImageViewVisiable(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
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
    @discardableResult
    func simulateFeedImageViewNotVisible(at row:Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisiable(at: row)
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageNumberOfSections())
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        return view
        
    }
    
    func simulateFeedImagViewNearVisiable(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageNumberOfSections())
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisiable(at row: Int) {
        simulateFeedImagViewNearVisiable(at: row)
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageNumberOfSections())
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
}

extension FeedImageCell {
    
    func simulateRetryActions() {
        feedImageRetryButton.simulateToTap()
    }
    var discrText:String? {
        return discrptionLabel.text
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var isShowinglocation: Bool {
        return !locationContainer.isHidden
    }
    
    var isShowingImageLoadingIndicator:Bool {
        return feedImageContainer.isShimmering
    }
    
    var renderImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    var isShowingRetryAction: Bool? {
        return !feedImageRetryButton.isHidden
    }
   
}

extension UIButton {
    func simulateToTap() {
        allTargets.forEach { target in
                      actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                          (target as NSObject).perform(Selector($0))
                      }
                  }
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

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
