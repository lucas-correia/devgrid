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

//MARK: - • OTHERS IMPORTS

//MARK: - • EXTENSIONS

//MARK: - • CLASS

class CameraQR_VC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //MARK: - • LOCAL DEFINES
    
    
    //MARK: - • PUBLIC PROPERTIES
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]
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
            captureMetadataOutput.rectOfInterest = CGRect(x: 0, y: 0, width: imgCode.frame.width, height: imgCode.frame.height);
            captureSession!.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession!.startRunning()
        
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    //MARK: - • INTERFACE/PROTOCOL METHODS
    
    
    //MARK: - • PUBLIC METHODS
    
    
    //MARK: - • ACTION METHODS
    
    
    //MARK: - • PRIVATE METHODS (INTERNAL USE ONLY)
    private func setupLayout() {
        
        var width = previewView.frame.size.width * 0.8;
        var height = width;
        rectScanSizeWidthConstraint.constant = width;
        rectScanSizeHeightConstraint.constant = height;
        self.view.layoutIfNeeded()
        
        var extHeight:CGFloat = previewView.frame.size.height;
        var extWidth:CGFloat = previewView.frame.size.width;
        var intHeight:CGFloat =  height;
        var intWidth:CGFloat =  width;
        
        var externalPath = UIBezierPath.init(roundedRect: CGRect.init(x: -(extWidth-intWidth)/2.0, y: -(extHeight-intHeight)/2.0, width: extWidth, height: extHeight), cornerRadius: 0)
        var internalPath = UIBezierPath.init(roundedRect: CGRect.init(x: 0, y: 0, width: intWidth, height: intHeight), cornerRadius: 0)
        externalPath.append(internalPath)
        externalPath.usesEvenOddFillRule = true
        
        var fillLayer = CAShapeLayer.init()
        fillLayer.path = externalPath.cgPath
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.5
        viewOfInterest.layer .addSublayer(fillLayer)
        
        var borderPath = UIBezierPath()
        //TODO: AQUI
        
//        borderPath.move(to: CGPoint.)
        
        
//        UIBezierPath* borderPath = [UIBezierPath bezierPath];
//
//        //TOP LEFT
//        [borderPath moveToPoint:CGPointMake(1, 25)];
//        [borderPath addLineToPoint:CGPointMake(1, 1)];
//        [borderPath addLineToPoint:CGPointMake(25, 1)];
//        //TOP RIGHT
//        [borderPath moveToPoint:CGPointMake(intWidth - 26, 1)];
//        [borderPath addLineToPoint:CGPointMake(intWidth - 1, 1)];
//        [borderPath addLineToPoint:CGPointMake(intWidth - 1, 25)];
//        //BOTTOM LEFT
//        [borderPath moveToPoint:CGPointMake(1, intHeight - 26)];
//        [borderPath addLineToPoint:CGPointMake(1, intHeight - 1)];
//        [borderPath addLineToPoint:CGPointMake(25, intHeight - 1)];
//        //BOTTOM RIGHT
//        [borderPath moveToPoint:CGPointMake(intWidth - 26, intHeight - 1)];
//        [borderPath addLineToPoint:CGPointMake(intWidth - 1, intHeight - 1)];
//        [borderPath addLineToPoint:CGPointMake(intWidth - 1, intHeight - 26)];
//
//        CAShapeLayer *pathLayer = [CAShapeLayer layer];
//        pathLayer.path = borderPath.CGPath;
//        pathLayer.strokeColor = AppD.styleManager.colorPalette.backgroundNormal.CGColor;
//        pathLayer.lineWidth = 5.0f;
//        pathLayer.fillColor = nil;
//
//        [viewOfInterest.layer addSublayer:pathLayer];
        
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


