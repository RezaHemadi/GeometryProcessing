//
//  is_edge_manifold.swift
//  GeometryProcessing
//
//  Created by Reza on 8/6/23.
//

import Foundation
import Matrix

// check if the mesh is edge-manifold (every edge is incident one one face
// (boundary) or two oppositely oriented faces).
//
// Inputs:
//   F  #F by 3 list of triangle indices
// Returns true iff all edges are manifold
//
// See also: is_vertex_manifold

public func is_edge_manifold<MF: Matrix>(_ F: MF) -> Bool where MF.Element == Int {
    var BF = Mat<Bool>()
    var BE = Vec<Bool>()
    var E = Mati()
    var EMAP = Veci()
    
    return is_edge_manifold(F, &BF, &E, &EMAP, &BE)
}

// Inputs:
//   F  #F by 3 list of triangle indices
// Outputs:
//   BF  #F by 3 list of flags revealing if edge opposite corresponding vertex
//   is non-manifold.
//   E  #E by 2 list of unique edges
//   EMAP  3*#F list of indices of opposite edges in "E"
//   BE  #E list of flages whether edge is non-manifold
public func is_edge_manifold<MF: Matrix, MBF: Matrix, ME: Matrix, MBE: Matrix>
(_ F: MF, _ BF: inout MBF, _ E: inout ME, _ EMAP: inout Veci, _ BE: inout MBE) -> Bool
where MBF.Element == Bool, ME.Element == Int, MBE.Element == Bool, MF.Element == Int
{
    var allE = Mati()
    unique_edge_map(F, &allE, &E, &EMAP)
    
    return is_edge_manifold(F, E.rows, EMAP, &BF, &BE)
}

// Inputs:
//   F  #F by 3 list of triangle indices
//   ne  number of edges (#E)
//   EMAP  3*#F list of indices of opposite edges in "E"
// Outputs:
//   BF  #F by 3 list of flags revealing if edge opposite corresponding vertex
//     is non-manifold.
//   BE  ne list of flages whether edge is non-manifold
public func is_edge_manifold<MF: Matrix, MEMAP: Vector, MBF: Matrix, MBE: Matrix>
(_ F: MF, _ ne: Int, _ EMAP: MEMAP, _ BF: inout MBF, _ BE: inout MBE) -> Bool
where MF.Element == Int, MEMAP.Element == Int, MBF.Element == Bool, MBE.Element == Bool
{
    var count: [Int] = .init(repeating: 0, count: ne)
    for e in 0..<EMAP.rows {
        count[EMAP[e]] += 1
    }
    let m: Int = F.rows
    BF.resize(m, 3)
    BE.resize(ne, 1)
    var all: Bool = true
    
    for e in 0..<EMAP.rows {
        let manifold: Bool = (count[EMAP[e]] <= 2)
        BF[e % m, e / m] = manifold
        all = (all && manifold)
        BE[EMAP[e]] = manifold
    }
    
    return all
}
