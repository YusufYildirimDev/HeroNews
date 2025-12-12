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

    // MARK: - Full Data Sets
    private var allArticles: [NewsArticle] = []
    private var filteredArticles: [NewsArticle] = []
    private var isSearching = false

    // MARK: - Persisted Saved Articles
    private var savedArticleIDs: Set<UUID> = []

    // MARK: - External Bind Target
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

                let (fetched, savedList) = try await (articlesRequest, savedListRequest)

                self.allArticles = fetched
                self.filteredArticles = fetched
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
                if newData != allArticles {
                    self.allArticles = newData
                    self.filteredArticles = newData
                    notify(.success)
                }
            } catch {
                print("Silent refresh failed: \(error)")
            }
        }
    }

    // MARK: - Table Helpers
    var numberOfRows: Int {
        isSearching ? filteredArticles.count : allArticles.count
    }

    func article(at index: Int) -> NewsArticle {
        isSearching ? filteredArticles[index] : allArticles[index]
    }

    func articleViewModel(at index: Int) -> ArticleViewModel {
        let article = article(at: index)
        let isSaved = savedArticleIDs.contains(article.id)
        return ArticleViewModel(article: article, isSaved: isSaved)
    }

    // MARK: - Search Logic
    func search(_ query: String?) {
        guard let q = query, !q.isEmpty else {
            isSearching = false
            filteredArticles = allArticles
            notify(.success)
            return
        }

        isSearching = true
        let lower = q.lowercased()

        filteredArticles = allArticles.filter {
            $0.title.lowercased().contains(lower) ||
            $0.summary.lowercased().contains(lower) ||
            $0.source.lowercased().contains(lower)
        }

        notify(.success)
    }

    // MARK: - Reading List
    func toggleReadingListStatus(at index: Int) {
        let article = article(at: index)
        let id = article.id

        if savedArticleIDs.contains(id) {
            savedArticleIDs.remove(id)
        } else {
            savedArticleIDs.insert(id)
        }

        notify(.updatedRows([IndexPath(row: index, section: 0)]))

        Task {
            if await readingManager.isArticleSaved(id: id) {
                await readingManager.removeFromReadingList(article)
            } else {
                await readingManager.addToReadingList(article)
            }
        }
    }

    // MARK: - State Notify
    private func notify(_ state: NewsListState) {
        DispatchQueue.main.async { [weak self] in
            self?.onStateChanged?(state)
        }
    }
}
