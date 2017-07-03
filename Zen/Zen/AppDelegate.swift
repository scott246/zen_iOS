//
//  AppDelegate.swift
//  Zen
//
//  Created by Nathan Scott on 6/10/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import UIKit
import Firebase

var lastLogin = "0"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        lastLogin = df.string(from: Date())
        if (Auth.auth().currentUser != nil){
            Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("lastlogin").setValue(lastLogin)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        lastLogin = df.string(from: Date())
        if (Auth.auth().currentUser != nil){
            Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("lastlogin").setValue(lastLogin)
        }
        
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if (Auth.auth().currentUser != nil){
            if shortcutItem.type == "com.scott246.Zen.addExpense" {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "addExpense") as! AddExpenseViewController
                let tab = sb.instantiateViewController(withIdentifier: "init2") as! UITabBarController
                let budget = sb.instantiateViewController(withIdentifier: "init") as! UINavigationController
                let record = sb.instantiateViewController(withIdentifier: "initrecord") as! UINavigationController
                let analysis = sb.instantiateViewController(withIdentifier: "initanalysis") as! UINavigationController
                let settings = sb.instantiateViewController(withIdentifier: "initsettings") as! UINavigationController
                //let login = sb.instantiateViewController(withIdentifier: "Login") as! LoginViewController
                window?.rootViewController = tab
                tab.setViewControllers([budget,record,analysis,settings], animated: false)
                budget.pushViewController(vc, animated: true)
                //window?.rootViewController?.addChildViewController(budget)
                //window?.rootViewController?.performSegue(withIdentifier: "addExpenseFromBudget", sender: nil)
                //let delegate = UIApplication.shared.delegate as! AppDelegate
                //delegate.window?.rootViewController!.present(budget, animated: false, completion: nil)
                //delegate.window?.rootViewController!.present(vc, animated: true, completion: { () -> Void in
                //    completionHandler(true)
                //})
                completionHandler(true)
            }
            else if shortcutItem.type == "com.scott246.Zen.addIncome" {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "addIncome") as! AddIncomeViewController
                let tab = sb.instantiateViewController(withIdentifier: "init2") as! UITabBarController
                let budget = sb.instantiateViewController(withIdentifier: "init") as! UINavigationController
                let record = sb.instantiateViewController(withIdentifier: "initrecord") as! UINavigationController
                let analysis = sb.instantiateViewController(withIdentifier: "initanalysis") as! UINavigationController
                let settings = sb.instantiateViewController(withIdentifier: "initsettings") as! UINavigationController
                window?.rootViewController = tab
                tab.setViewControllers([budget,record,analysis,settings], animated: false)
                budget.pushViewController(vc, animated: true)
                completionHandler(true)
            }
        }
        
    }


}

