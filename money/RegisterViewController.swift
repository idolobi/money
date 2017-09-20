//
//  RegisterViewController.swift
//  money
//
//  Created by KES on 2017. 2. 5..
//  Copyright © 2017년 es. All rights reserved.
//

import UIKit

//
//  사용하지 않음 2017. 9. 19..
//
class RegisterViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let myLocale = "ko_KR"
    
    var databasePath = String()
    
    @IBOutlet weak var txtTransDt: UITextField!
    @IBOutlet weak var sgmTransSlctn: UISegmentedControl!
    @IBOutlet weak var txtTransCntnt: UITextField!
    @IBOutlet weak var txtTransMns: UITextField!
    @IBOutlet weak var txtTransAmt: UITextField!
    @IBOutlet weak var tvwMemo: UITextView!
    @IBOutlet weak var txtTransSlctn: UITextField!
    
    var datePicker: UIDatePicker!
    var textPickerTransMns: UIPickerView? //계좌(결제수단)
    var textPickerTransSlctn: UIPickerView? //분류
    //var pickerData = [["000", "선택"]] //기본 값
    var pickerTransMns = [["000", "선택"]]
    var pickerTransSlctn = [[["000", "선택"], ["001", "용돈"], ["002", "생활비"], ["003", "쇼핑"], ["004", "문화"]], [["00", "선택"]]]
    var slctdPickerDataTransMns = ["", ""] //선택된 값
    var slctdPickerDataTransSlctnL1 = ["", ""]
    var slctdPickerDataTransSlctnL2 = ["", ""]
    
    var transMnsCd: String!
    var transSlctnL1: String!
    var transSlctnL2: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("로그 : RegisterViewController viewDidLoad() 시작")
        
        let myDateTime = MyDateTime(locale: self.myLocale)
        let strDate = myDateTime.nowForDisplay()
        txtTransDt.text = strDate
        
        sgmTransSlctn.selectedSegmentIndex = 1
        
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        tvwMemo.layer.borderColor = borderColor.cgColor
        tvwMemo.layer.borderWidth = 0.5
        tvwMemo.layer.cornerRadius = 5.0
        //tvwMemo.text = "메모"
        //tvwMemo.textColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        
        let bundle = Bundle.main
        databasePath = bundle.path(forResource: "money", ofType: "db")!
        
        let fileMgr = FileManager.default
        //let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        //databasePath = dirPaths[0].appendingPathComponent("money.db").path
        
        NSLog("로그 : RegisterViewController DB 파일 위치 세팅(" + databasePath + ")")
        
        if fileMgr.fileExists(atPath: databasePath as String) {
            let db = FMDatabase(path: databasePath as String)
            
            if db == nil {
                NSLog("DB 생성 오류")
            }
            
            if ((db?.open()) != nil) {
                let sqlTransMns = "select trans_mns_cd, trans_mns_nm from trans_mns order by trans_mns_cd"
                let resultData: FMResultSet? = db?.executeQuery(sqlTransMns, withArgumentsIn: nil)
                if (resultData != nil) {
                    var transMnsCd: String = ""
                    var transMnsNm: String = ""
                    
                    while resultData!.next() {
                        transMnsCd = resultData!.string(forColumn: "trans_mns_cd")!
                        transMnsNm = resultData!.string(forColumn: "trans_mns_nm")!
                        NSLog("불러온 값 : \(transMnsCd) | \(transMnsNm)")
                        pickerTransMns.append([transMnsCd, transMnsNm])
                    }
                } else {
                    NSLog("DB 조회 결과 없음")
                }
                db?.close()
            } else {
                NSLog("DB 연결 오류")
            }
        }
        NSLog("로그 : RegisterViewController viewDidLoad() 종료")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 저장
    @IBAction func saveTrans(_ sender: UIBarButtonItem) {
        let db = FMDatabase(path: databasePath as String)
        
        let myDateTime = MyDateTime(locale: self.myLocale)
        let strDt = myDateTime.dateForDB(date: txtTransDt.text!)
        NSLog(strDt)
        
        if ((db?.open()) != nil) {
            let sqlTransInfo = "insert into trans_info(usr_id, bnkac_id, trans_dt, trans_tm, pay_trans_mns_cd, trans_div_cd, trans_cntnt, trans_amt) values('snooper', '001', '\(strDt)', '000000', '\(transMnsCd!)', '1', '\(txtTransCntnt.text!)', '\(txtTransAmt.text!)')"
            db?.executeUpdate(sqlTransInfo, withArgumentsIn: nil)
            
            if (db?.hadError())! {
                NSLog("저장 오류 \(sqlTransInfo)")
            } else {
                NSLog("저장 성공 \(sqlTransInfo)")
            }
            db?.close()
        } else {
            NSLog("DB 연결 오류")
        }
    }
    
    // 데이트
    @IBAction func bgnEditTransDt(_ sender: UITextField) {
        sender.tintColor = UIColor.clear
        pickUpDate(sender)
        let myDateTime = MyDateTime(locale: self.myLocale)
        datePicker.date = myDateTime.dateForPicker(date: txtTransDt.text!)
    }
    
    // 결제수단
    @IBAction func bgnEditTransMns(_ sender: UITextField) {
        //pickerData = pickerTransMns //["선택", "현금", "신한카드", "신한체크", "하나체크"]
        pickUpTextTransMns(sender)
    }
    
    // 선택
    @IBAction func bgnEditTransSlctn(_ sender: UITextField) {
        //pickerData = [["선택", "용돈", "생활비", "쇼핑", "문화"], ["A", "B", "C"]]
        pickUpTextTransSlctn(sender)
    }
    
    // 이게 뭐였지?
    @IBAction func chgTransSlctn(_ sender: UISegmentedControl) {
        switch sgmTransSlctn.selectedSegmentIndex {
        case 0:
            print("First")
        case 1:
            print("Second")
        case 2:
            print("third")
        default:
            print("Default")
        }
    }
    
    // 메모
    func textViewDidBeginEditing(_ textView: UITextView) {
        /*
        if textView.text == "메모" {
            textView.text = ""
        }
        textView.resignFirstResponder()
        */
    }
    
    // 메모
    func textViewDidEndEditing(_ textView: UITextView) {
        /*
        if textView.text == "" {
            textView.text = "메모"
            textView.textColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        }
        textView.resignFirstResponder()
        */
    }
    
    // 원본출처(https://iosdevcenters.blogspot.com/2016/03/ios9-uidatepicker-example-with.html)
    // 데이트픽커 보임
    func pickUpDate(_ sender: UITextField) {
        datePicker = UIDatePicker(frame:CGRect(x:0, y:0, width:self.view.frame.size.width, height:216))
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.init(identifier: "ko_KR") // 선택 가능해야 함
        
        sender.inputView = datePicker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(doneClick)) // 선택
        let leftSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let todayButton = UIBarButtonItem(title: "오늘", style: .plain, target: self, action: #selector(todayClick)) // 오늘
        let rightSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelClick)) // 취소
        toolBar.setItems([cancelButton, leftSpaceButton, todayButton, rightSpaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        sender.inputAccessoryView = toolBar
    }
    
    // 원본출처(https://iosdevcenters.blogspot.com/2016/03/ios9-uidatepicker-example-with.html)
    // 데이트픽커 완료 버튼 선택시
    func doneClick() {
        let myDateTime = MyDateTime(locale: self.myLocale)
        txtTransDt.text = myDateTime.dateForPicker(date: datePicker.date)
        txtTransDt.resignFirstResponder()
    }
    
    // 데이트픽커 오늘 버튼 선택시
    func todayClick() {
        datePicker.date = Date()
    }
    
    // 원본출처(https://iosdevcenters.blogspot.com/2016/03/ios9-uidatepicker-example-with.html)
    // 데이트픽커 취소 버튼 선택시
    func cancelClick() {
        txtTransDt.resignFirstResponder()
    }
    
    // 결제수단 픽커
    func pickUpTextTransMns(_ sender: UITextField) {
        textPickerTransMns = UIPickerView(frame:CGRect(x:0, y:0, width:self.view.frame.size.width, height:216))
        textPickerTransMns?.backgroundColor = .white
        textPickerTransMns?.showsSelectionIndicator = true
        textPickerTransMns?.delegate = self
        textPickerTransMns?.dataSource = self
        
        sender.inputView = textPickerTransMns
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(doneTextTransMnsPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelTextTransMnsPicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        sender.inputAccessoryView = toolBar
    }
    
    // 결제수단 선택
    func doneTextTransMnsPicker() {
        // 코드를 저장하기 위한 텍스트 박스 필요
        transMnsCd = slctdPickerDataTransMns[0]
        txtTransMns.text = slctdPickerDataTransMns[1]
        txtTransMns.resignFirstResponder()
    }
    
    // 결제수단 선택 취소
    func cancelTextTransMnsPicker() {
        txtTransMns.resignFirstResponder()
    }
    
    // TransSlctn
    func pickUpTextTransSlctn(_ sender: UITextField) {
        textPickerTransSlctn = UIPickerView(frame:CGRect(x:0, y:0, width:self.view.frame.size.width, height:216))
        textPickerTransSlctn?.backgroundColor = .white
        textPickerTransSlctn?.showsSelectionIndicator = true
        textPickerTransSlctn?.delegate = self
        textPickerTransSlctn?.dataSource = self
        
        sender.inputView = textPickerTransSlctn
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(doneTextTransSlctnPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelTextTransSlctnPicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        sender.inputAccessoryView = toolBar
    }
    
    // TransSlctn
    func doneTextTransSlctnPicker() {
        // 코드를 저장하기 위한 텍스트 박스 필요
        transSlctnL1 = slctdPickerDataTransSlctnL1[0]
        transSlctnL2 = slctdPickerDataTransSlctnL2[1]
        txtTransSlctn.text = slctdPickerDataTransSlctnL1[1] + " > " + slctdPickerDataTransSlctnL2[1]
        txtTransSlctn.resignFirstResponder()
    }
    
    // TransSlctn
    func cancelTextTransSlctnPicker() {
        txtTransSlctn.resignFirstResponder()
    }
    
    // 픽커 공통
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        var num: Int = 1
        if pickerView == textPickerTransMns {
            num = 1
        } else if pickerView == textPickerTransSlctn {
            num = 2
        }
        return num
    }
    
    // 픽커 공통
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var cnt: Int = 0
        if pickerView == textPickerTransMns {
            cnt = pickerTransMns.count
        } else if pickerView == textPickerTransSlctn {
            cnt = pickerTransSlctn[component].count
        }
        return cnt
    }
 
    // 픽커 공통
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var value = ""
        if pickerView == textPickerTransMns {
            value = pickerTransMns[row][1]
        } else if pickerView == textPickerTransSlctn {
            value = pickerTransSlctn[component][row][1]
        }
        return value
    }
    
    // 픽커 공통
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == textPickerTransMns {
            slctdPickerDataTransMns = pickerTransMns[row]
            NSLog("선택된 값 : \(pickerTransMns[row])")
        } else if pickerView == textPickerTransSlctn {
            if component == 0 {
                slctdPickerDataTransSlctnL1 = pickerTransSlctn[component][row]
                if slctdPickerDataTransSlctnL1[0] == "001" {
                    pickerTransSlctn = [[["000", "선택"], ["001", "용돈"], ["002", "생활비"], ["003", "쇼핑"], ["004", "문화"]], [["00", "선택"], ["01", "선택1"], ["02", "선택2"]]]
                    self.textPickerTransSlctn?.reloadAllComponents()
                } else {
                    pickerTransSlctn = [[["000", "선택"], ["001", "용돈"], ["002", "생활비"], ["003", "쇼핑"], ["004", "문화"]], [["00", "선택"]]]
                    self.textPickerTransSlctn?.reloadAllComponents()
                }
            }
            if component == 1 {
                slctdPickerDataTransSlctnL2 = pickerTransSlctn[component][row]
            }
            NSLog("선택된 값 : \(component), \(row), \(pickerTransSlctn[component][row])")
        }
        
    }
}
