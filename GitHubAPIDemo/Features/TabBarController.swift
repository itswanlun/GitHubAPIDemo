import Foundation
import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupViewControllers()
    }
}

extension TabBarController {
    func setupUI() {
        tabBar.tintColor = .black
    }
    
    func setupViewControllers() {
        let HomeviewController = HomeViewController()
        let homeNavigationController = UINavigationController(rootViewController: HomeviewController)
        
        homeNavigationController.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        homeNavigationController.tabBarItem.title = "GitHub"
        
        let LogoutviewController = LogoutViewController()
        let logoutNavigationController = UINavigationController(rootViewController: LogoutviewController)
        
        logoutNavigationController.tabBarItem.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        logoutNavigationController.tabBarItem.title = "Logout"
        
        
        viewControllers = [homeNavigationController, logoutNavigationController]
    }
}
