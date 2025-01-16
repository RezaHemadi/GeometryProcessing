//
//  massmatrix_intrinsic.swift
//  GeometryProcessing
//
//  Created by Reza on 1/16/25.
//

import Foundation
import Matrix

/// Constructs the mass (area) matrix for a given mesh (V,F).
  ///
  /// @param[in] l  #l by simplex_size list of mesh edge lengths
  /// @param[in] F  #F by simplex_size list of mesh elements (triangles or tetrahedra)
  /// @param[in] type  one of the following ints:
  ///     MASSMATRIX_TYPE_BARYCENTRIC  barycentric
  ///     MASSMATRIX_TYPE_VORONOI voronoi-hybrid {default}
  ///     MASSMATRIX_TYPE_FULL full
  /// @param[out] M  #V by #V mass matrix
  ///
  /// \see massmatrix
  ///
public func massmatrix_intrinsic<ML: Matrix, MF: Matrix>(_ l: ML, _ F: MF, type: MassMatrixType) -> SparseMatrix<Double> {
    fatalError("To be implemented")
}

/// \overload
  /// @param[in] n  number of vertices (>= F.maxCoeff()+1)
public func massmatrix_intrinsic(_ l: Matd, _ F: Mati, type: MassMatrixType, n: Int) -> SparseMatrix<Double> {
    var eff_type: MassMatrixType = type
    let m: Int = F.rows
    let simplex_size: Int = F.cols
    if (type == .default) {
        eff_type = (simplex_size == 3) ? .voronoi : .barycentric
    }
    
    assert(F.cols == 3, "only trianlges are suppported.")
    
    var dbla = Vec<Double>()
    doublearea(l, 0.0, &dbla)
    
    var MI = Veci()
    var MJ = Veci()
    var MV = Vec<Double>()
    
    switch eff_type {
    case .barycentric:
        // diagonal entries for each face corner
        MI.resize(m * 3)
        MJ.resize(m * 3)
        MV.resize(m * 3)
        MI.block(0 * m, 0, m, 1) <<== F.col(0)
        MI.block(1 * m, 0, m, 1) <<== F.col(1)
        MI.block(2 * m, 0, m, 1) <<== F.col(2)
        MJ = MI.clone()
        
        let cosines = Mat<Double>(m, 3)
        // col0
        let col0LeftTerm = l.col(2).array().pow(2) + l.col(1).array().pow(2) - l.col(0).array().pow(2)
        let col0RightTerm = l.col(1).array() * l.col(2).array() * 2.0
        let col0 = col0LeftTerm / col0RightTerm
        cosines.col(0) <<== col0
        
        // col1
        let col1LeftTerm = l.col(0).array().pow(2)+l.col(2).array().pow(2)-l.col(1).array().pow(2)
        let col1RightTerm = l.col(2).array()*l.col(0).array()*2.0
        let col1 = col1LeftTerm / col1RightTerm
        cosines.col(1) <<== col1
        
        // col2
        let col2leftTerm = l.col(1).array().pow(2)+l.col(0).array().pow(2)-l.col(2).array().pow(2)
        let col2RightTerm = l.col(0).array()*l.col(1).array()*2.0
        let col2 = col2leftTerm / col2RightTerm
        cosines.col(2) <<== col2
        
        var barycentric = Matd()
        barycentric <<== (cosines.array() * l.array())
        
        for i in 0..<barycentric.rows {
            let rowSum = barycentric.row(i).sum()
            barycentric.row(i) /= rowSum
        }
        
        var partial: Matd = barycentric.clone()
        for j in 0..<3 {
            for i in 0..<partial.rows {
                partial[i, j] *= dbla[i] * 0.5
            }
        }
        var quads = Matd(partial.rows, partial.cols)
        quads.col(0) <<== ((partial.col(1) + partial.col(2)) * 0.5)
        quads.col(1) <<== ((partial.col(2) + partial.col(0)) * 0.5)
        quads.col(2) <<== ((partial.col(0) + partial.col(1)) * 0.5)
        
        // quads
        for i in 0..<quads.rows {
            if cosines[i, 0].isLess(than: .zero) {
                // col0
                quads[i, 0] = 0.25 * dbla[i]
                // col1
                quads[i, 1] = 0.125 * dbla[i]
                // col2
                quads[i, 2] = 0.125 * dbla[i]
            }
            
            if cosines[i, 1].isLess(than: .zero) {
                // col0
                quads[i, 0] = 0.125 * dbla[i]
                // col1
                quads[i, 1] = 0.25 * dbla[i]
                // col2
                quads[i, 2] = 0.125 * dbla[i]
            }
            
            if cosines[i, 2].isLess(than: .zero) {
                // col0
                quads[i, 0] = 0.125 * dbla[i]
                // col1
                quads[i, 1] = 0.125 * dbla[i]
                // col2
                quads[i, 2] = 0.25 * dbla[i]
            }
        }
        
        MV.block(0 * m, 0, m, 1) <<== quads.col(0)
        MV.block(1 * m, 0, m, 1) <<== quads.col(1)
        MV.block(2 * m, 0, m, 1) <<== quads.col(2)
        
    case .full:
        MI.resize(m * 9)
        MJ.resize(m * 9)
        //MV.resize(m * 9)
        // indicies and values of the element mass matrix entries in the order
        // (0,1),(1,0),(1,2),(2,1),(2,0),(0,2),(0,0),(1,1),(2,2)
        MI <<== [F.col(0), F.col(1), F.col(1), F.col(2), F.col(2), F.col(0), F.col(0), F.col(1), F.col(2)]
        MJ <<== [F.col(1), F.col(0), F.col(2), F.col(1), F.col(0), F.col(2), F.col(0), F.col(1), F.col(2)]
        MV = repmat(dbla, 9, 1)
        MV.block(0 * m, 0, 6 * m, 1) /= 24.0
        MV.block(6 * m, 0, 3 * m, 1) /= 12.0
    case .default:
        fatalError("to be implemented")
    default:
        assert(false, "Unknown mass matrix eff type")
    }
    
    let spmat = SpMat(MI, MJ, MV, m: n, n: n)
    return spmat
}
