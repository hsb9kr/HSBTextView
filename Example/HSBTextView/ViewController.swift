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
	@IBOutlet var chipsTextView: ChipsTextView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		hashTagTextView.didTouchClosure = {(hashTagInfo, URL, range) in
			print(hashTagInfo)
		}
		
		hashTagTextView.detectClosure = { hashTagInfo in
			print(hashTagInfo)
		}
		
		chipsTextView.detectsClosure = { chips in
			for chip in chips {
				print(chip.name)
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	@IBAction func didTouchUpInsideButton(_ sender: UIButton) {
		
		let isEditable = !hashTagTextView.isEditable
		
		hashTagTextView.isEditable = isEditable
		chipsTextView.isEditable = isEditable
		
		sender.setTitle(isEditable ? "Edit Mode" : "Read Mode", for: .normal)
		
	}
	
}

