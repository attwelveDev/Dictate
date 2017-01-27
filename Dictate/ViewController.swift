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
    
    @IBOutlet weak var pause: UIButton!
    @IBAction func stopMotion(_ sender: Any) {
        print("pressed")
        pause.tintColor = UIColor.lightGray
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
    var sessionOutput = AVCaptureStillImageOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for device in devices! {
            if (device as AnyObject).position == AVCaptureDevicePosition.back {
                
                do {
                    
                    let input = try AVCaptureDeviceInput(device: device as! AVCaptureDevice)
                    if captureSession.canAddInput(input) {
                        
                        captureSession.addInput(input)
                        sessionOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                        
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
        
        if let tesseract = G8Tesseract(language: "\(selectedLanguage)") {
            tesseract.delegate = self
            tesseract.image = UIImage(named: "\(sessionOutput)")?.g8_blackAndWhite()
            tesseract.recognize()
            
            let recognizedText = tesseract.recognizedText
            
            print(recognizedText!)
        }
        
        pause.tintColor = UIColor.black
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func progressImageRecognition(for tesseract: G8Tesseract!) {
        print("Overall process: \(tesseract.progress)%")
        if tesseract.progress == 100 {
            let synth = AVSpeechSynthesizer()
            let utterance = AVSpeechUtterance(string: "\(tesseract.recognizedText)")
            utterance.rate = 0.5
            utterance.voice = AVSpeechSynthesisVoice(language: selectedLanguage)
            synth.speak(utterance)
        }
    }

}

