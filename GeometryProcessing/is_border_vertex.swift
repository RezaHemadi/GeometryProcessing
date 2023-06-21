//
//  is_border_vertex.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Determine vertices on open boundary of a (manifold) mesh with triangle
// faces F
//
// Inputs:
//   V  #V by dim list of vertex positions
//   F  #F by 3 list of triangle indices
// Returns #V vector of bools revealing whether vertices are on boundary
//
// Known Bugs: - assumes mesh is edge manifold
//
public func is_border_vertex(F: Mati) -> [Bool] {
    var FF: Mati = .init()
    triangle_triangle_adjacency(F, &FF)
    var ret: [Bool] = .init(repeating: false, count: F.maxCoeff() + 1)
    
    for i in 0..<F.rows {
        for j in 0..<F.cols {
            if (FF[i, j] == -1) {
                ret[F[i, j]] = true
                ret[F[i, (j + 1) % F.cols]] = true
            }
        }
    }
    return ret
}

