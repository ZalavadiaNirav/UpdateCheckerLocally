//
//  UpdateChecker.swift
//  ForceUpdateDialogue
//
//  Created by Nirav  on 23/01/21.
//

import Foundation
import UIKit
//import FirebaseRemoteConfig
let kForceUpdateKey = "ios_force_update_require"
let kForceUpdateVersion = "ios_force_update_current_version"

enum AlertType
{
    case forceUpdate
    case optional
}

enum UpdateMsg : String
{
    case forceMsg = "Please Update Your Application and comeback again."
    case optionalMsg = "New Vesion Availble if you want you can download or continue."
}

class UpdateChecker : NSObject
{
    var latestCheckedDate = Date()
    var latestVersion = String()
    var presentingViewController : UIViewController?
    var isForceUpdate:Bool?
    
    override init()
    {
        super.init()
        if let remoteVersion = AppDelegate.shared?.remoteConfig?[kForceUpdateVersion], let forceUpdate = AppDelegate.shared?.remoteConfig?[kForceUpdateKey]
        {
         
            self.latestVersion = remoteVersion.stringValue ?? ""
            self.isForceUpdate = forceUpdate.boolValue
            print("latestVersion = \(self.latestVersion)")
            
            let obj = UserDefaults.standard.object(forKey: "latestVersionChecked")
            if let objDate = obj as? Date
            {
                self.latestCheckedDate = objDate
            }
            
        }
    }
    
    private func getLocalVersion() -> String
    {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        guard let appVersionString = appVersion as? String, let appBuildString = appBuild as? String else { return ("Please add version") }
        return appVersionString + String("." + appBuildString)
    }
    
    func checkVersionDaily()
    {
        if self.latestCheckedDate == nil
        {
            self.latestCheckedDate = Date()
            self.checkVersion()
        }
        else
        {
            if calculateNumberOfDay()>=1
            {
                self.checkVersion()
                self.latestCheckedDate = Date()
                UserDefaults.standard.set(self.latestCheckedDate, forKey: "latestVersionChecked")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    func checkVersion()
    {
        if presentingViewController == nil
        {
            print("Presnet viewcontroller first")
        }
        else
        {
            self.performCheckVersion()
        }
    }
    
    func performCheckVersion()
    {
        if compareVersion(newVersion: self.latestVersion, currentVersion: self.getLocalVersion())
        {
           showAlertWithOption()
        }
        else
        {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                if topController.isKind(of: UIAlertController.self)
                {
                    DispatchQueue.main.async {
                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func showAlertWithOption()
    {
        let choosenAlertType:AlertType = self.isForceUpdate == true ? AlertType.forceUpdate : AlertType.optional
        switch (choosenAlertType) {
        case .forceUpdate:
        do {
            let alertController = self.createAlert()
            self.showAlertController(alertController: alertController)
            break
        }
        case .optional:
            let alertController = self.createAlert()
            alertController.addAction(okAlertAction())
            self.showAlertController(alertController: alertController)
            
            break
        }
    }
    
    func showAlertController(alertController:UIAlertController)
    {
        if (self.presentingViewController != nil) {
            DispatchQueue.main.async
            {
                self.presentingViewController?.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func createAlert() -> UIAlertController
    {
        let kMsg = self.isForceUpdate == true ? UpdateMsg.forceMsg : .optionalMsg
        let alertController = UIAlertController.init(title: "Update Available", message: kMsg.rawValue, preferredStyle: .alert)
        return alertController
    }
    
    func okAlertAction() -> UIAlertAction
    {
        let alertaction = UIAlertAction.init(title: "Ok", style: .default) { (action) in
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        return alertaction
    }
    
    
    func calculateNumberOfDay() -> Int
    {
        let currentCalendar = NSCalendar.current
        return currentCalendar.component(.day, from: self.latestCheckedDate)
    }
    
    func compareVersion(newVersion:String,currentVersion:String) -> (Bool)
    {
        if(currentVersion.compare(newVersion, options:.numeric, range:nil, locale: nil) == .orderedAscending)
        {
           return true
        }
        else
        {
            return false
        }
    }
 
}


