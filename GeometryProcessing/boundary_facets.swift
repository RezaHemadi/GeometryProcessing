//
//  boundary_facets.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// BOUNDARY_FACETS Determine boundary faces (edges) of tetrahedra (triangles)
// stored in T (analogous to qptoolbox's `outline` and `boundary_faces`).
//
// Input:
//  T  tetrahedron (triangle) index list, m by 4 (3), where m is the number of tetrahedra
// Output:
//  F  list of boundary faces, n by 3 (2), where n is the number of boundary faces
//  J  list of indices into T, n by 1
//  K  list of indices revealing across from which vertex is this facet
//
//
public func boundary_facets(_ F: Mat<Int>,
                     _ E: inout Mat<Int>,
                     _ J: inout Vec<Int>,
                     _ K: inout Vec<Int>) {
    let simplex_size = F.cols
    
    // handle boring base case
    if (F.rows == 0) {
        E.resize(0, simplex_size - 1)
        J.resize(0)
        K.resize(0)
        return
    }
    
    // Get a list of all edges
    var allE: Mat<Int> = .init(F.rows * simplex_size, simplex_size - 1)
    
    assert(simplex_size == 3)
    
    // Gather edges ( loop over triangles )
    for i in 0..<F.rows {
        allE[i * simplex_size + 0, 0] = F[i, 1]
        allE[i * simplex_size + 0, 1] = F[i, 2]
        allE[i * simplex_size + 1, 0] = F[i, 2]
        allE[i * simplex_size + 1, 1] = F[i, 0]
        allE[i * simplex_size + 2, 0] = F[i, 0]
        allE[i * simplex_size + 2, 1] = F[i, 1]
    }
    var sortedE = Mat<Int>()
    geom_sort(allE, 2, true, &sortedE)
    
    var m: Veci = .init()
    var n: Veci = .init()
    
    var _1: Mat<Int> = .init()
    unique_rows(sortedE, &_1, &m, &n)
    
    var C: Vec<Int> = .init()
    accumarray(n, 1, &C)
    
    let ones: Int = (C.array() == 1).count()
    // Resize output to fit number of non-twos
    E.resize(ones, allE.cols)
    J.resize(F.rows)
    K.resize(F.rows)
    var k: Int = 0
    for c in 0..<C.count {
        if (C[c] == 1) {
            let i: Int = m[c]
            assert(k < E.rows)
            E.row(k) <<== allE.row(i)
            J[k] = i / simplex_size
            K[k] = i % simplex_size
            k += 1
        }
    }
    assert(k == E.rows)
}

public func boundary_facets(_ T: Mat<Int>,
                     _ F: inout Mat<Int>) {
    var J: Vec<Int> = .init()
    var K: Vec<Int> = .init()
    
    return boundary_facets(T, &F, &J, &K)
}
