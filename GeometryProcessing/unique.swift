//
//  unique.swift
//  GeometryProcessing
//
//  Created by Reza on 8/4/23.
//

import Foundation
import Matrix

// Act like matlab's [C,IA,IC] = unique(X)
//
// Templates:
//   T  comparable type T
// Inputs:
//   A  #A vector of type T
// Outputs:
//   C  #C vector of unique entries in A
//   IA  #C index vector so that C = A(IA);
//   IC  #A index vector so that A = C(IC);
func unique<T: Comparable>(_ A: [T], _ C: inout [T], _ IA: inout [Int], _ IC: inout [Int]) {
    var IM: [Int] = []
    var sortA: [T] = []
    geom_sort(A, true, &sortA, &IM)
    // Original unsorted index map
    IA = .init(repeating: 0, count: sortA.count)
    
    for i in 0..<sortA.count {
        IA[i] = i
    }
    
    let indexEquals: (Int, Int) -> Bool = { a, b in
        return sortA[a] == sortA[b]
    }
    
    IA.uniqueAll(by: indexEquals)
    
    IC = .init(repeating: 0, count: A.count)
    var j: Int = 0
    for i in 0..<sortA.count {
        if (sortA[IA[j]] != sortA[i]) {
            j += 1
        }
        IC[IM[i]] = j
    }
    var temp_C: [T?] = .init(repeating: nil, count: IA.count)
    // Reindex IA according to IM
    for i in 0..<IA.count {
        IA[i] = IM[IA[i]]
        temp_C[i] = A[IA[i]]
    }
    
    assert(!temp_C.contains(where: { $0 == nil }))
    C = temp_C.compactMap({ $0 })
}

func unique<T: Comparable>(_ A: [T], _ C: inout [T]) {
    var IA: [Int] = []
    var IC: [Int] = []
    return unique(A, &C, &IA, &IC)
}

func unique<MA: Matrix, MC: Matrix, MIA: Matrix, MIC: Matrix>(_ A: MA, _ C: inout MC, _ IA: inout MIA, _ IC: inout MIC) {
    fatalError("To be implemented")
}

func unique<MA: Matrix, MC: Matrix>(_ A: MA, _ C: MC) {
    fatalError("To be implemented")
}
