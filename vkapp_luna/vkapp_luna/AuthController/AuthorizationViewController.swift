//
//  AuthorizationViewController.swift
//  nvleonovich_homework
//
//  Created by nvleonovich on 21.06.2020.
//  Copyright © 2020 nvleonovich. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import WebKit

class AuthorizationViewController: UIViewController {


    @IBOutlet weak var webview: WKWebView!
        {
        didSet {
            webview.navigationDelegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        doRequest()
    }
    
    func doRequest() {
            var urlComponents = URLComponents()
                
            urlComponents.scheme = "https"
            urlComponents.host = "oauth.vk.com"
            urlComponents.path = "/authorize"
            urlComponents.queryItems = [
                URLQueryItem(name: "client_id", value: "7570397"),
                URLQueryItem(name: "display", value: "mobile"),
                URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
                URLQueryItem(name: "scope", value: "270342"),
                URLQueryItem(name: "response_type", value: "token"),
                URLQueryItem(name: "v", value: "5.120"),
//                URLQueryItem(name: "revoke", value: "1"),
            ]
            
            let request = URLRequest(url: urlComponents.url!)
            
            webview.load(request)
    }
    
//    "error": {
//           "error_code": 5,
//           "error_msg": "User authorization failed: invalid session.",
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        // Проверяем данные
//        let checkResult = checkUserData()
//
//        // Если данные не верны, покажем ошибку
//        if !checkResult {
//            showLoginError()
//        }
//
//        // Вернем результат
//        return checkResult
//    }
//
}

extension AuthorizationViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment  else {
            decisionHandler(.allow)
            return
        }
        
        let params = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
        }
        
        let token = params["access_token"]
        let id = params["user_id"]
        let userId = Int(id!) ?? 0
        Session.instance.userId = userId
        Session.instance.token = token!
        
        print("token \(Session.instance.token)")
        
        decisionHandler(.cancel)
        performSegue(withIdentifier: "GoToFriendsList", sender: nil)
        
        
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//
//        let vc : ProfileTabBarController = storyboard.instantiateViewController(withIdentifier: "profileTabBar") as! ProfileTabBarController
//
//        let navigationController = UINavigationController(rootViewController: vc)
//
//        navigationController.modalPresentationStyle = .fullScreen
//
//        present(navigationController, animated: true, completion: nil)
        
        }
    
}

