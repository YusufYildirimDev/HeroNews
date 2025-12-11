//
//  ImageLoader.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import UIKit

final class ImageLoader {

    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 200
        cache.totalCostLimit = 50 * 1024 * 1024
    }
   
    func downloadImage(url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString

        if let cached = cache.object(forKey: key) {
            return cached
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }

            cache.setObject(image, forKey: key)
            return image
        } catch {
            return nil
        }
    }
}
