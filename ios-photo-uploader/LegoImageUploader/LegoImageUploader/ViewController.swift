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
import FirebaseDatabase

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var dbRef: DatabaseReference!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    func firebaseDidAuthenticate() {
        dbRef = Database.database().reference()
    }

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
                firebaseDidAuthenticate()
            } else {
                let email = dict.value(forKey: "email")! as! String
                let password = dict.value(forKey: "password")! as! String
                auth.signIn(withEmail: email, password: password, completion: { (u: User?, e: Error?) in
                    if let error = e {
                        print("Error logging in! \(error)")
                    } else if let user = u {
                        print("Logged in! \(user.providerData[0].email!)")
                        self.firebaseDidAuthenticate()
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
    
    func getImageCount(_ type: String) {
        // TODO: enumerate on the type's path
        dbRef.child("images/\(type)")
    }
    
    func scaleImage(_ image: UIImage, scaleBy: CGFloat) -> UIImage? {
        let size = image.size.applying(CGAffineTransform(scaleX: scaleBy, y: scaleBy))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    func uploadImage(_ image: UIImage, type: String) {
        let imageID = UUID().uuidString
        guard let scaledImage = self.scaleImage(image, scaleBy: 0.5) else {
            print("Couldn't scale image")
            return
        }
        
        // first write metadata to the realtime database so we can find this image later
        let mdRef = dbRef.child("images/\(type)/\(imageID)")
        progressView.isHidden = false
        mdRef.setValue(false, withCompletionBlock: { (error, _) in
            if error != nil {
                print("Couldn't write metadata to database: \(error!)")
                return
            }
            let storage = Storage.storage()
            let storageRef = storage.reference(withPath: "images/\(type)/\(imageID).jpg")
            guard let data = UIImageJPEGRepresentation(scaledImage, 0.75) else {
                print("couldn't get jpg representation")
                return
            }
            let uploadTask = storageRef.putData(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    print("Error uploading image: \(error!)")
                    return
                }
                mdRef.setValue(true)
                print("Upload OK! \(metadata)")
            }
            uploadTask.observe(.progress) { snapshot in
                let percentComplete = Double(snapshot.progress!.completedUnitCount)
                    / Double(snapshot.progress!.totalUnitCount)
                self.progressView.progress = Float(percentComplete)
            }
            uploadTask.observe(.success) {snapshot in
                self.progressView.isHidden = true
            }

        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        uploadImage(image, type: "test")        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}

