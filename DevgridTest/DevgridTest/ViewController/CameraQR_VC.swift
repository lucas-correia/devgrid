//
//  CameraQR_VC.swift
//  DevgridTest
//
//  Created by lucas on 05/12/18.
//  Copyright © 2018 Lab360. All rights reserved.
//

//MARK: - • INTERFACE HEADERS

//MARK: - • FRAMEWORK HEADERS
import UIKit
import AVFoundation
import AudioToolbox

//MARK: - • OTHERS IMPORTS

//MARK: - • EXTENSIONS

//MARK: - • CLASS

class CameraQR_VC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //MARK: - • LOCAL DEFINES
    
    
    //MARK: - • PUBLIC PROPERTIES
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    let supportedCodeTypes =  [AVMetadataObject.ObjectType.qr]
    //
    @IBOutlet weak var previewView:UIView!
    @IBOutlet weak var viewOfInterest:UIView!
    @IBOutlet weak var rectScanSizeWidthConstraint:NSLayoutConstraint!
    @IBOutlet weak var rectScanSizeHeightConstraint:NSLayoutConstraint!
    
    //MARK: - • PRIVATE PROPERTIES
    
    
    //MARK: - • INITIALISERS
    
    
    //MARK: - • CUSTOM ACCESSORS (SETS & GETS)
    
    
    //MARK: - • DEALLOC
    
    deinit {
        // NSNotificationCenter no longer needs to be cleaned up!
    }
    
    //MARK: - • SUPER CLASS OVERRIDES
    
    
    //MARK: - • CONTROLLER LIFECYCLE/ TABLEVIEW/ DATA-SOURCE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.checkCamPermission()
        self.setupLayout()
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession!.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureMetadataOutput.rectOfInterest = self.view.frame //
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureSession!.addOutput(captureMetadataOutput)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
           
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = previewView.layer.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)
            previewView.bringSubviewToFront(viewOfInterest)
            
            // Start video capture.
            captureSession!.startRunning()
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    //MARK: - • INTERFACE/PROTOCOL METHODS
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array contains at least one object.
        if  metadataObjects.count  == 0 {
            previewView.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            previewView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                captureSession?.stopRunning()
                
                var gistId:String?
                if(metadataObj.stringValue!.contains("gist.github.com")){
                    
                    let url = URL(string: metadataObj.stringValue!)
                    gistId = url?.lastPathComponent
                    
                } else {
                    
                    gistId = metadataObj.stringValue
                    
                }
                print(gistId as Any)
                //TODO: CONNECTION
                
            }
        }
    }
    
    //MARK: - • PUBLIC METHODS
    
    
    //MARK: - • ACTION METHODS
    
    
    //MARK: - • PRIVATE METHODS (INTERNAL USE ONLY)
    private func setupLayout() {
        
        viewOfInterest.backgroundColor = nil
        
        //creating the target on screen
        let width = previewView.frame.size.width * 0.8;
        let height = width;
        rectScanSizeWidthConstraint.constant = width;
        rectScanSizeHeightConstraint.constant = height;
        self.view.layoutIfNeeded()
        
        //viewOfInterest.layer.sublayers?.forEach {$0.removeFromSuperlayer()}
        
        let extHeight:CGFloat = previewView.frame.size.height;
        let extWidth:CGFloat = previewView.frame.size.width;
        let intHeight:CGFloat =  height;
        let intWidth:CGFloat =  width;
        
        let externalPath = UIBezierPath.init(roundedRect: CGRect.init(x: -(extWidth-intWidth)/2.0, y: -(extHeight-intHeight)/2.0, width: extWidth, height: extHeight), cornerRadius: 0)
        let internalPath = UIBezierPath.init(roundedRect: CGRect.init(x: 0, y: 0, width: intWidth, height: intHeight), cornerRadius: 0)
        externalPath.append(internalPath)
        externalPath.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = externalPath.cgPath
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.5
        viewOfInterest.layer.addSublayer(fillLayer)
        
        let borderPath = UIBezierPath()
        
        //TOP LEFT
        borderPath.move(to: CGPoint(x: 1, y: 25))
        borderPath.addLine(to: CGPoint(x: 1, y: 1))
        borderPath.addLine(to: CGPoint(x: 25, y: 1))
        
        //TOP RIGHT
        borderPath.move(to: CGPoint(x: intWidth - 26, y: 1))
        borderPath.addLine(to: CGPoint(x: intWidth - 1, y: 1))
        borderPath.addLine(to: CGPoint(x: intWidth - 1, y: 25))
        
        //BOTTOM LEFT
        borderPath.move(to: CGPoint(x: 1, y: intHeight - 26))
        borderPath.addLine(to: CGPoint(x: 1, y: intHeight - 1))
        borderPath.addLine(to: CGPoint(x: 25, y: intHeight - 1))
        
        //TOPBOTTOMRIGHT
        borderPath.move(to: CGPoint(x: intWidth - 26, y: intHeight - 1))
        borderPath.addLine(to: CGPoint(x: intWidth - 1, y: intHeight - 1))
        borderPath.addLine(to: CGPoint(x: intWidth - 1, y: intHeight - 26))
        
        let pathLayer = CAShapeLayer()
        pathLayer.path = borderPath.cgPath
        pathLayer.strokeColor = UIColor.red.cgColor
        pathLayer.lineWidth = 5.0
        pathLayer.fillColor = nil
        
        viewOfInterest.layer.addSublayer(pathLayer)
        
    }
    private func checkCamPermission(){
        
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            // Already Authorized
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    // User granted
                }
            })
        }
    }
}


