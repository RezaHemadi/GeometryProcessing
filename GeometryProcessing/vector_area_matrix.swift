//
//  vector_area_matrix.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Constructs the symmetric area matrix A, s.t.  [V.col(0)' V.col(1)'] * A *
// [V.col(0); V.col(1)] is the **vector area** of the mesh (V,F).
//
// Templates:
//   DerivedV  derived type of eigen matrix for V (e.g. derived from
//     MatrixXd)
//   DerivedF  derived type of eigen matrix for F (e.g. derived from
//     MatrixXi)
//   Scalar  scalar type for eigen sparse matrix (e.g. double)
// Inputs:
//   F  #F by 3 list of mesh faces (must be triangles)
// Outputs:
//   A  #Vx2 by #Vx2 area matrix
//
public func vector_area_matrix<S: MatrixElement & ExpressibleByFloatLiteral>(_ F: Mat<Int>) -> SparseMatrix<S> {
    // number of vertices
    let n: Int = F.maxCoeff() + 1
    
    var E: Mat<Int> = .init()
    boundary_facets(F, &E)
    
    // Prepare a vector of triplets to set the matrix
    var tripletList: [Triplet<S>] = []
    tripletList.reserveCapacity(4 * E.rows)
    
    for k in 0..<E.rows {
        let i: Int = E[k, 0]
        let j: Int = E[k, 1]
        
        tripletList.append(.init(i: i + n, j: j, value: -0.25))
        tripletList.append(.init(i: j, j: i + n, value: -0.25))
        tripletList.append(.init(i: i, j: j + n, value: 0.25))
        tripletList.append(.init(i: j + n, j: i, value: 0.25))
    }
    
    var A = SparseMatrix<S>(n * 2, n * 2)
    A.setFromTriplets(tripletList)
    
    return A
}
