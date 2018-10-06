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
    var outputBuff: [UInt8] = []
    var inputBuff: [UInt8] = []
    var keyBuff: [UInt8] = []
    var keyBuff1: [UInt8] = []
    var keyBuff2: [UInt8] = []
    var keyBuff3: [UInt8] = []
    var positions: [[Int]] = [[0,2,3,23],
                              [0,26,27,31],
                              [1,18,20,39]]
    
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
    
    func generateInitialRC4Key(_ keyString: String) -> [UInt8] {
        var tempK: [UInt8] = []
        var tempkeyString: UInt = 0
        for i in 0..<keyString.count {
            tempkeyString <<= 1
            if keyString[i] == "1" {
                tempkeyString += 1
            }
        }
        for i: UInt in [24,16,8,0] {
            let kek = (tempkeyString >> i) & 255
            tempK.append(UInt8(kek))
        }
        return tempK
    }
    
    func generateRC4Key(forKey key: [UInt8]) -> [UInt8]  {
        var sBox: [UInt8] = []
        for i in 0...255 {
            sBox.append(UInt8(i))
        }
        var j = 0
        for i in 0...255 {
            let temp = sBox[i]
            j = (j + Int(temp) + Int(key[i % (key.count)])) % 256
            sBox.swapAt(i, j)
        }
        return sBox
    }
    
    func n_codeRC4(withKey keyn_code: String,forSourceBuffer inBuff: inout [UInt8], toBuffer outBuff: inout [UInt8]) -> (String, String) {
        var sBoxRC4: [UInt8] = generateRC4Key(forKey: generateInitialRC4Key(keyn_code))
        var keyGen = ""
        var encodedFile = ""
        outBuff.removeAll()
        var i = 0
        var j = 0
        var k = 0
        while (k < inBuff.count) && (k < 100) {
            i = (i + 1) % 256
            j = Int((j + Int(sBoxRC4[i])) % 256)
            sBoxRC4.swapAt(i, j)
            let key8Bits = sBoxRC4[(Int(sBoxRC4[i]) + Int(sBoxRC4[j])) % 256]
            
            var tempS = String(key8Bits, radix: 2)
            while tempS.count < 8 {
                tempS = "0" + tempS
            }
            keyGen += tempS
            
            let tempChu = inBuff[k] ^ key8Bits
            var tempS1 = String(tempChu, radix: 2)
            while tempS1.count < 8 {
                tempS1 = "0" + tempS1
            }
            encodedFile += tempS1
            
            outBuff.append(tempChu)
            k += 1
        }
        while (k < inBuff.count) {
            i = (i + 1) % 256
            j = Int((j + Int(sBoxRC4[i])) % 256)
            sBoxRC4.swapAt(i, j)
            let key8Bits = sBoxRC4[(Int(sBoxRC4[i]) + Int(sBoxRC4[j])) % 256]
            outBuff.append(inBuff[k] ^ key8Bits)
            k += 1
        }
        return (keyGen, encodedFile)
    }
    
    @IBAction func rc4Encode(_ sender: Any) {
        if inputBuff.count > 0 {
            key2.stringValue = key2.stringValue.filter { return ["0","1"].contains($0) }
            if (key2.stringValue.count) > 32 {
                dialogError(question: "Please, specify the key!", text: "Error: key must < 32 bits.")
            } else {
                (keyGenerated.stringValue, encipheredFile.stringValue) = n_codeRC4(withKey: key2.stringValue, forSourceBuffer: &inputBuff, toBuffer: &outputBuff)
            }
        } else {
            dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
    
    @IBAction func rc4Decode(_ sender: Any) {
        if outputBuff.count > 0  {
            key2.stringValue = key2.stringValue.filter { return ["0","1"].contains($0) }
            if (key2.stringValue.count) > 32 {
                dialogError(question: "Please, specify the key!", text: "Error: key must be < 32 bits.")
            } else {
                (keyGenerated.stringValue, represOfFile.stringValue) = n_codeRC4(withKey: key2.stringValue, forSourceBuffer: &outputBuff, toBuffer: &inputBuff)
            }
        } else {
            dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
    
    func generateInitialLFSRKey(_ keyString: String) -> UInt {
        var tempK: UInt = 0
        for i in 1...keyString.count {
            if keyString[i-1] == "1" {
                let t: UInt = 1 << (keyString.count-i)
                tempK += t
            }
        }
        return tempK
    }
    
    func generateLFSRKey( forKey tempKey: inout UInt, withLength length: Int, forRegister posits: [Int]) -> UInt8 {
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
    
    func n_codeJust(withKey keyn_code: String, onPositions poses:[Int], forSourceBuffer inBuff: inout [UInt8], toBuffer outBuff: inout [UInt8]) -> (String, String) {
        var keyRegister = generateInitialLFSRKey(keyn_code)
        var keyGen = ""
        var encodedFile = ""
        outBuff.removeAll()
        var i = 0
        while (i < inBuff.count) && (i < 100) {
            let key8Bits = generateLFSRKey(forKey: &keyRegister, withLength: keyn_code.count, forRegister: poses)
            var tempS = String(key8Bits, radix: 2)
            while tempS.count < 8 {
                tempS = "0" + tempS
            }
            keyGen += tempS
            
            let tempChu = inBuff[i] ^ key8Bits
            var tempS1 = String(tempChu, radix: 2)
            while tempS1.count < 8 {
                tempS1 = "0" + tempS1
            }
            encodedFile += tempS1
            
            outBuff.append(tempChu)
            i += 1
        }
        while (i < inBuff.count) {
            outBuff.append(inBuff[i] ^ generateLFSRKey(forKey: &keyRegister, withLength: keyn_code.count, forRegister: poses))
            i += 1
        }
        return (keyGen, encodedFile)
    }
    
    @IBAction func justEncode(_ sender: Any) {
        if inputBuff.count > 0 {
            key1.stringValue = key1.stringValue.filter { return ["0","1"].contains($0) }
            if (key1.stringValue.count != 24) {
                dialogError(question: "Please, specify the key!", text: "Error: key must be 24-bit.")
            } else {
                (keyGenerated.stringValue, encipheredFile.stringValue) = n_codeJust(withKey: key1.stringValue, onPositions: positions[0], forSourceBuffer: &inputBuff, toBuffer: &outputBuff)
            }
        } else {
            dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
    
    @IBAction func justDecode(_ sender: Any) {
        if outputBuff.count > 0 {
            key1.stringValue = key1.stringValue.filter { return ["0","1"].contains($0) }
            if (key1.stringValue.count != 24) {
                dialogError(question: "Please, specify the key!", text: "Error: key must be 24-bit.")
            } else {
                (keyGenerated.stringValue, represOfFile.stringValue) = n_codeJust(withKey: key1.stringValue, onPositions: positions[0], forSourceBuffer: &outputBuff, toBuffer: &inputBuff)
            }
        } else {
            dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
    
    func n_codeGeffe(withKeys keyn_codes: [String], onPositions poses:[[Int]], forSourceBuffer inBuff: inout [UInt8], toBuffer outBuff: inout [UInt8]) -> (String, String) {
        var keyRegister1 = generateInitialLFSRKey(keyn_codes[0])
        var keyRegister2 = generateInitialLFSRKey(keyn_codes[1])
        var keyRegister3 = generateInitialLFSRKey(keyn_codes[2])
        var keyGen = ""
        var encodedFile = ""
        outBuff.removeAll()
        var i = 0
        while (i < inBuff.count) && (i < 100) {
            let key8Bits1 = generateLFSRKey(forKey: &keyRegister1, withLength: keyn_codes[0].count, forRegister: poses[0])
            let key8Bits2 = generateLFSRKey(forKey: &keyRegister2, withLength: keyn_codes[1].count, forRegister: poses[1])
            let key8Bits3 = generateLFSRKey(forKey: &keyRegister3, withLength: keyn_codes[2].count, forRegister: poses[2])
            let key8Bits = (key8Bits1 & key8Bits2) | (~key8Bits1 & key8Bits3)
            var tempS = String(key8Bits, radix: 2)
            while tempS.count < 8 {
                tempS = "0" + tempS
            }
            keyGen += tempS
            
            let tempChu = inBuff[i] ^ key8Bits
            var tempS1 = String(tempChu, radix: 2)
            while tempS1.count < 8 {
                tempS1 = "0" + tempS1
            }
            encodedFile += tempS1
            
            outBuff.append(tempChu)
            i += 1
        }
        while (i < inBuff.count) {
            let key8Bits1 = generateLFSRKey(forKey: &keyRegister1, withLength: keyn_codes[0].count, forRegister: poses[0])
            let key8Bits2 = generateLFSRKey(forKey: &keyRegister2, withLength: keyn_codes[1].count, forRegister: poses[1])
            let key8Bits3 = generateLFSRKey(forKey: &keyRegister3, withLength: keyn_codes[2].count, forRegister: poses[2])
            let key8Bits = (key8Bits1 & key8Bits2) | (~key8Bits1 & key8Bits3)
            outBuff.append(inBuff[i] ^ key8Bits)
            i += 1
        }
        return (keyGen, encodedFile)
    }
    
    @IBAction func encodeGeffe(_ sender: NSButton) {
        if inputBuff.count > 0 {
            key1.stringValue = key1.stringValue.filter { return ["0","1"].contains($0) }
            key2.stringValue = key2.stringValue.filter { return ["0","1"].contains($0) }
            key3.stringValue = key3.stringValue.filter { return ["0","1"].contains($0) }
            if (key1.stringValue.count != 24) || (key2.stringValue.count != 32) || (key3.stringValue.count != 40) {
                dialogError(question: "Please, specify the key!", text: "Error: keys must be 24,32,40 bit.")
            } else {
                (keyGenerated.stringValue, encipheredFile.stringValue) = n_codeGeffe(withKeys: [key1.stringValue, key2.stringValue, key3.stringValue], onPositions: positions, forSourceBuffer: &inputBuff, toBuffer: &outputBuff)
            }
        } else {
            dialogError(question: "Please, enter the file!", text: "Error: file is empty")
        }
    }
    
    @IBAction func decodeGeffe(_ sender: Any) {
        if outputBuff.count > 0 {
            key1.stringValue = key1.stringValue.filter { return ["0","1"].contains($0) }
            key2.stringValue = key2.stringValue.filter { return ["0","1"].contains($0) }
            key3.stringValue = key3.stringValue.filter { return ["0","1"].contains($0) }
            if (key1.stringValue.count != 24) || (key2.stringValue.count != 32) || (key3.stringValue.count != 40) {
                dialogError(question: "Please, specify the key!", text: "Error: keys must be 24,32,40 bit.")
            } else {
                (keyGenerated.stringValue, represOfFile.stringValue) = n_codeGeffe(withKeys: [key1.stringValue, key2.stringValue, key3.stringValue], onPositions: positions, forSourceBuffer: &outputBuff, toBuffer: &inputBuff)
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
