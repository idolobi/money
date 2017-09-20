//
//  IEAddViewController.swift
//  money
//
//  Created by KES on 2017. 9. 13..
//  Copyright © 2017년 es. All rights reserved.
//

import UIKit

class IEAddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var ieAddIncVC: IEAddIncViewController?
    var ieAddExpVC: IEAddExpViewController?
    var recTransInfo: TransInfo?
    
    let myLocale = "ko_KR"
    var databasePath = String()
    var datePicker: UIDatePicker!
    var textPickerTransMns: UIPickerView? //계좌(결제수단)
    var textPickerTransClssf: UIPickerView? //분류
    var pickerTransMns: [[String]] = [["00000", "선택"]]
    var pickerTransClssf: [[[String]]] = [[["00000", "선택"]], [["000000000", "선택"]]]
    var slctdPickerDataTransMns = ["", ""] //선택된 값
    var slctdPickerDataTransClssfL2 = ["", ""]
    var slctdPickerDataTransClssfL3 = ["", ""]
    var transClssfL2: String!
    var transClssfL3: String!
    var l1Cd: String = "00"
    
    @IBOutlet weak var txtTransDt: UITextField!
    @IBOutlet weak var sgmTransSlctn: UISegmentedControl!
    @IBOutlet weak var cntTransInc: UIView!
    @IBOutlet weak var cntTransExp: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 오늘 날짜!!!
        let myDateTime = MyDateTime(locale: "ko_KR")
        let strDate = myDateTime.nowForDisplay()
        txtTransDt.text = strDate
        
        // 초기 선택은 지출!!!
        sgmTransSlctn.selectedSegmentIndex = 1
        cntTransInc.isHidden = true
        cntTransExp.isHidden = false
        l1Cd = "02"
        
        // database
        let bundle = Bundle.main
        databasePath = bundle.path(forResource: "money", ofType: "db")!
        
        let fileMgr = FileManager.default
        if fileMgr.fileExists(atPath: databasePath as String) {
            let db = FMDatabase(path: databasePath as String)
            if db == nil {
                NSLog("MONEY DB를 찾을 수 없음")
            } else {
                if ((db?.open()) != nil) {
                    // sql - transMns
                    let sqlTransMns = "" +
                        "select trans_mns_cd " +
                        "     , trans_mns_nm " +
                        "  from trans_mns " +
                        " where use_yn = 'Y' " +
                        "   and use_bgn_tstmp <= strftime('%Y%m%d%H%M%S')" +
                        "   and use_end_tstmp >= strftime('%Y%m%d%H%M%S')" +
                        " order by sort_ord_num"
                    let resultTransMnsData: FMResultSet? = db?.executeQuery(sqlTransMns, withArgumentsIn: nil)
                    if (resultTransMnsData != nil) {
                        var transMnsCd: String = ""
                        var transMnsNm: String = ""
                        while resultTransMnsData!.next() {
                            transMnsCd = resultTransMnsData!.string(forColumn: "trans_mns_cd")!
                            transMnsNm = resultTransMnsData!.string(forColumn: "trans_mns_nm")!
                            NSLog("결재수단 불러온 값 : [\(transMnsCd), \(transMnsNm)]")
                            pickerTransMns.append([transMnsCd, transMnsNm])
                        }
                    } else {
                        NSLog("거래수단 조회 결과 없음")
                    }
                    
                    // sql - transClssf
                    let sqlTransClssf = "" +
                        "select y.l2_cd as l2_cd " +
                        "     , y.l2_nm as l2_nm " +
                        "  from (select l2.cm_dtl_cd as l2_cd " +
                        "             , l2.cm_dtl_cd_nm as l2_nm " +
                        "             , l2.clm_1_cd_val as l1_cd " +
                        "          from cm_dtl_cd l2 " +
                        "         where l2.cm_cd = 'CM003' and l2.use_yn = 'Y' " +
                        "           and l2.use_bgn_tstmp <= strftime('%Y%m%d%H%M%S') " +
                        "           and l2.use_end_tstmp >= strftime('%Y%m%d%H%M%S') " +
                        "           and l2.clm_2_cd_val = 'L2' and l2.clm_1_cd_val = '\(l1Cd)' " +
                        "         order by l2.sort_ord_num) y "
                    let resultTransClssfData: FMResultSet? = db?.executeQuery(sqlTransClssf, withArgumentsIn: nil)
                    if (resultTransClssfData != nil) {
                        var pickerTransClssfL2: [[String]] = [["00000", "선택"]] // 초기화
                        let pickerTransClssfL3: [[String]] = [["000000000", "선택"]] // 초기화
                        while resultTransClssfData!.next() {
                            let transClssfL2Cd: String = resultTransClssfData!.string(forColumn: "l2_cd")!
                            let transClssfL2Nm: String = resultTransClssfData!.string(forColumn: "l2_nm")!
                            pickerTransClssfL2.append([transClssfL2Cd, transClssfL2Nm])
                        }
                        pickerTransClssf[0] = pickerTransClssfL2
                        pickerTransClssf[1] = pickerTransClssfL3
                    } else {
                        NSLog("분류 조회 결과 없음")
                    }
                    db?.close() // db close
                } else {
                    NSLog("DB 연결 오류")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // for read
        if let viewCtrl = segue.destination as? IEAddIncViewController {
            viewCtrl.delegate = self
        } else if let viewCtrl = segue.destination as? IEAddExpViewController {
            viewCtrl.delegate = self
        }
        // for execute
        if let vc = segue.destination as? IEAddIncViewController {
            ieAddIncVC = vc
        }
        if let vc = segue.destination as? IEAddExpViewController {
            ieAddExpVC = vc
        }
    }
    
    // MARK - 저장
    @IBAction func addTransInfo(_ sender: UIBarButtonItem) {
        switch sgmTransSlctn.selectedSegmentIndex {
        case 0:
            recTransInfo = getIncTransInfo()
        case 1:
            recTransInfo = getExpTransInfo()
        default:
            break
        }
        
        if recTransInfo != nil {
            // validate
            var isValid = true
            if !(recTransInfo!.isValidTransCntnt()) {
                showConfirmAlert(message: "내용을 50글자 이내로 입력해주세요.")
                isValid = false
            }
            
            if !(recTransInfo!.isValidTransAmt()) {
                showConfirmAlert(message: "금액을 입력해주세요.")
                isValid = false
            }
            
            if !(recTransInfo!.isValidTransMnsCds()) {
                showConfirmAlert(message: "계좌를 선택해주세요.")
                isValid = false
            }
            
            if !(recTransInfo!.isValidTransClssfCds()) {
                showConfirmAlert(message: "분류를 선택해주세요.")
                isValid = false
            }
            
            if !(recTransInfo!.isValidTransMmo()) {
                showConfirmAlert(message: "메모가 너무 길어요. 줄여주세요.")
                isValid = false
            }
            
            // 데이터 보정!!!!!!!!
            let myDateTime = MyDateTime(locale: self.myLocale)
            //let strDt = myDateTime.dateForDB(date: recTransInfo!.transDt)
            
            // 여기에 저장 구현
            if isValid {
                let sql = "" +
                    "insert into trans_info ( " +
                    "     usr_id, " +
                    "     bnkac_id, " +
                    "     trans_dt, " +
                    "     trans_tm, " +
                    "     pay_trans_mns_cd, " +
                    "     rcv_trans_mns_cd, " +
                    "     trans_div_cd, " +
                    "     hgh_clssf_cd, " +
                    "     mdl_clssf_cd, " +
                    "     low_clssf_cd, " +
                    "     trans_cntnt, " +
                    "     trans_amt, " +
                    "     sort_ord_num " +
                    ") values ( " +
                    "     'snooper', " +
                    "     '0000000001', " +
                    "     '\(myDateTime.dateForDB(date: recTransInfo!.transDt))', " +
                    "     '\(recTransInfo!.transTm)', " +
                    "     '\(recTransInfo!.transMnsCds[0])', " +
                    "     '\(recTransInfo!.transMnsCds[0])', " +
                    "     '\(recTransInfo!.transClssfCds[0])', " +
                    "     '\(recTransInfo!.transClssfCds[0])', " +
                    "     '\(recTransInfo!.transClssfCds[1])', " +
                    "     '\(recTransInfo!.transClssfCds[2])', " +
                    "     '\(recTransInfo!.transCntnt)', " +
                    "     '\(recTransInfo!.transAmt)', " +
                    "     0 " +
                    ")"
                if insert(dbPath: databasePath, sql: sql) {
                    showConfirmAlert(message: "저장되었습니다.")
                }
            }
        }
    }
    
    @IBAction func bgnEditTransDt(_ sender: UITextField) {
        sender.tintColor = UIColor.clear
        pickUpDate(sender)
        let myDateTime = MyDateTime(locale: self.myLocale)
        datePicker.date = myDateTime.dateForPicker(date: txtTransDt.text!)
    }
    
    @IBAction func changeIncExp(_ sender: Any) {
        switch sgmTransSlctn.selectedSegmentIndex {
        case 0: // 수입
            cntTransInc.isHidden = false
            cntTransExp.isHidden = true
            focusIncTxtTransCntnt() // 초기화
            l1Cd = "01"
        case 1: // 지출
            cntTransInc.isHidden = true
            cntTransExp.isHidden = false
            focusExpTxtTransCntnt() // 초기화
            l1Cd = "02"
        default:
            break;
        }
        
        let fileMgr = FileManager.default
        if fileMgr.fileExists(atPath: databasePath as String) {
            let db = FMDatabase(path: databasePath as String)
            if db == nil {
                NSLog("MONEY DB를 찾을 수 없음")
            } else {
                if ((db?.open()) != nil) {
                    let sqlTransClssf = "" +
                        "select y.l2_cd as l2_cd " +
                        "     , y.l2_nm as l2_nm " +
                        "  from (select l2.cm_dtl_cd as l2_cd " +
                        "             , l2.cm_dtl_cd_nm as l2_nm " +
                        "             , l2.clm_1_cd_val as l1_cd " +
                        "          from cm_dtl_cd l2 " +
                        "         where l2.cm_cd = 'CM003' and l2.use_yn = 'Y' " +
                        "           and l2.use_bgn_tstmp <= strftime('%Y%m%d%H%M%S') " +
                        "           and l2.use_end_tstmp >= strftime('%Y%m%d%H%M%S') " +
                        "           and l2.clm_2_cd_val = 'L2' and l2.clm_1_cd_val = '\(l1Cd)' " +
                    "         order by l2.sort_ord_num) y "
                    let resultTransClssfData: FMResultSet? = db?.executeQuery(sqlTransClssf, withArgumentsIn: nil)
                    if (resultTransClssfData != nil) {
                        var pickerTransClssfL2: [[String]] = [["00000", "선택"]] // 초기화
                        let pickerTransClssfL3: [[String]] = [["000000000", "선택"]] // 초기화
                        while resultTransClssfData!.next() {
                            let transClssfL2Cd: String = resultTransClssfData!.string(forColumn: "l2_cd")!
                            let transClssfL2Nm: String = resultTransClssfData!.string(forColumn: "l2_nm")!
                            pickerTransClssfL2.append([transClssfL2Cd, transClssfL2Nm])
                        }
                        pickerTransClssf[0] = pickerTransClssfL2
                        pickerTransClssf[1] = pickerTransClssfL3
                    } else {
                        NSLog("분류 조회 결과 없음")
                    }
                    db?.close()
                } else {
                    NSLog("DB 연결 오류")
                }
            }
        }
    }
    
    // 원본출처(https://iosdevcenters.blogspot.com/2016/03/ios9-uidatepicker-example-with.html)
    // 데이트픽커 보임
    func pickUpDate(_ sender: UITextField) {
        datePicker = UIDatePicker(frame:CGRect(x:0, y:0, width:self.view.frame.size.width, height:216))
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.init(identifier: self.myLocale) // 선택 가능해야 함
        
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
    
    func pickUpTextTransClssf(_ sender: UITextField) {
        textPickerTransClssf = UIPickerView(frame:CGRect(x:0, y:0, width:self.view.frame.size.width, height:216))
        textPickerTransClssf?.backgroundColor = .white
        textPickerTransClssf?.showsSelectionIndicator = true
        textPickerTransClssf?.delegate = self
        textPickerTransClssf?.dataSource = self
        
        sender.inputView = textPickerTransClssf
        
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
        switch sgmTransSlctn.selectedSegmentIndex {
        case 0:
            updateIncTxtTransClssf(transClssfL2: slctdPickerDataTransClssfL2, transClssfL3: slctdPickerDataTransClssfL3)
        case 1:
            updateExpTxtTransClssf(transClssfL2: slctdPickerDataTransClssfL2, transClssfL3: slctdPickerDataTransClssfL3)
        default:
            break;
        }
    }
    
    // TransClssf
    func cancelTextTransSlctnPicker() {
        switch sgmTransSlctn.selectedSegmentIndex {
        case 0:
            cancelIncTxtTransClssf()
        case 1:
            cancelExpTxtTransClssf()
        default:
            break;
        }
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
        switch sgmTransSlctn.selectedSegmentIndex {
        case 0:
            updateIncTxtTransMns(transMns: slctdPickerDataTransMns)
        case 1:
            updateExpTxtTransMns(transMns: slctdPickerDataTransMns)
        default:
            break;
        }
    }
    
    // 결제수단 선택 취소
    func cancelTextTransMnsPicker() {
        switch sgmTransSlctn.selectedSegmentIndex {
        case 0:
            cancelIncTxtTransMns()
        case 1:
            cancelExpTxtTransMns()
        default:
            break;
        }
    }
    
    // 픽커 공통
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        var num: Int = 1
        if pickerView == textPickerTransMns {
            num = 1
        } else if pickerView == textPickerTransClssf {
            num = 2
        }
        return num
    }
    
    // 픽커 공통
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var cnt: Int = 0
        if pickerView == textPickerTransMns {
            cnt = pickerTransMns.count
        } else if pickerView == textPickerTransClssf {
            cnt = pickerTransClssf[component].count
        }
        return cnt
    }
    
    // 픽커 공통
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var value = ""
        if pickerView == textPickerTransMns {
            value = pickerTransMns[row][1]
        } else if pickerView == textPickerTransClssf {
            value = pickerTransClssf[component][row][1]
        }
        return value
    }
    
    // 픽커 공통 - 선택
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == textPickerTransMns {
            slctdPickerDataTransMns = pickerTransMns[row]
            NSLog("선택된 값 : [\(component), \(row)], \(pickerTransMns[component][row])")
        } else if pickerView == textPickerTransClssf {
            switch component {
            case 0: // L2 선택
                slctdPickerDataTransClssfL2 = pickerTransClssf[component][row]
                // 세팅
                let fileMgr = FileManager.default
                if fileMgr.fileExists(atPath: databasePath as String) {
                    let db = FMDatabase(path: databasePath as String)
                    if db == nil {
                        NSLog("MONEY DB를 찾을 수 없음")
                    } else {
                        if ((db?.open()) != nil) {
                            let sqlTransClssf = "" +
                                "select z.l3_cd as l3_cd " +
                                "     , z.l3_nm as l3_nm " +
                                "  from (select l3.cm_dtl_cd as l3_cd " +
                                "             , l3.cm_dtl_cd_nm as l3_nm " +
                                "             , l3.clm_1_cd_val " +
                                "          from cm_dtl_cd l3 " +
                                "         where l3.cm_cd = 'CM003' and l3.use_yn = 'Y' " +
                                "           and l3.use_bgn_tstmp <= strftime('%Y%m%d%H%M%S') " +
                                "           and l3.use_end_tstmp >= strftime('%Y%m%d%H%M%S') " +
                                "           and l3.clm_1_cd_val = '\(slctdPickerDataTransClssfL2[0])' " +
                                "           and l3.clm_2_cd_val = 'L3' " +
                            "         order by l3.sort_ord_num) z "
                            let resultTransClssfData: FMResultSet? = db?.executeQuery(sqlTransClssf, withArgumentsIn: nil)
                            var pickerTransClssfL3: [[String]] = [["000000000", "선택"]] // 초기화
                            if (resultTransClssfData != nil) {
                                while resultTransClssfData!.next() {
                                    let transClssfL3Cd: String = resultTransClssfData!.string(forColumn: "l3_cd")!
                                    let transClssfL3Nm: String = resultTransClssfData!.string(forColumn: "l3_nm")!
                                    pickerTransClssfL3.append([transClssfL3Cd, transClssfL3Nm])
                                }
                            }
                            pickerTransClssf[1] = pickerTransClssfL3
                            db?.close()
                        } else {
                            NSLog("MONEY DB 연결 오류")
                        }
                    }
                }
                self.textPickerTransClssf?.reloadAllComponents()
                slctdPickerDataTransClssfL3 = pickerTransClssf[1][0] // L3 선택 초기화(L2가 선택되면 L3은 선택 해제되어야 함)
            case 1: // L3 선택
                slctdPickerDataTransClssfL3 = pickerTransClssf[component][row]
            default:
                break
            }
            NSLog("선택된 값 : [\(component), \(row)], \(pickerTransClssf[component][row])")
        }
    }
    
    func showConfirmAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func select(dbPath: String, sql: String) -> FMResultSet {
        var resultData: FMResultSet? = nil
        
        let fileMgr = FileManager.default
        if fileMgr.fileExists(atPath: dbPath as String) {
            let db = FMDatabase(path: dbPath as String)
            if db == nil {
                NSLog("DB를 찾을 수 없음")
            } else {
                if ((db?.open()) != nil) {
                    resultData = db?.executeQuery(sql, withArgumentsIn: nil)
                    db?.close()
                } else {
                    NSLog("DB에 연결 할 수 없음")
                }
            }
        }
        
        return resultData!
    }
    
    func insert(dbPath: String, sql: String) -> Bool {
        var isSuccess = false
        let fileMgr = FileManager.default
        if fileMgr.fileExists(atPath: dbPath as String) {
            let db = FMDatabase(path: dbPath as String)
            if db == nil {
                NSLog("DB를 찾을 수 없음")
            } else {
                if ((db?.open()) != nil) {
                    isSuccess = (db?.executeUpdate(sql, withArgumentsIn: nil))!
                    
                    if (db?.hadError())! {
                        NSLog("저장 오류")
                    } else {
                        NSLog("저장 성공")
                    }
                    db?.close()
                } else {
                    NSLog("DB에 연결 할 수 없음")
                }
            }
        }
        return isSuccess
    }
}

extension IEAddViewController: IETransInfoDelegate {
    func showTransMns(_ sender: UITextField) {
        pickUpTextTransMns(sender)
        var selectedTransMnsCd = ""
        var selectedRow = 0
        switch sgmTransSlctn.selectedSegmentIndex {
        case 0:
            selectedTransMnsCd = (ieAddIncVC?.txtTransMnsCd.text)!
        case 1:
            selectedTransMnsCd = (ieAddExpVC?.txtTransMnsCd.text)!
        default:
            break
        }
        
        var i = 0
        if !(selectedTransMnsCd.isEmpty) {
            for allTransMnsCds in pickerTransMns {
                if allTransMnsCds[0] == selectedTransMnsCd {
                    selectedRow = i
                }
                i += 1
            }
            textPickerTransMns?.selectRow(selectedRow, inComponent: 0, animated: true)
        }
    }
    
    func showTransClssf(_ sender: UITextField) {
        pickUpTextTransClssf(sender)
        var selectedTransClssfL2Cd = ""
        var selectedTransClssfL3Cd = ""
        var selectedL2Row = 0
        var selectedL3Row = 0
        switch sgmTransSlctn.selectedSegmentIndex {
        case 0:
            selectedTransClssfL2Cd = (ieAddIncVC?.txtTransClssfL2Cd.text)!
            selectedTransClssfL3Cd = (ieAddIncVC?.txtTransClssfL3Cd.text)!
        case 1:
            selectedTransClssfL2Cd = (ieAddExpVC?.txtTransClssfL2Cd.text)!
            selectedTransClssfL3Cd = (ieAddExpVC?.txtTransClssfL3Cd.text)!
        default:
            break
        }
        
        if !(selectedTransClssfL2Cd.isEmpty) {
            var i = 0
            for allTransClssfL2Cds in pickerTransClssf[0] {
                if allTransClssfL2Cds[0] == selectedTransClssfL2Cd {
                    selectedL2Row = i
                }
                i += 1
            }
            textPickerTransClssf?.selectRow(selectedL2Row, inComponent: 0, animated: true)
        }
        
        if !(selectedTransClssfL3Cd.isEmpty) {
            var j = 0
            for allTransClssfL3Cds in pickerTransClssf[1] {
                if allTransClssfL3Cds[0] == selectedTransClssfL3Cd {
                    selectedL3Row = j
                }
                j += 1
            }
            textPickerTransClssf?.selectRow(selectedL3Row, inComponent: 1, animated: true)
        }
    }
    
    func updateIncTxtTransMns(transMns: [String]) {
        ieAddIncVC?.updateTxtTransMns(transMns: transMns)
    }
    
    func cancelIncTxtTransMns() {
        ieAddIncVC?.hideTransMns()
    }
    
    func updateIncTxtTransClssf(transClssfL2: [String], transClssfL3: [String]) {
        ieAddIncVC?.updateTxtTransClssf(transClssfL2: transClssfL2, transClssfL3: transClssfL3)
    }
    
    func cancelIncTxtTransClssf() {
        ieAddIncVC?.hideTransClssf()
    }
    
    func updateExpTxtTransMns(transMns: [String]) {
        ieAddExpVC?.updateTxtTransMns(transMns: transMns)
    }
    
    func cancelExpTxtTransMns() {
        ieAddExpVC?.hideTransMns()
    }
    
    func updateExpTxtTransClssf(transClssfL2: [String], transClssfL3: [String]) {
        ieAddExpVC?.updateTxtTransClssf(transClssfL2: transClssfL2, transClssfL3: transClssfL3)
    }
    
    func cancelExpTxtTransClssf() {
        ieAddExpVC?.hideTransClssf()
    }
    
    func focusIncTxtTransCntnt() {
        ieAddIncVC?.txtTransCntnt.text = ""
        ieAddIncVC?.txtTransAmt.text = ""
        ieAddIncVC?.txtTransMns.text = ""
        ieAddIncVC?.txtTransMnsCd.text = ""
        ieAddIncVC?.txtTransClssf.text = ""
        ieAddIncVC?.txtTransClssfL2Cd.text = ""
        ieAddIncVC?.txtTransClssfL3Cd.text = ""
        ieAddIncVC?.txvTransMmo.text = ""
        ieAddIncVC?.txtTransCntnt.becomeFirstResponder()
    }
    
    func focusExpTxtTransCntnt() {
        ieAddExpVC?.txtTransCntnt.text = ""
        ieAddExpVC?.txtTransAmt.text = ""
        ieAddExpVC?.txtTransMns.text = ""
        ieAddExpVC?.txtTransMnsCd.text = ""
        ieAddExpVC?.txtTransClssf.text = ""
        ieAddExpVC?.txtTransClssfL2Cd.text = ""
        ieAddExpVC?.txtTransClssfL3Cd.text = ""
        ieAddExpVC?.txvTransMmo.text = ""
        ieAddExpVC?.txtTransCntnt.becomeFirstResponder()
    }
    
    func getIncTransInfo() -> TransInfo {
        let transMnsCds: [String] = [(ieAddIncVC?.txtTransMnsCd.text)!]
        let transClssfCds: [String] = [l1Cd, (ieAddIncVC?.txtTransClssfL2Cd.text)!, (ieAddIncVC?.txtTransClssfL3Cd.text)!]
        let transInfo = TransInfo.init(transDt: (txtTransDt.text)!, transTm: "000000", transCntnt: (ieAddIncVC?.txtTransCntnt.text)!, transAmt: (ieAddIncVC?.txtTransAmt.text)!, transMnsCds: transMnsCds, transClssfCds: transClssfCds, transMmo: (ieAddIncVC?.txvTransMmo.text)!)
        return transInfo
    }
    
    func getExpTransInfo() -> TransInfo {
        let transMnsCds: [String] = [(ieAddExpVC?.txtTransMnsCd.text)!, (ieAddExpVC?.txtTransMns.text)!]
        let transClssfCds: [String] = [l1Cd, (ieAddExpVC?.txtTransClssfL2Cd.text)!, (ieAddExpVC?.txtTransClssfL3Cd.text)!]
        let transInfo = TransInfo.init(transDt: (txtTransDt.text)!, transTm: "000000", transCntnt: (ieAddExpVC?.txtTransCntnt.text)!, transAmt: (ieAddExpVC?.txtTransAmt.text)!, transMnsCds: transMnsCds, transClssfCds: transClssfCds, transMmo: (ieAddExpVC?.txvTransMmo.text)!)
        return transInfo
    }
}
