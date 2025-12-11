//
//  NewsListViewModel.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import Foundation

// MARK: - View State
enum NewsListState {
    case idle
    case loading
    case success
    case updatedRows([IndexPath])
    case error(String)
}

final class NewsListViewModel {

    // MARK: - Public Properties
    private(set) var articles: [NewsArticle] = []
    
    private var savedArticleIDs: Set<UUID> = []
    
    var onStateChanged: ((NewsListState) -> Void)?

    // MARK: - Dependencies
    private let service: NewsServiceProtocol
    private let readingManager: ReadingListManagerProtocol
    private var timer: Timer?

    // MARK: - Init
    init(
        service: NewsServiceProtocol = NewsService(),
        readingManager: ReadingListManagerProtocol = ReadingListManager.shared
    ) {
        self.service = service
        self.readingManager = readingManager
    }

    // MARK: - Load News
    func loadNews() {
        notify(.loading)

        Task {
            do {
                async let articlesRequest = service.fetchHeadlines()
                async let savedListRequest = readingManager.getReadingList()
                
                let (fetchedArticles, savedList) = try await (articlesRequest, savedListRequest)
                
                self.articles = fetchedArticles
                self.savedArticleIDs = Set(savedList.map { $0.id })
                
                notify(.success)
            } catch {
                notify(.error(error.localizedDescription))
            }
        }
    }

    // MARK: - Auto Refresh
    func startAutoRefresh() {
        stopAutoRefresh()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.refreshSilently()
        }
    }

    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }

    private func refreshSilently() {
        Task {
            do {
                let newData = try await service.fetchHeadlines()
                if newData != self.articles {
                    self.articles = newData
                    notify(.success)
                }
            } catch {
                print("Silent refresh failed: \(error)")
            }
        }
    }

    // MARK: - Helpers
    var numberOfRows: Int {
        articles.count
    }

    func article(at index: Int) -> NewsArticle {
        articles[index]
    }

    func articleViewModel(at index: Int) -> ArticleViewModel {
        let article = articles[index]
        let isSaved = savedArticleIDs.contains(article.id)
        return ArticleViewModel(article: article, isSaved: isSaved)
    }

    // MARK: - Reading List Actions
    func toggleReadingListStatus(at index: Int) {
        let article = articles[index]
        let id = article.id

        if savedArticleIDs.contains(id) {
            savedArticleIDs.remove(id)
        } else {
            savedArticleIDs.insert(id)
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        notify(.updatedRows([indexPath]))

        Task {
            if await readingManager.isArticleSaved(id: id) {
                await readingManager.removeFromReadingList(article)
            } else {
                await readingManager.addToReadingList(article)
            }
        }
    }

    private func notify(_ state: NewsListState) {
        DispatchQueue.main.async { [weak self] in
            self?.onStateChanged?(state)
        }
    }
}
