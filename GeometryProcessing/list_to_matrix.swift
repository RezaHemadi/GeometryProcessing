//
//  list_to_matrix.swift
//  GeometryProcessing
//
//  Created by Reza on 6/23/23.
//

import Foundation
import Matrix

// Convert a list (std::vector) of row vectors of the same length to a matrix
// Template:
//   T  type that can be safely cast to type in Mat via '='
//   Mat  Matrix type, must implement:
//     .resize(m,n)
//     .row(i) = Row
// Inputs:
//   V  a m-long list of vectors of size n
// Outputs:
//   M  an m by n matrix
// Returns true on success, false on errors
@discardableResult
public func list_to_matrix<T: MatrixElement, MO: Matrix>(_ V: [[T]], _ M: inout MO) -> Bool where MO.Element == T {
    // number of rows
    let m: Int = V.count
    if (m == 0) {
        M.resize(MO.Rows >= 0 ? MO.Rows : 0,
                 MO.Cols >= 0 ? MO.Cols : 0)
        return true
    }
    // number of columns
    let n = min_size(V)
    if (n != max_size(V)) {
        return false
    }
    assert(n != -1)
    // Resize output
    M.resize(m, n)
    
    // Loop over rows
    for i in 0..<m {
        // Loop over cols
        for j in 0..<n {
            M[i, j] = V[i][j]
        }
    }
    
    return true
}
