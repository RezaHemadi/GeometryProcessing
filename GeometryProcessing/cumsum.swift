//
//  cumsum.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Computes a cumulative sum of the columns of X, like matlab's `cumsum`.
  //
  // Templates:
  //   DerivedX  Type of matrix X
  //   DerivedY  Type of matrix Y
  // Inputs:
  //   X  m by n Matrix to be cumulatively summed.
  //   dim  dimension to take cumulative sum (1 or 2)
  // Output:
  //   Y  m by n Matrix containing cumulative sum.
public func cumsum<M: Matrix>(_ X: M, _ dim: Int, _ Y: inout M) where M.Element: AdditiveArithmetic & ExpressibleByIntegerLiteral {
    return cumsum(X, dim, false, &Y)
}

// Computes a cumulative sum of the columns of [0;X]
  //
  // Inputs:
  //   X  m by n Matrix to be cumulatively summed.
  //   dim  dimension to take cumulative sum (1 or 2)
  //   zero_prefix whe
  // Output:
  //   if zero_prefix == false
  //     Y  m by n Matrix containing cumulative sum
  //   else
  //     Y  m+1 by n Matrix containing cumulative sum if dim=1
  //     or
  //     Y  m by n+1 Matrix containing cumulative sum if dim=2
public func cumsum<M: Matrix>(_ X: M, _ dim: Int, _ zero_prefix: Bool, _ Y: inout M) where M.Element: AdditiveArithmetic & ExpressibleByIntegerLiteral {
    Y.resize(
        X.rows + (zero_prefix && dim == 1 ? 1 : 0),
        X.cols + (zero_prefix && dim == 2 ? 1 : 0))
    // get number of columns (or rows)
    let num_outer: Int = (dim == 1 ? X.cols : X.rows)
    // get number of rows ( or columns)
    let num_inner: Int = (dim == 1 ? X.rows : X.cols)
    
    if (dim == 1) {
        if (zero_prefix) {
            Y.row(0).setConstant(0)
        }
        
        for o in 0..<num_outer {
            var sum: M.Element = 0
            for i in 0..<num_inner {
                sum += X[i, o]
                let yi: Int = zero_prefix ? i + 1 : i
                Y[yi, o] = sum
            }
        }
    } else {
        if (zero_prefix) {
            Y.col(0).setConstant(0)
        }
        for i in 0..<num_inner {
            let yi: Int = zero_prefix ? i + 1 : i
            for o in 0..<num_outer {
                if ( i == 0 ) {
                    Y[o, yi] = X[o, i]
                } else {
                    Y[o, yi] = Y[o, yi - 1] + X[o, i]
                }
            }
        }
    }
}
