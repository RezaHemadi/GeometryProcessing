//
//  avg_edge_length.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Compute the average edge length for the given triangle mesh
// Templates:
//   DerivedV derived from vertex positions matrix type: i.e. MatrixXd
//   DerivedF derived from face indices matrix type: i.e. MatrixXi
//   DerivedL derived from edge lengths matrix type: i.e. MatrixXd
// Inputs:
//   V  eigen matrix #V by 3
//   F  #F by simplex-size list of mesh faces (must be simplex)
// Outputs:
//   l  average edge length
//
// See also: adjacency_matrix
func avg_edge_length<MV: Matrix, MF: Matrix>(_ V: MV, _ F: MF) -> Double where MV.Element == Double, MF.Element == Int {
    var E = MatX2<Int>()
    edges(F, &E)
    
    var avg: Double = .zero
    
    for i in 0..<E.rows {
        avg += (V.row(E[i, 0]) - V.row(E[i, 1])).norm()
    }
    
    return avg / Double(E.rows)
}

func avg_edge_length<MV: Matrix, MF: Matrix>(_ V: MV, _ F: MF) -> Float where MV.Element == Float, MF.Element == Int {
    var E = MatX2<Int>()
    edges(F, &E)
    
    var avg: Float = .zero
    
    for i in 0..<E.rows {
        avg += (V.row(E[i, 0]) - V.row(E[i, 1])).norm()
    }
    
    return avg / Float(E.rows)
}
