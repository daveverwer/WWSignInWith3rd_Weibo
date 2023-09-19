//
//  WWSignInWith3rd+Weibo.swift
//  WWSignInWith3rd+Weibo
//
//  Created by William.Weng on 2023/9/13.
//

import UIKit
import WWPrint
import WWSignInWith3rd_Apple
import WeiboSDK

// MARK: - 第三方登入
extension WWSignInWith3rd {
    
    /// [新浪微博SDK - 3.3.5](https://github.com/sinaweibosdk/weibo_ios_sdk)
    open class Weibo: NSObject {

        public static let shared = Weibo()
        
        private(set) var appKey: String?
        private(set) var secret: String?
        private(set) var universalLink: String?
        private(set) var redirectURI: String?
        private(set) var accessToken: String?
        
        private var completionBlock: ((Result<Data?, Error>) -> Void)?
        
        private override init() {}
    }
}

// MARK: - WeiboSDKDelegate + WBHttpRequestDelegate
extension WWSignInWith3rd.Weibo: WeiboSDKDelegate, WBHttpRequestDelegate {
    
    public func didReceiveWeiboRequest(_ request: WBBaseRequest?) { wwPrint(request) }
    public func didReceiveWeiboResponse(_ response: WBBaseResponse?) { loginInformation(with: response) }
}

// MARK: - 公開函式
public extension WWSignInWith3rd.Weibo {
    
    /// [參數設定](https://open.weibo.com/wiki/Sdk/ios)
    /// - Parameters:
    ///   - appKey: [String](https://www.jianshu.com/p/5a468f60c111)
    ///   - secret: String
    ///   - universalLink: String
    ///   - redirectURI: String
    ///   - isEnableDebugMode: 開啟log輸出
    /// - Returns: Bool
    func configure(appKey: String, secret: String, universalLink: String, redirectURI: String, isEnableDebugMode: Bool = false) -> Bool {
        
        let isSuccess = WeiboSDK.registerApp(appKey, universalLink: universalLink)
        
        if (isSuccess) {
            self.appKey = appKey
            self.secret = secret
            self.universalLink = universalLink
            self.redirectURI = redirectURI
        }
        
        enableDebugMode(isEnableDebugMode)
        return isSuccess
    }
    
    /// [登入](https://open.weibo.com/wiki/Scope)
    /// - Parameter completion: [Result<Data?, Error>](https://www.jianshu.com/p/1b744a97e63d)
    func login(completion: ((Result<Data?, Error>) -> Void)?) {
        
        completionBlock = completion
        
        let request = WBAuthorizeRequest()
        request.scope = "all"
        request.redirectURI = WWSignInWith3rd.Weibo.shared.redirectURI
        
        WeiboSDK.send(request) { isSuccess in
            if (!isSuccess) { self.completionBlock?(.failure(Constant.MyError.notOpenURL)) }
        }
    }
    
    /// 登出
    /// - Parameter tag: String
    /// - Returns: Bool
    func logout(with tag: String = "Weibo") -> Bool {
        
        guard let accessToken = accessToken else { return false }
        
        WeiboSDK.logOut(withToken: accessToken, delegate: self, withTag: tag)
        return true
    }
    
    /// 在外部由URL Scheme開啟 -> application(_:open:options:)
    /// - Parameters:
    ///   - app: UIApplication
    ///   - url: URL
    ///   - options: [UIApplication.OpenURLOptionsKey: Any]
    /// - Returns: Bool
    func canOpenURL(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        guard let appKey = appKey,
              url.absoluteString.contains(appKey)
        else {
            return true
        }
        
        return WeiboSDK.handleOpen(url, delegate: self)
    }
    
    /// 在外部由UniversalLink開啟 -> application(_:continue:restorationHandler:)
    func canOpenUniversalLink(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return WeiboSDK.handleOpenUniversalLink(userActivity, delegate: self)
    }
}

// MARK: - 小工具
private extension WWSignInWith3rd.Weibo {
    
    /// 取得Login後的相關資訊 (確認 / 取消)
    /// - Parameter response: BaseResp
    func loginInformation(with response: WBBaseResponse!) {
        
        guard let response = response as? WBAuthorizeResponse,
              let uid = response.userID,
              let accessToken = response.accessToken
        else {
            self.completionBlock?(.failure(Constant.MyError.isCancel)); return
        }

        DispatchQueue(label: "SinaLoginDispatchQueue").async {
            let data = self.responseData(with: uid, accessToken: accessToken)
            self.completionBlock?(.success(data))
        }
    }
    
    /// 由Response取得的相關資訊
    /// - Parameters:
    ///   - uid: String
    ///   - accessToken: String
    /// - Returns: Data?
    func responseData(with uid: String, accessToken: String) -> Data? {
        
        guard let url = accessTokenURL(with: uid, accessToken: accessToken),
              let data = try? Data(contentsOf: url, options: .alwaysMapped)
        else {
            return nil
        }
        
        return data
    }
    
    /// 產生AccessTokenURL
    /// - Parameters:
    ///   - uid: String
    ///   - accessToken: String
    /// - Returns: URL?
    func accessTokenURL(with uid: String, accessToken: String) -> URL? {
        
        guard let appKey = WWSignInWith3rd.Weibo.shared.appKey,
              let urlString = Optional.some("https://api.weibo.com/2/users/show.json?uid=\(uid)&access_token=\(accessToken)&source=\(appKey)"),
              let url = URL(string: urlString)
        else {
            return nil
        }
        
        self.accessToken = accessToken
        
        return url
    }
    
    /// 輸出Log訊息
    func enableDebugMode(_ isEnable: Bool) {
        WeiboSDK.enableDebugMode(isEnable)
    }
}
