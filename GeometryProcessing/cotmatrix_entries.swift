//
//  cotmatrix_entries.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// COTMATRIX_ENTRIES compute the cotangents of each angle in mesh (V,F)
//
// Inputs:
//   V  #V by dim list of rest domain positions
//   F  #F by {3|4} list of {triangle|tetrahedra} indices into V
// Outputs:
//     C  #F by 3 list of 1/2*cotangents corresponding angles
//       for triangles, columns correspond to edges [1,2],[2,0],[0,1]
//   OR
//     C  #F by 6 list of 1/6*cotangents of dihedral angles*edge lengths
//       for tets, columns along edges [1,2],[2,0],[0,1],[3,0],[3,1],[3,2]
//
public func cotmatrix_entries(_ V: Matd, _ F: Mati, _ C: inout Matd) {
    let m: Int = F.rows
    
    // Compute Squared Edge lengths
    //let l2: MatX3<Double>
    let l2: Matd = squared_edge_lengths(vertices: V, faces: F)
    
    // compute edge lengths
    let l: Matd = l2.unaryExpr({ sqrt($0) })
    
    // double area
    var dblA: Vec<Double> = .init()
    doublearea(l, 0.0, &dblA)
    // cotangents and diagonal entries for element matrices
    // correctly divided by 4 (alec 2010)
    C.resize(m, 3)
    for i in 0..<m {
        C[i, 0] = (l2[i, 1] + l2[i, 2] - l2[i, 0]) / dblA[i] / 4.0
        C[i, 1] = (l2[i, 2] + l2[i, 0] - l2[i, 1]) / dblA[i] / 4.0
        C[i, 2] = (l2[i, 0] + l2[i, 1] - l2[i, 2]) / dblA[i] / 4.0
    }
}
