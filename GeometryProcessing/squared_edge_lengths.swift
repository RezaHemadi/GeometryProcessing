//
//  squared_edge_lengths.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Constructs a list of squared lengths of edges opposite each index in a face
  // (triangle) list
  //
  // Inputs:
  //   V  matrix #V by 3
  //   F  #F by 2 list of mesh edges
  //    or
  //   F  #F by 3 list of mesh faces (must be triangles)
  // Outputs:
  //   L  #F by {1|3} list of edge lengths squared
  //     for edges, column of lengths
  //     for triangles, columns correspond to edges [1,2],[2,0],[0,1]
  //
  //
public func squared_edge_lengths<M1: Matrix, M2: Matrix, S: Numeric>(vertices: M1, edges: M2) -> Vec<S> where M2.Element == Int, M1.Element == S, M1.RowType: Vector, M1.RowType.Element == S {
    let m = edges.rows
    
    var output = Vec<S>(m)
    
    for i in 0..<m {
        output[i] = (vertices.row(edges[i, 1]) - vertices.row(edges[i, 0])).squaredNorm()
    }
    
    return output
}

public func squared_edge_lengths<M1: Matrix, M2: Matrix, S: Numeric>(vertices: M1, faces: M2) -> Mat<S> where M2.Element == Int, M1.Element == S, M1.RowType: Vector, M1.RowType.Element == S {
    let m = faces.rows
    
    var output = Mat<S>(m, 3)
    
    for i in 0..<m {
        output[i, 0] = (vertices.row(faces[i, 1]) - vertices.row(faces[i, 2])).squaredNorm()
        output[i, 1] = (vertices.row(faces[i, 2]) - vertices.row(faces[i, 0])).squaredNorm()
        output[i, 2] = (vertices.row(faces[i, 0]) - vertices.row(faces[i, 1])).squaredNorm()
    }

    return output
}
