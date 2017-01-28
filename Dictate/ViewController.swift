//
//  ViewController.swift
//  Dictate
//
//  Created by Aaron on 26/1/17.
//  Copyright © 2017 Aaron Nguyen. All rights reserved.
//

import UIKit
import TesseractOCR
import AVFoundation

var language = "eng"

class ViewController: UIViewController, G8TesseractDelegate {

    @IBOutlet weak var cameraView: UIView!
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    var activityIndicator = UIActivityIndicatorView()
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        //activityIndicator = nil
    }
    
    var theBool: Bool = true {
        didSet {
            if theBool == false {
                captureSession.stopRunning()
                if let tesseract = G8Tesseract(language: "\(selectedLanguage)") {
                    
                    print("Thru to this stage")
                    
                    UIGraphicsBeginImageContextWithOptions(cameraView.bounds.size, true, 0)
                    cameraView.drawHierarchy(in: cameraView.bounds, afterScreenUpdates: true)
                
                    let scaledImage = scaleImage(image: UIGraphicsGetImageFromCurrentImageContext()!, maxDimension: 640)
                    
                    tesseract.delegate = self
                    tesseract.image = scaleImage(image: UIGraphicsGetImageFromCurrentImageContext()!, maxDimension: 640)
                    
                    if tesseract.image == scaledImage && tesseract.image == scaleImage(image: UIGraphicsGetImageFromCurrentImageContext()!, maxDimension: 640) {
                        print("Correct")
                    }
                    
                    tesseract.recognize()
                    
                }
            } else {
                captureSession.startRunning()
            }
        }
    }
    
    @IBOutlet weak var pause: UIButton!
    @IBAction func stopMotion(_ sender: Any) {
        print("pressed")
        pause.tintColor = UIColor.lightGray
        
        theBool = !theBool
        
    }
    
    @IBAction func revertBTNColour(_ sender: Any) {
        pause.tintColor = UIColor.black
    }
    
    let selectedLanguage = { () -> String in 
        //if language == "eng" {
            return language
        //}
    }()
    
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCapturePhotoOutput() //AVCapturePhotoOutput
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        let devices = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInDuoCamera, AVCaptureDeviceType.builtInTelephotoCamera,AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.unspecified)
        for device in (devices?.devices)! {
            if (device as AnyObject).position == AVCaptureDevicePosition.back {
                
                do {
                    
                    let input = try AVCaptureDeviceInput(device: device)
                    if captureSession.canAddInput(input) {
                        
                        captureSession.addInput(input)
                        //sessionOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                        
                        if captureSession.canAddOutput(sessionOutput) {
                            
                            captureSession.addOutput(sessionOutput)
                            captureSession.startRunning()
                            
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                            
                            cameraView.layer.addSublayer(previewLayer)
                            
                            previewLayer.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
                            previewLayer.bounds = cameraView.frame
                            
                        }
                        
                    }
                    
                } catch {
                    print(error.localizedDescription)
                }
                
            } else {
                print("No device")
            }
        }

        pause.tintColor = UIColor.black
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func progressImageRecognition(for tesseract: G8Tesseract!) {
        addActivityIndicator()
        print("Overall process: \(tesseract.progress)%")
        if tesseract.progress == 92 {
            let synth = AVSpeechSynthesizer()
            let utterance = AVSpeechUtterance(string: "\(tesseract.recognizedText!)")
            utterance.rate = 0.3
            utterance.voice = AVSpeechSynthesisVoice(language: selectedLanguage)
            synth.speak(utterance)
            
            let recognizedText = tesseract.recognizedText
            
            if recognizedText != nil {
                print(recognizedText!)
            }
            removeActivityIndicator()
            UIGraphicsEndImageContext()
        }
    }

    
}

