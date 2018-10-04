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
    
    var positions: [[Int]] = [[0,2,3,23],[0,26,7,31],[1,18,20,39]]
    
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
    
    func generateKey(_ keyString: String) -> UInt {
        var tempK: UInt = 0
        for i in 1...keyString.count {
            if keyString[i-1] == "1" {
                let t: UInt = 1 << (keyString.count-i)
                tempK += t
            }
        }
        return tempK
    }
    
    func generateLFSR( forKey tempKey: inout UInt, withLength length: Int, forRegister posits: [Int]) -> UInt8 {
        var tempKeyAppend: UInt = 0
        for _ in 0...7 {
            var xor: UInt = 0
            for j in posits {
                let t = (tempKey >> j) & UInt(1)
                xor ^= t
            }
            tempKeyAppend ^= (tempKey >> (length-1)) & 1
            tempKeyAppend <<= 1
            tempKey <<= 1
            tempKey ^= xor
        }
        tempKeyAppend >>= 1
        return UInt8(tempKeyAppend)
    }
    
    @IBAction func justEncode(_ sender: Any) {
        if represOfFile.stringValue.count > 0 {
            key1.stringValue = key1.stringValue.filter { return ["0","1"].contains($0) }
            if (key1.stringValue.count != 24) {
                dialogError(question: "Please, specify the key!", text: "Error: key must be 24-bit.")
            } else {
                var keyRegister = generateKey(key1.stringValue)
                keyGenerated.stringValue = ""
                encipheredFile.stringValue = ""
                outputBuff.removeAll()
                var i = 0
                while (i < inputBuff.count) && (i < 100) {
                    let key8Bits = generateLFSR(forKey: &keyRegister, withLength: key1.stringValue.count, forRegister: positions[0])
                    var tempS = String(key8Bits, radix: 2)
                    while tempS.count < 8 {
                        tempS = "0" + tempS
                    }
                    keyGenerated.stringValue += tempS
                    
                    let tempChu = inputBuff[i] ^ key8Bits
                    var tempS1 = String(tempChu, radix: 2)
                    while tempS1.count < 8 {
                        tempS1 = "0" + tempS1
                    }
                    encipheredFile.stringValue += tempS1
                    
                    outputBuff.append(tempChu)
                    i += 1
                }
                while (i < inputBuff.count) {
                    outputBuff.append(inputBuff[i] ^ generateLFSR(forKey: &keyRegister, withLength: key1.stringValue.count, forRegister: positions[0]))
                    i += 1
                }
            }
        } else {
            dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
    
    @IBAction func justDecode(_ sender: Any) {
        if encipheredFile.stringValue.count > 0 {
            key1.stringValue = key1.stringValue.filter { return ["0","1"].contains($0) }
            if (key1.stringValue.count != 24) {
                dialogError(question: "Please, specify the key!", text: "Error: key must be 24-bit.")
            } else {
                var keyRegister = generateKey(key1.stringValue)
                keyGenerated.stringValue = ""
                represOfFile.stringValue = ""
                inputBuff.removeAll()
                var i = 0
                while (i < outputBuff.count) && (i < 100) {
                    let key8Bits = generateLFSR(forKey: &keyRegister, withLength: key1.stringValue.count, forRegister: positions[0])
                    var tempS = String(key8Bits, radix: 2)
                    while tempS.count < 8 {
                        tempS = "0" + tempS
                    }
                    keyGenerated.stringValue += tempS
                    
                    let tempChu = outputBuff[i] ^ key8Bits
                    var tempS1 = String(tempChu, radix: 2)
                    while tempS1.count < 8 {
                        tempS1 = "0" + tempS1
                    }
                    represOfFile.stringValue += tempS1
                    
                    inputBuff.append(tempChu)
                    i += 1
                }
                while (i < outputBuff.count) {
                    inputBuff.append(outputBuff[i] ^ generateLFSR(forKey: &keyRegister, withLength: key1.stringValue.count, forRegister: positions[0]))
                    i += 1
                }
            }
        } else {
            dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
    
    @IBAction func encodeGeffe(_ sender: NSButton) {
        if represOfFile.stringValue.count > 0 {
            key1.stringValue = key1.stringValue.filter { return ["0","1"].contains($0) }
            if (key1.stringValue.count != 24) {
                dialogError(question: "Please, specify the key!", text: "Error: key must be 24-bit.")
            } else {
                var keyRegister1 = generateKey(key1.stringValue)
                var keyRegister2 = generateKey(key2.stringValue)
                var keyRegister3 = generateKey(key3.stringValue)
                keyGenerated.stringValue = ""
                encipheredFile.stringValue = ""
                outputBuff.removeAll()
                var i = 0
                while (i < inputBuff.count) && (i < 100) {
                    let key8Bits1 = generateLFSR(forKey: &keyRegister1, withLength: key1.stringValue.count, forRegister: positions[0])
                    let key8Bits2 = generateLFSR(forKey: &keyRegister2, withLength: key1.stringValue.count, forRegister: positions[1])
                    let key8Bits3 = generateLFSR(forKey: &keyRegister3, withLength: key1.stringValue.count, forRegister: positions[2])
                    let key8Bits = (key8Bits1 & key8Bits2) | (~key8Bits1 & key8Bits3)
                    
                    var tempS = String(key8Bits, radix: 2)
                    while tempS.count < 8 {
                        tempS = "0" + tempS
                    }
                    keyGenerated.stringValue += tempS
                    
                    let tempChu = inputBuff[i] ^ key8Bits
                    var tempS1 = String(tempChu, radix: 2)
                    while tempS1.count < 8 {
                        tempS1 = "0" + tempS1
                    }
                    encipheredFile.stringValue += tempS1
                    
                    outputBuff.append(tempChu)
                    i += 1
                }
                while (i < inputBuff.count) {
                    let key8Bits1 = generateLFSR(forKey: &keyRegister1, withLength: key1.stringValue.count, forRegister: positions[0])
                    let key8Bits2 = generateLFSR(forKey: &keyRegister2, withLength: key1.stringValue.count, forRegister: positions[1])
                    let key8Bits3 = generateLFSR(forKey: &keyRegister3, withLength: key1.stringValue.count, forRegister: positions[2])
                    let key8Bits = (key8Bits1 & key8Bits2) | (~key8Bits1 & key8Bits3)
                    outputBuff.append(inputBuff[i] ^ key8Bits)
                    i += 1
                }
            }
        } else {
            dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
    
    @IBAction func decodeGeffe(_ sender: Any) {
        if encipheredFile.stringValue.count > 0 {
            key1.stringValue = key1.stringValue.filter { return ["0","1"].contains($0) }
            if (key1.stringValue.count != 24) {
                dialogError(question: "Please, specify the key!", text: "Error: key must be 24-bit.")
            } else {
                var keyRegister1 = generateKey(key1.stringValue)
                var keyRegister2 = generateKey(key2.stringValue)
                var keyRegister3 = generateKey(key3.stringValue)
                keyGenerated.stringValue = ""
                represOfFile.stringValue = ""
                inputBuff.removeAll()
                var i = 0
                while (i < outputBuff.count) && (i < 100) {
                    let key8Bits1 = generateLFSR(forKey: &keyRegister1, withLength: key1.stringValue.count, forRegister: positions[0])
                    let key8Bits2 = generateLFSR(forKey: &keyRegister2, withLength: key1.stringValue.count, forRegister: positions[1])
                    let key8Bits3 = generateLFSR(forKey: &keyRegister3, withLength: key1.stringValue.count, forRegister: positions[2])
                    let key8Bits = (key8Bits1 & key8Bits2) | (~key8Bits1 & key8Bits3)
                    var tempS = String(key8Bits, radix: 2)
                    while tempS.count < 8 {
                        tempS = "0" + tempS
                    }
                    keyGenerated.stringValue += tempS
                    
                    let tempChu = outputBuff[i] ^ key8Bits
                    var tempS1 = String(tempChu, radix: 2)
                    while tempS1.count < 8 {
                        tempS1 = "0" + tempS1
                    }
                    represOfFile.stringValue += tempS1
                    
                    inputBuff.append(tempChu)
                    i += 1
                }
                while (i < outputBuff.count) {
                    let key8Bits1 = generateLFSR(forKey: &keyRegister1, withLength: key1.stringValue.count, forRegister: positions[0])
                    let key8Bits2 = generateLFSR(forKey: &keyRegister2, withLength: key1.stringValue.count, forRegister: positions[1])
                    let key8Bits3 = generateLFSR(forKey: &keyRegister3, withLength: key1.stringValue.count, forRegister: positions[2])
                    let key8Bits = (key8Bits1 & key8Bits2) | (~key8Bits1 & key8Bits3)
                    inputBuff.append(outputBuff[i] ^ key8Bits)
                    i += 1
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
                    if represOfFile.stringValue.count >= 800 {
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
                    if encipheredFile.stringValue.count >= 800 {
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
