//
//  is_vertex_manifold.swift
//  GeometryProcessing
//
//  Created by Reza on 8/4/23.
//

import Foundation
import Matrix

// Check if a mesh is vertex-manifold. This only checks whether the faces
// incident on each vertex form exactly one connected component. Vertices
// incident on non-manifold edges are not consider non-manifold by this
// function (see is_edge_manifold.h). Unreferenced verties are considered
// non-manifold (zero components).
//
// Inputs:
//   F  #F by 3 list of triangle indices
// Outputs:
//   B  #V list indicate whether each vertex is locally manifold.
// Returns whether mesh is vertex manifold.
//
public func is_vertex_manifold(_ F: Mati, _ B: inout Veci) -> Bool {
    assert(F.cols == 3, "F must contain triangles")
    
    let m: Int = F.rows
    let n: Int = F.maxCoeff() + 1
    var TT: [[[Int]]] = [[[]]]
    var TTi: [[[Int]]] = [[[]]]
    triangle_triangle_adjacency(F, true, &TT, &TTi)
    
    var V2F: [[Int]] = [[]]
    var _1: [[Int]] = [[]]
    vertex_triangle_adjacency(n, F, &V2F, &_1)
    
    let check_vertex: (Int) -> Bool = { v in
        var uV2Fv: [Int] = []
        var _1: [Int] = []
        var _2: [Int] = []
        unique(V2F[v], &uV2Fv, &_1, &_2)
        
        let one_ring_size: Int = uV2Fv.count
        if (one_ring_size == 0) {
            return false
        }
        let g: Int = uV2Fv[0]
        var Q: [Int] = []
        Q.append(g)
        var seen: [Int : Bool] = [:]
        
        while (!Q.isEmpty) {
            let f: Int = Q.removeFirst()
            if seen[f] != nil {
                continue
            }
            seen[f] = true
            // Face f's neighbors lists opposite each corner
            for c in TT[f] {
                for n in c {
                    var contains_v: Bool = false
                    for nc in 0..<F.cols {
                        if (F[n, nc] == v) {
                            contains_v = true
                            break
                        }
                    }
                    if (seen[n] == nil && contains_v) {
                        Q.append(n)
                    }
                }
            }
        }
        return one_ring_size == seen.count
    }
    
    // Unreferenced vertices are considered non-manifold
    B.setConstant(n, 1, 0)
    // Loop over all vertices  touched  by F
    var all: Bool = true
    for v in 0..<n {
        let temp: Bool = check_vertex(v)
        all = (all && temp)
        B[v] = (temp ? 1 : 0)
    }
    return all
}
