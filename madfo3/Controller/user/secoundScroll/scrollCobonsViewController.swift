//
//  scrollCobonsViewController.swift
//  instaPay
//
//  Created by Ebtsam alkhuzai on 22/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit

class scrollCobonsViewController: UIViewController {

    //Outlet:
    @IBOutlet weak var scroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

      HorizontalScrollView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //add scroll view to coubon tableview..
    func HorizontalScrollView(){

        let cobons = self.storyboard?.instantiateViewController(withIdentifier: "cobons") as! MainTableViewController
        
        self.addChildViewController(cobons)
        self.scroll.addSubview(cobons.view)
        self.didMove(toParentViewController: self)
        self.scroll.contentSize = CGSize(width: self.view.frame.width , height: self.view.frame.height)
        self.scroll.contentOffset.x = cobons.view.frame.origin.x
        
        
    }

}
