//
//  lscm.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Inputs:
//   V  #V by 3 list of mesh vertex positions
//   F  #F by 3 list of mesh faces (must be triangles)
//   b  #b boundary indices into V
//   bc #b by 2 list of boundary values
// Outputs:
//   UV #V by 2 list of 2D mesh vertex positions in UV space
//   Q  #Vx2 by #Vx2 symmetric positive semi-definite matrix for computing LSCM energy
// Returns true only on solver success.
public func lscm(_ V: Mat<Double>,
          _ F: Mat<Int>,
          _ b: Vec<Int>,
          _ bc: Mat<Double>,
          _ V_uv: inout Mat<Double>,
          _ Q: inout SparseMatrix<Double>) -> Bool {
    // Assemble the area matrix (note that A is #Vx2 by #Vx2
    let A: SparseMatrix<Double> = vector_area_matrix(F)
    
    // Assembe the cotan laplacian matrix
    let L: SparseMatrix<Double> = cotmatrix(V, F)
    
    let L_flat: SparseMatrix<Double> = repdiag(L, 2)
    
    let b_flat = Vec<Int>(b.count * bc.cols)
    let bc_flat = Vec<Double>(bc.size.count)
    
    for c in 0..<bc.cols {
        b_flat.block(c * b.count, 0, b.rows, 1) <<== (b.array() + c * V.rows)
        bc_flat.block(c * bc.rows, 0, bc.rows, 1) <<== bc.col(c)
    }
    
    // Minimize the LSCM energy
    Q = -L_flat - (2.0 * A)
    let B_flat = Vec<Double>.Zero(V.rows * 2)
    let data = min_quad_with_fixed_precompute(Q, b_flat, SpMat(), true)
    var W_flat = Vec<Double>()
    if (!min_quad_with_fixed_solve(data, B_flat, bc_flat, Vec<Double>(), &W_flat)) {
        return false
    }
    
    assert(W_flat.rows == V.rows * 2)
    V_uv.resize(V.rows, 2)
    for i in 0..<V_uv.cols {
        V_uv.col(i) <<== W_flat.block(V_uv.rows * i, 0, V_uv.rows, 1)
    }
    
    return true
}

// Wrapper where the output Q is discarded
public func lscm(_ V: Mat<Double>,
          _ F: Mat<Int>,
          _ b: Vec<Int>,
          _ bc: Mat<Double>,
          _ V_uv: inout Mat<Double>) -> Bool {
    var Q = SparseMatrix<Double>()
    return lscm(V, F, b, bc, &V_uv, &Q)
}

