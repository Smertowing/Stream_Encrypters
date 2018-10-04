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
//    browse.directoryURL = URL(fileURLWithPath: "~/test", isDirectory: true)
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
    var outputBuff: [UInt8] = []
    var inputBuff: [UInt8] = []
    var keyBuff: [UInt8] = []
    var keyBuff1: [UInt8] = []
    var keyBuff2: [UInt8] = []
    var keyBuff3: [UInt8] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        key1.stringValue = "101010101010101010101010"
        key2.stringValue = "10101010101010101010101010101010"
        key3.stringValue = "1010101010101010101010101010101010101010"
    }
    
    @IBOutlet weak var represOfFile: NSTextField!
    @IBOutlet weak var keyGenerated: NSTextField!
    @IBOutlet weak var encipheredFile: NSTextField!
    @IBOutlet weak var key1: NSTextField!
    @IBOutlet weak var key2: NSTextField!
    @IBOutlet weak var key3: NSTextField!
    
    @IBAction func newEncode(_ sender: Any) {
        if represOfFile.stringValue.count > 0 {
            key1.stringValue = key1.stringValue.filter { return ["0","1"].contains($0) }
            if (key1.stringValue.count != 24) {
                 dialogError(question: "Please, specify the key!", text: "Error: key must be 24-bit.")
            } else {
                let LFSR = LFSRkey(key: key1.stringValue)
                keyBuff = LFSR.generateLFSR(len: inputBuff.count)
                keyGenerated.stringValue = ""
                encipheredFile.stringValue = ""
                for i in 0...keyBuff.count-1 {
                    if keyGenerated.stringValue.count <= 1500 {
                        var tempS = String(keyBuff[i], radix: 2)
                        while tempS.count < 8 {
                            tempS = "0" + tempS
                        }
                        keyGenerated.stringValue += tempS
                
                        var tempS1 = String(inputBuff[i] ^ keyBuff[i], radix: 2)
                        while tempS1.count < 8 {
                            tempS1 = "0" + tempS1
                        }
                        encipheredFile.stringValue += tempS1
                    } else {
                        break
                    }
                }
                outputBuff.removeAll()
                for i in 0...inputBuff.count-1 {
                    outputBuff.append(inputBuff[i] ^ keyBuff[i])
                }
                
            }
        } else {
            dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
    
    @IBAction func newDecode(_ sender: Any) {
        if encipheredFile.stringValue.count > 0 {
            key1.stringValue = key1.stringValue.filter { return ["0","1"].contains($0) }
            if (key1.stringValue.count != 24) {
                dialogError(question: "Please, specify the key!", text: "Error: key must be 24-bit.")
            } else {
                let LFSR = LFSRkey(key: key1.stringValue)
                keyBuff = LFSR.generateLFSR(len: outputBuff.count)
                keyGenerated.stringValue = ""
                represOfFile.stringValue = ""
                for i in 0...keyBuff.count-1 {
                    if keyGenerated.stringValue.count <= 1500 {
                        var tempS = String(keyBuff[i], radix: 2)
                        while tempS.count < 8 {
                            tempS = "0" + tempS
                        }
                        keyGenerated.stringValue += tempS
                        
                        var tempS1 = String(outputBuff[i] ^ keyBuff[i], radix: 2)
                        while tempS1.count < 8 {
                            tempS1 = "0" + tempS1
                        }
                        represOfFile.stringValue += tempS1
                    } else {
                        break
                    }
                }
                inputBuff.removeAll()
                for i in 0...outputBuff.count-1 {
                    inputBuff.append(outputBuff[i] ^ keyBuff[i])
                }
                
            }
        } else {
            dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
  
    
    @IBAction func EncodeGeffe(_ sender: NSButton) {
        if represOfFile.stringValue.count > 0 {
            key1.stringValue = key1.stringValue.filter { return ["0","1"].contains($0) }
            key2.stringValue = key2.stringValue.filter { return ["0","1"].contains($0) }
            key3.stringValue = key3.stringValue.filter { return ["0","1"].contains($0) }
            if (key1.stringValue.count != 24) {
                dialogError(question: "Please, specify the key!", text: "Error: key1 must be 24-bit.")
            } else
                if (key2.stringValue.count != 32) {
                    dialogError(question: "Please, specify the key!", text: "Error: key2 must be 32-bit.")
                } else
                    if (key3.stringValue.count != 40) {
                        dialogError(question: "Please, specify the key!", text: "Error: key3 must be 40-bit.")
                    } else {
                        let LFSR1 = LFSRkey(key: key1.stringValue)
                        let LFSR2 = LFSRkey(key: key2.stringValue, positions: [1,27,28,32])
                        let LFSR3 = LFSRkey(key: key3.stringValue, positions: [2,19,21,40])
                        keyBuff1 = LFSR1.generateLFSR(len: inputBuff.count)
                        keyBuff2 = LFSR2.generateLFSR(len: inputBuff.count)
                        keyBuff3 = LFSR3.generateLFSR(len: inputBuff.count)
                        keyBuff.removeAll()
                        for i in 0...inputBuff.count-1 {
                            keyBuff.append((keyBuff1[i] & keyBuff2[i]) | (~keyBuff1[i] & keyBuff3[i])) 
                        }
                        
                        keyGenerated.stringValue = ""
                        encipheredFile.stringValue = ""
                        for i in 0...keyBuff.count-1 {
                            if keyGenerated.stringValue.count <= 1500 {
                                var tempS = String(keyBuff[i], radix: 2)
                                while tempS.count < 8 {
                                    tempS = "0" + tempS
                                }
                                keyGenerated.stringValue += tempS
                                
                                var tempS1 = String(inputBuff[i] ^ keyBuff[i], radix: 2)
                                while tempS1.count < 8 {
                                    tempS1 = "0" + tempS1
                                }
                                encipheredFile.stringValue += tempS1
                            } else {
                                break
                            }
                        }
                        outputBuff.removeAll()
                        for i in 0...inputBuff.count-1 {
                            outputBuff.append(inputBuff[i] ^ keyBuff[i])
                        }
                    
            }
        } else {
            dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
        
    @IBAction func decodeGeffe(_ sender: NSButton) {
        if encipheredFile.stringValue.count > 0 {
            key1.stringValue = key1.stringValue.filter { return ["0","1"].contains($0) }
            key2.stringValue = key2.stringValue.filter { return ["0","1"].contains($0) }
            key3.stringValue = key3.stringValue.filter { return ["0","1"].contains($0) }
            if (key1.stringValue.count != 24) {
                dialogError(question: "Please, specify the key!", text: "Error: key1 must be 24-bit.")
            } else
                if (key2.stringValue.count != 32) {
                    dialogError(question: "Please, specify the key!", text: "Error: key2 must be 32-bit.")
                } else
                    if (key3.stringValue.count != 40) {
                        dialogError(question: "Please, specify the key!", text: "Error: key3 must be 40-bit.")
                    } else {
                        let LFSR1 = LFSRkey(key: key1.stringValue)
                        let LFSR2 = LFSRkey(key: key2.stringValue)
                        let LFSR3 = LFSRkey(key: key3.stringValue)
                        keyBuff1 = LFSR1.generateLFSR(len: outputBuff.count)
                        keyBuff2 = LFSR2.generateLFSR(len: outputBuff.count)
                        keyBuff3 = LFSR3.generateLFSR(len: outputBuff.count)
                        for i in 0...outputBuff.count-1 {
                            keyBuff[i] = (keyBuff1[i] & keyBuff2[i]) | (~keyBuff1[i] & keyBuff3[i])
                        }
                        
                        keyGenerated.stringValue = ""
                        represOfFile.stringValue = ""
                        for i in 0...keyBuff.count-1 {
                            if keyGenerated.stringValue.count <= 1500 {
                                var tempS = String(keyBuff[i], radix: 2)
                                while tempS.count < 8 {
                                    tempS = "0" + tempS
                                }
                                keyGenerated.stringValue += tempS
                                
                                var tempS1 = String(outputBuff[i] ^ keyBuff[i], radix: 2)
                                while tempS1.count < 8 {
                                    tempS1 = "0" + tempS1
                                }
                                represOfFile.stringValue += tempS1
                            } else {
                                break
                            }
                        }
                        inputBuff.removeAll()
                        for i in 0...outputBuff.count-1 {
                            inputBuff.append(outputBuff[i] ^ keyBuff[i])
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
            switch sender.tag {
            case 0:
                inputBuff = [UInt8](repeating: 0, count: Int(fileSize))
                inputStream.open()
                inputStream.read(&inputBuff, maxLength: Int(fileSize))
                inputStream.close()
                represOfFile.stringValue = ""
                outerLoop: for i in inputBuff {
                    if represOfFile.stringValue.count >= 1500 {
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
                    if encipheredFile.stringValue.count >= 1500 {
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
