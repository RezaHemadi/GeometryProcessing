//
//  adjacency_matrix.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Constructs the graph adjacency matrix  of a given mesh (V,F)
  // Templates:
  //   T  should be a eigen sparse matrix primitive type like int or double
  // Inputs:
  //   F  #F by dim list of mesh simplices
  // Outputs:
  //   A  max(F)+1 by max(F)+1 adjacency matrix, each row i corresponding to V(i,:)
  //
  // Example:
  //   // Mesh in (V,F)
  //   Eigen::SparseMatrix<double> A;
  //   adjacency_matrix(F,A);
  //   // sum each row
  //   SparseVector<double> Asum;
  //   sum(A,1,Asum);
  //   // Convert row sums into diagonal of sparse matrix
  //   SparseMatrix<double> Adiag;
  //   diag(Asum,Adiag);
  //   // Build uniform laplacian
  //   SparseMatrix<double> U;
  //   U = A-Adiag;
  //
  // See also: edges, cotmatrix, diag
public func adjacency_matrix<MF: Matrix, S: MatrixElement & ExpressibleByIntegerLiteral>(_ F: MF, _ A: inout SparseMatrix<S>) where MF.Element == Int {
    var ijv: [Triplet<S>] = []
    ijv.reserveCapacity(F.size.count * 2)
    // loop over simplex
    for i in 0..<F.rows {
        // loop over this simplex
        for j in 0..<F.cols {
            for k in (j+1)..<F.cols {
                // Get indices of edge: s --> d
                let s = F[i, j]
                let d = F[i, k]
                ijv.append(.init(i: s, j: d, value: 1))
                ijv.append(.init(i: d, j: s, value: 1))
            }
        }
    }
    
    let n = F.maxCoeff() + 1
    A.resize(n, n)
    A.reserve(6 * n)
    A.setFromTriplets(ijv)
    A.forceAllNNZ(to: 1)
}

// Constructs an vertex adjacency for a polygon mesh.
//
// Inputs:
//   I  #I vectorized list of polygon corner indices into rows of some matrix V
//   C  #polygons+1 list of cumulative polygon sizes so that C(i+1)-C(i) =
//     size of the ith polygon, and so I(C(i)) through I(C(i+1)-1) are the
//     indices of the ith polygon
// Outputs:
//   A  max(I)+1 by max(I)+1 adjacency matrix, each row i corresponding to V(i,:)
//
public func adjacency_matrix<VI: Vector, VC: Vector, S: MatrixElement & ExpressibleByIntegerLiteral>(_ I: VI, _ C: VC, _ A: inout SparseMatrix<S>) where VI.Element == VC.Element, VI.Element == Int {
    var ijv: [Triplet<S>] = []
    ijv.reserveCapacity(C[C.count - 1] * 2)
    
    let n = I.maxCoeff() + 1
    
    // Loop over polygons
    for p in 0..<(C.count - 1) {
        // number of edges
        let np = C[p + 1] - C[p]
        // loop over edges
        for c in 0..<np {
            let i = I[C[p] + c]
            let j = I[C[p] + (c + 1) % np]
            ijv.append(.init(i: i, j: j, value: 1))
            ijv.append(.init(i: j, j: i, value: 1))
        }
    }
    
    A.resize(n, n)
    A.reserve(6 * n)
    A.setFromTriplets(ijv)
    
    // Force all nonzeros to be one
    A.forceAllNNZ(to: 1)
}
