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
public func adjacency_matrix(_ F: Mati, _ A: inout SpMat) {
    var ijv: [Tripletd] = []
    ijv.reserveCapacity(F.size.count * 2)
    // loop over simplex
    for i in 0..<F.rows {
        // loop over this simplex
        for j in 0..<F.cols {
            for k in (j+1)..<F.cols {
                // Get indices of edge: s --> d
                let s = F[i, j]
                let d = F[i, k]
                ijv.append(.init(i: s, j: d, value: 1.0))
                ijv.append(.init(i: d, j: s, value: 1.0))
            }
        }
    }
    
    let n = F.maxCoeff() + 1
    A.resize(n, n)
    A.reserve(6 * n)
    A.setFromTriplets(ijv)
    A.forceAllNNZ(to: 1.0)
}

