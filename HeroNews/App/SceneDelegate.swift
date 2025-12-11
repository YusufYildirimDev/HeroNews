//
//  SceneDelegate.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties
    var window: UIWindow?

    // MARK: - Scene Lifecycle
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        // MARK: Create window
        let window = UIWindow(windowScene: windowScene)

        // MARK: Load Initial View Controller from Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateInitialViewController()

        // MARK: Set Root Controller
        window.rootViewController = initialViewController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Restart tasks paused when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the app is about to move from active to inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from background to foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save application data when moving to background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
