//
//  edges.swift
//  GeometryProcessing
//
//  Created by Reza on 6/22/23.
//

import Foundation
import Matrix

// Constructs a list of unique edges represented in a given mesh (V,F)
//
// Inputs:
//   F  #F by 3 list of mesh faces (must be triangles)
//   or
//   T  #T x 4  matrix of indices of tet corners
// Outputs:
//   E #E by 2 list of edges in no particular order
//
// See also: adjacency_matrix
public func edges<MF: Matrix, ME: Matrix>(_ F: MF, _ E: inout ME) where MF.Element == ME.Element, MF.Element == Int {
    // build adjacency matrix
    var A = SparseMatrix<Int>()
    adjacency_matrix(F, &A)
    edges(A, &E)
}

// Constructs a list of unique edges represented in a given polygon mesh.
//
// Inputs:
//   I  #I vectorized list of polygon corner indices into rows of some matrix V
//   C  #polygons+1 list of cumulative polygon sizes so that C(i+1)-C(i) =
//     size of the ith polygon, and so I(C(i)) through I(C(i+1)-1) are the
//     indices of the ith polygon
// Outputs:
//   E #E by 2 list of edges in no particular order
public func edges<IV: Vector, CV: Vector, ME: Matrix>(_ I: IV, _ C: CV, _ E: inout ME) where IV.Element == CV.Element, IV.Element == Int, ME.Element == Int {
    var A = SparseMatrix<Int>()
    adjacency_matrix(I, C, &A)
    edges(A, &E)
}

// Inputs:
//   A  #V by #V symmetric adjacency matrix
// Outputs:
//   E  #E by 2 list of edges in no particular order
public func edges<ME: Matrix>(_ A: SparseMatrix<Int>, _ E: inout ME) where ME.Element == Int {
    // Number of nonzeros should be twice number of edges
    assert(A.nonZeros % 2 == 0)
    
    // Resize to fit edges
    E.resize(A.nonZeros / 2, 2)
    var i: Int = 0
    // Iterate over outside
    for k in 0..<A.outerSize {
        // iterate over inside
        for it in A.innerIterator(k) {
            // only add edge in one direction
            if (it.row < it.col) {
                E[i, 0] = it.row
                E[i, 1] = it.col
                i += 1
            }
        }
    }
    
    assert(i == E.rows, "A should be symmetric")
}
