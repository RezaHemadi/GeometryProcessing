//
//  edge_lengths.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Constructs a list of lengths of edges opposite each index in a face
  // (triangle) list
  //
  // Inputs:
  //   V  matrix #V by 3
  //   F  #F by 2 list of mesh edges
  //    or
  //   F  #F by 3 list of mesh faces (must be triangles)
  // Outputs:
  //   L  #F by {1|3} list of edge lengths
  //     for edges, column of lengths
  //     for triangles, columns correspond to edges [1,2],[2,0],[0,1]
public func edge_lengths<M1: Matrix, M2: Matrix>(vertices: M1, edges: M2) -> Vec<Double> where M1.Element == Double, M2.Element == Int, M1.RowType: Vector, M1.RowType.Element == Double {
    var output = squared_edge_lengths(vertices: vertices, edges: edges).unaryExpr({ sqrt($0) })
    
    return output
}

public func edge_lengths<M1: Matrix, M2: Matrix>(vertices: M1, edges: M2) -> Vec<Float> where M1.Element == Float, M2.Element == Int, M1.RowType: Vector, M1.RowType.Element == Float {
    var output = squared_edge_lengths(vertices: vertices, edges: edges).unaryExpr({ sqrtf($0) })
    return output
}


public func edge_lengths<M1: Matrix, M2: Matrix>(vertices: M1, faces: M2) -> Mat<Double> where M1.Element == Double, M1.RowType: Vector, M1.RowType.Element == Double, M2.Element == Int {
    var output = squared_edge_lengths(vertices: vertices, faces: faces).unaryExpr({ sqrt($0) })
    return output
}

public func edge_lengths<M1: Matrix, M2: Matrix>(vertices: M1, faces: M2) -> Mat<Float> where M1.Element == Float, M1.RowType: Vector, M1.RowType.Element == Float, M2.Element == Int {
    var output = squared_edge_lengths(vertices: vertices, faces: faces).unaryExpr({ sqrtf($0) })
    return output
}

