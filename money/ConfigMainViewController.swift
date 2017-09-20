//
//  ConfigMainViewController.swift
//  money
//
//  Created by KES on 2017. 4. 16..
//  Copyright © 2017년 es. All rights reserved.
//

import UIKit


class ConfigMainViewController: UITableViewController {
    let myLocale = "ko_KR"
    
    var databasePath = String()
    
    @IBAction func doSomething(_ sender: UIButton) {
        NSLog("로그 : ConfigMainViewController doSomething() 시작")
        // create the alert
        let alert = UIAlertController(title: "초기화", message: "설정을 초기화 합니다.", preferredStyle: UIAlertControllerStyle.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
        NSLog("로그 : ConfigMainViewController doSomething() 여기에서 기초 데이터 insert 하기")
    }
    
    func insTransMnsCd(transMnsCd: String, transMnsNm: String, db: FMDatabase) {
        if ((db.open()) == true) {
            let dml = "insert into trans_mns(trans_mns_cd, trans_mns_nm) values('\(transMnsCd)', '\(transMnsNm)')"
            db.executeUpdate(dml, withArgumentsIn: nil)
            if (db.hadError()) {
                NSLog("저장 오류 \(dml)")
            } else {
                NSLog("저장 성공 \(dml)")
            }
            db.close()
        } else {
            NSLog("DB 연결 오류")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sqlite3 db file import!!!
        let bundle = Bundle.main
        let initDbPath = bundle.path(forResource: "moneyInit", ofType: "db")
        NSLog(initDbPath!)
        
        
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        databasePath = dirPaths[0].appendingPathComponent("money.db").path
        
        if fileMgr.fileExists(atPath: initDbPath! as String) {
            let db = FMDatabase(path: initDbPath! as String)
            if db == nil {
                NSLog("DB 생성 오류")
            } else {
                insTransMnsCd(transMnsCd: "01", transMnsNm: "현금", db: db!)
            }
        } else {
            let db = FMDatabase(path: initDbPath! as String)
            
            if db == nil {
                NSLog("DB 생성 오류")
            }
            
            if ((db?.open()) != nil) {
                let sqlTransMns = "CREATE TABLE IF NOT EXISTS trans_mns(trans_mns_cd TEXT PRIMARY KEY, trans_mns_nm TEXT)"
                if !(db?.executeStatements(sqlTransMns))! {
                    NSLog("데이터 저장소 생성 오류[TRANS_MNS]\(sqlTransMns)")
                }
                
                let sqlTransMnsData = "insert into trans_mns(trans_mns_cd, trans_mns_nm) values('01', '현금')"
                db?.executeUpdate(sqlTransMnsData, withArgumentsIn: nil)
                if (db?.hadError())! {
                    NSLog("저장 오류 \(sqlTransMnsData)")
                } else {
                    NSLog("저장 성공 \(sqlTransMnsData)")
                }
                db?.close()
            } else {
                NSLog("DB 연결 오류")
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigItemCell", for: indexPath)
        return cell
    }
}
