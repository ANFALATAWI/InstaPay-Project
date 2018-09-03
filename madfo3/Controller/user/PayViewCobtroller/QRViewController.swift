//
//  QRViewController.swift
//  madfo3
//
//  Created by Ebtsam alkhuzai on 11/5/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit

class QRViewController: UIViewController {

    @IBOutlet weak var qrView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        qrView.layer.cornerRadius = 10
        qrView.layer.shadowOffset = CGSize(width: -1, height: 1)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
