//
//  ViewController.swift
//  CalendarSwift
//
//  Created by edianzu on 2017/5/31.
//  Copyright © 2017年 LCY. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var dateLabel: UILabel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRect(x: 20, y: 100, width: 60, height: 30))
        label.text = "选择日期:"
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13.0)
        self.view.addSubview(label)
        
        let dateLabel = UILabel(frame: CGRect(x: 100, y: 100, width: 200, height: 30))
        dateLabel.text = ""
        dateLabel.textColor = UIColor.black
        dateLabel.textAlignment = .left
        dateLabel.font = UIFont.systemFont(ofSize: 13.0)
        dateLabel.isUserInteractionEnabled = true
        self.dateLabel = dateLabel
        self.view.addSubview(dateLabel)
        
        let line = UIView(frame: CGRect(x: 90, y: 130, width: 210, height: 1))
        line.backgroundColor = UIColor.gray
        self.view.addSubview(line)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.showCalendar))
        dateLabel.addGestureRecognizer(gestureRecognizer)
    }

    
    func showCalendar() -> Void {
        let calendarView = CalendarView { (start, end) in
            self.dateLabel?.text = start.toString(format: "yyyy-MM-dd") + " - " + end.toString(format: "yyyy-MM-dd")
        }
        calendarView.show()
    }
}

