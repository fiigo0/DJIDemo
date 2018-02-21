//
//  FBManager.swift
//  DJIDemo
//
//  Created by Diaz Orona, Jesus A. on 2/21/18.
//  Copyright © 2018 Diaz Orona, Jesus A. All rights reserved.
//

import Foundation
import FirebaseDatabase


class FBManager: NSObject {
    
    static let sharedInstance:FBManager = FBManager()
    private var ref: DatabaseReference = Database.database().reference()
    
    func addLog(message:String){
        self.ref.child("Logs").child(message).setValue(0)
    }
    func log(method:String, withMessage message:String) {
        self.ref.child("Logs").child(method).setValue(message)
    }
    
}

