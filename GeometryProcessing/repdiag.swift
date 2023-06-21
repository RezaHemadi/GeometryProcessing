//
//  repdiag.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// REPDIAG repeat a matrix along the diagonal a certain number of times, so
// that if A is a m by n matrix and we want to repeat along the diagonal d
// times, we get a m*d by n*d matrix B such that:
// B( (k*m+1):(k*m+1+m-1), (k*n+1):(k*n+1+n-1)) = A
// for k from 0 to d-1
//
// Inputs:
//   A  m by n matrix we are repeating along the diagonal. May be dense or
//     sparse
//   d  number of times to repeat A along the diagonal
// Outputs:
//   B  m*d by n*d matrix with A repeated d times along the diagonal,
//     will be dense or sparse to match A
//
public func repdiag<T: MatrixElement>(_ A: SparseMatrix<T>,
                               _ d: Int) -> SparseMatrix<T> {
    let m: Int = A.rows
    let n: Int = A.cols
    
    var IJV: [Triplet<T>] = []
    IJV.reserveCapacity(A.nonZeros * d)
    
    // Loop outer level
    for k in 0..<A.outerSize {
        // loop inner level
        for it in A.innerIterator(k) {
            for i in 0..<d {
                IJV.append(.init(i: i * m + it.row,
                                 j: i * n + it.col,
                                 value: it.value))
            }
        }
    }
    var B = SparseMatrix<T>(m * d, n * d)
    B.setFromTriplets(IJV)
    
    return B
}

public func repdiag<T: MatrixElement>(_ A: Mat<T>,
                               _ d: Int,
                               _ B: inout Mat<T>) {
    let m: Int = A.rows
    let n: Int = A.cols
    B.resize(m * d, n * d)
    B.setZero()
    
    for i in 0..<d {
        B.block(i * m, i * n, m, n) <<== A
    }
}

