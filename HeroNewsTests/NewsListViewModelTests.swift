//
//  NewsListViewModelTests.swift
//  HeroNewsTests
//
//  Created by Yusuf Muhammet Yıldırım on 12/12/25.
//

import XCTest
@testable import HeroNews

final class NewsListViewModelTests: XCTestCase {
    
    // MARK: - Properties
    var viewModel: NewsListViewModel!
    var mockService: MockNewsService!
    var mockReadingManager: MockReadingManager!
    
    // MARK: - Setup & Teardown
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Initialize Mocks
        mockService = MockNewsService()
        mockReadingManager = MockReadingManager()
        
        // Initialize ViewModel with Dependency Injection
        viewModel = NewsListViewModel(service: mockService, readingManager: mockReadingManager)
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockService = nil
        mockReadingManager = nil
        try await super.tearDown()
    }
    
    // MARK: - Tests
    
    func testLoadNews_Success() async {
        // GIVEN: Service returns a valid article
        let article = makeArticle(title: "Success News")
        mockService.mockArticles = [article]
        
        let expectation = XCTestExpectation(description: "ViewModel should return success state")
        
        viewModel.onStateChanged = { state in
            if case .success = state {
                expectation.fulfill()
            }
        }
        
        // WHEN: Loading data
        viewModel.loadNews()
        
        // THEN: Verify success state and data integrity
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertEqual(viewModel.numberOfRows, 1)
        XCTAssertEqual(viewModel.article(at: 0).title, "Success News")
    }
    
    func testLoadNews_Failure() async {
        // GIVEN: Service returns an error
        mockService.shouldFail = true
        
        let expectation = XCTestExpectation(description: "ViewModel should return error state")
        
        viewModel.onStateChanged = { state in
            if case .error = state {
                expectation.fulfill()
            }
        }
        
        // WHEN: Loading data
        viewModel.loadNews()
        
        // THEN: Verify error state and empty list
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.numberOfRows, 0)
    }
    
    func testSearchFilter_Logic() async {
        // GIVEN: Two different articles
        let appleNews = makeArticle(title: "Apple launches iPhone 16")
        let googleNews = makeArticle(title: "Google releases Gemini AI")
        mockService.mockArticles = [appleNews, googleNews]
        
        await loadDataAndWait()
        
        // WHEN: Searching for "Apple"
        viewModel.search("Apple")
        
        // THEN: Result should be filtered to 1 item
        XCTAssertEqual(viewModel.numberOfRows, 1)
        XCTAssertEqual(viewModel.article(at: 0).title, "Apple launches iPhone 16")
        
        // WHEN: Clearing search
        viewModel.search("")
        
        // THEN: All items should return
        XCTAssertEqual(viewModel.numberOfRows, 2)
    }
    
    func testReadingList_Toggle() async {
        // GIVEN: An article is loaded
        let article = makeArticle(title: "Favorite News")
        mockService.mockArticles = [article]
        
        await loadDataAndWait()
        
        // WHEN: Adding to reading list
        let isAdded = await viewModel.toggleReadingListStatus(at: 0)
        
        // THEN: Should return true and update ViewModel state
        XCTAssertTrue(isAdded)
        let vm = viewModel.articleViewModel(at: 0)
        XCTAssertTrue(vm.isSaved)
        
        // Verify Persistence via Mock Manager
        let savedList = await mockReadingManager.getReadingList()
        XCTAssertEqual(savedList.count, 1)
        
        // WHEN: Removing from reading list
        let isRemoved = await viewModel.toggleReadingListStatus(at: 0)
        
        // THEN: Should return false (not saved)
        XCTAssertFalse(isRemoved)
        let vmRemoved = viewModel.articleViewModel(at: 0)
        XCTAssertFalse(vmRemoved.isSaved)
    }
    
    // MARK: - Helpers
    
    /// Helper to wait for initial data load
    private func loadDataAndWait() async {
        let expectation = XCTestExpectation(description: "Data Loaded")
        viewModel.onStateChanged = { state in
            if case .success = state {
                expectation.fulfill()
            }
        }
        viewModel.loadNews()
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    /// Factory helper to create dummy articles
    private func makeArticle(title: String) -> NewsArticle {
        return NewsArticle(
            id: UUID(),
            title: title,
            summary: "Test Summary",
            content: "Test Content",
            publishedAt: Date(),
            imageURL: nil,
            source: "Test Source",
            authors: []
        )
    }
}
