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
    var key = "101010101010101010101010"
    var positions: [Int] = [1,3,4,24] //x24 + x4 + x3 + x + 1
    
    init(key:String){
        self.key = key

    }
    
    init(key:String, positions: [Int]){
        self.key = key
        self.positions = positions
    }

    func generateLFSR(len: Int) -> String {
        var str: String = ""
        var tempKey = key
        for _ in 1...len {
            var tempAppend = 0
            for i in positions {
                tempAppend ^= Int(String(tempKey[tempKey.count-i]))!
            }
            tempKey.append(String(tempAppend)[0])
            str.append(tempKey.removeFirst())
        }

        return str
    }
    
    
    
    
    
}


