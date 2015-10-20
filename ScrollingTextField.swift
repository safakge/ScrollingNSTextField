//
//  ScrollingTextField.swift
//
//  Created by Şafak Gezer on 18/10/15.
//  Copyright © 2015 Şafak Gezer. All rights reserved.
//

import Cocoa

class ScrollingTextField: NSScrollView {
	
	private let textField:NSTextField = NSTextField()
	
	private var animating = false

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
	}
	
	override func viewDidMoveToWindow() {
		self.setup()
	}
	
	override func rightMouseUp(theEvent: NSEvent) {
		if self.animating {
			self.stopAnimating()
		}
	}
	
	private func stopAnimating() {
		assert(self.animating)
		NSAnimationContext.beginGrouping()
		NSAnimationContext.currentContext().duration = 0.0 //must stop
		self.contentView.animator().setBoundsOrigin(NSPoint(x:0, y:0))
		NSAnimationContext.endGrouping()
		self.animating = false
	}
	
	private func animateScrollingStep(back:Bool) {
		//should we actually animate?
		self.animating = true
		
		let newOrigin = NSPoint(x: (back ? 0 : self.textField.frame.size.width - self.frame.size.width), y: 0)
		
		NSAnimationContext.beginGrouping()
		Swift.print("scrolling animation (back=\(back)) (titleW:\(self.textField.frame.size.width), selfW:\(self.frame.size.width))")
		NSAnimationContext.currentContext().duration = 3.0
		NSAnimationContext.currentContext().completionHandler = {
			if self.animating {
				let nextStepIsBack = !back
				let nextStepBlock = { () -> Void in
					self.animateScrollingStep(nextStepIsBack)
				}
				
				delay(nextStepIsBack ? 2.0 : 4.0, closure: nextStepBlock)
			}
		}
		self.contentView.animator().setBoundsOrigin(newOrigin)
		NSAnimationContext.endGrouping()
	}
	
	private func beginOrStopAnimatingAsNeeded() {
		let shouldAnimateFurther = self.textField.frame.size.width > self.frame.size.width + 4
		if self.animating && !shouldAnimateFurther {
			//should it be stopped?
			self.stopAnimating()
		} else if !self.animating && shouldAnimateFurther {
			//should it be started?
			self.animateScrollingStep(false)
		}
	}
	
	override func scrollWheel(theEvent: NSEvent) {
		//overridden for no-op. (we do not want mouse scrolling to interfere with animation)
	}
	
	private func setup() {
		self.textField.bordered = false
		self.textField.drawsBackground = false
		self.textField.textColor = NSColor(white:0.6, alpha: 1.0)
		
        self.hasHorizontalScroller      = false
        self.hasVerticalScroller        = false
        self.verticalScrollElasticity   = NSScrollElasticity.None
        self.horizontalScrollElasticity = NSScrollElasticity.None
		
		Swift.print("\(self.documentView) ----")
		
		self.documentView = self.textField
		
		self.textField.editable = false
		
		Swift.print("setup ended")
	}
	
	var stringValue:String = "" {
		didSet {
			self.textField.stringValue = "\(stringValue)"
			self.textField.sizeToFit()
			self.contentView.setBoundsOrigin(NSPoint(x:0, y:0))
			self.beginOrStopAnimatingAsNeeded()
		}
	}
}
