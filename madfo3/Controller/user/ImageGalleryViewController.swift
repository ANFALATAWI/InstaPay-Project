//
//  ImageGalleryViewController.swift
//  madfo3
//
//  Created by Anfal Alatawi on 05/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit

class ImageGalleryViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    //var awayImage : CIImage = CIImage(image: #imageLiteral(resourceName: "qr-code"))!
    var x : UIImage?
    var code : String?
    
    
    @IBAction func cancelButton3(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func importButton(_ sender: Any) {
        
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true)
        {
            //After it is complete
           
            
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imageView.image = image
            print("After image view")
            //var ciImage = CIImage(image: uiImage)
            x = image
        }
        else
        {
            //Error message
        }
        
        
        //code = performQRCodeDetection(image: x!)
        if let features = detectQRCode(x), !features.isEmpty{
            for case let row as CIQRCodeFeature in features{
                print(row.messageString ?? "nope")
                code = row.messageString
            }
        }
        
        ///////////////////// maybe switch the order of these two
        
        
        self.dismiss(animated: true, completion: nil)
        launchApp(decodedURL: code!)
        
        print("First message")
        
        print("Second message")
    }
    
    //**********************
    func launchApp(decodedURL: String) {
        
//        if presentedViewController != nil {
//            return
//        }
        //CHANGE
      //  print("Here!!!")
        //vv
      //  let alertPrompt = pay(decodedURL: decodedURL)
        //        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (action) -> Void in
        //        //^^
        //
        //            if let url = URL(string: decodedURL) {
        //                if UIApplication.shared.canOpenURL(url) {
        //                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
        //                }
        //            }
        //        })
        
       // let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
      //   let action = UIAlertAction(title: "add Friend", style: .default)
       // alertPrompt.addAction(action)
        
        //alertPrompt.addAction(con)
       // alertPrompt.addAction(cancelAction)
        
       // present(alertPrompt, animated: true, completion: nil)
    }

    
    //*******************************************
    func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        if let image = image, let ciImage = CIImage.init(image: image){
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            }else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            return features
            
        }
        return nil
    }
//    var detector: CIDetector?
//
//
//    func performQRCodeDetection(image: CIImage) ->String {
//        var resultImage: CIImage?
//        var decode = ""
//        if let detector = detector {
//            let features = detector.features(in: image)
//            for feature in features as! [CIQRCodeFeature] {
//                resultImage = drawHighlightOverlayForPoints(image,
//                                                            topLeft: feature.topLeft,
//                                                            topRight: feature.topRight,
//                                                            bottomLeft: feature.bottomLeft,
//                                                            bottomRight: feature.bottomRight)
//                decode = feature.messageString!
//            }
//        }
//        return decode
//    }
//
////    //*******************************************
//
//
////    //*******************************************
//
//    func drawHighlightOverlayForPoints(_ image: CIImage, topLeft: CGPoint, topRight: CGPoint,
//                                       bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
//        var overlay = CIImage(color: CIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5))
//        overlay = overlay.cropped(to: image.extent)
//        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
//                                         parameters: [
//                                            "inputExtent": CIVector(cgRect: image.extent),
//                                            "inputTopLeft": CIVector(cgPoint: topLeft),
//                                            "inputTopRight": CIVector(cgPoint: topRight),
//                                            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
//                                            "inputBottomRight": CIVector(cgPoint: bottomRight)
//            ])
//        return overlay.composited(over: image)
//    }

//**************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

/*
func pay(decodedURL: String) -> UIAlertController
{
    //create a ui alert
    let alert = UIAlertController(title: "Pay \(decodedURL)", message: "Enter $$ to pay", preferredStyle: UIAlertControllerStyle.alert)
    
    //creat a ui action
    let action = UIAlertAction(title: "Pay", style: .default) { (alertAction) in
        let textField = alert.textFields![0] as UITextField
    }
    
    //you add the text field here and tell it additionalo info in the closure block
    alert.addTextField { (textField) in
        textField.placeholder = "amount"
    }
    
    //present
    
    alert.addAction(action)
    
    return alert
    
}*/





