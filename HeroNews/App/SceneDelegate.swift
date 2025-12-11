//
//  SceneDelegate.swift
//  HeroNews
//
//  Created by Yusuf Muhammet Yıldırım on 12/11/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 1. Scene'i bir UIWindowScene olarak yakala (Eğer başarısız olursa dur)
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 2. Bu scene'i kullanarak yeni bir UIWindow oluştur
        let window = UIWindow(windowScene: windowScene)
        
        // 3. Main.storyboard dosyasını bul
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // 4. Storyboard'daki "ok işaretiyle" gösterilen giriş (initial) sayfasını al
        // NOT: Main.storyboard dosyasında bir View Controller'ın "Is Initial View Controller" seçeneğinin işaretli olduğundan emin olun.
        let initialViewController = storyboard.instantiateInitialViewController()
        
        // 5. Pencerenin ana görünümü olarak bu sayfayı ayarla
        window.rootViewController = initialViewController
        
        // 6. Pencereyi belleğe al ve ekranda göster
        self.window = window
        window.makeKeyAndVisible()
    }

    // Diğer fonksiyonlar (sceneDidDisconnect vb.) olduğu gibi kalabilir,
    // onlarda değişiklik yapmanıza gerek yok.
    
    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

