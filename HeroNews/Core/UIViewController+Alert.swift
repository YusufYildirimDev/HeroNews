//
//  UIViewController+Alert.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import UIKit

extension UIViewController {
    
    /// Simple reusable alert presenter for the whole app.
    func showAlert(
        title: String,
        message: String,
        buttonTitle: String = "OK"
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default))
        present(alert, animated: true)
    }
}
