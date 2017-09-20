//
//  IETransInfoDelegate.swift
//  money
//
//  Created by KES on 2017. 9. 14..
//  Copyright © 2017년 es. All rights reserved.
//

import Foundation
import UIKit

protocol IETransInfoDelegate: class {
    
    //func addTransInfo(transInfo: TransInfo)
    
    func showTransMns(_ sender: UITextField)
    
    func showTransClssf(_ sender: UITextField)
    
    func updateIncTxtTransMns(transMns: [String])
    
    func cancelIncTxtTransMns()
    
    func updateIncTxtTransClssf(transClssfL2: [String], transClssfL3: [String])
    
    func cancelIncTxtTransClssf()
    
    func updateExpTxtTransMns(transMns: [String])
    
    func cancelExpTxtTransMns()
    
    func updateExpTxtTransClssf(transClssfL2: [String], transClssfL3: [String])
    
    func cancelExpTxtTransClssf()
    
    func focusIncTxtTransCntnt()
    
    func focusExpTxtTransCntnt()
    
    func getIncTransInfo() -> TransInfo
    
    func getExpTransInfo() -> TransInfo

}
