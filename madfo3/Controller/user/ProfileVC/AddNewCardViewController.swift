//
//  AddNewCardViewController.swift
//  instaPay
//
//  Created by Ebtsam alkhuzai on 08/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit

class AddNewCardViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var numberOfCard: UITextField!
    @IBOutlet weak var expiryDate: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var nameOnCard: UITextField!
    

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNewCard(_ sender: Any) {

    if (nameOnCard.text?.isEmpty)! || (numberOfCard.text?.isEmpty)! || (expiryDate.text?.isEmpty)! || (password.text?.isEmpty)!{
            
            let alert = UIAlertController(title: "Error", message: "some thing missing", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else{
            dismiss(animated: true, completion: nil)
        }
    }
    

}
