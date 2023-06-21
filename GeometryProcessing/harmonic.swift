//
//  harmonic.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Compute k-harmonic weight functions "coordinates".
//
//
// Inputs:
//   V  #V by dim vertex positions
//   F  #F by simplex-size list of element indices
//   b  #b boundary indices into V
//   bc #b by #W list of boundary values
//   k  power of harmonic operation (1: harmonic, 2: biharmonic, etc)
// Outputs:
//   W  #V by #W list of weights
//
public func harmonic<M: Matrix>(_ V: Matd, _ F: Mati, _ b: Veci, _ bc: Matd, _ k: Int) throws -> M where M.Element == Double {
    var M: SpMat = .init()
    let L = cotmatrix(V, F)
    if (k > 1) {
        fatalError("to be implemented")
    }
    return try harmonic(L, M, b, bc, k)
}

// Compute harmonic map using uniform laplacian operator
//
// Inputs:
//   F  #F by simplex-size list of element indices
//   b  #b boundary indices into V
//   bc #b by #W list of boundary values
//   k  power of harmonic operation (1: harmonic, 2: biharmonic, etc)
// Outputs:
//   W  #V by #W list of weights
//
public func harmonic<M: Matrix>(_ F: Mati, _ b: Veci, _ bc: Matd, _ k: Int) throws -> M where M.Element == Double {
    var A: SpMat = .init()
    adjacency_matrix(F, &A)
    
    // sum each row of A
    let ASum: Vec<Double> = A.outerSum()
    // convert row sums into diagonal of sparse matrix
    let Adiag: SpMat = .Diagonal(vector: ASum)
    let L: SpMat = A - Adiag
    let M: SpMat = .Identity(dimension: L.rows)
    
    return try harmonic(L, M, b, bc, k)
}

// Compute a harmonic map using a given Laplacian and mass matrix
//
// Inputs:
//   L  #V by #V discrete (integrated) Laplacian
//   M  #V by #V mass matrix
//   b  #b boundary indices into V
//   bc  #b by #W list of boundary values
//   k  power of harmonic operation (1: harmonic, 2: biharmonic, etc)
// Outputs:
//   W  #V by #V list of weights
public func harmonic<M: Matrix>(_ L: SpMat, _ M: SpMat, _ b: Veci, _ bc: Matd, _ k: Int) throws -> M where M.Element == Double {
    let n: Int = L.rows
    
    assert(n == L.cols)
    assert(k == 1 || n == M.cols)
    assert(k == 1 || n == M.rows)
    // assert mass matrix must be diagonal
    
    let Q: SpMat = harmonic(L, M, k)
    print("pre-computing minimization problem data...")
    let data = min_quad_with_fixed_precompute(Q, b, SpMat(), true)
    print("minimization data ready.")
    let W: M = .init(n, bc.cols)
    let B: Vec<Double> = .Zero(n)
    
    for w in 0..<bc.cols {
        let bcw = bc.col(w)
        var Ww: Vec<Double> = .init()
        if (!min_quad_with_fixed_solve(data, B, bcw, Vec<Double>(), &Ww)) {
            throw HarmonicError.unsolvable
        }
        W.col(w) <<== Ww
    }
    return W
}

// Build the discrete k-harmonic operator (computing integrated quantities).
// That is, if the k-harmonic PDE is Q x = 0, then this minimizes x' Q x
//
// Inputs:
//   L  #V by #V discrete (integrated) Laplacian
//   M  #V by #V mass matrix
//   k  power of harmonic operation (1: harmonic, 2: biharmonic, etc)
// Outputs:
//   Q  #V by #V discrete (integrated) k-Laplacian
public func harmonic(_ L: SpMat, _ M: SpMat, _ k: Int) -> SpMat {
    assert(L.rows == L.cols)
    let Q: SpMat = -L
    if (k == 1) { return Q }
    
    fatalError("To be implemented")
}

enum HarmonicError: Error {
    case unsolvable
}

