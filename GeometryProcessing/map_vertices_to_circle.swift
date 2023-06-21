//
//  map_vertices_to_circle.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Map the vertices whose indices are in a given boundary loop (bnd) on the
  // unit circle with spacing proportional to the original boundary edge
  // lengths.
  //
  // Inputs:
  //   V  #V by dim list of mesh vertex positions
  //   b  #W list of vertex ids
  // Outputs:
  //   UV   #W by 2 list of 2D position on the unit circle for the vertices in b
public func map_vertices_to_circle(_ V: Mat<Double>, _ bnd: Vec<Int>, _ UV: inout Mat<Double>) {
    // Get sorted list of boundary vertices
    var interior: [Int] = []
    var map_ij: [Int] = .init(repeating: 0, count: V.rows)
    
    var isOnBnd: [Bool] = .init(repeating: false, count: V.rows)
    
    for i in 0..<bnd.count {
        isOnBnd[bnd[i]] = true
        map_ij[bnd[i]] = i
    }
    
    for i in 0..<isOnBnd.count {
        if (!isOnBnd[i]) {
            map_ij[i] = interior.count
            interior.append(i)
        }
    }
    
    // Map boundary to unit circle
    var len: [Double] = .init(repeating: 0.0, count: bnd.count)
    
    for i in 1..<bnd.count {
        len[i] = len[i - 1] + (V.row(bnd[i - 1]) - V.row(bnd[i])).norm()
    }
    
    let total_len = len[len.count - 1] + (V.row(bnd[0]) - V.row(bnd[bnd.count - 1])).norm()
    
    UV.resize(bnd.count, 2)
    for i in 0..<bnd.count {
        let frac: Double = len[i] * 2 * .pi / total_len
        UV.row(map_ij[bnd[i]]) <<== [cos(frac), sin(frac)]
    }
}
