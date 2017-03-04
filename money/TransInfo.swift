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
    var payTransMnsCd: String = ""
    var transCntnt: String = ""
    //var transAmt: Int32 = 0
    var transAmt: String = "0"
    
    init(transDt:String, transTm: String, payTransMnsCd: String, transCntnt: String, transAmt: String) {
        self.transDt = transDt
        self.transTm = transTm
        self.payTransMnsCd = payTransMnsCd
        self.transCntnt = transCntnt
        self.transAmt = transAmt
    }
}
