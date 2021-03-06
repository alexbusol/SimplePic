//
//  AppDelegate.swift
//  SimplePic
//
//  Created by Alex Busol on 7/23/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //MARK: - Configuring ParseSDK with Heroku Server
        //UPDATE: will use back4app instead to enable password reset functionality
        
        let parseConfig = ParseClientConfiguration {
            
            //getting access to Heroku using our AppID and MasterKey
            $0.applicationId = "h7Q0MzrvScGQnf2BZQH1O7GY6kiHPbFsmQpouNMu"
            $0.clientKey = "nb9rHXoYYO9ibGfpGrpJA8RAJEPf7BtGAcT8S0Vw"
            $0.server = "https://parseapi.back4app.com"
        }
      
        Parse.enableLocalDatastore()
        PFAnalytics.trackAppOpened(launchOptions: launchOptions)

        login()

        Parse.initialize(with: parseConfig)
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
    
    //MARK: - Remember user after logging in
    func login() {
        let username : String? = UserDefaults.standard.string(forKey: "username") //retrieve the user info from the user defaults. only works if there's info there already
        
        if username != nil {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let myTabBar = storyboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController //showing tab bar if the user is logged in
            window?.rootViewController = myTabBar
        }
    }
}

