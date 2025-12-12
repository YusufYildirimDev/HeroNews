//
//  SceneDelegate.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties
    var window: UIWindow?

    // MARK: - Scene Lifecycle
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else {
            assertionFailure("Failed to cast scene to UIWindowScene")
            return
        }

        // MARK: Window Setup
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .systemBackground

        // MARK: Build Root Scene
        let rootVC = buildRootViewController()
        window.rootViewController = rootVC
        window.makeKeyAndVisible()

        self.window = window
    }

    // MARK: - Build Root
    /// Builds the entire root navigation structure.
    private func buildRootViewController() -> UIViewController {

        // Dependencies (Injection)
        let service = NewsService()
        let readingManager = ReadingListManager.shared
        
        let viewModel = NewsListViewModel(
            service: service,
            readingManager: readingManager
        )

        let listVC = NewsListViewController(viewModel: viewModel)

        // Navigation Controller Setup
        let navigation = UINavigationController(rootViewController: listVC)
        navigation.navigationBar.prefersLargeTitles = true
        navigation.navigationBar.tintColor = .label

        return navigation
    }

    // MARK: - Scene State Handlers
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
