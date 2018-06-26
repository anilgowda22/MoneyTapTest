//
//  MTWikiPageViewController.swift
//  MoneyTapSample
//
//  Created by Batman on 26/06/18.
//  Copyright © 2018 AnilKumar. All rights reserved.
//

import UIKit

class MTWikiPageViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var titleString: String = ""
    var loadingView : UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleString

        //--------- Activity Indicator setup ----------//
        let center = Int(UIScreen.main.bounds.width / 2 - UIScreen.main.bounds.height / 2)
        loadingView = UIActivityIndicatorView(frame : CGRect(x: center, y: center, width: 50, height: 50))
        loadingView.activityIndicatorViewStyle = .gray
        view.addSubview(loadingView)
        view.bringSubview(toFront: loadingView)
        loadingView.startAnimating()


        let wikiText =  titleString.replacingOccurrences(of: " ", with: "_")
        webView.loadRequest(URLRequest(url: URL(string: "https://en.wikipedia.org/wiki/\(wikiText)")!))
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        loadingView.removeFromSuperview()
    }

}
