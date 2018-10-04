//
//  ViewController.swift
//  HSBTextView
//
//  Created by Red on 10/03/2018.
//  Copyright (c) 2018 Red. All rights reserved.
//

import UIKit
import HSBTextView

class ViewController: UIViewController {

	@IBOutlet var hashTagTextView: HashTagTextView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		hashTagTextView.didTouchClosure = {(hashTagInfo, URL, range) in
			print(hashTagInfo.name)
		}
		
		hashTagTextView.detectClosure = { hashTagInfo in
			print(hashTagInfo.name)
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

