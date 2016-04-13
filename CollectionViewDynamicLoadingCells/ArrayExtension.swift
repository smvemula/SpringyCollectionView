//
//  ArrayExtension.swift
//  PlayNFLBetting
//
//  Created by Vemula, Manoj (Contractor) on 4/2/15.
//  Copyright (c) 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import Foundation

extension Array {
    func contains<T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
    
    func removeObject<T:Equatable>(inout arr:Array<T>, object:T) -> T? {
        if let found = arr.indexOf(object) {
            return arr.removeAtIndex(found)
        }
        return nil
    }
    
    func indexOfObject<T: Equatable>(array: Array<T>, object: T) -> Int? {
        var i: Int
        
        for i = 0; i < array.count; ++i {
            if (array[i] == object) {
                return i
            }
        }
        
        return nil
    }
}