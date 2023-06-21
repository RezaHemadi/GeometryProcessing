//
//  unique_rows.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Act like matlab's [C,IA,IC] = unique(X,'rows')
//
// Templates:
//   DerivedA derived scalar type, e.g. MatrixXi or MatrixXd
//   DerivedIA derived integer type, e.g. MatrixXi
//   DerivedIC derived integer type, e.g. MatrixXi
// Inputs:
//   A  m by n matrix whose entries are to unique'd according to rows
// Outputs:
//   C  #C vector of unique rows in A
//   IA  #C index vector so that C = A(IA,:);
//   IC  #A index vector so that A = C(IC,:);
public func unique_rows<M: Matrix>(_ A: M,
                            _ C: inout M,
                            _ IA: inout Vec<Int>,
                            _ IC: inout Vec<Int>) where M.Element: Comparable {
    typealias Scalar = M.Element
    var IM: Vec<Int> = .init()
    var sortA: M = .init(A.rows, A.cols)
    sortrows(A, true, &sortA, &IM)
    
    let num_rows: Int = sortA.rows
    let num_cols: Int = sortA.cols
    var vIA: [Int] = .init(repeating: 0, count: num_rows)
    for i in 0..<num_rows {
        vIA[i] = i
    }
    
    let index_equal: (Int, Int) -> Bool = { i, j in
        for c in 0..<num_cols {
            if (sortA[i, c] != sortA[j, c]) {
                return false
            }
        }
        return true
    }
    
    vIA.unique(by: index_equal)
    
    IC.resize(A.rows)
    var j: Int = 0
    for i in 0..<num_rows {
        if (sortA.row(vIA[j]) != sortA.row(i)) {
            //print("\(sortA.row(vIA[j])) and \(sortA.row(i)) are not equal")
            j += 1
        } else {
            //print("\(sortA.row(vIA[j])) and \(sortA.row(i)) are equal")
        }
        IC[IM[i]] = j
    }
    let unique_rows: Int = vIA.count
    C.resize(unique_rows, A.cols)
    IA.resize(unique_rows)
    // Reindex IA according to IM
    for i in 0..<unique_rows {
        IA[i] = IM[vIA[i]]
        C.row(i) <<== A.row(IA[i])
    }
}
