//
//  DataService.swift
//  showcase
//
//  Created by shengxiang guo on 1/26/16.
//  Copyright © 2016 shengxiang guo. All rights reserved.
//

import Foundation
import Firebase

class DataService{
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url:"https://showcasekkk.firebaseio.com")
    
    var REF_BASE: Firebase{
        return _REF_BASE
    }
}