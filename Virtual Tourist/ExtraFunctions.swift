//
//  ExtraFunctions.swift
//  Virtual Tourist
//
//  Created by Komil Bagshi on 08/01/2019.
//  Copyright © 2019 KamelBaqshi. All rights reserved.
//

import Foundation
import UIKit

struct displayAlert {
    
    static func displayAlert(message: String, title: String, vc: UIViewController)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        alertController.addAction(OKAction)
        
        vc.present(alertController, animated: true, completion: nil)
    }
    
    
}

