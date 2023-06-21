//
//  min_quad_with_fixed_solve.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Solves a system previously factored using min_quad_with_fixed_precompute
//
// Template:
//   T  type of sparse matrix (e.g. double)
//   DerivedY  type of Y (e.g. derived from VectorXd or MatrixXd)
//   DerivedZ  type of Z (e.g. derived from VectorXd or MatrixXd)
// Inputs:
//   data  factorization struct with all necessary precomputation to solve
//   B  n by k column of linear coefficients
//   Y  b by k list of constant fixed values
//   Beq  m by k list of linear equality constraint constant values
// Outputs:
//   Z  n by k solution
//   sol  #unknowns+#lagrange by k solution to linear system
// Returns true on success, false on error
public func min_quad_with_fixed_solve(_ data: min_quad_with_fixed_data,
                               _ B: Vec<Double>,
                               _ Y: Vec<Double>,
                               _ Beq: Vec<Double>,
                               _ Z: inout Vec<Double>) -> Bool {
    // number of known rows
    let kr: Int = data.known.count
    
    if (kr != 0) {
        assert(kr == Y.count)
    }
    
    // number of columns to solve
    let cols: Int = 1
    
    Z.resize(data.n)
    
    // set known values
    for i in 0..<kr {
        Z[data.known[i]] = Y[i]
    }
    
    var BBequlcols: Matd = .init()
    slice(B, data.unknown_lagrange, 1, &BBequlcols)
    let NB: Mat<Double>
    
    if (kr == 0) {
        NB = BBequlcols
    } else {
        NB = data.preY * Y + BBequlcols
    }
    
    var sol: Vec<Double>
    
    switch (data.solverType) {
    case .LLT:
        sol = data.llt.solve(b: NB)
    default:
        fatalError("To be implemented")
    }
    
    sol *= -0.5
    
    for i in 0..<sol.rows {
        Z[data.unknown_lagrange[i]] = sol[i]
    }
    
    return true
}

