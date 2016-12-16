//
//  Callback.swift
//  PetPolar
//
//  Created by meow kling :3 on 6/4/2558 BE.
//  Copyright (c) 2558 Zuck3 Interactive. All rights reserved.
//

import Foundation

class Callback<T> {
    
    var callback: (T?, Bool, String?, NSError?) -> Void
    
    required init(callback: @escaping (T?, Bool, String?, NSError?) -> Void) {
        self.callback = callback
    }
    
}
