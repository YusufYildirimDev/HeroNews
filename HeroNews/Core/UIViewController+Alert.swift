//
//  UIViewController+Alert.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String, buttonTitle: String = "OK") {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            
            if let presented = self.presentedViewController {
                if presented is UIAlertController {
                    presented.dismiss(animated: false) {
                        self.presentNewAlert(title: title, message: message, buttonTitle: buttonTitle)
                    }
                }
                return
            }
            
            self.presentNewAlert(title: title, message: message, buttonTitle: buttonTitle)
        }
    }
   
    func showToast(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                alert.dismiss(animated: true)
            }
        }
    }
    
    private func presentNewAlert(title: String, message: String, buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default))
        self.present(alert, animated: true)
    }
}
