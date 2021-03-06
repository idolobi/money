//
//  ViewController.swift
//  money
//
//  Created by KES on 2017. 1. 8..
//  Copyright © 2017년 es. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    let myLocale = "ko_KR"
    
    var databasePath = String()
    var transInfoArr = Array<TransInfo>()
    var transInfoSet = TransInfoSet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSLog("로그 : viewDidLoad() 시작")
        
        let bundle = Bundle.main
        databasePath = bundle.path(forResource: "money", ofType: "db")!
        
        let fileMgr = FileManager.default
        //let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        //databasePath = dirPaths[0].appendingPathComponent("money.db").path
        
        NSLog("로그 : DB 파일 위치 세팅(" + databasePath + ")")
        
        if !fileMgr.fileExists(atPath: databasePath as String) {
            let db = FMDatabase(path: databasePath as String)
            
            if db == nil {
                NSLog("DB 생성 오류")
            }
            
            if ((db?.open()) != nil) {
                let sqlUsrInfo = "CREATE TABLE IF NOT EXISTS usr_info(usr_id TEXT PRIMARY KEY, usr_pwd TEXT, usr_nm TEXT)"
                if !(db?.executeStatements(sqlUsrInfo))! {
                    NSLog("데이터 저장소 생성 오류[USR_INFO]")
                }
                
                let sqlBnkacInfo = "CREATE TABLE IF NOT EXISTS bnkac_info(bnkac_id TEXT PRIMARY KEY, usr_id TEXT REFERENCES usr_info(usr_id), bnkac_nm TEXT, bnkac_strt_dt TEXT, bnkac_mntry_unit TEXT)"
                if !(db?.executeStatements(sqlBnkacInfo))! {
                    NSLog("데이터 저장소 생성 오류[USR_INFO]")
                }
                
                let sqlTransInfo = "CREATE TABLE IF NOT EXISTS trans_info(trans_num INTEGER PRIMARY KEY AUTOINCREMENT, usr_id TEXT, bnkac_id TEXT, trans_dt TEXT, trans_tm TEXT, pay_trans_mns_cd TEXT, rcv_trans_mns_cd TEXT, trans_div_cd TEXT, hgh_clssf_cd TEXT, mdl_clssf_cd TEXT, low_clssf_cd TEXT, trans_cntnt TEXT, trans_amt NUMERIC, sort_ord_num INTEGER)"
                if !(db?.executeStatements(sqlTransInfo))! {
                    NSLog("데이터 저장소 생성 오류[TRANS_INFO]")
                }
                
                let sqlTransMns = "CREATE TABLE IF NOT EXISTS trans_mns(trans_mns_cd TEXT PRIMARY KEY, trans_mns_nm TEXT)"
                if !(db?.executeStatements(sqlTransMns))! {
                    NSLog("데이터 저장소 생성 오류[TRANS_MNS]")
                }
                
                db?.close()
            } else {
                NSLog("DB 연결 오류")
            }
        }
        NSLog("로그 : viewDidLoad() 종료")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTransInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.gray
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        header.textLabel?.frame = header.frame
    }
    
    // 섹션 타이틀 리턴
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(transInfoSet.sections[section])"
    }
    
    // 센션 수 설정
    override func numberOfSections(in tableView: UITableView) -> Int {
        NSLog("로그 : 섹션 수 : \(transInfoSet.sections.count)")
        return transInfoSet.sections.count
    }
    
    // 로우 수 설정
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("로그 : 섹션의 로우 수 : \(transInfoSet.items[section].count)")
        return transInfoSet.items[section].count
    }
    
    // 로우에 데이터 바이드
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        NSLog("로그 : tableView* 시작")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dealingCell", for: indexPath as IndexPath) as! DealingCell

        let row: Int = indexPath.row
        let sec: Int = indexPath.section
        NSLog("로그 : tableView* 확인 : \(sec) \(row)")
        let data = transInfoSet.items[sec][row]

        //cell.lblDealDate.text = "\(data.transDt)"
        cell.lblDealMeasure.text = "\(data.transMnsNm)"
        cell.lblDealContent.text = "\(data.transCntnt)"
        cell.lblDealAmount.text = "\(data.transAmt)"
        
        NSLog("로그 : tableView* 종료")
        return cell
    }
    
    // 거래 데이터 불러오기
    func loadTransInfo() {
        NSLog("로그 : loadTransInfo 시작")
        
        transInfoArr = Array<TransInfo>()
        transInfoSet = TransInfoSet()
        
        let db = FMDatabase(path: databasePath as String)
        
        if ((db?.open()) != nil) {
            let sqlCnt = "select count(*) as cnt from trans_info"
            let sqlData = "select trans_dt, trans_tm, pay_trans_mns_cd, trans_cntnt, trans_amt from trans_info"
            let resultCnt: FMResultSet? = db?.executeQuery(sqlCnt, withArgumentsIn: nil)
            let resultData: FMResultSet? = db?.executeQuery(sqlData, withArgumentsIn: nil)
            
            if (resultData != nil) && (resultCnt != nil) {
                var rowCnt = 0
                
                while resultCnt!.next() {
                    rowCnt = resultCnt!.long(forColumn: "cnt")
                }
                
                var isFirst: BooleanLiteralType = true
                var prevTransDt: String = ""
                var newTransDt: String = ""
                var rowNum = 0
                
                while resultData!.next() {
                    rowNum += 1
                    
                    let myDateTime = MyDateTime(locale: self.myLocale)
                    newTransDt = myDateTime.dateForDisplay(date: resultData!.string(forColumn: "trans_dt")!)
                    
                    if isFirst {
                        NSLog("첫번째 로우")
                        prevTransDt = newTransDt
                        isFirst = false
                    }
                    
                    if prevTransDt != newTransDt { //날짜가 바뀔 때마다 세트로 구성해서 추가
                        transInfoSet.add(section: prevTransDt, item: transInfoArr)
                        transInfoArr = Array<TransInfo>()
                        prevTransDt = newTransDt
                    }
                    
                    let transInfo = TransInfo(transDt: newTransDt, transTm: (resultData!.string(forColumn: "trans_tm")!), transCntnt: (resultData!.string(forColumn: "trans_cntnt")!), transAmt: (resultData!.string(forColumn: "trans_amt")!), transMnsCds: [(resultData!.string(forColumn: "pay_trans_mns_cd")!)], transClssfCds: ["", "", ""], transMmo: "")
                    transInfoArr.append(transInfo)
                    
                    if rowCnt == rowNum {
                        NSLog("마지막 로우")
                        transInfoSet.add(section: prevTransDt, item: transInfoArr)
                    }
                }
            } else {
                NSLog("데이터 불러오기 실패")
            }
            db?.close()
        } else {
            NSLog("DB 연결 오류")
        }
        
        tableView.reloadData()
        
        NSLog("로그 : loadTransInfo 종료")
    }
}

