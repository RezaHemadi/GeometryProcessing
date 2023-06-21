//
//  local_basis.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Compute a local orthogonal reference system for each triangle in the given mesh
  // Templates:
  //   DerivedV derived from vertex positions matrix type: i.e. MatrixXd
  //   DerivedF derived from face indices matrix type: i.e. MatrixXi
  // Inputs:
  //   V  eigen matrix #V by 3
  //   F  #F by 3 list of mesh faces (must be triangles)
  // Outputs:
  //   B1 eigen matrix #F by 3, each vector is tangent to the triangle
  //   B2 eigen matrix #F by 3, each vector is tangent to the triangle and perpendicular to B1
  //   B3 eigen matrix #F by 3, normal of the triangle
public func local_basis(V: MatX3d, F: MatX3i, B1: inout MatX3d, B2: inout MatX3d, B3: inout MatX3d) {
    B1.resize(F.rows, 3)
    B2.resize(F.rows, 3)
    B3.resize(F.rows, 3)
    
    for i in 0..<F.rows {
        let v1: RVec3d = (V.row(F[i, 1]) - V.row(F[i, 0])).normalized()
        let t: RVec3d = V.row(F[i, 2]) - V.row(F[i, 0])
        let v3: RVec3d = v1.cross(t).normalized()
        let v2: RVec3d = v1.cross(v3).normalized()
        
        B1.row(i) <<== v1
        B2.row(i) <<== -v2
        B3.row(i) <<== v3
    }
}
