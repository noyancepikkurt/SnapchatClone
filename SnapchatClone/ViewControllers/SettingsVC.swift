//
//  SettingsVC.swift
//  SnapchatClone
//
//  Created by Noyan Çepikkurt on 12.10.2022.
//

import UIKit
import FirebaseAuth

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func logOutClicked(_ sender: Any) {
   
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "toSignInVC", sender: nil)
        } catch {
            
        }
    }
    

}
