//
//  FeedVC.swift
//  SnapchatClone
//
//  Created by Noyan Çepikkurt on 12.10.2022.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class FeedVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let fireStoreDataBase = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

      getUserInfo()
    }
    
    func getUserInfo() {
        
        fireStoreDataBase.collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email).getDocuments { snapshot, error in
            if error != nil {
                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
            } else {
                if snapshot?.isEmpty == false && snapshot != nil {
                    for document in snapshot!.documents {
                        if let username = document.get("username") as? String {
                            UserSingleton.sharedUserInfo.email = Auth.auth().currentUser!.email!
                            UserSingleton.sharedUserInfo.username = username
                        } else {
                            
                        }
                    }
                }
            }
        }
        
    }

    func makeAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }

}
