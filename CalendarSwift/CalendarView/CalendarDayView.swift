//
//  CalendarDayView.swift
//  CalendarSwift
//
//  Created by edianzu on 2017/5/31.
//  Copyright © 2017年 LCY. All rights reserved.
//

import UIKit

protocol CalendarDayViewDelegate {
    func calendarDidClicked(with dayView: CalendarDayView) -> Void
}

class CalendarDayView: UIView {
    
    enum Location {
        ///左边缘位置
        case left
        ///中间、非边缘位置
        case center
        ///右边缘位置
        case right
    }
    
    fileprivate enum DrawType: Int {
        case current,startWithoutEnd,startWithEnd,startAtRightWithEnd,left,center,right,end,endAtLeft
    }
    
    enum State {
        ///过去的日期
        case invalid(pastMonth: Bool)
        ///当前月份中的日期
        case current(current: Bool)
        ///下个月份中的日期
        case future(previous: Bool,current: Bool,future: Bool)
        ///选中日期中的结束日期
        case end
        ///选中日期中的开始日期
        case start(hasEnd: Bool)
        ///被选中的日期
        case selected
    }
    
    fileprivate let ratio: CGFloat = 0.5
    
    var font: UIFont {
        didSet{
            if titleLabel != nil {
               titleLabel.font = font
            }
            
            if dayLabel != nil {
                dayLabel.font = font
            }
        }
    }

    var date: Date? = nil {
        didSet{
            if date != nil {
                if let currentDayOrdinal = CalendarView.calendar.ordinality(of: .day, in: .month, for: date!) {
                    self.dayLabel.text = "\(currentDayOrdinal)"
                }                
            }
            else {
            
            }
        }
    }
    
    var loction: Location = .center
    
    var dayState: State = .invalid(pastMonth: false){
        didSet{
            self.setNeedsDisplay()
        }
    }
    var delegate: CalendarDayViewDelegate? = nil
    
    ///日期
    fileprivate weak var dayLabel: UILabel!
    ///日期上方的标题
    fileprivate weak var titleLabel: UILabel!
    
    override init(frame: CGRect){
        self.font = UIFont.systemFont(ofSize: 12.0)
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        createSubViews()
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        let totalW = self.frame.size.width
        let totalH = self.frame.size.height
        self.titleLabel.frame = CGRect(x: 0, y: 0, width: totalW, height: totalH * ratio)
        self.dayLabel.frame = CGRect(x: 0, y: totalH * ratio, width: totalW, height: totalH - (totalH * ratio))
    }
    
    fileprivate func createSubViews() {
        let titleLabel = UILabel()
        self.titleLabel = titleLabel
        titleLabel.font = font
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.gray
        self.addSubview(titleLabel)
        
        let dayLabel = UILabel()
        self.dayLabel = dayLabel
        dayLabel.font = font
        dayLabel.textAlignment = .center
        dayLabel.textColor = UIColor.black
        self.addSubview(dayLabel)
        ///点击手势
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CalendarDayView.didClicked))
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    func didClicked() -> Void {
        delegate?.calendarDidClicked(with: self)
    }
        
    override func draw(_ rect: CGRect) {
        self.isUserInteractionEnabled = true

        switch dayState{
        case .invalid(_):
            titleLabel.isHidden = true
            dayLabel.textColor = UIColor.gray
            self.isUserInteractionEnabled = false
            
        case .current(current: false): //展示的不是当前系统时间正在的月份
            titleLabel.text = "当天"
            titleLabel.isHidden = false
            dayLabel.textColor = UIColor.gray
            self.drawGraphics(for: .current)

        case .current(current: true):
            titleLabel.text = "当天"
            titleLabel.isHidden = false
            titleLabel.textColor = UIColor.gray
            dayLabel.textColor = UIColor.black
            self.drawGraphics(for: .current)

        case .future(previous: true, _, _):
            fallthrough
            
        case .future(_, _, future: true):
            titleLabel.isHidden = true
            dayLabel.textColor = UIColor.gray
            
        case .future(_, current: true, _):
            titleLabel.isHidden = true
            dayLabel.textColor = UIColor.black
            
        case .start(hasEnd: true):
            titleLabel.text = "起始"
            titleLabel.isHidden = false
            titleLabel.textColor = UIColor.red
            dayLabel.textColor = UIColor.white
            if loction == .right {
                self.drawGraphics(for: .startAtRightWithEnd)
            }
            else {
                self.drawGraphics(for: .startWithEnd)
            }
            
        case .start(hasEnd: false):
            titleLabel.text = "起始"
            titleLabel.isHidden = false
            titleLabel.textColor = UIColor.red
            dayLabel.textColor = UIColor.white
            self.drawGraphics(for: .startWithoutEnd)
            
        case .selected:
            titleLabel.isHidden = true
            dayLabel.textColor = UIColor.white
            UIColor.red.setFill()
            UIColor.white.setStroke()
            if loction == .left {
                self.drawGraphics(for: .left)
            }
            else if loction == .right {
                self.drawGraphics(for: .right)
            }
            else {
                self.drawGraphics(for: .center)
            }
            
        case .end:
            titleLabel.text = "截止"
            titleLabel.isHidden = false
            titleLabel.textColor = UIColor.red
            dayLabel.textColor = UIColor.white
            if loction == .left {
                self.drawGraphics(for: .endAtLeft)
            }
            else {
                self.drawGraphics(for: .end)
            }
            
        default:
            break
        }
    }
    
    fileprivate func drawGraphics(for type: DrawType) {
        let radius = min(self.dayLabel.frame.width, self.dayLabel.frame.height) * 0.5
        
        var startAngle: CGFloat = 0.0
        var endAngle: CGFloat = CGFloat(Double.pi * 2)
        var fillColor: UIColor? = nil
        var strockColor: UIColor? = nil
        var arcBezierPath: UIBezierPath? = nil
        var rectBezierPath: UIBezierPath? = nil
        var drawRect: CGRect? = nil
        
        ///当天
        if type == .current {
            strockColor = UIColor.gray
        }
        
        if type == .startWithoutEnd {
            fillColor = UIColor.red
        }
        if type == .startAtRightWithEnd {
            fillColor = UIColor.red
            strockColor = UIColor.white
        }
        if type == .startWithEnd {
            fillColor = UIColor.red
            strockColor = UIColor.white
            drawRect = CGRect(x: dayLabel.center.x, y: dayLabel.center.y - (radius - 0.5), width: dayLabel.frame.width * 0.5, height: (radius - 0.5) * 2)
        }

        ///左边缘选中
        if type == .left {
            fillColor = UIColor.red
            startAngle = CGFloat(Double.pi * 0.5)
            endAngle = CGFloat(Double.pi * 1.5)
            drawRect = CGRect(x: dayLabel.center.x, y: dayLabel.center.y - (radius - 0.5), width: dayLabel.frame.width * 0.5, height: (radius - 0.5) * 2)
        }
        ///右边缘选中
        if type == .right {
            fillColor = UIColor.red
            startAngle = CGFloat(-Double.pi * 0.5)
            endAngle = CGFloat(Double.pi * 0.5)
            drawRect = CGRect(x: 0.0, y: dayLabel.center.y - (radius - 0.5), width: dayLabel.frame.width * 0.5, height: (radius - 0.5) * 2)
        }
        
        if type == .endAtLeft {
            fillColor = UIColor.red
            strockColor = UIColor.white
        }
        if type == .end {
            fillColor = UIColor.red
            strockColor = UIColor.white
            drawRect = CGRect(x: 0.0, y: dayLabel.center.y - (radius - 0.5), width: dayLabel.frame.width * 0.5, height: (radius - 0.5) * 2)
        }
        
        fillColor?.setFill()
        strockColor?.setStroke()

        if type != .center {
            arcBezierPath = UIBezierPath(arcCenter: dayLabel.center, radius:radius - 0.5, startAngle: startAngle, endAngle:endAngle, clockwise: true)
            arcBezierPath?.lineWidth = 1.0
        }
        else {
            fillColor = UIColor.red
            drawRect = CGRect(x: 0.0, y: dayLabel.center.y - (radius - 0.5), width: dayLabel.frame.width, height: (radius - 0.5) * 2)
        }
        
        if drawRect != nil {
            rectBezierPath = UIBezierPath(rect: drawRect!)
            rectBezierPath?.fill()
        }
        
        if fillColor != nil {
            arcBezierPath?.fill()
        }
        if strockColor != nil {
            arcBezierPath?.stroke()
        }
    }
}
