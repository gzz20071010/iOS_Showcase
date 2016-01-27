//
//  DataService.swift
//  showcase
//
//  Created by shengxiang guo on 1/26/16.
//  Copyright © 2016 shengxiang guo. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "https://showcasekkk.firebaseio.com"

class DataService{
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: URL_BASE)
    private var _REF_POSTS = Firebase(url:"\(URL_BASE)/posts")
    private var _REF_USERS = Firebase(url:"\(URL_BASE)/users")
    
    var REF_POSTS: Firebase{
        return _REF_POSTS
    }
    
    var REF_USERS: Firebase{
        return _REF_USERS
    }
    
    var REF_BASE: Firebase{
        return _REF_BASE
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>){
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
}