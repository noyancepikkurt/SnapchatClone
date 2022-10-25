//
//  UploadVC.swift
//  SnapchatClone
//
//  Created by Noyan Çepikkurt on 12.10.2022.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosePicture))
        imageView.addGestureRecognizer(gestureRecognizer)
       
    }
    
    @objc func choosePicture() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker .sourceType = .photoLibrary
        self.present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
   
    @IBAction func uploadClicked(_ sender: Any) {
   
        let storage = Storage.storage()
        let storeReference = storage.reference()
        
        let mediaFolder = storeReference.child("media")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
            
            let uuid = UUID().uuidString
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            
            imageReference.putData(data, metadata: nil) { metadata, error in
                if error != nil {
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                } else {
                    
                    imageReference.downloadURL { url, error in
                        if error == nil {
                            
                            let imageURL = url?.absoluteString
                            
                            //FireStore
                            
                            let fireStore = Firestore.firestore()
                            
                            fireStore.collection("Snaps").whereField("snapOwner", isEqualTo: UserSingleton.sharedUserInfo.username).getDocuments { snapshot, error in
                                
                                if error != nil {
                                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                } else {
                                    if snapshot?.isEmpty == false && snapshot != nil {
                                        for document in snapshot!.documents {
                                            
                                            let documentId = document.documentID
                                            
                                            if var imageUrlArray = document.get("imageUrlArray") as? [String] {
                                                imageUrlArray.append(imageURL!)
                                                
                                                let additionalDictionary = ["imageUrlArray" : imageUrlArray] as [String : Any]
                                                
                                                fireStore.collection("Snaps").document(documentId).setData(additionalDictionary, merge: true) { error in
                                                    if error == nil {
                                                        self.tabBarController?.selectedIndex = 0
                                                        self.imageView.image = UIImage(named: "selectImage.png")
                                                    }
                                                }
                                                
                                            }
                                        }
                                    } else {
                                        let snapDictionary = ["imageUrlArray" : [imageURL!], "snapOwner" : UserSingleton.sharedUserInfo.username, "date" : FieldValue.serverTimestamp()] as [String : Any]
                                        
                                        fireStore.collection("Snaps").addDocument(data: snapDictionary) { error in
                                            if error != nil {
                                                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                            } else {
                                                self.tabBarController?.selectedIndex = 0
                                                self.imageView.image = UIImage(named: "selectImage.png")
                                            }
                                        }
                                    }
                                }
                            }
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
