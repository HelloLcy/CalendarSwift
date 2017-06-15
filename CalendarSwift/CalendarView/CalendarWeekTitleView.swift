//
//  CalendarWeekTitleView.swift
//  CalendarSwift
//
//  Created by edianzu on 2017/5/31.
//  Copyright © 2017年 LCY. All rights reserved.
//

import UIKit

class CalendarWeekTitleView: UIView {
    
    ///标题
    var weekTitles = ["S","M","T","W","T","F","S"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(titles: [String], frame: CGRect) {
        self.init(frame: frame)
        self.weekTitles = titles
        
        var startX: CGFloat = 0.0
        let titleCount = weekTitles.count > 0 ? weekTitles.count : 1
        let width = self.frame.size.width / CGFloat(titleCount)        
        for (index,title) in weekTitles.enumerated() {
            startX = CGFloat(index) * width
            let titleLabel = UILabel(frame: CGRect(x: startX, y: 0, width: width, height: self.frame.size.height))
            titleLabel.text = title
            titleLabel.textAlignment = .center
            titleLabel.textColor = UIColor(red: 1.0, green: 109.0/255.0, blue: 108.0/255.0, alpha: 1.0)
            titleLabel.font = UIFont.systemFont(ofSize: 15.0)
            
            self.addSubview(titleLabel)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var startX: CGFloat = 0.0
        let titleCount = self.subviews.count > 0 ? weekTitles.count : 1
        let width = self.frame.size.width / CGFloat(titleCount)
        
        for (index,view) in self.subviews.enumerated() {
            startX = CGFloat(index) * width
            view.frame = CGRect(x: startX, y: 0, width: width, height: self.frame.size.height)
        }
    }
}
