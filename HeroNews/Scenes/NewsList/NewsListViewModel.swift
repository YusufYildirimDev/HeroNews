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

    // MARK: - Data Sources
    private var allArticles: [NewsArticle] = []
    private var filteredArticles: [NewsArticle] = []
    private var isSearching = false

    // MARK: - Saved Reading Items
    private var savedArticleIDs: Set<UUID> = []

    // MARK: - Output
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
                async let articlesReq = service.fetchHeadlines()
                async let savedReq = readingManager.getReadingList()

                let (articles, saved) = try await (articlesReq, savedReq)

                self.allArticles = articles
                self.filteredArticles = articles
                self.savedArticleIDs = Set(saved.map { $0.id })

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
            self?.silentRefresh()
        }
    }

    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }

    private func silentRefresh() {
        Task {
            do {
                let newData = try await service.fetchHeadlines()

                guard newData != allArticles else { return }

                self.allArticles = newData
                if !isSearching {
                    filteredArticles = newData
                }

                notify(.success)

            } catch {
                print("Silent refresh failed:", error)
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

    // MARK: - Search Feature
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

    // MARK: - Reading List Toggle
    func toggleReadingListStatus(at index: Int) async -> Bool {
        let article = article(at: index)
        let id = article.id
        let willSave = !savedArticleIDs.contains(id)
        if willSave {
            savedArticleIDs.insert(id)
        }
        else {
            savedArticleIDs.remove(id)
        }

        notify(.updatedRows([IndexPath(row: index, section: 0)]))

        if willSave {
            await readingManager.addToReadingList(article)
        } 
        else {
            await readingManager.removeFromReadingList(article)
        }
        return willSave
    }

    // MARK: - Notify Helper
    private func notify(_ state: NewsListState) {
        DispatchQueue.main.async { [weak self] in
            self?.onStateChanged?(state)
        }
    }
}
