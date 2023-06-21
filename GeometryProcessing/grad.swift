//
//  grad.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// GRAD
  // G = grad(V,F)
  //
  // Compute the numerical gradient operator
  //
  // Inputs:
  //   V          #vertices by 3 list of mesh vertex positions
  //   F          #faces by 3 list of mesh face indices [or a #faces by 4 list of tetrahedral indices]
  //   uniform    boolean (default false) - Use a uniform mesh instead of the vertices V
  // Outputs:
  //   G  #faces*dim by #V Gradient operator
  //

  // Gradient of a scalar function defined on piecewise linear elements (mesh)
  // is constant on each triangle [tetrahedron] i,j,k:
  // grad(Xijk) = (Xj-Xi) * (Vi - Vk)^R90 / 2A + (Xk-Xi) * (Vj - Vi)^R90 / 2A
  // where Xi is the scalar value at vertex i, Vi is the 3D position of vertex
  // i, and A is the area of triangle (i,j,k). ^R90 represent a rotation of
  // 90 degrees
// triangle  case
public func grad(V: MatX3d, F: MatX3i, G: inout SpMat, uniform: Bool = false) {
    // number of faces
    let m: Int = F.rows
    // number of vertices
    let nv: Int = V.rows
    // number of dimensions
    let dims: Int = V.cols
    let eperp21: MatX3d = .init(m, 3)
    let eperp13: MatX3d = .init(m, 3)
    
    for i in 0..<m {
        // renaming indices of vertices of triangles for convenience
        let i1: Int = F[i, 0]
        let i2: Int = F[i, 1]
        let i3: Int = F[i, 2]
        
        // #F x 3 matrices of triangle edge vectors, named after opposite vertices
        var v32: RVec3d = .Zero(1, 3)
        var v13: RVec3d = .Zero(1, 3)
        var v21: RVec3d = .Zero(1, 3)
        
        v32.head(V.cols) <<== V.row(i3) - V.row(i2)
        v13.head(V.cols) <<== V.row(i1) - V.row(i3)
        v21.head(V.cols) <<== V.row(i2) - V.row(i1)
        var n: RVec3d = v32.cross(v13)
        // area of parallelogram is twice area of triangle
        // area of parallelogram is || v1 x v2 ||
        // This does correct l2 norm of rows, so that it contains #F list of twice
        // triangle areas
        let dblA = sqrt(n.dot(n))
        var u: RVec3d = .init([0, 0, 1])
        if (!uniform) {
            // now normalize normals to get unit normals
            u = n / dblA
        } else {
            // Abstract equilateral triangle v1=(0, 0), v2=(h, 0), v3=(h/2, (sqrt(3) / 2)*h)
            
            // get h (by the area of the triangle)
            let h: Double = sqrt( (dblA) / sin(.pi / 3)) // (h^2*sin(60))/2. = Area => h = sqrt(2*Area/sin_60)
            
            let v1: Vec3d = [0, 0, 0]
            let v2: Vec3d = [h, 0, 0]
            let v3: Vec3d = [h / 2.0, (sqrt(3.0) / 2.0) * h, 0]
            
            // now fix v32, v13, v21 and the normal
            v32 = v3 - v2
            v13 = v1 - v3
            v21 = v2 - v1
            n = v32.cross(v13)
        }
        
        // rotate each vector 90 degrees around normal
        let norm21: Double = sqrt(v21.dot(v21))
        let norm13: Double = sqrt(v13.dot(v13))
        eperp21.row(i) <<== u.cross(v21)
        eperp21.row(i) <<== eperp21.row(i) / sqrt(eperp21.row(i).dot(eperp21.row(i)))
        eperp21.row(i) *= norm21 / dblA
        eperp13.row(i) <<== u.cross(v13)
        eperp13.row(i) <<== eperp13.row(i) / sqrt(eperp13.row(i).dot(eperp13.row(i)))
        eperp13.row(i) *= norm13 / dblA
    }
    
    // create sparse gradient operator matrix
    G.resize(dims * m, nv)
    var Gijv = [Tripletd]()
    Gijv.reserveCapacity(4 * dims * m)
    for f in 0..<F.rows {
        for d in 0..<dims {
            Gijv.append(.init(i: f + d * m, j: F[f, 1], value: eperp13[f, d]))
            Gijv.append(.init(i: f + d * m, j: F[f, 0], value: -eperp13[f, d]))
            Gijv.append(.init(i: f + d * m, j: F[f, 2], value: eperp21[f, d]))
            Gijv.append(.init(i: f + d * m, j: F[f, 0], value: -eperp21[f, d]))
        }
    }
    G.setFromTriplets(Gijv)
}
