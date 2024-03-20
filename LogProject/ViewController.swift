//
//  ViewController.swift
//  LogProject
//
//  Created by 김현구 on 3/15/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Test Function
        Log.setLogLevel(LogLevel.DEBUG)
        Log.tag(Tag.CALL).t("message")
        Log.tag(Tag.GROUP).tag(Tag.URI).e("message")
        Log.tag([Tag.CALL, Tag.URI]).d("message")
    }


}

