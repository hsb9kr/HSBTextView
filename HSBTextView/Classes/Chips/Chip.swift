//
//  Chip.swift
//  HSBTextView
//
//  Created by 홍상보 on 04/10/2018.
//

import UIKit

public class Chip: NSObject {
	public var name: String
	public var range: NSRange
	
	init(name: String, range: NSRange) {
		self.name = name
		self.range = range
	}
}
