//
//  ViewController.swift
//  LegoImageUploader
//
//  Created by Art Gillespie on 1/10/18.
//  Copyright © 2018 tapsquare. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "secrets", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            let auth = Auth.auth()
            if let u = auth.currentUser  {
                print("Already signed in! \(u.providerData[0].email!)")
                self.user = u
            } else {
                let email = dict.value(forKey: "email")! as! String
                let password = dict.value(forKey: "password")! as! String
                auth.signIn(withEmail: email, password: password, completion: { (u: User?, e: Error?) in
                    if let error = e {
                        print("Error logging in! \(error)")
                    } else if let user = u {
                        print("Logged in! \(user.providerData[0].email!)")
                        self.user = user
                    } else {
                        print("Both user and error are nil :-(")
                    }
                })
            }
        } else {
            print("Couldn't lead secrets plist")
        }
    }

    @IBAction func handlePhotoButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Can't pick from camera")
            return
        }
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Image Picked! \(info[UIImagePickerControllerMediaType] as! String)")
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image picker canceled!")
    }

}

