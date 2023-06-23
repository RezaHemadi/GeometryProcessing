//
//  max_size.swift
//  GeometryProcessing
//
//  Created by Reza on 6/23/23.
//

import Foundation

// Determine max size of lists in a vector
// Template:
//   T  some list type object that implements .size()
// Inputs:
//   V  vector of list types T
// Returns max .size() found in V, returns -1 if V is empty
public func max_size<T: Countable>(_ V: [T]) -> Int {
    var max_size: Int = -1
    for i in 0..<V.count {
        let size: Int = V[i].count
        max_size = (max_size > size ? max_size : size)
    }
    return max_size
}
