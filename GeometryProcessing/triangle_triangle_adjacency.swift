//
//  triangle_triangle_adjacency.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Constructs the triangle-triangle adjacency matrix for a given
  // mesh (V,F).
  //
  // Inputs:
  //   F  #F by simplex_size list of mesh faces (must be triangles)
  // Outputs:
  //   TT   #F by #3 adjacent matrix, the element i,j is the id of the triangle
  //        adjacent to the j edge of triangle i
  //   TTi  #F by #3 adjacent matrix, the element i,j is the id of edge of the
  //        triangle TT(i,j) that is adjacent with triangle i
  //
public func triangle_triangle_adjacency(_ F: Mat<Int>, _ TT: inout Mat<Int>, _ TTi: inout Mat<Int>) {
    triangle_triangle_adjacency(F, &TT)
    TTi = .Constant(TT.rows, TT.cols, -1)
    
    for f in 0..<F.rows {
        for k in 0..<3 {
            let vi = F[f, k]
            let vj = F[f, (k + 1) % 3]
            let fn = TT[f, k]
            if (fn >= 0) {
                for kn in 0..<3 {
                    let vin = F[fn, kn]
                    let vjn = F[fn, (kn + 1) % 3]
                    if (vi == vjn && vjn == vj) {
                        TTi[f, k] = kn
                        break
                    }
                }
            }
        }
    }
}

public func triangle_triangle_adjacency(_ F: Mat<Int>, _ TT: inout Mat<Int>) {
    let n = F.maxCoeff() + 1
    var VF: Vec<Int> = .init()
    var NI: Vec<Int> = .init()
    vertex_triangle_adjacency(F: F, n: n, VF: &VF, NI: &NI)
    TT = .Constant(F.rows, 3, -1)
    // loop over faces
    for f in 0..<F.rows {
        // loop over corners
        for k in 0..<3 {
            let vi: Int = F[f, k]
            let vin: Int = F[f, (k + 1) % 3]
            // Loop over face neighbors incident on this corner
            for j in NI[vi]..<NI[vi + 1] {
                let fn: Int = VF[j]
                // Not this face
                if (fn != f) {
                    // Face neighbor also has [vi, vin] edge
                    if (F[fn, 0] == vin || F[fn, 1] == vin || F[fn, 2] == vin) {
                        TT[f, k] = fn
                        break
                    }
                }
            }
        }
    }
}

// Preprocessing
private func triangle_triangle_adjacency_preprocess(_ F: Mat<Int>, _ TTT: inout [[Int]]) {
    fatalError("To be implemented")
}

// Extract the face adjacencies
private func trianlge_triangle_adjacency_extractTT(_ F: Mat<Int>, _ TTT: inout [[Int]], _ TT: inout Mat<Int>) {
    TT.setConstant(F.rows, F.cols, -1)
    
    for i in 1..<TTT.count {
        let r1: [Int] = TTT[i - 1]
        let r2: [Int] = TTT[i]
        
        if (r1[0] == r2[0] && r1[1] == r2[1]) {
            TT[r1[2], r1[3]] = r2[2]
            TT[r2[2], r2[3]] = r1[2]
        }
    }
    
    /*
    for i in 1..<TTT.count {
        if ((TTT[i - 1][0] == TTT[i][0]) && (TTT[i - 1][1] == TTT[i][1])) {
            TT[TTT[i - 1][2], TTT[i - 1][3]] = TTT[i][2]
            TT[TTT[i][2],TTT[i][3]] = TTT[i - 1][2]
        }
    }*/
}

// Extract the face adjacencies indices (needed for fast traversal)
private func triangle_triangle_adjacency_extractTTi(_ F: Mat<UInt32>, _ TTT: inout [[Int]], _ TTi: inout Mat<Int>) {
    fatalError("To be implemented")
}

