//
//  min_quad_with_fixed_data.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

public struct min_quad_with_fixed_data {
    enum SolverType: Int {
        case LLT
        case LDLT
        case LU
        case QR_LLT
        case NUM_SOLVER_TYPES = 4
    }
    
    // MARK: - Properties
    /// size of original system: number of unknowns + number of knowns
    var n: Int
    /// Whether A(unknonwn, unknown) is positive definite
    var Auu_pd: Bool
    /// Whether A(unknown, unkonwn) is symmetric
    var Auu_sym: Bool
    /// Indices of known variables
    var known: Veci
    /// Indices of unkown variables
    var unknown: Veci
    /// Indices of lagrange variables
    //var lagrange: Veci?
    /// Indices of unknown variable followed by indices of lagrange variables
    var unknown_lagrange: Veci
    /// Matrix multiplied against Y when constructing right hand side
    var preY: SpMat
    
    var solverType: SolverType
    
    // MARK: - Sovers
    var llt: SparseLLT
    //var ldlt: SimplicalLDLT?
    //var lu: SparseLU?
    
    // MARK: - QR factorization
    /// Are rows of Aeq linearly independent?
    //var Aeq_li: Bool?
    /// Columns of Aeq corresponding to unkowns
    //var neq: Int?
    //var AeqTQR: SparseQR?
    //var Aeqk: SpMat?
    //var Aequ: SpMat?
    //var Auu: SpMat?
    //var AeqTQ1: SpMat?
    //var AeqTQ1T: SpMat?
    //var AeqTQ2: SpMat?
    //var AeqTQ2T: SpMat?
    //var AeqTR1: SpMat?
    //var AeqTR1T: SpMat?
    //var AeqTE: SpMat?
    //var AeqTET: SpMat?
    
    // MARK: - Debug
    //var NA: SpMat?
    //var NB: Matd?
}

public struct SimplicalLDLT {}
public struct SparseLU {}
