//
//  cotmatrix.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Constructs the cotangent stiffness matrix (discrete laplacian) for a given
// mesh (V,F).
//
// Templates:
//   DerivedV  derived type of eigen matrix for V (e.g. derived from
//     MatrixXd)
//   DerivedF  derived type of eigen matrix for F (e.g. derived from
//     MatrixXi)
//   Scalar  scalar type for eigen sparse matrix (e.g. double)
// Inputs:
//   V  #V by dim list of mesh vertex positions
//   F  #F by simplex_size list of mesh elements (triangles or tetrahedra)
// Outputs:
//   L  #V by #V cotangent matrix, each row i corresponding to V(i,:)
//
// See also: adjacency_matrix
//
// Note: This Laplacian uses the convention that diagonal entries are
// **minus** the sum of off-diagonal entries. The diagonal entries are
// therefore in general negative and the matrix is **negative** semi-definite
// (immediately, -L is **positive** semi-definite)
//
public func cotmatrix(_ V: Matd, _ F: Mati) -> SpMat {
    var L: SpMat = .init(V.rows, V.rows)
    let edges: MatX2<Int> = .init([1, 2, 2, 0, 0, 1], [3, 2])
    L.reserve(10 * V.rows)
    
    // Gather cotangents
    var C: Matd = .init()
    cotmatrix_entries(V, F, &C)
    
    var IJV: [Tripletd] = []
    IJV.reserveCapacity(F.rows * edges.rows * 4)
    
    // loop over triangles
    for i in 0..<F.rows {
        // loop over edges of elements
        for e in 0..<edges.rows {
            let source = F[i, edges[e, 0]]
            let dest = F[i, edges[e, 1]]
            IJV.append(.init(i: source, j: dest, value: C[i, e]))
            IJV.append(.init(i: dest, j: source, value: C[i, e]))
            IJV.append(.init(i: source, j: source, value: -C[i, e]))
            IJV.append(.init(i: dest, j: dest, value: -C[i, e]))
        }
    }
    L.setFromTriplets(IJV)
    return L
}

