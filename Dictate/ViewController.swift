//
//  ViewController.swift
//  Dictate
//
//  Created by Aaron on 26/1/17.
//  Copyright © 2017 Aaron Nguyen. All rights reserved.
//

import UIKit
import TesseractOCR

var language = "eng"

class ViewController: UIViewController, G8TesseractDelegate {

    let selectedLanguage = { () -> String in 
        //if language == "eng" {
            return language
        //}
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.delegate = self
            tesseract.image = UIImage(named: "testPoem")?.g8_blackAndWhite()
            tesseract.recognize()
            
            let recognizedText = tesseract.recognizedText
            
            print(recognizedText!)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func progressImageRecognition(for tesseract: G8Tesseract!) {
        print("Overall process: \(tesseract.progress)%")
    }

}

