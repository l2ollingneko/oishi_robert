//
//  EstHTTPService.swift
//  est
//
//  Created by warinporn khantithamaporn on 9/20/2559 BE.
//  Copyright © 2559 com.rollingneko. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper
import FBSDKCoreKit

class AdapterHTTPService {
    
    static let sharedInstance = AdapterHTTPService()
    
    private let BASE_API_URL = "http://www.oishidrink.com/sakura/api/mobile/"
    
    private static let APP_DATA_KEY = [
        "appname",
        "share_url",
        "share_title",
        "share_description",
        "share_image",
        "share_twitter_url",
        "share_twitter_description",
        "share_gplus_url",
        "copy_url"
    ]
    
    private init() {}
    
    // MARK: - get data info
    
    func getDataInfo(cb: Callback<Bool>) {
        let url = self.BASE_API_URL + "getDataInfo.aspx"
        Alamofire.request(url).responseJSON { response in
            if let data: AnyObject = response.result.value as AnyObject? {
                let json = JSON(data)
                print(json)
                for appData in json["appdata"].array! {
                    for key in AdapterHTTPService.APP_DATA_KEY {
                        _ = DataManager.sharedInstance.setObjectForKey(value: appData[key].string as AnyObject?, key: key)
                    }
                }
                cb.callback(true, true, nil, nil)
            } else {
                cb.callback(nil, false, nil, nil)
            }   
        }
    }
    
    // MARK: -
    
    func saveGameNonToken() {
        let url: String = "http://www.oishidrink.com/sakura/api/mobile/submitGameNonToken.aspx"
        var parameters = Dictionary<String, AnyObject>()
        parameters["param1"] = "ios" as AnyObject?
       
        if let _ = FBSDKAccessToken.current() {
            parameters["fbuid"] = KeychainWrapper.standard.string(forKey: "fbuid") as AnyObject?
            if let value = DataManager.sharedInstance.getObjectForKey(key: "first_name") as? String {
                parameters["firstname"] = value as AnyObject?
            } else {
                parameters["firstname"] = "" as AnyObject?
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "last_name") as? String {
                parameters["lastname"] = value as AnyObject?
            } else {
                parameters["lastname"] = "" as AnyObject?
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "email") as? String {
                parameters["email"] = value as AnyObject?
            } else {
                parameters["email"] = "" as AnyObject?
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "gender") as? String {
                parameters["gender"] = value as AnyObject?
            } else {
                parameters["gender"] = "" as AnyObject?
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "link") as? String {
                parameters["link"] = value as AnyObject?
            } else {
                parameters["link"] = "" as AnyObject?
            }
        } else {
            parameters["fbuid"] = KeychainWrapper.standard.string(forKey: "fbuid") as AnyObject?
            parameters["firstname"] = "" as AnyObject?
            parameters["lastname"] = "" as AnyObject?
            parameters["email"] = "" as AnyObject?
            parameters["gender"] = "" as AnyObject?
            parameters["link"] = "" as AnyObject?
        }

		parameters["access"] = "mobileapp" as AnyObject?
		parameters["caller"] = "json" as AnyObject?

        _ = Alamofire.request(url, method: .post).responseJSON { response in
            if let data: AnyObject = response.result.value as AnyObject? {
                let json = JSON(data)
                print(json)
            } else {
                print("no response")
            }
        }

    }

	func saveGameComplete(emitterOrigin: String) {
		let url: String = "http://www.oishidrink.com/sakura/api/mobile/submitGameComplete.aspx"
        var parameters = Dictionary<String, AnyObject>()

		if let gid = KeychainWrapper.standard.string(forKey: "gid") as AnyObject? {
			parameters["gid"] = gid as AnyObject?
		}

		parameters["param2"] = emitterOrigin as AnyObject?

		_ = Alamofire.request(url, method: .post)
	}
    
    func updateFacebookIDNonToken(fakefbuid: String) {
        var url: String = "http://www.oishidrink.com/sakura/api/mobile/getinfoV3NonToken.aspx"
        var parameters = Dictionary<String, AnyObject>()
        
        parameters["fakefbuid"] = fakefbuid as AnyObject?
        
        if let _ = FBSDKAccessToken.current() {
            parameters["fbuid"] = KeychainWrapper.standard.string(forKey: "fbuid") as AnyObject?
            if let value = DataManager.sharedInstance.getObjectForKey(key: "first_name") as? String {
                parameters["firstname"] = value as AnyObject?
            } else {
                parameters["firstname"] = "" as AnyObject?
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "last_name") as? String {
                parameters["lastname"] = value as AnyObject?
            } else {
                parameters["lastname"] = "" as AnyObject?
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "email") as? String {
                parameters["email"] = value as AnyObject?
            } else {
                parameters["email"] = "" as AnyObject?
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "gender") as? String {
                parameters["gender"] = value as AnyObject?
            } else {
                parameters["gender"] = "" as AnyObject?
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "link") as? String {
                parameters["profilelink"] = value as AnyObject?
            } else {
                parameters["profilelink"] = "" as AnyObject?
            }
        }
        
        parameters["access"] = "mobileapp" as AnyObject?
        parameters["caller"] = "json" as AnyObject?

		Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
			if (response.result.isSuccess) {
				let id = FBSDKAccessToken.current().userID
                KeychainWrapper.standard.set(id!, forKey: "fbuid")
			}
		}

    }

    // MARK: - stat
    
    func openApp() {
        var url: String = "http://www.oishidrink.com/sakura/api/mobile/applicationstatlog.aspx"
        if let api_stat = DataManager.sharedInstance.getObjectForKey(key: "api_stat") as? String {
            url = api_stat
        }
        var parameters = Dictionary<String, AnyObject>()
        parameters["stat"] = "sakura" as AnyObject?
        parameters["param1"] = "ios" as AnyObject?
        parameters["param2"] = "openapp" as AnyObject?
        _ = Alamofire.request(url, parameters: parameters)
    }
    
    func startGame() {
        var url: String = "http://www.oishidrink.com/sakura/api/mobile/applicationstatlog.aspx"
        if let api_stat = DataManager.sharedInstance.getObjectForKey(key: "api_stat") as? String {
            url = api_stat
        }
        var parameters = Dictionary<String, AnyObject>()
        parameters["stat"] = "sakura" as AnyObject?
        parameters["param1"] = "ios" as AnyObject?
        parameters["param2"] = "startgame" as AnyObject?
        _ = Alamofire.request(url, parameters: parameters)
    }
    
    func shareResult() {
        var url: String = "http://www.oishidrink.com/sakura/api/mobile/applicationstatlog.aspx"
        if let api_stat = DataManager.sharedInstance.getObjectForKey(key: "api_stat") as? String {
            url = api_stat
        }
        var parameters = Dictionary<String, AnyObject>()
        parameters["stat"] = "sakura" as AnyObject?
        parameters["param1"] = "ios" as AnyObject?
        parameters["param2"] = "shareresult" as AnyObject?
        _ = Alamofire.request(url, parameters: parameters)
    }
    
    func saveVideo() {
        var url: String = "http://www.oishidrink.com/sakura/api/mobile/applicationstatlog.aspx"
        if let api_stat = DataManager.sharedInstance.getObjectForKey(key: "api_stat") as? String {
            url = api_stat
        }
        var parameters = Dictionary<String, AnyObject>()
        parameters["stat"] = "sakura" as AnyObject?
        parameters["param1"] = "ios" as AnyObject?
        parameters["param2"] = "saveresult" as AnyObject?
        _ = Alamofire.request(url, parameters: parameters)
    }
    
}
