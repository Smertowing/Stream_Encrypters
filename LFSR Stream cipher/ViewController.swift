//
//  ViewController.swift
//  LFSR Stream cipher
//
//  Created by Kiryl Holubeu on 9/16/18.
//  Copyright © 2018 Kiryl Holubeu. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    @IBOutlet weak var represOfFile: NSTextField!
    @IBOutlet weak var keyGenerated: NSTextField!
    @IBOutlet weak var encipheredFile: NSTextField!
    
    @IBAction func GenerateAct(_ sender: Any) {
        
    }
    
    @IBAction func LoadBtn(_ sender: NSButton) {
        
    }
    
    @IBAction func SaveBtn(_ sender: NSButton) {
        
    }
    
}

