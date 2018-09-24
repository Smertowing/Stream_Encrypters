//
//  MainVIewController.swift
//  LFSR Stream cipher
//
//  Created by Kiryl Holubeu on 9/24/18.
//  Copyright © 2018 Kiryl Holubeu. All rights reserved.
//

import Cocoa

fileprivate extension String {
    subscript(i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
}



func browseFile(sender: AnyObject) -> String {
    let browse = NSOpenPanel()
    browse.title                   = "Choose a .txt file"
    browse.showsResizeIndicator    = true
    browse.canChooseDirectories    = false
    browse.canCreateDirectories    = true
    browse.allowsMultipleSelection = false
    browse.allowedFileTypes = ["txt"]
    if (browse.runModal() == NSApplication.ModalResponse.OK) {
        let result = browse.url
        
        if (result != nil) {
            return result!.path
        }
    }
    return ""
}

func dialogError(question: String, text: String) {
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .critical
    alert.addButton(withTitle: "Ok")
    alert.runModal()
}

class MainVIewController: NSViewController {
    var keyGen: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyGenerated.stringValue = "101010101010101010101010"
    }
    
    @IBOutlet weak var represOfFile: NSTextField!
    @IBOutlet weak var keyGenerated: NSTextField!
    @IBOutlet weak var encipheredFile: NSTextField!
    
    @IBAction func Encode(_ sender: Any) {
        if represOfFile.stringValue.count > 0 {
            keyGenerated.stringValue = keyGenerated.stringValue.filter { return ["0","1"].contains($0) }
            if keyGenerated.stringValue.count < 24 {
                 dialogError(question: "Please, specify the key!", text: "Error: key is too short.")
            } else {
                let LFSR = LFSRkey(key: keyGenerated.stringValue)
                keyGen = LFSR.generateLFSR(len: represOfFile.stringValue.count)
                keyGenerated.stringValue = keyGen
                
                var tempStr:String = ""
                for i in 0...represOfFile.stringValue.count-1 {
                    tempStr += String(Int(String(keyGenerated.stringValue[i]))! ^ Int(String(represOfFile.stringValue[i]))!)
                }
                encipheredFile.stringValue = tempStr
            }
        } else {
            dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
    
    @IBAction func Decode(_ sender: Any) {
        if encipheredFile.stringValue.count > 0 {
            keyGenerated.stringValue = keyGenerated.stringValue.filter { return ["0","1"].contains($0) }
            if keyGenerated.stringValue.count < 24 {
                dialogError(question: "Please, specify the key!", text: "Error: key is too short.")
            } else {
                let LFSR = LFSRkey(key: keyGenerated.stringValue)
                keyGen = LFSR.generateLFSR(len: encipheredFile.stringValue.count)
                keyGenerated.stringValue = keyGen
                
                var tempStr: String = ""
                for i in 0...encipheredFile.stringValue.count-1 {
                    tempStr += String(Int(String(keyGenerated.stringValue[i]))! ^ Int(String(encipheredFile.stringValue[i]))!)
                }
                represOfFile.stringValue = tempStr
            }
        } else {
        dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
    
    @IBAction func LoadBtn(_ sender: NSButton) {
        let fileURL = URL(fileURLWithPath: browseFile(sender: self))
        if fileURL.path == "" {
        } else {
            let inputStream = InputStream(fileAtPath: fileURL.path)!
            var inputBuffer = [UInt8](repeating: 0, count: 32478734 * 4)
            inputStream.open()
            inputStream.read(&inputBuffer, maxLength: inputBuffer.count)
            inputStream.close()
            
            switch sender.tag {
            case 0:
                represOfFile.stringValue = ""
                outerLoop: for i in inputBuffer {
                    var str = String(i, radix: 2)
                    while str.count < 8 {
                        str = "0" + str
                    }
                    if str != "00000000" {
                        represOfFile.stringValue.append(str)
                    } else {
                        break outerLoop
                    }
                }
            case 1:
                encipheredFile.stringValue = ""
                outerLoop: for i in inputBuffer {
                    var str = String(i, radix: 2)
                    while str.count < 8 {
                        str = "0" + str
                    }
                    if str != "00000000" {
                        encipheredFile.stringValue.append(str)
                    } else {
                        break outerLoop
                    }
                }
            default:
                break
            }
        }
    }
    
    @IBAction func SaveBtn(_ sender: NSButton) {
        let fileURL = URL(fileURLWithPath: browseFile(sender: self))
        if fileURL.path == "" {
        } else {
            let outputStream = OutputStream(toFileAtPath: fileURL.path, append: false)!
            var outputBuffer: [UInt8] = []
            var tempString: String = ""
            switch sender.tag {
            case 0:
                tempString = represOfFile.stringValue
            case 1:
                tempString = encipheredFile.stringValue
            default:
                break
            }
            while tempString.count > 0 {
                var tempUInt8: UInt8 = 0
                for i in 0...7 {
                    if tempString.removeFirst() == "1" {
                        tempUInt8 += UInt8(pow(Double(2), Double(7-i)))
                    }
                }
                outputBuffer.append(tempUInt8)
            }
            outputStream.open()
            outputStream.write(outputBuffer, maxLength: outputBuffer.count)
            outputStream.close()
        }
    }
    
    
}
