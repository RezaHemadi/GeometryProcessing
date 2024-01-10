//
//  per_face_normals.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation

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
public func per_face_normals<M1: Matrix, M2: Matrix, V: Vector, M3: Matrix>(V: M1, F: M2, Z: V, N: inout M3) where M1.Element == V.Element, M1.Element == M3.Element, M2.Element == Int, M1.Element: SignedNumeric, M1.Element == Double {
    typealias S = M1.Element
    
    N.resize(F.rows, 3)
    // Loop over faces
    let Frows: Int = F.rows
    for i in 0..<Frows {
        let v1: RVec3 = V.row(F[i, 1]) - V.row(F[i, 0])
        let v2: RVec3 = V.row(F[i, 2]) - V.row(F[i, 0])
        N.row(i) <<== v1.cross(v2)
        let r: S = N.row(i).norm()
        if (r == 0) {
            N.row(i) <<== Z
        } else {
            N.row(i) /= r
        }
    }
}

public func per_face_normals<M1: Matrix, M2: Matrix, V: Vector, M3: Matrix>(V: M1, F: M2, Z: V, N: inout M3) where M1.Element == V.Element, M1.Element == M3.Element, M2.Element == Int, M1.Element: SignedNumeric, M1.Element == Float {
    typealias S = M1.Element
    
    N.resize(F.rows, 3)
    // Loop over faces
    let Frows: Int = F.rows
    for i in 0..<Frows {
        let v1: RVec3 = V.row(F[i, 1]) - V.row(F[i, 0])
        let v2: RVec3 = V.row(F[i, 2]) - V.row(F[i, 0])
        N.row(i) <<== v1.cross(v2)
        let r: S = N.row(i).norm()
        if (r == 0) {
            N.row(i) <<== Z
        } else {
            N.row(i) /= r
        }
    }
}

public func per_face_normals<M1: Matrix, M2: Matrix, M3: Matrix>(V: M1, F: M2, N: inout M3) where M1.Element == M3.Element, M2.Element == Int, M1.Element: SignedNumeric, M1.Element == Double {
    let Z: Vec3<M1.Element> = [0, 0, 0]
    return per_face_normals(V: V, F: F, Z: Z, N: &N)
}

public func per_face_normals<M1: Matrix, M2: Matrix, M3: Matrix>(V: M1, F: M2, N: inout M3) where M1.Element == M3.Element, M2.Element == Int, M1.Element: SignedNumeric, M1.Element == Float {
    let Z: Vec3<M1.Element> = [0, 0, 0]
    return per_face_normals(V: V, F: F, Z: Z, N: &N)
}
