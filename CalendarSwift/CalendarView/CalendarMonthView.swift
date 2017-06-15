//
//  CalendarMonthView.swift
//  CalendarSwift
//
//  Created by edianzu on 2017/6/2.
//  Copyright © 2017年 LCY. All rights reserved.
//

import UIKit

fileprivate func *(lhs: Int, rhs: CGFloat) -> CGFloat {
    return CGFloat(lhs) * rhs
}

protocol CalendarMonthViewDelegate {
    func calendarDidSelected(start: Date, end: Date?) -> Void
}

class CalendarMonthView: UIView {
    
    fileprivate enum DayInMonth {
        case previous
        case current
        case next
    }
    ///最大总共展示的天数
    fileprivate static let maxDaysCount = 42
    ///当前展示的日期
    fileprivate var date = Date()
    ///每周天数
    fileprivate let maxDayInWeek = 7
    ///当月的周数所占的最大行
    fileprivate let maxWeekInMonth = 6
    ///dayView的tag基值
    fileprivate let tagBaseValue = 1212
    ///选择的起始日期
    var startDate: Date? = nil
    ///选择的截止日期
    var endDate: Date? = nil
    ///代理
    var delegate: CalendarMonthViewDelegate? = nil
    
    ///日期组件
    fileprivate var dateComponent: DateComponents {
        get{
            return CalendarView.calendar.dateComponents([.year,.month,.day,.hour,.minute,.second,.weekday,.weekdayOrdinal], from: date)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CalendarMonthView.didStartAndMove(with:)))
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    convenience init(date: Date, frame: CGRect) {
        self.init(frame: frame)
        self.date = date
        let width = frame.width / CGFloat(maxDayInWeek)
        let height = frame.height / CGFloat(maxWeekInMonth)
        
        for index in 0..<CalendarMonthView.maxDaysCount {
            let dayView = CalendarDayView(frame: CGRect(x: (index % maxDayInWeek) * width, y: (index / maxDayInWeek) * height, width: width, height: height))
            dayView.delegate = self
            dayView.tag = tagBaseValue + index
            if index % maxDayInWeek == 0 {
                dayView.loction = .left
            }
            else if index % maxDayInWeek == (maxDayInWeek - 1) {
                dayView.loction = .right
            }
            else {
                dayView.loction = .center
            }
            
            self.addSubview(dayView)
        }
        self.reloadDaysForCurrentMonth()
        self.reloadMonthDayState()
    }
    ///
    func changedDate(with date: Date) {
        self.date = date
        self.reloadDaysForCurrentMonth()
        self.reloadMonthDayState()
    }
    
    ///定义下标访问
    fileprivate subscript(index: Int) -> Date?{
        get{
            if let dayView = self.viewWithTag(index + tagBaseValue) as? CalendarDayView {
                return dayView.date
            }
            else{
                fatalError("subscript(index:\(index)) has no matching value")
            }
        }
        set{
            if let dayView = self.viewWithTag(index + tagBaseValue) as? CalendarDayView {
                dayView.date = newValue
            }
            else{
                fatalError("subscript(index:\(index)) has no matching value")
            }
        }
    }

    ///定义下标访问
    fileprivate subscript(row: Int, col: Int) -> CalendarDayView {
        get{
            let index = row * maxDayInWeek + col
            if let dayView = self.viewWithTag(index + tagBaseValue) as? CalendarDayView {
                return dayView
            }
            else{
                fatalError("subscript(index:\(index)) has no matching value")
            }
        }
    }

    fileprivate func weekDayOfFirstDayMonth() -> Int?{
        guard let currentNumOfMonth = CalendarView.calendar.ordinality(of: .day, in: .month, for: date) else {
            return nil
        }
        guard dateComponent.weekday != nil else {
            return nil
        }

        let minSameWeekDay = (currentNumOfMonth % 7 == 0 ? 7 : currentNumOfMonth % 7)
        
        let weekDay = (7 - (minSameWeekDay - 1) + dateComponent.weekday!)
        
        return (weekDay > 7 ? weekDay % 7 : weekDay)
    }
    
    fileprivate func reloadDaysForCurrentMonth() -> Void {
        ///计算当前月的第一天是星期几
        let weekDayOfFirstDayMonth = self.weekDayOfFirstDayMonth()!
        ///当月有多少天
        let maxDayInCurrentMonth = CalendarView.calendar.range(of: .day, in: .month, for: date)!.upperBound - 1
        let nextMonth = CalendarView.calendar.date(byAdding: .month, value: 1, to: date)!
        let previousMonth = CalendarView.calendar.date(byAdding: .month, value: -1, to: date)!
        ///上个月有多少天
        let maxDayInPreviousMonth = CalendarView.calendar.range(of: .day, in: .month, for: previousMonth)!.upperBound - 1
        
        for index in 0..<CalendarMonthView.maxDaysCount {
            if index < weekDayOfFirstDayMonth - 1 {
                let dayIndex = maxDayInPreviousMonth - (weekDayOfFirstDayMonth - 1) + index + 1
                self[index] = previousMonth.date(with: dayIndex)
            }
            else if (index < weekDayOfFirstDayMonth + maxDayInCurrentMonth - 1){
                
                let dayIndex = index - (weekDayOfFirstDayMonth - 1) + 1
                self[index] = date.date(with: dayIndex)
            }
            else {
                let dayIndex = index - (weekDayOfFirstDayMonth + maxDayInCurrentMonth - 1) + 1
                self[index] = nextMonth.date(with: dayIndex)
            }
        }
    }
    
    ///重新加载当月日期
    @objc fileprivate func reloadMonthDayState() -> Void {

        let currentDate = Date()
        
        for index in 0..<CalendarMonthView.maxDaysCount {
            guard let dayView = self.viewWithTag(index + tagBaseValue) as? CalendarDayView else {
                continue
            }
            guard let compareCurrentDayResult = dayView.date?.compareDay(other: currentDate) else {
                continue
            }
            guard let compareCurrentMonthResult = dayView.date?.compareMonth(other: currentDate) else {
                continue
            }
            guard let compareShowMonthResult = dayView.date?.compareMonth(other: self.date) else {
                continue
            }
            
            if compareCurrentDayResult == .orderedSame {
                dayView.dayState = .current(current: compareShowMonthResult == .orderedSame)
            }
            else if compareCurrentDayResult == .orderedAscending {
                dayView.dayState = .invalid(pastMonth: compareCurrentMonthResult == .orderedAscending)
                continue
            }
            else {
                dayView.dayState = .future(previous: (compareShowMonthResult == .orderedAscending), current: (compareShowMonthResult == .orderedSame), future: (compareShowMonthResult == .orderedDescending))
            }
            
            if startDate == nil {
                continue
            }
            
            let compareToStart = dayView.date!.compareDay(other: startDate!)
            if compareToStart == .orderedSame {
                dayView.dayState = .start(hasEnd: (endDate != nil))
                continue
            }
            
            if endDate == nil {
                continue
            }
            
            let compareToEnd = dayView.date!.compareDay(other: endDate!)
            if compareToEnd == .orderedSame {
                dayView.dayState = .end
                continue
            }
            
            if compareToStart == .orderedDescending && compareToEnd == .orderedAscending {
                dayView.dayState = .selected
            }
        }
    }
    
    @objc fileprivate func didStartAndMove(with recognizer: UIPanGestureRecognizer) -> Void{
        let state = recognizer.state
        let width = frame.width / CGFloat(maxDayInWeek)
        let height = frame.height / CGFloat(maxWeekInMonth)
        
        if state == .began {
            startDate = nil
            endDate = nil
        }
        
        let point = recognizer.location(in: self)
        let current_col = Int(point.x / width)
        let current_row = Int(point.y / height)
        if current_row * maxDayInWeek + current_col >= CalendarMonthView.maxDaysCount || current_row * maxDayInWeek + current_col < 0 {
            return
        }
        
        let dayView = self[current_row,current_col]
        ///dayView上有效的触摸范围
        let start_x = current_col * width + width * 0.5 - 10
        let start_y = current_row * height + height * 0.5 - 10
        let validRect = CGRect(x: start_x, y: start_y, width: 20, height: 20)
        
        if validRect.contains(point) {
            switch dayView.dayState {
            case .invalid(_):
                break
            default:
                if startDate == nil {
                    startDate = dayView.date
                }
                else if endDate == nil {
                    let compareStart = startDate!.compareDay(other: dayView.date!)
                    if compareStart == .orderedSame {
                        break
                    }
                    
                    endDate = dayView.date
                }
                else {
                    let compareStart = startDate!.compareDay(other: dayView.date!)
                    let compareEnd = endDate!.compareDay(other: dayView.date!)
                    
                    if compareStart == .orderedDescending {
                        endDate = startDate
                        startDate = dayView.date
                    }
                    else if compareStart == .orderedAscending {
                        endDate = dayView.date
                    }
                    else if compareEnd == .orderedSame {
                        break
                    }
                }
                
                self.reloadMonthDayState()
            }
        }
                
        if state == .ended {
            self.completeSelected()
        }
    }
    
    fileprivate func completeSelected() -> Void {
        if startDate == nil {
            return
        }
        
        self.delegate?.calendarDidSelected(start: startDate!, end: endDate)
    }
}

extension CalendarMonthView: CalendarDayViewDelegate {

    func calendarDidClicked(with dayView: CalendarDayView) {
        
        print("用户点击日期：" + (dayView.date?.toString(format: "yyyy-MM-dd") ?? "日期错误"))
        
        if startDate == nil {
            startDate = dayView.date
        }
        else if endDate == nil {
            let compareResult = startDate!.compareDay(other: dayView.date!)
            if compareResult == .orderedDescending {
                endDate = startDate
                startDate = dayView.date
            }
            else if compareResult != .orderedSame {
                endDate = dayView.date
            }
            
            self.completeSelected()
        }
        else {
            startDate = dayView.date
            endDate = nil
        }

        self.reloadMonthDayState()
    }
}


extension Date {

    func toString(format: String) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        dateFormat.timeZone = TimeZone(secondsFromGMT: 8 * 3600)
        
        return dateFormat.string(from: self)
    }
    
    func compareMonth(other: Date) -> ComparisonResult {
        let components1 = CalendarView.calendar.dateComponents([.year,.month,.day], from: self)
        let components2 = CalendarView.calendar.dateComponents([.year,.month,.day], from: other)
        
        if components1.year! > components2.year! {
            return .orderedDescending
        }
        if components1.year! < components2.year! {
            return .orderedAscending
        }
        
        if components1.month! > components2.month! {
            return .orderedDescending
        }
        if components1.month! < components2.month! {
            return .orderedAscending
        }
        
        return .orderedSame
    }
    
    func compareDay(other: Date) -> ComparisonResult {
        let components1 = CalendarView.calendar.dateComponents([.year,.month,.day], from: self)
        let components2 = CalendarView.calendar.dateComponents([.year,.month,.day], from: other)
        
        if components1.year! > components2.year! {
            return .orderedDescending
        }
        if components1.year! < components2.year! {
            return .orderedAscending
        }
        
        if components1.month! > components2.month! {
            return .orderedDescending
        }
        if components1.month! < components2.month! {
            return .orderedAscending
        }
        
        if components1.day! > components2.day! {
            return .orderedDescending
        }
        if components1.day! < components2.day! {
            return .orderedAscending
        }
        
        return .orderedSame
    }
    
    ///返回指定序号的当月日期
    func date(with dayOrdinal: Int) -> Date? {
        
        let maxDayRange = CalendarView.calendar.range(of: .day, in: .month, for: self)
        
        if maxDayRange!.upperBound <= dayOrdinal {
            return nil
        }
        
        let currentDayOrdinal = CalendarView.calendar.ordinality(of: .day, in: .month, for: self)
        
        return CalendarView.calendar.date(byAdding: .day, value: (dayOrdinal - currentDayOrdinal!), to: self)
    }
}

extension String {
    
    func toDate() -> Date? {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = self
        dateFormat.timeZone = TimeZone(secondsFromGMT: 8 * 3600)
        
        return dateFormat.date(from: self)
    }
}
