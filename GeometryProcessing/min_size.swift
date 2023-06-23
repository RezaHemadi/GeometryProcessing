//
//  min_size.swift
//  GeometryProcessing
//
//  Created by Reza on 6/23/23.
//

import Foundation

// Determine min size of lists in a vector
// Template:
//   T  some list type object that implements .size()
// Inputs:
//   V  vector of list types T
// Returns min .size() found in V, returns -1 if V is empty
public func min_size<T: Countable>(_ V: [T]) -> Int {
    var min_size: Int = -1
    for i in 0..<V.count {
        let size = V[i].count
        // have to handle base case
        if (min_size == -1) {
            min_size = size
        } else {
            min_size = (min_size < size ? min_size : size)
        }
    }
    return min_size
}
