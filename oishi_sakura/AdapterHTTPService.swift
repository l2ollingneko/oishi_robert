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
        var parameters = Dictionary<String, String>()
        parameters["param1"] = "ios"
        
        if let emitterOrigin = DataManager.sharedInstance.getObjectForKey(key: "emitter_origin") as? String {
            parameters["param2"] = emitterOrigin
        }
       
        if let _ = FBSDKAccessToken.current() {
            parameters["fbuid"] = KeychainWrapper.standard.string(forKey: "fbuid")
            if let value = DataManager.sharedInstance.getObjectForKey(key: "first_name") as? String {
                parameters["firstname"] = value
            } else {
                parameters["firstname"] = ""
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "last_name") as? String {
                parameters["lastname"] = value
            } else {
                parameters["lastname"] = ""
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "email") as? String {
                parameters["email"] = value
            } else {
                parameters["email"] = ""
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "gender") as? String {
                parameters["gender"] = value
            } else {
                parameters["gender"] = ""
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "link") as? String {
                parameters["link"] = value
            } else {
                parameters["link"] = ""
            }
        } else {
            parameters["fbuid"] = KeychainWrapper.standard.string(forKey: "fbuid")
            parameters["firstname"] = ""
            parameters["lastname"] = ""
            parameters["email"] = ""
            parameters["gender"] = ""
            parameters["link"] = ""
        }

		parameters["access"] = "mobileapp"
		parameters["caller"] = "json"
        
        print("saveGameNonToken ...")
        
        for (key, value) in parameters.enumerated() {
            print("\(key): \(value)")
        }

        _ = Alamofire.request(url, method: .post).responseString { response in
            if let responseString = response.result.value {
                var splited = responseString.components(separatedBy: "&")
                splited = splited[1].components(separatedBy: "=")
                DataManager.sharedInstance.setObjectForKey(value: splited[1] as AnyObject?, key: "gid")
                print("gid: \(splited[1])")
            } else {
                print("saveGameComplete error: \(response.result.error?.localizedDescription)")
            }
        }

    }

	func saveGameComplete(emitterOrigin: String) {
		let url: String = "http://www.oishidrink.com/sakura/api/mobile/submitGameComplete.aspx"
        var parameters = Dictionary<String, String>()

        if let gid = DataManager.sharedInstance.getObjectForKey(key: "gid") as? String {
			parameters["gid"] = gid
		}

		parameters["param2"] = emitterOrigin
        
        print("saveGameComplete ...")
        
        for (key, value) in parameters.enumerated() {
            print("\(key): \(value)")
        }

        _ = Alamofire.request(url, method: .post).responseString { response in
            if let responseString = response.result.value {
                print("saveGameComplete: \(responseString)")
            } else {
                print("saveGameComplete error: \(response.result.error?.localizedDescription)")
            }
        }
	}
    
    func saveFBShare(postId: String) {
        let url: String = "http://www.oishidrink.com/sakura/api/mobile/saveShareToWall.aspx"
        var parameters = Dictionary<String, String>()
        parameters["type"] = "postshare"
        parameters["postid"] = postId
        parameters["access"] = "mobileapp"
        parameters["caller"] = "json"
        
        if let _ = FBSDKAccessToken.current() {
            parameters["code"] = FBSDKAccessToken.current().tokenString
        }
        
        if let gid = DataManager.sharedInstance.getObjectForKey(key: "gid") as? String {
			parameters["gid"] = gid
		}
        
        print("saveFBShare ...")
        
        for (key, value) in parameters.enumerated() {
            print("\(key): \(value)")
        }
        
        _ = Alamofire.request(url, method: .post, parameters: parameters).responseString { response in
            if let responseString = response.result.value {
                print("saveFBShare: \(responseString)")
            } else {
                print("saveFBShare error: \(response.result.error?.localizedDescription)")
            }
        }
    }
    
    func updateFacebookIDNonToken(fakefbuid: String) {
        let url: String = "http://www.oishidrink.com/sakura/api/mobile/getinfoV3NonToken.aspx"
        var parameters = Dictionary<String, String>()
        
        parameters["fakefbuid"] = fakefbuid
        
        if let _ = FBSDKAccessToken.current() {
            parameters["fbuid"] = KeychainWrapper.standard.string(forKey: "fbuid")
            if let value = DataManager.sharedInstance.getObjectForKey(key: "first_name") as? String {
                parameters["firstname"] = value
            } else {
                parameters["firstname"] = ""
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "last_name") as? String {
                parameters["lastname"] = value
            } else {
                parameters["lastname"] = ""
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "email") as? String {
                parameters["email"] = value
            } else {
                parameters["email"] = ""
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "gender") as? String {
                parameters["gender"] = value
            } else {
                parameters["gender"] = ""
            }
            if let value = DataManager.sharedInstance.getObjectForKey(key: "link") as? String {
                parameters["profilelink"] = value 
            } else {
                parameters["profilelink"] = ""
            }
        }
        
        parameters["access"] = "mobileapp"
        parameters["caller"] = "json"
        
        print("updateFacebookIDNonToken ...")
        
        for (key, value) in parameters.enumerated() {
            print("\(key): \(value)")
        }

		Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
			if (response.result.isSuccess) {
                print("updateFacebookIDNonToken: success")
				let id = FBSDKAccessToken.current().userID
                KeychainWrapper.standard.set(id!, forKey: "fbuid")
            } else {
                print("updateFacebookIDNonToken error: \(response.result.error?.localizedDescription)")
            }
		}

    }

    // MARK: - stat
    
    func openApp() {
        var url: String = "http://www.oishidrink.com/sakura/api/mobile/applicationstatlog.aspx"
        if let api_stat = DataManager.sharedInstance.getObjectForKey(key: "api_stat") as? String {
            url = api_stat
        }
        var parameters = Dictionary<String, String>()
        parameters["stat"] = "sakura"
        parameters["param1"] = "ios"
        parameters["param2"] = "openapp"
        _ = Alamofire.request(url, parameters: parameters)
    }
    
    func startGame() {
        var url: String = "http://www.oishidrink.com/sakura/api/mobile/applicationstatlog.aspx"
        if let api_stat = DataManager.sharedInstance.getObjectForKey(key: "api_stat") as? String {
            url = api_stat
        }
        var parameters = Dictionary<String, String>()
        parameters["stat"] = "sakura"
        parameters["param1"] = "ios"
        parameters["param2"] = "startgame"
        _ = Alamofire.request(url, parameters: parameters)
    }
    
    func shareResult() {
        var url: String = "http://www.oishidrink.com/sakura/api/mobile/applicationstatlog.aspx"
        if let api_stat = DataManager.sharedInstance.getObjectForKey(key: "api_stat") as? String {
            url = api_stat
        }
        var parameters = Dictionary<String, String>()
        parameters["stat"] = "sakura"
        parameters["param1"] = "ios"
        parameters["param2"] = "shareresult"
        _ = Alamofire.request(url, parameters: parameters)
    }
    
    func saveVideo() {
        var url: String = "http://www.oishidrink.com/sakura/api/mobile/applicationstatlog.aspx"
        if let api_stat = DataManager.sharedInstance.getObjectForKey(key: "api_stat") as? String {
            url = api_stat
        }
        var parameters = Dictionary<String, String>()
        parameters["stat"] = "sakura"
        parameters["param1"] = "ios"
        parameters["param2"] = "saveresult"
        _ = Alamofire.request(url, parameters: parameters)
    }
    
}
