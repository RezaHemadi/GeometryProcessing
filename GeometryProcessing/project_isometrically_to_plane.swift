//
//  project_isometrically_to_plane.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Project each triangle to the plane
  //
  // [U,UF,I] = project_isometrically_to_plane(V,F)
  //
  // Inputs:
  //   V  #V by 3 list of vertex positions
  //   F  #F by 3 list of mesh indices
  // Outputs:
  //   U  #F*3 by 2 list of triangle positions
  //   UF  #F by 3 list of mesh indices into U
  //   I  #V by #F*3 such that I(i,j) = 1 implies U(j,:) corresponds to V(i,:)
public func project_isometrically_to_plane(V: MatX3<Double>, F: MatX3<Int>, U: inout MatX2<Double>, UF: inout MatX3<Int>, I: inout SparseMatrix<Double>) {
    let l = edge_lengths(vertices: V, faces: F)
    // Number of faces
    let m = F.rows
    
    // First corner at origin
    U = .Zero(3 * m, 2)
    // Second corner along x-axis
    U.block(m, 0, m, 1) <<== l.col(2)
    // Third corner rotated onto plane
    let tmp1 = -l.col(0).array().square()
    let tmp2 = l.col(1).array().square()
    let tmp3 = l.col(2).array().square()
    let tmp4 = 2.0 * l.col(2).array()
    U.block(2 * m, 0, m, 1) <<== (tmp1 + tmp2 + tmp3) / tmp4
    U.block(2 * m, 1, m, 1) <<== (l.col(1).array().square() - U.block(2 * m, 0, m, 1).array().square()).sqrt()
    
    typealias IJV = Triplet<Double>
    
    var ijv = [IJV]()
    ijv.reserveCapacity(3 * m)
    UF.resize(m, 3)
    
    for f in 0..<m {
        for c in 0..<3 {
            UF[f, c] = c * m + f
            ijv.append(.init(i: F[f, c], j: c * m + f, value: 1))
        }
    }
    I.resize(V.rows, m * 3)
    I.setFromTriplets(ijv)
}

public func project_isometrically_to_plane(V: MatX3<Float>, F: MatX3<Int>, U: inout MatX2<Float>, UF: inout MatX3<Int>, I: inout SparseMatrix<Float>) {
    let l = edge_lengths(vertices: V, faces: F)
    // Number of faces
    let m = F.rows
    
    // First corner at origin
    U = .Zero(3 * m, 2)
    // Second corner along x-axis
    U.block(m, 0, m, 1) <<== l.col(2)
    // Third corner rotated onto plane
    let tmp1 = -l.col(0).array().square()
    let tmp2 = l.col(1).array().square()
    let tmp3 = l.col(2).array().square()
    let tmp4 = 2.0 * l.col(2).array()
    U.block(2 * m, 0, m, 1) <<== (tmp1 + tmp2 + tmp3) / tmp4
    U.block(2 * m, 1, m, 1) <<== (l.col(1).array().square() - U.block(2 * m, 0, m, 1).array().square()).sqrt()
    
    typealias IJV = Triplet<Float>
    
    var ijv = [IJV]()
    ijv.reserveCapacity(3 * m)
    UF.resize(m, 3)
    
    for f in 0..<m {
        for c in 0..<3 {
            UF[f, c] = c * m + f
            ijv.append(.init(i: F[f, c], j: c * m + f, value: 1))
        }
    }
    I.resize(V.rows, m * 3)
    I.setFromTriplets(ijv)
}
/*
func project_isometrically_to_plane(V: MatX3<Float80>, F: MatX3<Int>, U: inout MatX2<Float80>, UF: inout MatX3<Int>, I: inout SparseMatrix<Float80>) {
    let l = edge_lengths(vertices: V, faces: F)
    // Number of faces
    let m = F.rows
    
    // First corner at origin
    U = .Zero(3 * m, 2)
    // Second corner along x-axis
    U.block(m, 0, m, 1) <<== l.col(2)
    // Third corner rotated onto plane
    let tmp1 = -l.col(0).array().square()
    let tmp2 = l.col(1).array().square()
    let tmp3 = l.col(2).array().square()
    let tmp4 = 2.0 * l.col(2).array()
    U.block(2 * m, 0, m, 1) <<== (tmp1 + tmp2 + tmp3) / tmp4
    U.block(2 * m, 1, m, 1) <<==  (l.col(1).array().square() - U.block(2 * m, 0, m, 1).array().square()).sqrt()
    
    typealias IJV = Triplet<Float80>
    
    var ijv = [IJV]()
    ijv.reserveCapacity(3 * m)
    UF.resize(m, 3)
    
    for f in 0..<m {
        for c in 0..<3 {
            UF[f, c] = c * m + f
            ijv.append(.init(i: F[f, c], j: c * m + f, value: 1))
        }
    }
    I.resize(V.rows, m * 3)
    I.setFromTriplets(ijv)
}*/
