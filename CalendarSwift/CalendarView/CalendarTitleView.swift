//
//  CalendarTitleView.swift
//  CalendarSwift
//
//  Created by edianzu on 2017/5/31.
//  Copyright © 2017年 LCY. All rights reserved.
//

import UIKit

public let LCYCalendarMonthChangedObjectKey = "LCYCalendarMonthChangedObjectKey"

class CalendarTitleView: UIView {
    
    let buttonBaseTag = 6125
    ///日期标题
    var title: String {
        get{
            if let string = titleLabel?.text {
               return string
            }
            
            return ""
        }
        set{
            titleLabel.text = newValue
        }
    }
    ///标题label
    var titleLabel: UILabel!
    ///跳到前一月按钮
    weak var previousButton: UIButton!
    ///跳到下一月按钮
    weak var nextButton: UIButton!
    ///
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        var width: CGFloat = 30.0
        var leftMargin: CGFloat = 25.0
        let topMargin: CGFloat = (frame.height - width ) * 0.5
        
        let previousButton = UIButton(frame: CGRect(x: leftMargin, y: topMargin, width: width, height: width))
        previousButton.tag = buttonBaseTag
        self.previousButton = previousButton
        previousButton.contentMode = .scaleAspectFit
        previousButton.setImage(UIImage(named: "left_arrow"), for: .normal)
        previousButton.setImage(UIImage(named: "left_arrow"), for: .selected)
        previousButton.addTarget(self, action: #selector(CalendarTitleView.didClicked(button:)), for: .touchUpInside)
        self.addSubview(previousButton)
        
        width = frame.width - (width + leftMargin) * 2 - 20
        leftMargin += 30.0 + 10.0
        let titleLabel = UILabel(frame: CGRect(x: leftMargin, y: topMargin, width: width, height: frame.height - 2 * topMargin))
        self.titleLabel = titleLabel
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 18.0)
        titleLabel.textColor = UIColor(red: 1.0, green: 109.0/255.0, blue: 108.0/255.0, alpha: 1.0)
        self.addSubview(titleLabel)
        
        width = 30.0
        leftMargin = frame.width - width - 25.0
        let nextButton = UIButton(frame: CGRect(x: leftMargin, y: topMargin, width: width, height: width))
        self.nextButton = nextButton
        nextButton.tag = buttonBaseTag + 1
        nextButton.contentMode = .scaleAspectFit
        nextButton.setImage(UIImage(named: "right_arrow"), for: .normal)
        nextButton.setImage(UIImage(named: "right_arrow"), for: .selected)
        nextButton.addTarget(self, action: #selector(CalendarTitleView.didClicked(button:)), for: .touchUpInside)
        self.addSubview(nextButton)
    }
    
    func didClicked(button: UIButton) -> Void {

        if button.tag == buttonBaseTag { //上个月
            NotificationCenter.default.post(name: .LCYCalendarDidChangedMonthNotification, object: self, userInfo: [LCYCalendarMonthChangedObjectKey : false])
        }
        else { //下个月
            NotificationCenter.default.post(name: .LCYCalendarDidChangedMonthNotification, object: self, userInfo: [LCYCalendarMonthChangedObjectKey : true])
        }
    }
}


extension NSNotification.Name{
    ///切换月份
    static let LCYCalendarDidChangedMonthNotification: NSNotification.Name = NSNotification.Name.init("LCYCalendarDidChangedMonthNotification")
}
