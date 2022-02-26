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
        let viewController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        
        navigationController.tabBarItem.image = UIImage(systemName: "person.crop.circle")
        navigationController.tabBarItem.title = "用戶"
        
        viewControllers = [navigationController]
    }
}
