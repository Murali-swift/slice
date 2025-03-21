//
//  AppCoordinator.swift
//  SpotiJ
//
//  Created by Murali on 14.06.20.
//  Copyright © 2020 Murali. All rights reserved.
//

import UIKit

class MainCoordinator: NSObject, Coordinator, UINavigationControllerDelegate {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    deinit {
        print("dealloc \(self)")
    }

    func start() {
        showCategoryList()
    }
}

extension MainCoordinator {
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {

        /// Read the view controller we’re moving from.
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }

        // Check whether our view controller array already contains that view controller.
        // If it does it means we’re pushing a different view controller on top rather than popping it, so exit.
        if navigationController.viewControllers.contains(fromViewController) {
            return
        }

        // We’re still here – it means we’re popping the view controller, so we can check whether it’s a category view controller
        if let categoryViewController = fromViewController as? CategoryViewController {
            // We're popping a buy view controller; end its coordinator
            childDidFinish(categoryViewController.coordinator)
        }

        if let productViewController = fromViewController as? ProductDetailViewController {
            // We're popping a buy view controller; end its coordinator
            childDidFinish(productViewController.coordinator)
        }
    }
}

// MARK: - Handler Show Login or Main View
extension MainCoordinator {
    fileprivate func showCategoryList() {
        let categoryCoordinator = CategoryCoordinator(navigationController: navigationController)
        categoryCoordinator.delegate = self
        categoryCoordinator.parentCoordinator = self
        categoryCoordinator.start()
        childCoordinators.append(categoryCoordinator)
    }
    
    fileprivate func showProductDetail(_ product: Product,_ catTitle:String) {
        let productDetailCoordinator = ProductDetailCoordinator(product: product, title: catTitle, navigationController: navigationController)
        productDetailCoordinator.parentCoordinator = self
        productDetailCoordinator.start()
        childCoordinators.append(productDetailCoordinator)
    }
}

// MARK: - Delegate Authentication Coordinator
extension MainCoordinator: CategoryCoordinatorDelegate {
    func categoryCoordinatorDidSelected(product: Product, forTitle title: String,  coordinator: CategoryCoordinator) {
       showProductDetail(product,title)
    }
}


//extension MainCoordinator: ProductCoordinatorDelegate {
//    func productCoordinatorDidSelected(id: Int64, coordinator: ProductCoordinator) {
//        showProductDetail(id)
//    }
//}
