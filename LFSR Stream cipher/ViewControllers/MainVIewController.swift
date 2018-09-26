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
    browse.title                   = "Choose a file"
    browse.showsResizeIndicator    = true
    browse.canChooseDirectories    = false
    browse.canCreateDirectories    = true
    browse.allowsMultipleSelection = false
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
    var outputBuff: [UInt8] = []
    var inputBuff: [UInt8] = []
    var keyBuff: [UInt8] = []
    
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
            if (keyGenerated.stringValue.count < 24)||(keyGenerated.stringValue.count > 64) {
                 dialogError(question: "Please, specify the key!", text: "Error: key must be from 24 to 64 bits.")
            } else {
                let LFSR = LFSRkey(key: keyGenerated.stringValue)
                keyBuff = LFSR.generateLFSR(len: inputBuff.count)
                keyGenerated.stringValue = ""
                for i in keyBuff {
                    if keyGenerated.stringValue.count <= 10000 {
                        var tempS = String(i, radix: 2)
                        while tempS.count < 8 {
                            tempS = "0" + tempS
                        }
                        keyGenerated.stringValue += tempS
                    } else {
                        break
                    }
                }
                outputBuff = []
                encipheredFile.stringValue = ""
                for i in 0...inputBuff.count-1 {
                    let kek: UInt8 = inputBuff[i] ^ keyBuff[i]
                    outputBuff.append(kek)
                    if encipheredFile.stringValue.count <= 10000 {
                        var tempS = String(kek, radix: 2)
                        while tempS.count < 8 {
                            tempS = "0" + tempS
                        }
                        encipheredFile.stringValue += tempS
                    }
                }
                
            }
        } else {
            dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
    
    @IBAction func Decode(_ sender: Any) {
        if encipheredFile.stringValue.count > 0 {
            keyGenerated.stringValue = keyGenerated.stringValue.filter { return ["0","1"].contains($0) }
            if (keyGenerated.stringValue.count < 24)||(keyGenerated.stringValue.count > 64) {
                dialogError(question: "Please, specify the key!", text: "Error: key must be from 24 to 64 bits.")
            } else {
                let LFSR = LFSRkey(key: keyGenerated.stringValue)
                keyBuff = LFSR.generateLFSR(len: outputBuff.count)
                keyGenerated.stringValue = ""
                for i in keyBuff {
                    if keyGenerated.stringValue.count <= 10000 {
                        var tempS = String(i, radix: 2)
                        while tempS.count < 8 {
                            tempS = "0" + tempS
                        }
                        keyGenerated.stringValue += tempS
                    } else {
                        break
                    }
                }
                inputBuff = []
                represOfFile.stringValue = ""
                for i in 0...outputBuff.count-1 {
                    let kek: UInt8 = outputBuff[i] ^ keyBuff[i]
                    inputBuff.append(kek)
                    if represOfFile.stringValue.count <= 10000 {
                        var tempS = String(kek, radix: 2)
                        while tempS.count < 8 {
                            tempS = "0" + tempS
                        }
                        represOfFile.stringValue += tempS
                    }
                }
            }
        } else {
            dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
    
    @IBAction func LoadBtn(_ sender: NSButton) {
        let fileURL = URL(string: browseFile(sender: self))
        if fileURL != nil {
            let filePath = fileURL!.path
            var fileSize: UInt64 = 0
            do {
                let attr = try FileManager.default.attributesOfItem(atPath: filePath)
                fileSize = attr[FileAttributeKey.size] as! UInt64
                let dict = attr as NSDictionary
                fileSize = dict.fileSize()
            } catch {
                
            }
            let inputStream = InputStream(fileAtPath: fileURL!.path)!
       //     var inputBuffer = [UInt8](repeating: 0, count: Int(fileSize))
            switch sender.tag {
            case 0:
                inputBuff = [UInt8](repeating: 0, count: Int(fileSize))
                inputStream.open()
                inputStream.read(&inputBuff, maxLength: Int(fileSize))
                inputStream.close()
                represOfFile.stringValue = ""
                outerLoop: for i in inputBuff {
                    if represOfFile.stringValue.count >= 10000 {
                        break outerLoop
                    }
                    var str = String(i, radix: 2)
                    while str.count < 8 {
                        str = "0" + str
                    }
                    represOfFile.stringValue.append(str)
                }
            case 1:
                outputBuff = [UInt8](repeating: 0, count: Int(fileSize))
                inputStream.open()
                inputStream.read(&outputBuff, maxLength: Int(fileSize))
                inputStream.close()
                encipheredFile.stringValue = ""
                outerLoop: for i in outputBuff {
                    if encipheredFile.stringValue.count >= 10000 {
                        break outerLoop
                    }
                    var str = String(i, radix: 2)
                    while str.count < 8 {
                        str = "0" + str
                    }
                    encipheredFile.stringValue.append(str)
                }
            default:
                break
            }
        }
    }
    
    @IBAction func SaveBtn(_ sender: NSButton) {
        let fileURL = URL(string: browseFile(sender: self))
        if fileURL != nil {
            let outputStream = OutputStream(toFileAtPath: fileURL!.path, append: false)!
      //      var outputBuffer: [UInt8] = []
            switch sender.tag {
            case 0:
                outputStream.open()
                outputStream.write(inputBuff, maxLength: inputBuff.count)
                outputStream.close()
            case 1:
                outputStream.open()
                outputStream.write(outputBuff, maxLength: outputBuff.count)
                outputStream.close()
            default:
                break
            }
        }
    }
    
    
}
