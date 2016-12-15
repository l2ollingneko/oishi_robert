//
//  ActionInfo.swift
//  oishi
//
//  Created by warinporn khantithamaporn on 8/26/2559 BE.
//  Copyright © 2559 com.rollingneko. All rights reserved.
//

import Foundation
import SwiftyJSON

class ActionInfo {
    
    var id: String?
    var active: String?
    var version: String?
    var actor: String?
    var type: String?
    var no: String?
    
    var name: String?
    var notiTitle: String?
    var notiMessage: String?
    
    var videoUrlString: String?
    var audioUrlString: String?
    
    // playlistfriend
    var galleryImageUrlString: String?
    var shareTitle: String?
    var shareDesription: String?
    var shareImageUrlString: String?
    var shareUrl: String?
    
    init(id: String?, active: String?, version: String?, actor: String?, type: String?, no: String?, name: String?, notiTitle: String?, notiMessage: String?, videoUrlString: String?, audioUrlString: String?) {
        self.id = id
        self.active = active
        self.version = version
        self.actor = actor
        self.type = type
        self.no = no
        
        self.name = name
        self.notiTitle = notiTitle
        self.notiMessage = notiMessage
        
        self.videoUrlString = videoUrlString
        self.audioUrlString = audioUrlString
    }
    
    init(id: String?, active: String?, version: String?, actor: String?, type: String?, no: String?, name: String?, videoUrlString: String?, galleryImageUrlString: String?, shareTitle: String?, shareDescription: String?, shareImageUrlString: String?, shareUrl: String?) {
        self.id = id
        self.active = active
        self.version = version
        self.actor = actor
        self.type = type
        self.no = no
        
        self.name = name
        
        self.videoUrlString = videoUrlString
        self.galleryImageUrlString = galleryImageUrlString
        self.shareTitle = shareTitle
        self.shareDesription = shareDescription
        self.shareImageUrlString = shareImageUrlString
        self.shareUrl = shareUrl
    }
    
    class func getActionInfo(json: JSON) -> ActionInfo {
        let id = json["id"].string
        let active = json["active"].string
        let version = json["version"].string
        let actor = json["actor"].string
        let type = json["type"].string
        let no = json["no"].string
        
        let name = json["name"].string
        let notiTitle = json["noti_title"].string
        let notiMessage = json["noti_message"].string
        
        let videoUrlString = json["video"].string
        let audioUrlString = json["audio_ios"].string
        
        let shareTitle = json["share_title"].string
        let shareDescription = json["share_description"].string
        let shareImageUrlString = json["share_image"].string
        let shareUrl = json["share_url"].string
        
        let actionInfo = ActionInfo(id: id, active: active, version: version, actor: actor, type: type, no: no, name: name, notiTitle: notiTitle, notiMessage: notiMessage, videoUrlString: videoUrlString, audioUrlString: audioUrlString)
        
        actionInfo.shareTitle = shareTitle
        actionInfo.shareDesription = shareDescription
        actionInfo.shareImageUrlString = shareImageUrlString
        actionInfo.shareUrl = shareUrl
        
        return actionInfo
    }
    
    class func getFriendActionInfo(json: JSON) -> ActionInfo {
        let id = json["id"].string
        let active = json["active"].string
        let version = json["version"].string
        let actor = json["actor"].string
        let type = json["type"].string
        let no = json["no"].string
        
        let name = json["name"].string
        
        let videoUrlString = json["video"].string
        let galleryImageUrlString = json["gallery_image"].string
        let shareTitle = json["share_title"].string
        let shareDescription = json["share_description"].string
        let shareImageUrlString = json["share_image"].string
        let shareUrl = json["share_url"].string
        
        return ActionInfo(id: id, active: active, version: version, actor: actor, type: type, no: no, name: name, videoUrlString: videoUrlString, galleryImageUrlString: galleryImageUrlString, shareTitle: shareTitle, shareDescription: shareDescription, shareImageUrlString: shareImageUrlString, shareUrl: shareUrl)
    }
    
}