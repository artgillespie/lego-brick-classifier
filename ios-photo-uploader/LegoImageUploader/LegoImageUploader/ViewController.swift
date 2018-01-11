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

class ViewController: UIViewController {
    
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        let auth = Auth.auth()
        if let u = auth.currentUser  {
            print("Already signed in! \(u.providerData[0].email!)")
            self.user = u
        } else {
            auth.signIn(withEmail: "<>", password: "<>", completion: { (u: User?, e: Error?) in
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

