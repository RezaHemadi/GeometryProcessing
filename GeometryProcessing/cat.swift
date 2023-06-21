//
//  cat.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// This is an attempt to act like matlab's cat function.

// Perform concatenation of a two matrices along a single dimension
// If dim == 1, then C = [A;B]. If dim == 2 then C = [A B]
//
// Template:
//   Scalar  scalar data type for sparse matrices like double or int
//   Mat  matrix type for all matrices (e.g. MatrixXd, SparseMatrix)
//   MatC  matrix type for output matrix (e.g. MatrixXd) needs to support
//     resize
// Inputs:
//   A  first input matrix
//   B  second input matrix
//   dim  dimension along which to concatenate, 1 or 2
// Outputs:
//   C  output matrix
//
public func cat<S: MatrixElement>(_ dim: Int, _ A: SparseMatrix<S>, _ B: SparseMatrix<S>, _ C: inout SparseMatrix<S>) {
    assert(dim == 1 || dim == 2)
    
    // special case if B or A is empty
    if (A.size.count == 0) {
        C = B
        return
    }
    if (B.size.count == 0) {
        C = A
        return
    }
    
    C = SparseMatrix(dim == 1 ? A.rows + B.rows : A.rows,
                     dim == 1 ? A.cols          : A.cols + B.cols)
    let per_col: Veci = .Zero(C.cols)
    if (dim == 1) {
        assert(A.outerSize == B.outerSize)
        for k in 0..<A.outerSize {
            fatalError("To be implemented")
        }
    }
}
