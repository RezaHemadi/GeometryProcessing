//
//  PerFaceNormals.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Compute face normals via vertex position list, face list
// Inputs:
//   V  #V by 3 eigen Matrix of mesh vertex 3D positions
//   F  #F by 3 eigen Matrix of face (triangle) indices
//   Z  3 vector normal given to faces with degenerate normal.
// Output:
//   N  #F by 3 eigen Matrix of mesh face (triangle) 3D normals
//
// Example:
//   // Give degenerate faces (1/3,1/3,1/3)^0.5
//   per_face_normals(V,F,Vector3d(1,1,1).normalized(),N);
public func perFaceNormals<MV: Matrix, MF: Matrix, ZV: Vector, MN: Matrix> (_ V: MV,
                                                                    _ F: MF,
                                                                    _ Z: ZV) -> MN
where MV.Element == Float, MF.Element == Int, ZV.Element == MV.Element, MN.Element == MV.Element {
    typealias VScalar = MV.Element
    // Initialize output
    let N: MN = .init(F.rows, 3)
    
    // loop over faces
    let Frows = F.rows
    
    for i in 0..<Frows {
        let v1: RVec3<VScalar> = V.row(F[i, 1]) - V.row(F[i, 0])
        let v2: RVec3<VScalar> = V.row(F[i, 2]) - V.row(F[i, 0])
        
        N.row(i) <<== v1.cross(v2)
        
        
        let r: VScalar = N.row(i).norm()
        
        if (r == 0) {
            N.row(i) <<== Z
        } else {
            N.row(i) /= r
        }
    }
    
    return N
}

public func perFaceNormals<MV: Matrix, MF: Matrix, MN: Matrix> (_ V: MV,
                                                         _ F: MF) -> MN
where MV.Element == Float, MF.Element == Int, MN.Element == MV.Element {
    let Z: Vec3<MV.Element> = .init(0, 0, 0)
    return perFaceNormals(V, F, Z)
}
