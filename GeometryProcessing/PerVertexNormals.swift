//
//  PerVertexNormals.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

public enum VertexNormalWeighingType {
    /// Incident face normals have uniform influence on vertex normal
    case uniform
    /// Incident face normals are averaged weighted by area
    case area
    /// Incident face normals are averaged weighted by incident angle of vertex
    case angle
}

// Compute vertex normals via vertex position list, face list
// Inputs:
//   V  #V by 3 eigen Matrix of mesh vertex 3D positions
//   F  #F by 3 eigne Matrix of face (triangle) indices
//   weighting  Weighting type
// Output:
//   N  #V by 3 eigen Matrix of mesh vertex 3D normals
public func perVertexNormals<MV: Matrix, MF: Matrix>(_ V: MV,
                                                         _ F: MF,
                                                         _ weighing: VertexNormalWeighingType) -> Mat<MV.Element> where
MV.Element == Float, MF.Element == Int {
    let PFN: Mat<Float> = perFaceNormals(V, F)
    return perVertexNormals(V, F, weighing, PFN)
}

// Inputs:
//   FN  #F by 3 matrix of face (triangle) normals
public func perVertexNormals<MV: Matrix, MF: Matrix, MFN: Matrix>(_ V: MV,
                                                                      _ F: MF,
                                                                      _ weighing: VertexNormalWeighingType,
                                                                      _ FN: MFN) -> Mat<MV.Element> where
MV.Element == Float, MF.Element == Int, MFN.Element == MV.Element {
    typealias Scalar = MV.Element
    
    var output: Mat<Scalar> = .init(V.rows, 3)
    var W: Mat<Scalar> = .init(F.rows, 3)
    
    switch weighing {
    case .uniform:
        W.setConstant(1.0)
    case .area:
        var A: Vec<Scalar> = .init()
        doubleArea(V: V, F: F, dblA: &A)
        W.col(0) <<== A
        W.col(1) <<== A
        W.col(2) <<== A
    case .angle:
        fatalError("to be implemented")
    }
    
    // loop over faces
    for i in 0..<F.rows {
        // throw normal at each corner
        for j in 0..<3 {
            let rowVec: RVec<Scalar> = FN.row(i)
            let value = W[i, j] * rowVec
            output.row(F[i, j]) += value
        }
    }
    
    for i in 0..<output.rows {
        let rowMagnitude = output.row(i).norm()
        for j in 0..<output.cols {
            output[i, j] /= rowMagnitude
        }
    }
    
    return output
}

