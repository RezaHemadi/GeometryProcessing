//
//  Slice.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

/*
/// Slice input matrix in one direction (dim)
func slice<T: Matrix, L: Vector, Y: Matrix>(_ x: T, _ r: L, _ dim: Int, _ y: inout Y) where L.Element == Int, T.Element == Y.Element {
    // Dim is either 1 or 2
    // dim == 1 -> select in row direction
    // dim == 2 -> select in column direction
    assert(dim == 1 || dim == 2)
    
    if dim == 1 {
        // select in row direction
        for i in 0..<r.size.count {
            let curRow = r[i]
            for j in 0..<x.size.cols {
                y[i, j] = x[curRow, j]
            }
        }
    } else {
        // select in column direction
        for i in 0..<r.size.count {
            let curColumn = r[i]
            for j in 0..<x.size.rows {
                y[j, i] = x[j, curColumn]
            }
        }
    }
}

/// Slice input matrix in one direction (dim)
func slice<T: Matrix, Y: Matrix>(_ x: T, _ r: MatrixRow<Int>, _ dim: Int, _ y: inout Y) where T.Element == Y.Element {
    // Dim is either 1 or 2
    // dim == 1 -> select in row direction
    // dim == 2 -> select in column direction
    assert(dim == 1 || dim == 2)
    
    if dim == 1 {
        // select in row direction
        for i in 0..<r.count {
            let curRow = r.values[i].pointee
            for j in 0..<x.size.cols {
                y[i, j] = x[curRow, j]
            }
        }
    } else {
        // select in column direction
        for i in 0..<r.count {
            let curColumn = r.values[i].pointee
            for j in 0..<x.size.rows {
                y[j, i] = x[j, curColumn]
            }
        }
    }
}

/// Slice input matrix in one direction (dim)
func slice<T: Matrix, Y: Matrix>(_ x: T, _ r: MatrixColumn<Int>, _ dim: Int, _ y: inout Y) where T.Element == Y.Element {
    // Dim is either 1 or 2
    // dim == 1 -> select in row direction
    // dim == 2 -> select in column direction
    assert(dim == 1 || dim == 2)
    
    if dim == 1 {
        // select in row direction
        for i in 0..<r.count {
            let curRow = r.values[i].pointee
            for j in 0..<x.size.cols {
                y[i, j] = x[curRow, j]
            }
        }
    } else {
        // select in column direction
        for i in 0..<r.count {
            let curColumn = r.values[i].pointee
            for j in 0..<x.size.rows {
                y[j, i] = x[j, curColumn]
            }
        }
    }
}*/

// Act like the matlab X(row_indices,col_indices) operator, where
// row_indices, col_indices are non-negative integer indices.
//
// Inputs:
//   X  m by n matrix
//   R  list of row indices
//   C  list of column indices
// Output:
//   Y  #R by #C matrix
public func slice<S: MatrixElement, V1: Vector, V2: Vector>(_ X: SparseMatrix<S>, _ R: V1, _ C: V2, _ Y: inout SparseMatrix<S>) where V1.Element == V2.Element, V1.Element == Int {
    let xm: Int = X.rows
    let xn: Int = X.cols
    let ym: Int = R.count
    let yn: Int = C.count
    
    // special case where R or C is empty
    if (ym == 0 || yn == 0) {
        Y.resize(ym, yn)
        return
    }
    
    assert(R.minCoeff() >= 0)
    assert(R.maxCoeff() < xm)
    assert(C.minCoeff() >= 0)
    assert(C.maxCoeff() < xn)
    
    // Build reindexing maps for columns and rows
    var RI: [[Int]] = .init(repeating: [], count: xm)
    for i in 0..<ym {
        RI[R[i]].append(i)
    }
    var CI: [[Int]] = .init(repeating: [], count: xn)
    for i in 0..<yn {
        CI[C[i]].append(i)
    }
    
    // Take a guess at the number of nonzeros (this assumes uniform distribution
    // not banded or heavily diagonal)
    var entries = [Triplet<S>]()
    entries.reserveCapacity((X.nonZeros / (X.rows * X.cols)) * (ym * yn))
    
    // Iterate over outside
    for k in 0..<X.outerSize {
        // Iterate over inside
        for entry in X.innerIterator(k) {
            for rit in RI[entry.row] {
                for cit in CI[entry.col] {
                    entries.append(.init(i: rit, j: cit, value: entry.value))
                }
            }
        }
    }
    Y.resize(ym, yn)
    Y.setFromTriplets(entries)
}

public func slice<M1: Matrix, M2: Matrix, V1: Vector>(_ X: M1, _ R: V1, _ dim: Int, _ Y: inout M2) where V1.Element == Int, M1.Element == M2.Element {
    var C: Veci = .init()
    switch dim {
    case 1:
        // boring base case
        if (X.cols == 0) {
            Y.resize(R.count, 0)
            return
        }
        C = .LineSpaced(low: 0, high: X.cols - 1, count: X.cols)
        return slice(X, R, C, &Y)
        
    case 2:
        // boring base case
        if (X.rows == 0) {
            Y.resize(0, R.count)
            return
        }
        C = .LineSpaced(low: 0, high: X.rows - 1, count: X.rows)
        return slice(X, C, R, &Y)
    default:
        fatalError("Unsupported dimension")
    }
}

public func slice<S: MatrixElement, V: Vector>(_ X: SparseMatrix<S>, _ R: V, _ dim: Int, _ Y: inout SparseMatrix<S>) where V.Element == Int {
    var C = Vec<Int>()
    switch (dim) {
    case 1:
        // boring base case
        if (X.cols == 0) {
            Y.resize(R.count, 0)
            return
        }
        C = .LineSpaced(low: 0, high: X.cols - 1, count: X.cols)
        return slice(X, R, C, &Y)
    case 2:
        // boring base case
        if (X.rows == 0) {
            Y.resize(0, R.count)
            return
        }
        C = .LineSpaced(low: 0, high: X.rows - 1, count: X.rows)
        return slice(X, C, R, &Y)
    default:
        fatalError("Unsupported dimension")
    }
}

public func slice<M1: Matrix, V1: Vector, V2: Vector, M2: Matrix>(_ X: M1, _ R: V1, _ C: V2, _ Y: inout M2) where V1.Element == Int, V2.Element == Int, M1.Element == M2.Element {
    let xm: Int = X.rows
    let xn: Int = X.cols
    let ym: Int = R.count
    let yn: Int = C.count
    
    // special case where R or C is empty
    if (ym == 0 || yn == 0) {
        Y.resize(ym, yn)
        return
    }
    
    assert(R.minCoeff() >= 0)
    assert(R.maxCoeff() < xm)
    assert(C.minCoeff() >= 0)
    assert(C.maxCoeff() < xn)
    
    // resize output
    Y.resize(ym, yn)
    // loop over output rows, then columns
    for i in 0..<ym {
        for j in 0..<yn {
            Y[i, j] = X[R[i], C[j]]
        }
    }
}
