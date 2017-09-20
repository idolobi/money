//
//  TransInfo.swift
//  money
//
//  Created by KES on 2017. 1. 21..
//  Copyright © 2017년 es. All rights reserved.
//

import UIKit

class TransInfo {
    var transDt: String = ""
    var transTm: String = "000000"
    var transCntnt: String = ""
    var transAmt: String = "0"
    var transMnsCds: [String] = []
    var transMnsNm: String = ""
    var transClssfCds: [String] = []
    var transClssfNm: String = ""
    var transMmo: String = ""
    
    init(transDt:String, transTm: String, transCntnt: String, transAmt: String, transMnsCds: [String], transClssfCds: [String], transMmo: String) {
        self.transDt = transDt
        self.transTm = transTm
        self.transCntnt = transCntnt
        self.transAmt = transAmt
        self.transMnsCds = transMnsCds
        self.transClssfCds = transClssfCds
        self.transMmo = transMmo
    }
    
    func isValidTransCntnt() -> Bool {
        NSLog("transCntnt : \(self.transCntnt), transCntntLength : \(self.transCntnt.characters.count)")
        var isValid = false
        if self.transCntnt.characters.count <= 50 && self.transCntnt.characters.count > 0 { // 50글자
            isValid = true
        }
        return isValid
    }
    
    func isValidTransAmt() -> Bool {
        var isValid = false
        if self.transAmt.characters.count <= 20 && self.transAmt.characters.count > 0 { // 100,000,000,000,000,000,000
            isValid = true
        }
        return isValid
    }
    
    func isValidTransMnsCds() -> Bool {
        var isValid = false
        if self.transMnsCds[0].characters.count == 5 {
            isValid = true
        }
        return isValid
    }
    
    func isValidTransClssfCds() -> Bool {
        var isValid = false
        if self.transClssfCds[0].characters.count == 2
            && self.transClssfCds[1].characters.count == 5
            && self.transClssfCds[2].characters.count == 9 {
            isValid = true
        }
        return isValid
    }
    
    func isValidTransMmo() -> Bool {
        var isValid = false
        if self.transMmo.characters.count <= 4000 { // 4000글자
            isValid = true
        }
        return isValid
    }
}
