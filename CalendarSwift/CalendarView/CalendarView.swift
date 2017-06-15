//
//  CalendarView.swift
//  CalendarSwift
//
//  Created by edianzu on 2017/5/31.
//  Copyright © 2017年 LCY. All rights reserved.
//

import UIKit

class CalendarView: UIView {

    static let calendar = Calendar(identifier: .gregorian)
    
    fileprivate var date = Date()
    fileprivate weak var monthView: CalendarMonthView!
    fileprivate weak var titleView: CalendarTitleView!
    var didCompleteSelected: ((Date, Date) -> Void)?
    
    ///
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let backGroundView = UIView(frame: frame)
        backGroundView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CalendarView.hiddenCalendar))
        backGroundView.addGestureRecognizer(gestureRecognizer)
        self.addSubview(backGroundView)
        
        let contentView = UIView(frame: CGRect(x: 25, y: (frame.height - 300) * 0.5, width: frame.width - 25 * 2, height: 315))
        contentView.backgroundColor = UIColor.white
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 8.0
        self.addSubview(contentView)
        
        let titleView = CalendarTitleView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 40))
        self.titleView = titleView
        titleView.title = date.toString(format: "yyyy年MM月")
        contentView.addSubview(titleView)
        
        let edgeMargin: CGFloat = 15.0
        let weekTitles = ["日","一","二","三","四","五","六"]
        let weekTitleView = CalendarWeekTitleView(titles: weekTitles, frame: CGRect(x: edgeMargin, y: titleView.frame.height, width: contentView.frame.width - 2 * edgeMargin, height: 35))
        contentView.addSubview(weekTitleView)
        
        let topMargin = (titleView.frame.height + weekTitleView.frame.height)
        let height = contentView.frame.height - topMargin - 10
        let monthView = CalendarMonthView(date: date, frame: CGRect(x: edgeMargin, y: topMargin, width: contentView.frame.width - edgeMargin * 2.0, height: height))
        monthView.delegate = self
        self.monthView = monthView
        contentView.addSubview(monthView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CalendarView.receiveChangedMonthNotification(note:)), name: .LCYCalendarDidChangedMonthNotification, object: nil)
    }

    convenience init( didSelected: @escaping (Date, Date) -> Void) {
        self.init(frame: UIScreen.main.bounds)
        self.didCompleteSelected = didSelected
    }
    
    @objc fileprivate func receiveChangedMonthNotification(note: Notification) {
        
        guard note.userInfo?[LCYCalendarMonthChangedObjectKey] != nil else {
            return
        }
        
        let isNextMonth: Bool = note.userInfo![LCYCalendarMonthChangedObjectKey]! as! Bool
        
        let calendar = Calendar(identifier: .gregorian)
        
        if isNextMonth {
            self.date = (calendar.date(byAdding: .month, value: 1, to: date)!)
        }
        else {
            self.date = (calendar.date(byAdding: .month, value: -1, to: date)!)
        }
    
        self.monthView.changedDate(with: self.date)
        self.titleView.title = self.date.toString(format: "yyyy年MM月")
    }
    
    func show() -> Void {
        let keyWindow = UIApplication.shared.keyWindow
        self.alpha = 0.0
        keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.3) { 
            self.alpha = 1.0
        }
    }
    
    func hiddenCalendar() -> () {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}

extension CalendarView: CalendarMonthViewDelegate {
    func calendarDidSelected(start: Date, end: Date?) {
        
        var endDate = end
        
        if end == nil {
            endDate = start
        }
        
        self.didCompleteSelected?(start,endDate!)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 2)) {
            self.hiddenCalendar()
        }
    }
}
