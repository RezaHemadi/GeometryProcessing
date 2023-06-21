//
//  reorder.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation

// Act like matlab's Y = X(I) for std vectors
// where I contains a vector of indices so that after,
// Y[j] = X[I[j]] for index j
// this implies that Y.size() == I.size()
// X and Y are allowed to be the same reference
public func reorder<T>(_ unordered: [T], _ index_map: [Int], _ ordered: inout [T]) {
    // copy for the reorder according to index_map, because unsorted may also be
    // sorted
    let copy = unordered
    assert(ordered.count == index_map.count)
    for i in 0..<index_map.count {
        ordered[i] = copy[index_map[i]]
    }
}
