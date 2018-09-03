//
//  MScrollViewController.swift
//  instaPay
//
//  Created by Ebtsam alkhuzai on 11/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit

class MScrollViewController: UIViewController {
    
    //OUTLETS:
    @IBOutlet weak var mScroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loading Scroll View:
        HorizontalScrollView()
    }
    
    //Loads the view:
    func  HorizontalScrollView(){
        
        //creating StoryBoard references:
        let home = self.storyboard?.instantiateViewController(withIdentifier: "home") as! MHomeViewController
        //adding to the view:
        self.addChildViewController(home)
        //adding subview:
        self.mScroll.addSubview(home.view)
        self.didMove(toParentViewController: self)
        
        let profile = self.storyboard?.instantiateViewController(withIdentifier: "profile") as! MProfileViewController
        self.addChildViewController(profile)
        self.mScroll.addSubview(profile.view)
        self.didMove(toParentViewController: self)
        
        //setting height and width:
        var profileFrame : CGRect = profile.view.frame
        profileFrame.origin.x =  self.view.frame.width
        profile.view.frame = profileFrame
        self.mScroll.contentSize = CGSize(width: (self.view.frame.width) * 2 , height: self.view.frame.height)
        self.mScroll.contentOffset.x = home.view.frame.origin.x
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
