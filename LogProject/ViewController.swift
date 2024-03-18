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
        Log.tag(Tag.CALL).t("message")
        Log.tag(Tag.FLOOR).tag(Tag.CALL).d("message")
        Log.tag(Tag.MESSAGE).tag(Tag.FLOOR).tag(Tag.CALL).w("message")
        Log.tag(Tag.GROUP).e("message")
        Log.tag(Tag.NOTIFY).f("message")
    }


}

