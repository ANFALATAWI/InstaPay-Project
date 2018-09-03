//
//  MHomeViewController.swift
//  instaPay
//
//  Created by Ebtsam alkhuzai on 11/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseDatabase

class MHomeViewController: UIViewController {

    //Vars:
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var ref:DatabaseReference?
    
    //Constant:
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    //OUTLETS:
    @IBOutlet weak var messageLabel: UILabel!
    
    
    //stop running when this interface do'es not appear ..
    override func viewWillDisappear(_ animated: Bool) {
        captureSession.stopRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:[AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.back)
        
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubview(toFront: messageLabel)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    
    func launchApp(decodedURL: String) {
        
        if presentedViewController != nil {
            return
        }
        
        //CHANGE
        
        
        //to refrence fire base
         ref = Database.database().reference()
        //to get current user from firebase ..
         let userID = Auth.auth().currentUser?.uid
        
           //check if detected QR is coupons , if it's true perform segue to buying coupons
        self.ref?.child("users").child("merchants").child(userID!).child("cobons").observe(.childAdded) {(snapshot) in
             print(snapshot.key)
            if snapshot.key == decodedURL {
              self.performSegue(withIdentifier: "detectCobon", sender: self)
            } else {
                print("error")
            }
            
        }
          //check if detected QR is customer , if it's true perform segue to create coupons
        self.ref?.child("users").child("customer").observe(.childAdded) {(snapshot) in
            if snapshot.key == decodedURL {
                self.performSegue(withIdentifier: "createCobon", sender: self)
            }else {
                print("error, this QR means nothing .. ")}
        }
    }

}


extension MHomeViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        
        // Get the metadata object.
        
        metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if supportedCodeTypes.contains((metadataObj?.type)!) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj!)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj?.stringValue != nil {
                launchApp(decodedURL: (metadataObj?.stringValue!)!)
                messageLabel.text = metadataObj?.stringValue
            }
        }
        
    }
    
}
