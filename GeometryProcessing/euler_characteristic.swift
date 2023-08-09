//
//  euler_characteristic.swift
//  GeometryProcessing
//
//  Created by Reza on 8/8/23.
//

import Foundation
import Matrix

// Computes the Euler characteristic of a given mesh (V,F)
//
// Inputs:
//   F #F by dim list of mesh faces (must be triangles)
// Returns An int containing the Euler characteristic
public func euler_characteristic<MF: Matrix>(_ F: MF) -> Int where MF.Element == Int {
    let nf: Int = F.rows
    let nv: Int = F.maxCoeff() + 1
    var E = Mati()
    edges(F, &E)
    let ne: Int = E.rows
    
    return nv - ne + nf
}

// Computes the Euler characteristic of a given mesh (V,F)
// Templates:
//   Scalar  should be a floating point number type
//   Index   should be an integer type
// Inputs:
//   V       #V by dim list of mesh vertex positions
//   F       #F by dim list of mesh faces (must be triangles)
// Returns An int containing the Euler characteristic
public func euler_characteristic<MF: Matrix, MV: Matrix>(_ V: MV, _ F: MF) -> Int
where MF.Element == Int, MV.Element == Double
{
    let euler_v = V.rows
    var EV = Mati()
    var FE = Mati()
    var EF = Mati()
    edge_topology(V, F, &EV, &FE, &EF)
    let euler_e = EV.rows
    let euler_f = F.rows
    
    let euler_char = euler_v - euler_e - euler_f
    
    return euler_char
}
