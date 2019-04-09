//
//  ChipsTextView.swift
//  HSBTextView
//
//  Created by 홍상보 on 04/10/2018.
//

import UIKit

public protocol ChipsTextViewDelegate {
	func detect(textView: ChipsTextView, chip: Chip)
	func detects(textView: ChipsTextView, chips: [Chip])
	func didTouch(textView: ChipsTextView, chip: Chip, URL: URL, range: NSRange)
}


public class ChipsTextView: UITextView {
	
	public var didTouchClosure: ((_ chip: Chip, _ URL: URL, _ range: NSRange) -> Void)?
	public var detectClosure: ((_ chip: Chip) -> Void)?
	public var detectsClosure: ((_ chips: [Chip]) -> Void)?
	public var chips = [Chip]()
	public var textViewDelegate: ChipsTextViewDelegate?
	
	override public func awakeFromNib() {
		super.awakeFromNib()
		delegate = self
		attributedText = detect(string: text)
	}

	fileprivate func detect(string: String) -> NSMutableAttributedString {
		
		let regex = try? NSRegularExpression(pattern: "\\w+", options: [.caseInsensitive])
		
		let attributeString = NSMutableAttributedString(string: string, attributes: [
			.font : UIFont.systemFont(ofSize: font?.pointSize ?? 14),
			.foregroundColor : textColor ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
			])
		
		guard let words = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: string.count)).map ({ (result) -> Chip in
			let startIndex = string.index(string.startIndex, offsetBy: result.range.location)
			let endIndex = string.index(string.startIndex, offsetBy: result.range.location + result.range.length)
			
			let name = String(string[startIndex..<endIndex])
			let range = NSRange(location: startIndex.utf16Offset(in: string), length: endIndex.utf16Offset(in: string) - startIndex.utf16Offset(in: string))
			
			return Chip(name: name, range: range)
		}) else {
			return attributeString
		}
		
		chips = words
		
		for chip in chips {
			attributeString.addAttributes([.link : ""], range: chip.range)
		}
		
		return attributeString
	}
	
	fileprivate func detect(string: String, range: NSRange) {
		
		let endIndex = string.index(string.startIndex, offsetBy: range.location + range.length)
		
		let substring = string[string.startIndex..<endIndex]
		let regex = try? NSRegularExpression(pattern: "\\w+", options: [.caseInsensitive])
		var searchRange: NSRange?
		
		guard let words = regex?.matches(in: String(substring), options: [], range: NSRange(location: 0, length: substring.count)).map ({ (result) -> String in
			let startIndex = substring.index(substring.startIndex, offsetBy: result.range.location)
			let endIndex = substring.index(substring.startIndex, offsetBy: result.range.location + result.range.length)
			searchRange = NSRange(location: startIndex.utf16Offset(in: string), length: endIndex.utf16Offset(in: string) - startIndex.utf16Offset(in: string))
			return String(substring[startIndex..<endIndex])
		}), let word = words.last else {
			return
		}
		
		let chip = Chip(name: word, range: searchRange!)
		detectClosure?(chip)
		textViewDelegate?.detect(textView: self, chip: chip)
	}
}


extension ChipsTextView: UITextViewDelegate {
	
	public func textViewDidChange(_ textView: UITextView) {
		
		guard let string = textView.text else {
			return
		}
		
		let range = textView.selectedRange
		
		textView.attributedText = detect(string: string)
		
		textView.selectedRange = range
		
		detect(string: string, range: range)
		
		detectsClosure?(chips)
		textViewDelegate?.detects(textView: self, chips: chips)
	}
	
	@available(iOS 10.0, *)
	public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		
		guard let string = textView.text else {
			return false
		}
		
		let startIndex = string.index(string.startIndex, offsetBy: characterRange.location)
		let endIndex = string.index(startIndex, offsetBy: characterRange.length)
		let substring = string[startIndex..<endIndex]
		
		let chip = Chip(name: String(substring), range: characterRange)
		
		textViewDelegate?.didTouch(textView: textView as! ChipsTextView, chip: chip, URL: URL, range: characterRange)
		didTouchClosure?(chip, URL, characterRange)
		
		return false
	}
}
