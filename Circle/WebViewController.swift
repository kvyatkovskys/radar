//
//  WebViewController.swift
//  Circle
//
//  Created by Sergei Kviatkovskii on 19/09/2018.
//  Copyright © 2018 Kviatkovskii. All rights reserved.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {
    fileprivate let url: URL
    
    fileprivate lazy var webView: WKWebView = {
       let web = WKWebView()
        web.navigationDelegate = self
        return web
    }()
    
    fileprivate lazy var refreshButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
    }()
    
    override func loadView() {
        view = webView
    }

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.load(URLRequest(url: url))
        toolbarItems = [refreshButton]
        navigationController?.isToolbarHidden = false
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
}
