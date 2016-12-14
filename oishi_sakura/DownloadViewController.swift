//
//  DownloadViewController.swift
//  oishi
//
//  Created by warinporn khantithamaporn on 8/26/2559 BE.
//  Copyright © 2559 com.rollingneko. All rights reserved.
//

import UIKit

protocol DownloadViewControllerDelegate {
    func finishedDownloadResources()
    func failedDownloadResources()
    func didCancelDownloadResources()
}

class DownloadViewController: UIViewController {
    
    var backgroundImageView = UIImageView()
    
    var percentageLabel = UILabel()
    
    var progressBar = M13ProgressViewBorderedBar()
    var progress = UIProgressView()
    var progressLabel = UILabel()
    
    var videoUrlString: String?
    var audioUrlString: String?
    
    var fileURLs = [String]()
    var fileDestinations = [NSURL]()
    var basePercent: Int = 0
    var baseProgress: CGFloat = 0.0
    
    var videoDownloaded: Bool = false
    var audioDownloaded: Bool = false
    
    var isDownloadVideoPreview: Bool = false
    
    var delegate: DownloadViewControllerDelegate?
    
    /*
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     */
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = CGRect.init(x: 0.0, y: 0.0, width: Adapter.rWidth, height: Adapter.rHeight)
        self.view.clipsToBounds = true

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        self.view.clipsToBounds = true
        
        self.backgroundImageView.frame = CGRect.init(x: 0.0, y: 0.0, width: Adapter.rWidth, height: Adapter.rHeight)
        self.backgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
        self.backgroundImageView.image = UIImage(named: "loading_bg")
        
        let labelSize = CGSize.init(width: Adapter.calculatedWidthFromRatio(width: 390.0), height: Adapter.calculatedHeightFromRatio(height: 260.0))
        self.percentageLabel.frame = CGRect.init(x: Adapter.calculatedWidthFromRatio(width: 790.0), y: Adapter.calculatedHeightFromRatio(height: 860.0), width: labelSize.width, height: labelSize.height)
        // self.percentageLabel.font = UIFont(name: Adapter.DBHELVETHAICA_X_MEDIUM, size: Adapter.calculatedHeightFromRatio(260.0))
        self.percentageLabel.textAlignment = .center
        self.percentageLabel.textColor = UIColor.white
        
        self.percentageLabel.text = "0%"
        
        let progressBarSize = CGSize.init(width: Adapter.calculatedWidthFromRatio(width: 1052.0), height: Adapter.calculatedHeightFromRatio(height: 85.0))
        self.progressBar.frame = CGRect.init(x: Adapter.calculatedWidthFromRatio(width: 95.0), y: Adapter.calculatedHeightFromRatio(height: 1138.0), width: progressBarSize.width, height: progressBarSize.height)
        self.progressBar.layer.cornerRadius = progressBarSize.height / 2.0
        self.progressBar.clipsToBounds = true
        self.progressBar.layer.borderColor = UIColor.white.cgColor
        self.progressBar.layer.borderWidth = Adapter.calculatedWidthFromRatio(width: 8.0)
        self.progressBar.primaryColor = UIColor.red
        self.progressBar.backgroundColor = UIColor.black
        
        self.progress.frame = CGRect.init(x: Adapter.calculatedWidthFromRatio(width: 95.0), y: Adapter.calculatedHeightFromRatio(height: 1138.0), width: progressBarSize.width, height: progressBarSize.height)
        self.progress.progressTintColor = UIColor.red
        self.progress.backgroundColor = UIColor.black
        self.progress.progress = 0.0
        //self.progress.layer.borderColor = UIColor.white.CGColor
        //self.progress.layer.borderWidth = Adapter.calculatedWidthFromRatio(8.0)
        
        let progressLabelSize = CGSize.init(width: Adapter.calculatedWidthFromRatio(width: 1242.0), height: Adapter.calculatedHeightFromRatio(height: 85.0))
        self.progressLabel.frame = CGRect.init(x: 0.0, y: Adapter.calculatedHeightFromRatio(height: 1250.0), width: progressLabelSize.width, height: progressLabelSize.height)
        // self.progressLabel.font = UIFont(name: Adapter.DBHELVETHAICA_X_MEDIUM, size: Adapter.calculatedHeightFromRatio(85.0))
        self.progressLabel.textAlignment = .center
        self.progressLabel.textColor = UIColor.white
        self.progressLabel.text = "1/2"
        
        self.view.addSubview(self.backgroundImageView)
        self.backgroundImageView.addSubview(self.percentageLabel)
        self.backgroundImageView.addSubview(self.progressBar)
        // self.backgroundImageView.addSubview(self.progressLabel)
        
        if (self.isDownloadVideoPreview) {
            self.initSingleDownload()
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        } else {
            self.initDownload()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.frame = CGRect.init(x: 0.0, y: 0.0, width: Adapter.rWidth, height: Adapter.rHeight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initAnimate() {
        
    }
    
    func initDownload() {
        /*
        if let videoUrlString = self.videoUrlString {
            let splitedString = videoUrlString.characters.split{$0 == "/"}.map(String.init)
            let fileName = splitedString[splitedString.count - 1]
            
            if (!self.isFileDownloaded(self.getVideoFilePath(fileName))) {
                let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                let pathComponent = "video/\(fileName)"
                let localPath: NSURL = directoryURL.URLByAppendingPathComponent(pathComponent)
                self.fileURLs.append(videoUrlString)
                self.fileDestinations.append(localPath)
                let clipName = fileName.characters.split{$0 == "."}.map(String.init)
                AdapterHTTPService.sharedInstance.loadClip(clipName[0])
            } else {
                print("file \(fileName) downloaded")
                self.videoDownloaded = true
            }
        }
        
        if let audioUrlString = self.audioUrlString {
            let splitedString = audioUrlString.characters.split{$0 == "/"}.map(String.init)
            let fileName = splitedString[splitedString.count - 1]
            print("audioFilePath: \(self.getSoundFilePath(fileName))")
            print("audioFileName: \(fileName)")
            
            if (!self.isFileDownloaded(self.getSoundFilePath(fileName))) {
                let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)[0]
                let pathComponent = "Sounds/\(fileName)"
                let localPath = directoryURL.URLByAppendingPathComponent(pathComponent)
                self.fileURLs.append(audioUrlString)
                self.fileDestinations.append(localPath)
                
                /*
                var localPath: NSURL?
                Alamofire.download(.GET,
                    audioUrlString,
                    destination: { (temporaryURL, response) in
                        let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)[0]
                        let pathComponent = "Sounds/\(fileName)"
                        
                        localPath = directoryURL.URLByAppendingPathComponent(pathComponent)
                        return localPath!
                })
                    .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                        print(totalBytesRead)
                        
                        // This closure is NOT called on the main queue for performance
                        // reasons. To update your ui, dispatch to the main queue.
                        dispatch_async(dispatch_get_main_queue()) {
                            print("Total bytes read on main queue: \(totalBytesRead)")
                        }
                    }
                    .response { request, response, _, error in
                        if let error = error {
                            print("Failed with error: \(error)")
                        } else {
                            print("Downloaded file successfully at \(localPath!)")
                        }
                } 
                 */
            } else {
                print("file \(fileName) downloaded")
                self.audioDownloaded = true
            }
        }
        
        if (!(self.videoDownloaded && self.audioDownloaded)) {
            self.downloadFile()
        } else {
            self.delegate?.finishedDownloadResources()
        }
     */
    }
    
    func downloadFile() -> Void {
        /*
        if let url = self.fileURLs.popLast() {
            Alamofire.download(.GET,
                url,
                destination: { (temporaryURL, response) in
                    let path = self.fileDestinations.popLast()
                    return path!
            })
                .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                    // This closure is NOT called on the main queue for performance
                    // reasons. To update your ui, dispatch to the main queue.
                    dispatch_async(dispatch_get_main_queue()) {
                        // print("Total bytes read on main queue: \((Float(totalBytesRead) / Float(totalBytesExpectedToRead)) * 100.0) : \(totalBytesRead) \(totalBytesExpectedToRead)")
                        var percent = (Int(floor(((Float(totalBytesRead) / Float(totalBytesExpectedToRead)) * 100.0)))) / 2
                        percent = self.basePercent + percent
                        if (percent != 100) {
                            self.percentageLabel.text = "\(percent)%"
                        }
                        let progress = ((CGFloat(totalBytesRead) / CGFloat(totalBytesExpectedToRead)) / 2.0) + self.baseProgress
                        self.progressBar.setProgress(progress, animated: false)
                    }
                }
                .response { request, response, _, error in
                    if let error = error {
                        print("Failed with error: \(error)")
                    } else {
                        print("Downloaded file successfully")
                        if (self.fileURLs.count > 0) {
                            self.downloadFile()
                            self.basePercent = 50
                            self.baseProgress = 0.5
                        } else {
                            self.delegate?.finishedDownloadResources()
                        }
                    }
            }
        }
     */
    }
    
    func initSingleDownload() {
        /*
        if let videoUrlString = self.videoUrlString {
            let splitedString = videoUrlString.characters.split{$0 == "/"}.map(String.init)
            let fileName = splitedString[splitedString.count - 1]
            print("videoFilePath: \(self.getVideoFilePath(fileName))")
            print("videoFileName: \(fileName)")
            
            if (!self.isFileDownloaded(self.getVideoFilePath(fileName))) {
                let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                let pathComponent = "video/\(fileName)"
                let localPath: NSURL = directoryURL.URLByAppendingPathComponent(pathComponent)
                self.fileURLs.append(videoUrlString)
                self.fileDestinations.append(localPath)
                self.downloadSingleFile()
                let clipName = fileName.characters.split{$0 == "."}.map(String.init)
                AdapterHTTPService.sharedInstance.loadClip(clipName[0])
            } else {
                self.delegate?.finishedDownloadResources()
            }
        }
    }
    
    func downloadSingleFile() -> Void {
        if let url = self.fileURLs.popLast() {
            Alamofire.download(.GET,
                url,
                destination: { (temporaryURL, response) in
                    let path = self.fileDestinations.popLast()
                    return path!
            })
                .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                    // This closure is NOT called on the main queue for performance
                    // reasons. To update your ui, dispatch to the main queue.
                    dispatch_async(dispatch_get_main_queue()) {
                        // print("Total bytes read on main queue: \((Float(totalBytesRead) / Float(totalBytesExpectedToRead)) * 100.0) : \(totalBytesRead) \(totalBytesExpectedToRead)")
                        var percent = (Int(floor(((Float(totalBytesRead) / Float(totalBytesExpectedToRead)) * 100.0))))
                        percent = self.basePercent + percent
                        if (percent != 100) {
                            self.percentageLabel.text = "\(percent)%"
                        }
                        let progress = ((CGFloat(totalBytesRead) / CGFloat(totalBytesExpectedToRead))) + self.baseProgress
                        self.progressBar.setProgress(progress, animated: false)
                    }
                }
                .response { request, response, _, error in
                    if let error = error {
                        print("Failed with error: \(error)")
                    } else {
                        print("Downloaded file successfully")
                        if (self.fileURLs.count > 0) {
                            self.downloadFile()
                            self.basePercent = 50
                            self.baseProgress = 0.5
                        } else {
                            self.delegate?.finishedDownloadResources()
                        }
                    }
            }
        }
     */
    }

}
