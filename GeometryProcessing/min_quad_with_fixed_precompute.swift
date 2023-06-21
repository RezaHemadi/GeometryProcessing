//
//  min_quad_with_fixed_precompute.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

public func min_quad_with_fixed_precompute(_ A2: SpMat, _ known: Veci, _ Aeq: SpMat, _ pd: Bool) -> min_quad_with_fixed_data {
    let A: SpMat = 0.5 * A2
    
    // cache problem size
    let n: Int = A.rows
    
    // number of equality constraints
    let neq: Int = Aeq.rows
    
    // number of known rows
    let kr: Int = known.count
    
    let data_known: Vec<Int> = .init(known, known.count, 1)
    var data_unknown: Vec<Int> = .init(n - kr)
    var unknown_mask: [Bool] = .init(repeating: true, count: n)
    
    for i in 0..<kr {
        unknown_mask[known[i]] = false
    }
    
    var u: Int = 0
    for i in 0..<n {
        if (unknown_mask[i]) {
            data_unknown[u] = i
            u += 1
        }
    }
    
    var data_unknown_lagrange: Vec<Int> = .init()
    
    if (data_unknown.count > 0) {
        data_unknown_lagrange = .init(data_unknown, data_unknown.rows, data_unknown.cols)
    }
    
    // Auu is a slice of A that correspond to unknown variables in the problem
    var Auu: SpMat = .init()
    slice(A, data_unknown, data_unknown, &Auu)
    
    // determine whether Auu is positive definite
    let data_Auu_pd: Bool = pd
    
    var data_Auu_sym: Bool = false
    if (data_Auu_pd) {
        data_Auu_sym = true
    } else {
        fatalError("To be implemented")
    }
    
    // variable storing number of linearly independent constraints
    let nc: Int = 0
    let data_Aeq_li: Bool
    
    if (neq > 0) {
        fatalError("To be implemented")
    } else {
        data_Aeq_li = true
    }
    
    var data_preY: SpMat = .init()
    
    if data_Aeq_li {
        let new_A = SpMat(A)
        if (kr > 0) {
            var Aulk: SpMat = .init()
            let Akul: SpMat
            slice(new_A, data_unknown_lagrange, data_known, &Aulk)
            
            if (data_Auu_sym) {
                data_preY = 2.0 * Aulk
            } else {
                fatalError("to be implemented")
            }
        } else {
            fatalError("To be implemented")
        }
        
        // Positive definite and no equality constraints
        // positive definiteness implies symmetry
        if (data_Auu_pd && neq == 0) {
            let data_llt: SparseLLT = .init(Auu, transpose: false)
            let solverType: min_quad_with_fixed_data.SolverType = .LLT
            
            return .init(n: n, Auu_pd: data_Auu_pd, Auu_sym: data_Auu_sym,
                         known: data_known,
                         unknown: data_unknown,
                         unknown_lagrange: data_unknown_lagrange,
                         preY: data_preY, solverType: solverType, llt: data_llt)
        } else {
            fatalError("To be implemented")
        }
    } else {
        fatalError("To be implemented")
    }
}
