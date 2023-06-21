//
//  accumarray.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// ACCUMARRY Like Matlab's accumarray. Accumulate values in V using subscripts
// in S.
//
// Inputs:
//   S  #S list of subscripts
//   V  #V list of values
// Outputs:
//   A  max(subs)+1 list of accumulated values
public func accumarray<T: MatrixElement & AdditiveArithmetic>(_ S: Vec<Int>,
                                                       _ V: Vec<T>,
                                                       _ A: inout Vec<T>) {
    // S and V should be same size
    assert(V.count == S.count)
    
    if (S.count == 0) { A.resize(0); return}
    
    A.resize(S.maxCoeff() + 1, 1)
    A.setZero()
    
    for s in 0..<S.count {
        A[S[s]] += V[s]
    }
}

public func accumarray<T: MatrixElement & AdditiveArithmetic>(_ S: Vec<Int>,
                                                       _ V: T,
                                                       _ A: inout Vec<T>) {
    if (S.count == 0) { A.resize(0); return }
    A.resize(S.maxCoeff() + 1, 1)
    A.setZero()
    
    for s in 0..<S.count {
        A[S[s]] += V
    }
}
