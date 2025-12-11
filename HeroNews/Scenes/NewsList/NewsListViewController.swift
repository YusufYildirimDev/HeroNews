//
//  NewsListViewController.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import UIKit

class NewsListViewController: UIViewController {

    private let service: NewsServiceProtocol = NewsService()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Startup Heroes News"
        fetchDataForTest()
    }
    
    private func fetchDataForTest() {
        Task {
            do {
                print(" İstek atılıyor...")
                let articles = try await service.fetchHeadlines()
                print(" BAŞARILI! \(articles.count) tane haber geldi.")
                
                if let first = articles.first {
                    print("Başlık: \(first.title)")
                }
            } catch {
                print("HATA OLUŞTU: \(error.localizedDescription)")
                print(error)
            }
        }
    }
}
