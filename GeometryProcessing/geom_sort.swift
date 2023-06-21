//
//  geom_sort.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Sort the elements of a matrix X along a given dimension like matlabs sort
// function
//
// Templates:
//   DerivedX derived scalar type, e.g. MatrixXi or MatrixXd
//   DerivedIX derived integer type, e.g. MatrixXi
// Inputs:
//   X  m by n matrix whose entries are to be sorted
//   dim  dimensional along which to sort:
//     1  sort each column (matlab default)
//     2  sort each row
//   ascending  sort ascending (true, matlab default) or descending (false)
// Outputs:
//   Y  m by n matrix whose entries are sorted
//   IX  m by n matrix of indices so that if dim = 1, then in matlab notation
//     for j = 1:n, Y(:,j) = X(I(:,j),j); end
public func geom_sort<M: Matrix>(_ X: M,
                          _ dim: Int,
                          _ ascending: Bool,
                          _ Y: inout M,
                          _ IX: inout Mati) where M.Element: Comparable & Numeric {
    // get number of rows (or columns)
    let num_inner: Int = (dim == 1 ? X.rows : X.cols)
    
    switch num_inner {
    case 2:
        return geom_sort2(X, dim, ascending, &Y, &IX)
    case 3:
        return geom_sort3(X, dim, ascending, &Y, &IX)
    default:
        break
    }
    
    // get number of columns (or rows)
    let num_outer: Int = (dim == 1 ? X.cols : X.rows)
    // dim must be 2 or 1
    assert(dim == 1 || dim == 2)
    // Resize output
    Y.resize(X.rows, X.cols)
    IX.resize(X.rows, X.cols)
    
    // loop over columns (or rows)
    for i in 0..<num_outer {
        // Unsorted index map for this column (or row)
        var index_map: [Int] = .init(repeating: 0, count: num_inner)
        var data: [M.Element] = .init(repeating: .zero, count: num_inner)
        for j in 0..<num_inner {
            if (dim == 1) {
                data[j] = X[j, i]
            } else {
                data[j] = X[i, j]
            }
        }
        // sort this column (or row)
        geom_sort(data, ascending, &data, &index_map)
        // Copy into Y and IX
        for j in 0..<num_inner {
            if (dim == 1) {
                Y[j, i] = data[j]
                IX[j, i] = index_map[j]
            } else {
                Y[i, j] = data[j]
                IX[i, j] = index_map[j]
            }
        }
    }
}

public func geom_sort<M: Matrix>(_ X: M, _ dim: Int, _ ascending: Bool, _ Y: inout M) where M.Element: Comparable & Numeric {
    var IX = Mati()
    return geom_sort(X, dim, ascending, &Y, &IX)
}

public func geom_sort2<M: Matrix>(_ X: M, _ dim: Int, _ ascending: Bool, _ Y: inout M, _ IX: inout Mati) where M.Element: Comparable & Numeric {
    
    Y = .init(X, X.rows, X.cols)
    
    let num_outer: Int = (dim == 1 ? X.cols : X.rows)
    let num_inner: Int = (dim == 1 ? X.rows : X.cols)
    assert(num_inner == 2)
    
    IX.resize(X.rows, X.cols)
    
    if (dim == 1) {
        IX.row(0).setConstant(0)
        IX.row(1).setConstant(1)
    } else {
        IX.col(0).setConstant(0)
        IX.col(1).setConstant(1)
    }
    
    for i in 0..<num_outer {
        let a: UnsafeMutablePointer<M.Element> = (dim == 1 ? Y.ptrRef(0, i) : Y.ptrRef(i, 0))
        let b: UnsafeMutablePointer<M.Element> = (dim == 1 ? Y.ptrRef(1, i) : Y.ptrRef(i, 1))
        let ai: UnsafeMutablePointer<Int> = (dim == 1 ? IX.ptrRef(0, i) : IX.ptrRef(i, 0))
        let bi: UnsafeMutablePointer<Int> = (dim == 1 ? IX.ptrRef(1, i) : IX.ptrRef(i, 1))
        
        if ((ascending && a.pointee > b.pointee) || (!ascending && a.pointee < b.pointee)) {
            let tmp: M.Element = a.pointee
            a.pointee = b.pointee
            b.pointee = tmp
            
            let tmpi: Int = ai.pointee
            ai.pointee = bi.pointee
            bi.pointee = tmpi
        }
    }
}

public func geom_sort3<M: Matrix>(_ X: M, _ dim: Int, _ ascending: Bool, _ Y: inout M, _ IX: inout Mati) where M.Element: Comparable & Numeric {
    Y.resize(X.rows, X.cols)
    
    for j in 0..<X.cols {
        for i in 0..<X.rows {
            Y[i, j] = X[i, j]
        }
    }
    
    // get number of columns (or rows)
    let num_outer: Int = (dim == 1 ? X.cols : X.rows)
    // get number of rows (or columns)
    let num_inner: Int = (dim == 1 ? X.rows : X.cols)
    assert(num_inner == 3)
    
    IX.resize(X.rows, X.cols)
    if (dim == 1) {
        IX.row(0).setConstant(0)
        IX.row(1).setConstant(1)
        IX.row(2).setConstant(2)
    } else {
        IX.col(0).setConstant(0)
        IX.col(1).setConstant(1)
        IX.col(2).setConstant(2)
    }
    
    for i in 0..<num_outer {
        let a = (dim == 1 ? Y.ptrRef(0, i) : Y.ptrRef(i, 0))
        let b = (dim == 1 ? Y.ptrRef(1, i) : Y.ptrRef(i, 1))
        let c = (dim == 1 ? Y.ptrRef(2, i) : Y.ptrRef(i, 2))
        
        let ai = (dim == 1 ? IX.ptrRef(0, i) : IX.ptrRef(i, 0))
        let bi = (dim == 1 ? IX.ptrRef(1, i) : IX.ptrRef(i, 1))
        let ci = (dim == 1 ? IX.ptrRef(2, i) : IX.ptrRef(i, 2))
        
        if ascending {
            // 123 132 213 231 312 321
            if (a.pointee > b.pointee) {
                // swap a, b
                // swap ai, bi
                swap(a, b)
                swap(ai, bi)
            }
            
            // 123 132 123 231 132 231
            if (b.pointee > c.pointee) {
                swap(b, c)
                swap(bi, ci)
                // 123 123 123 213 123 213
                if (a.pointee > b.pointee) {
                    swap(a, b)
                    swap(ai, bi)
                }
                // 123 123 123 123 123 123
            }
            
        } else {
            // 123 132 213 231 312 321
            if (a.pointee < b.pointee) {
                swap(a, b)
                swap(ai, bi)
            }
            // 213 312 213 321 312 321
            if (b.pointee < c.pointee) {
                swap(b, c)
                swap(bi, ci)
                // 231 321 231 321 321 321
                if (a.pointee < b.pointee) {
                    swap(a, b)
                    swap(ai, bi)
                }
                // 321 321 321 321 321 321
            }
        }
    }
}

public func geom_sort<S: Comparable>(_ unsorted: [S], _ ascending: Bool, _ sorted: inout [S], _ index_map: inout [Int]) {
    // Original unsorted index map
    assert(unsorted.count == index_map.count)
    
    for i in 0..<unsorted.count {
        index_map[i] = i
    }
    
    // Sort the index map, using unsorted for comparison
    index_map.sort(by: { unsorted[$0] < unsorted[$1] })
    
    // if not ascending then reverse
    if (!ascending) {
        index_map.reverse()
    }
    
    // make space for output without clobbering
    assert(sorted.count == unsorted.count)
    // reorder unsorted into sorted using index map
    reorder(unsorted, index_map, &sorted)
}

