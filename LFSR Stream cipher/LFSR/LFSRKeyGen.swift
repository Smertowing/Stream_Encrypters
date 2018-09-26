//
//  File.swift
//  LFSR Stream cipher
//
//  Created by Kiryl Holubeu on 9/24/18.
//  Copyright © 2018 Kiryl Holubeu. All rights reserved.
//

import Foundation

fileprivate extension String {
    subscript(i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
}

class LFSRkey {
    var key: String
    var positions: [Int] = [1,3,4,24] //x24 + x4 + x3 + x + 1
    
    init(key: String){
        self.key = key

    }
    
    init(key: String, positions: [Int]){
        self.key = key
        self.positions = positions
    }

    func generateLFSR(len: Int) -> [UInt8] {
        var col: [UInt8] = []
      //  var tempKey = key
        
        var tempK:UInt = 0
        for i in 1...key.count {
            if key[i-1] == "1" {
                let t:UInt = 1 << (Int.bitWidth-i)
                tempK += t
            }
        }
        let diff = Int.bitWidth-key.count
        var le = len
        while le > 0 {
            var tempKeyAppend: UInt8 = 0
            for i in 0...7 {
                var xor: UInt8 = 0
                for j in positions {
                    let t = UInt8((tempK << (key.count-j)) >> (Int.bitWidth-1))
                    xor ^= t
                }
                let xor2 = UInt8(tempK >> (Int.bitWidth-1))
                tempK <<= 1
                tempK ^= (UInt(xor) << (diff))
                tempKeyAppend ^= xor2 << (7-i)
            }
            col.append(tempKeyAppend)
            le -= 1
        }
        /*
        var l = len
        while l > 0 {
            var tempKeyAppend: UInt8 = 0
            for i in 0...7 {
                var tempAppend: UInt8 = 0
                for j in positions {
                    tempAppend ^= UInt8(String(tempKey[tempKey.count-j]))!
                }
                
                tempKey.append(String(tempAppend)[0])
                if tempKey.removeFirst() == "1" {
                    tempKeyAppend += UInt8(pow(Double(2), Double(7-i)))
                }
            }
            col.append(tempKeyAppend)
            l -= 1
        }*/
        
        return col
    }
    
    
    
    
    
}


