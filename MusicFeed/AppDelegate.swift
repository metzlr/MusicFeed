//
//  AppDelegate.swift
//  MusicFeed
//
//  Created by Reed Metzler-Gilbertz on 8/31/19.
//  Copyright © 2019 Reed Metzler-Gilbertz. All rights reserved.
//

/*
TO DO
 - better icon for open in spotify
 
 
BUGS
 - If internet is slow, read artists from file requests time out and then artist images glitch out
*/


import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let storageController = StorageController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.overrideUserInterfaceStyle = .light
        guard let tabBarController = window?.rootViewController as? UITabBarController,
            let viewControllers = tabBarController.viewControllers else {
                return true
        }
        for viewController in viewControllers {
            if let navigationController = viewController as? UINavigationController {
                if let vc = navigationController.viewControllers.first as? ReleaseListViewController {
                    vc.storageController = storageController
                } else if let vc = navigationController.viewControllers.first as? ArtistViewController {
                    vc.storageController = storageController

                } else if let vc = navigationController.viewControllers.first as? OtherScreenController {
                    vc.storageController = storageController

                }
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let tabView = window?.rootViewController as? UITabBarController {
            //vc.oauth2.handleRedirectURL(url)
            //return true
            guard let vc: OtherScreenController = {for view in tabView.viewControllers! {
                if let navView = view as? UINavigationController {
                    for view2 in navView.viewControllers {
                        if let otherView = view2 as? OtherScreenController {
                            return otherView
                        }
                    }
                }}
                return nil
                }() else {
                    return false
            }
            vc.storageController?.authImplicit.handleRedirectURL(url)
            return true
        }
        return false
    }

}

