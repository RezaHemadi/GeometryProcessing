//
//  repmat.swift
//  GeometryProcessing
//
//  Created by Reza on 1/16/25.
//

import Foundation
import Matrix

/// replicate and tile a matrix
///
/// @tparam T  should be a eigen matrix primitive type like int or double
/// @param[in] A  m by n input matrix
/// @param[in] r  number of row-direction copies
/// @param[in] c  number of col-direction copies
/// @param[out] B  r*m by c*n output matrix
///
/// \note At least for Dense matrices this is replaced by `replicate` e.g., dst = src.replicate(n,m);
/// http://forum.kde.org/viewtopic.php?f=74&t=90876#p173517
///
public func repmat<MA: Matrix, MB: Matrix>(_ A: MA, _ r: Int, _ c: Int) -> MB where MA.Element == MB.Element {
    assert(r > 0)
    assert(c > 0)
    // Make room for output
    let output = MB(r * A.rows, c * A.cols)
    
    // copy tiled objects
    for i in 0..<r {
        for j in 0..<c {
            output.block(i * A.rows, j * A.cols, A.rows, A.cols) <<== A
        }
    }
    
    return output
}
