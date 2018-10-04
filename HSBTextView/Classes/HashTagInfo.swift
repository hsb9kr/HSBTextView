//
//  HashTagInfo.swift
//  HSBTextView
//
//  Created by 홍상보 on 04/10/2018.
//

import UIKit

public class HashTagInfo: NSObject {
	public var prefix: String
	public var name: String
	public var range: NSRange
	public override var description: String {
		return "prefix(\(prefix), name(\(name)), range(loaction: \(range.location), length: \(range.length))"
	}
	
	init(prefix: String, name: String, range: NSRange) {
		self.prefix = prefix
		self.name = name
		self.range = range
	}
}
