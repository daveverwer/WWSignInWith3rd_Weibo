//
//  AppDelegate.swift
//  Example
//
//  Created by William.Weng on 2023/9/11.
//

import UIKit
import WWSignInWith3rd_Apple
import WWSignInWith3rd_Weibo

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = WWSignInWith3rd.Weibo.shared.configure(appKey: "<WeiboAppKey>", secret: "<WeiboSecret>", universalLink: "https://api.weibo.com/oauth2", redirectURI: "https://api.weibo.com/oauth2")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return WWSignInWith3rd.Weibo.shared.canOpenURL(app, open: url)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return WWSignInWith3rd.Weibo.shared.canOpenUniversalLink(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}



