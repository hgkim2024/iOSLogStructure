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
        Log.tag(.CALL).t("message")
        Log.tag(.GROUP).tag(.URI).tag(.FLOOR).e("message")
        Log.tag([.CALL, Tag.URI]).d("message")
        Log.tag([.MESSAGE, .NOTIFY]).tag(.URI).d("message")
        Log.tag(.CALL).tag([.URI, .NAME]).d("message")
    }


}

