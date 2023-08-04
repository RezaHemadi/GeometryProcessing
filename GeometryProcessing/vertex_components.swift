//
//  vertex_components.swift
//  GeometryProcessing
//
//  Created by Reza on 7/11/23.
//

import Foundation
import Matrix

// Compute connected components of a graph represented by an adjacency
// matrix.
//
// Returns a component ID per vertex of the graph where connectivity is established by edges.
//
// Inputs:
//   A  n by n adjacency matrix
// Outputs:
//   C  n list of component ids (starting with 0)
//   counts  #components list of counts for each component
//
public func vertex_components<S: MatrixElement & ExpressibleByIntegerLiteral, VC: Vector, VCOUNT: Vector>
(_ A: SparseMatrix<S>, _ C: inout VC, _ counts: inout VCOUNT) where VC.Element == Int, VCOUNT.Element == Int {
    
    assert(A.rows == A.cols, "A should be square")
    
    let n: Int = A.rows
    var seen: [Bool] = .init(repeating: false, count: n)
    C.resize(n, 1)
    
    var id: Int = 0
    var vcounts: [Int] = []
    
    // breadth first search
    for k in 0..<A.outerSize {
        if (seen[k]) {
            continue
        }
        var Q: [Int] = []
        Q.append(k)
        vcounts.append(0)
        
        while (!Q.isEmpty) {
            let f: Int = Q.removeFirst()
            if (seen[f]) {
                continue
            }
            seen[f] = true
            C[f, 0] = id
            vcounts[id] += 1
            
            // iterate over inside
            for it in A.innerIterator(f) {
                let g: Int = it.index
                if (!seen[g] && (it.value != 0)) {
                    Q.append(g)
                }
            }
        }
        id += 1
    }
    assert(id == vcounts.count)
    let ncc: Int = vcounts.count
    assert(C.maxCoeff() + 1 == ncc)
    counts.resize(ncc, 1)
    for i in 0..<ncc {
        counts[i] = vcounts[i]
    }
}

public func vertex_components<S: MatrixElement & ExpressibleByIntegerLiteral, VC: Vector>
(_ A: SparseMatrix<S>, _ C: inout VC) where VC.Element == Int {
    
    var counts = Veci()
    return vertex_components(A, &C, &counts)
}

public func vertex_components<MF: Matrix, VC: Vector>(_ F: MF, _ C: inout VC) where MF.Element == Int, VC.Element == Int {
    var A = SparseMatrix<VC.Element>()
    adjacency_matrix(F, &A)
    return vertex_components(A, &C)
}
