//
//  IEAddIncViewController.swift
//  money
//
//  Created by KES on 2017. 9. 13..
//  Copyright © 2017년 es. All rights reserved.
//

import UIKit

class IEAddIncViewController: UITableViewController, UITextFieldDelegate {
    weak var delegate: IETransInfoDelegate?
    var transInfo: TransInfo?
    
    @IBOutlet weak var txtTransCntnt: UITextField!
    @IBOutlet weak var txtTransAmt: UITextField!
    @IBOutlet weak var txtTransMns: UITextField!
    @IBOutlet weak var txtTransClssf: UITextField!
    @IBOutlet weak var txvTransMmo: UITextView!
    @IBOutlet weak var txtTransMnsCd: UITextField!
    @IBOutlet weak var txtTransClssfL2Cd: UITextField!
    @IBOutlet weak var txtTransClssfL3Cd: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor(red: 186/255, green: 186/255, blue: 186/255, alpha: 1.0).cgColor
        txvTransMmo.layer.borderColor = color
        txvTransMmo.layer.borderWidth = 0.5
        txvTransMmo.layer.cornerRadius = 5
        
        // olny number
        txtTransAmt.delegate = self
    }
    

    @IBAction func editingDidBeginTxtTransMns(_ sender: UITextField) {
        delegate?.showTransMns(sender)
    }
    
    @IBAction func editingDidBeginTxtTransClssf(_ sender: UITextField) {
        delegate?.showTransClssf(sender)
    }
        
    func updateTxtTransMns(transMns: [String]) {
        if transMns[0] != "00000" && !(transMns[0].isEmpty) {
            txtTransMns.text = transMns[1] // 이름
            txtTransMnsCd.text = transMns[0] // 코드
        
            hideTransMns()
        }
    }
    
    func hideTransMns() {
        txtTransMns.resignFirstResponder()
    }
    
    func updateTxtTransClssf(transClssfL2: [String], transClssfL3: [String]) {
        if transClssfL2[0] != "00000" && !(transClssfL2[0].isEmpty) {
            if transClssfL3[0] == "000000000" || (transClssfL3[0].isEmpty) {
                txtTransClssf.text = transClssfL2[1]
            } else {
                txtTransClssf.text = transClssfL2[1] + " > " + transClssfL3[1]
            }
            txtTransClssfL2Cd.text = transClssfL2[0]
            txtTransClssfL3Cd.text = transClssfL3[0]
        
            hideTransClssf()
        }
    }
    
    func hideTransClssf() {
        txtTransClssf.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
