//
//  Utils.swift
//  MapDemo
//
//  Created by Milan on 07/10/22.
//

import Foundation
import UIKit

class Utils {
    
    static let shared = Utils()
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    class func getWindowMain() -> UIWindow? {
        return UIApplication.shared.delegate?.window!
    }
    
    class func getRootViewController() -> UIViewController? {
        return self.getWindowMain()?.rootViewController
    }
    
}

extension Utils {
    class func showAlertForAppSettings(title: String, message: String, allowCancel: Bool = true, completion: @escaping (Bool) -> ()) {
        
        let alertController: UIAlertController = UIAlertController(title: NSLocalizedString(title, comment: ""), message: NSLocalizedString(message, comment: ""), preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { (action) -> Void in
            
            let settingURL = URL(string: UIApplication.openSettingsURLString)!
            
            if(UIApplication.shared.canOpenURL(settingURL)) {
                UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
            }
            
            completion(false)
            
        }))
        
        if allowCancel {
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) -> Void in
                
                completion(false)
                
            }))
        }
        
        Utils.getRootViewController()?.present(alertController, animated: true, completion: nil)
    }
}
