//
//  NetworkMonitor.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/12/25.
//

import Network
import Foundation

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    // Anlık bağlantı durumu
    var isConnected: Bool = false
    
    // Bağlantı durumu değiştiğinde tetiklenecek closure
    var onStatusChange: ((Bool) -> Void)?
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            self?.isConnected = isConnected
            
            DispatchQueue.main.async {
                self?.onStatusChange?(isConnected)
            }
        }
        monitor.start(queue: queue)
    }
}
