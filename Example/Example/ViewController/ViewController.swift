//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2023/9/11.
//  ~/Library/Caches/org.swift.swiftpm/

import UIKit
import WWPrint
import WWSignInWith3rd_Apple
import WWSignInWith3rd_Weibo

final class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// [設定Build Settings -> Other Linker Flags => -ObjC -all_load](https://www.jianshu.com/p/96ce02c214aa)
    /// - Parameter sender: UIButton
    @IBAction func signInWithWeibo(_ sender: UIButton) {
        
        WWSignInWith3rd.Weibo.shared.login { result in

            switch result {
            case .failure(let error): wwPrint(error)
            case .success(let info): wwPrint(info)
            }
        }
    }
}
