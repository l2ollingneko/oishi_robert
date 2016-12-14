//
//  StateManager.swift
//  oishi_sakura
//
//  Created by warinporn khantithamaporn on 12/14/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import Foundation

class StateManager {
    
    static let sharedInstance = StateManager()
    
    private(set) var currentState: Int = 0
    
    private init() {}
    
    func resetState() {
        self.currentState = 0
    }
    
    func increaseState() {
        self.currentState += 1
    }
    
}
