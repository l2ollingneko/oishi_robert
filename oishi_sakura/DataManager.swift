//
//  DataManager.swift
//  OISHI
//
//  Created by warinporn khantithamaporn on 8/30/2559 BE.
//  Copyright © 2559 com.rollingneko. All rights reserved.
//

import Foundation

class DataManager {
    
    static let sharedInstance = DataManager()
    
    private init() {}
    
    func setBoolForKey(value: Bool?, key: String) -> Bool {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
        if let value = value {
            defaults.set(value, forKey: key)
            return true
        } else {
            return false
        }
    }
    
    func setObjectForKey(value: AnyObject?, key: String) -> Bool {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
        if let value = value {
            defaults.set(value, forKey: key)
            return true
        } else {
            return false
        }
    }
    
    func setObjectForKey(value: AnyObject?, key: String, appName: String) -> Bool {
        let defaults = UserDefaults.standard
        let finalKey = "\(appName)_\(key)"
        defaults.removeObject(forKey: finalKey)
        if let value = value {
            defaults.set(value, forKey: finalKey)
            return true
        } else {
            return false
        }
    }
    
    func getBoolForKey(key: String) -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: key)
    }
    
    func getObjectForKey(key: String) -> AnyObject? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: key) as AnyObject?
    }
    
    func getObjectForKey(key: String, appName: String) -> AnyObject? {
        let defaults = UserDefaults.standard
        let finalKey = "\(appName)_\(key)"
        return defaults.object(forKey: finalKey) as AnyObject?
    }
    
    func removeObjectForKey(key: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
    }
    
}
