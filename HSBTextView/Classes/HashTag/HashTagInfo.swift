//
//  HashTagInfo.swift
//  HSBTextView
//
//  Created by 홍상보 on 04/10/2018.
//

import UIKit

public class HashTagInfo: NSObject {
	public var prefix: String
	public var string: String
	public var word: String
	public var range: NSRange
	public override var description: String {
		return "string: \(string), prefix(\(prefix)), word(\(word)), range(loaction: \(range.location), length: \(range.length))"
	}
	
	init(string: String, prefix: String, range: NSRange) {
		self.string = string
		self.prefix = prefix
		self.range = range
		self.word = string.replacingOccurrences(of: prefix, with: "")
	}
}
