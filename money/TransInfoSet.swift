//
//  TransInfoSet.swift
//  money
//
//  Created by KES on 2017. 1. 21..
//  Copyright © 2017년 es. All rights reserved.
//

import UIKit

class TransInfoSet {
    var sections: Array<String> = []
    var items: Array<Array<TransInfo>> = []
    
    func add(section: String, item: Array<TransInfo>) {
        sections = sections + [section]
        items = items + [item]
    }
}
