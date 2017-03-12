//
//  MyDateTime.swift
//  money
//
//  Created by KES on 2017. 3. 12..
//  Copyright © 2017년 es. All rights reserved.
//

import UIKit

class MyDateTime {
    var myDispFormat: String
    
    init(locale: String) {
        if (locale == "ko_KR") {
            self.myDispFormat = "yyyy년MM월dd일(E)"
        } else {
            self.myDispFormat = "yyyy년MM월dd일(E)"
        }
    }
    
    // 현재시간을 display용으로 변환
    func nowForDisplay() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.myDispFormat
        return dateFormatter.string(from: date)
    }
    
    // display용 날짜를 db용으로 변환
    func dateForDB(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.myDispFormat
        let dateForDisplay = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: dateForDisplay!)
    }
    
    // db용 날짜를 display용으로 변환
    func dateForDisplay(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateForDB = dateFormatter.date(from: date)
        dateFormatter.dateFormat = self.myDispFormat
        return dateFormatter.string(from: dateForDB!)
    }
    
    // picker용(String to Date)
    func dateForPicker(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.myDispFormat
        return dateFormatter.date(from: date)!
    }
    
    // picker용(Date to String)
    func dateForPicker(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.myDispFormat
        return dateFormatter.string(from: date)
    }
}
