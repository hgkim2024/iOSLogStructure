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
        Log.tag(Tag.GROUP).tag(Tag.URI).tag(Tag.FLOOR).e("message")
        Log.tag([Tag.CALL, Tag.URI]).d("message")
        Log.tag([Tag.MESSAGE, Tag.NOTIFY]).tag(Tag.URI).d("message")
        Log.tag(Tag.CALL).tag([Tag.URI, Tag.NAME]).d("message")
    }


}

