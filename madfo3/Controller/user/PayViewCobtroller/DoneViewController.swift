//
//  DoneViewController.swift
//  instaPay
//
//  Created by Ebtsam alkhuzai on 15/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class DoneViewController: UIViewController , NVActivityIndicatorViewable
{
    
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var done: UIImageView!
    @IBOutlet weak var check: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        check.color = .white
        check.type = NVActivityIndicatorType.ballClipRotate
        check.startAnimating()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.check.stopAnimating()
            self.done.image = UIImage(named: "success")
            self.doneLabel.text = "Done successfuly"
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.performSegue(withIdentifier: "done", sender: self)
        }
 

 }

   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
