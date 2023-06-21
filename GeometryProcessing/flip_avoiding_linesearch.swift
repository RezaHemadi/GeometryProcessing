//
//  flip_avoiding_linesearch.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// MARK: - Helpers
    //---------------------------------------------------------------------------
    // x - array of size 3
    // In case 3 real roots: => x[0], x[1], x[2], return 3
    //         2 real roots: x[0], x[1],          return 2
    //         1 real root : x[0], x[1] ± i*x[2], return 1
    // http://math.ivanovo.ac.ru/dalgebra/Khashin/poly/index.html
public func SolveP3(x: inout [Double], a: Double, b: Double, c: Double) -> Int {
    // solve cubic equation x^3 + a*x^2 + b*x + c
    assert(x.count == 3)
    
    let a2 = a * a
    var q = (a2 - 3 * b) / 9
    let r = (a * (2 * a2 - 9*b) + 27 * c) / 54
    let r2 = r * r
    let q3 = q * q * q
    var A: Double
    let B: Double
    
    if (r2 < q3) {
        var t: Double = r / sqrt(q3)
        if ( t.isLess(than: -1.0)) { t = -1.0 }
        if ( !t.isLessThanOrEqualTo(1) ) { t = 1.0 }
        t = acos(t)
        var a = (a / 3)
        q = -2 * sqrt(q)
        x[0] = q * cos(t / 3) - a
        x[1] = q * cos((t + (2 * .pi)) / 3.0) - a
        x[2] = q * cos((t - (2 * .pi)) / 3.0) - a
        return 3
    } else {
        A = -pow(fabs(r) + sqrt(r2 - q3), 1.0 / 3.0)
        if ( r.isLess(than: 0.0)) { A = -A }
        B = A==0 ? 0 : q / A
        
        var a = (a / 3)
        x[0] = (A + B) - a
        x[1] = -0.5 * (A + B) - a
        x[2] = 0.5 * sqrt(3.0) * (A - B)
        if (fabs(x[2]).isLess(than: 1.0e-14)) {
            x[2] = x[1]
            return 2
        }
        return 1
    }
}

public func get_smallest_pos_quad_zero(a: Double, b: Double, c: Double) -> Double {
    var t1: Double
    var t2: Double
    if (abs(a) > 1.0e-10) {
        let delta_in: Double = pow(b, 2) - 4 * a * c
        if (delta_in <= 0.0) {
            return .infinity
        }
        
        let delta: Double = sqrt(delta_in) // delta >= 0
        if (b >= 0.0) { // avoid subtracting two similar numbers
            let bd: Double = -b - delta
            t1 = 2 * c / bd
            t2 = bd / (2 * a)
        } else {
            let bd: Double = -b + delta
            t1 = bd / (2 * a)
            t2 = (2 * c) / bd
        }
        
        assert(t1.isFinite)
        assert(t2.isFinite)
        
        if (a < 0.0) { swap(&t1, &t2) } // make t1 > t2
        // return the smaller positive root if it exists, otherwise return infinity
        if (t1 > 0.0) {
            return t2 > 0 ? t2 : t1
        } else {
            return .infinity
        }
    } else {
        if (b == 0) { return .infinity } // just to avoid divide-by-zero
        t1 = -c / b
        return t1 > 0 ? t1 : .infinity
    }
}

public func get_min_pos_root_2D<MV: Matrix, MF: Matrix, MD: Matrix>(uv: MV, F: MF, d: inout MD, f: Int) -> Double where MV.Element == Double, MD.Element == Double, MF.Element == Int {
    let v1: Int = F[f, 0]
    let v2: Int = F[f, 1]
    let v3: Int = F[f, 2]
    // get quadratic coefficients (ax^2 + b^x + c)
    let U11: Double = uv[v1, 0]
    let U12: Double = uv[v1, 1]
    let U21: Double = uv[v2, 0]
    let U22: Double = uv[v2, 1]
    let U31: Double = uv[v3, 0]
    let U32: Double = uv[v3, 1]
    
    let V11: Double = d[v1, 0]
    let V12: Double = d[v1, 1]
    let V21: Double = d[v2, 0]
    let V22: Double = d[v2, 1]
    let V31: Double = d[v3, 0]
    let V32: Double = d[v3, 1]
    
    let a: Double = V11 * V22 - V12 * V21 - V11 * V32 + V12 * V31 + V21 * V32 - V22 * V31
    let b: Double = U11 * V22 - U12 * V21 - U21 * V12 + U22 * V11 - U11 * V32 + U12 * V31 + U31 * V12 - U32 * V11 + U21 * V32 - U22 * V31 - U31 * V22 + U32 * V21
    let c: Double = U11 * U22 - U12 * U21 - U11 * U32 + U12 * U31 + U21 * U32 - U22 * U31
    
    return get_smallest_pos_quad_zero(a: a, b: b, c: c)
}

public func get_min_pos_root_3D<MV: Matrix, MF: Matrix, MD: Matrix>(uv: MV, F: MF, direc: inout MD, f: Int) -> Double where MV.Element == Double, MD.Element == Double, MF.Element == Int {
    let v1: Int = F[f, 0]
    let v2: Int = F[f, 1]
    let v3: Int = F[f, 2]
    let v4: Int = F[f, 3]
    
    let a_x: Double = uv[v1, 0]
    let a_y: Double = uv[v1, 1]
    let a_z: Double = uv[v1, 2]
    let b_x: Double = uv[v2, 0]
    let b_y: Double = uv[v2, 1]
    let b_z: Double = uv[v2, 2]
    let c_x: Double = uv[v3, 0]
    let c_y: Double = uv[v3, 1]
    let c_z: Double = uv[v3, 2]
    let d_x: Double = uv[v4, 0]
    let d_y: Double = uv[v4, 1]
    let d_z: Double = uv[v4, 2]
    
    let a_dx: Double = direc[v1, 0]
    let a_dy: Double = direc[v1, 1]
    let a_dz: Double = direc[v1, 2]
    let b_dx: Double = direc[v2, 0]
    let b_dy: Double = direc[v2, 1]
    let b_dz: Double = direc[v2, 2]
    let c_dx: Double = direc[v3, 0]
    let c_dy: Double = direc[v3, 1]
    let c_dz: Double = direc[v3, 2]
    let d_dx: Double = direc[v4, 0]
    let d_dy: Double = direc[v4, 1]
    let d_dz: Double = direc[v4, 2]
    
    // Find solution for: a*t^3 + b*t^2 + c*d + d = 0
    let a: Double = a_dx*b_dy*c_dz - a_dx*b_dz*c_dy - a_dy*b_dx*c_dz + a_dy*b_dz*c_dx + a_dz*b_dx*c_dy - a_dz*b_dy*c_dx - a_dx*b_dy*d_dz + a_dx*b_dz*d_dy + a_dy*b_dx*d_dz - a_dy*b_dz*d_dx - a_dz*b_dx*d_dy + a_dz*b_dy*d_dx + a_dx*c_dy*d_dz - a_dx*c_dz*d_dy - a_dy*c_dx*d_dz + a_dy*c_dz*d_dx + a_dz*c_dx*d_dy - a_dz*c_dy*d_dx - b_dx*c_dy*d_dz + b_dx*c_dz*d_dy + b_dy*c_dx*d_dz - b_dy*c_dz*d_dx - b_dz*c_dx*d_dy + b_dz*c_dy*d_dx
    var b: Double = a_dy*b_dz*c_x - a_dy*b_x*c_dz - a_dz*b_dy*c_x + a_dz*b_x*c_dy + a_x*b_dy*c_dz - a_x*b_dz*c_dy - a_dx*b_dz*c_y + a_dx*b_y*c_dz + a_dz*b_dx*c_y - a_dz*b_y*c_dx - a_y*b_dx*c_dz + a_y*b_dz*c_dx + a_dx*b_dy*c_z - a_dx*b_z*c_dy - a_dy*b_dx*c_z + a_dy*b_z*c_dx + a_z*b_dx*c_dy - a_z*b_dy*c_dx - a_dy*b_dz*d_x + a_dy*b_x*d_dz + a_dz*b_dy*d_x - a_dz*b_x*d_dy - a_x*b_dy*d_dz + a_x*b_dz*d_dy + a_dx*b_dz*d_y - a_dx*b_y*d_dz - a_dz*b_dx*d_y + a_dz*b_y*d_dx + a_y*b_dx*d_dz - a_y*b_dz*d_dx - a_dx*b_dy*d_z + a_dx*b_z*d_dy + a_dy*b_dx*d_z - a_dy*b_z*d_dx - a_z*b_dx*d_dy + a_z*b_dy*d_dx + a_dy*c_dz*d_x - a_dy*c_x*d_dz - a_dz*c_dy*d_x + a_dz*c_x*d_dy + a_x*c_dy*d_dz - a_x*c_dz*d_dy - a_dx*c_dz*d_y + a_dx*c_y*d_dz + a_dz*c_dx*d_y - a_dz*c_y*d_dx - a_y*c_dx*d_dz + a_y*c_dz*d_dx + a_dx*c_dy*d_z - a_dx*c_z*d_dy - a_dy*c_dx*d_z + a_dy*c_z*d_dx + a_z*c_dx*d_dy - a_z*c_dy*d_dx - b_dy*c_dz*d_x + b_dy*c_x*d_dz + b_dz*c_dy*d_x - b_dz*c_x*d_dy - b_x*c_dy*d_dz + b_x*c_dz*d_dy + b_dx*c_dz*d_y - b_dx*c_y*d_dz - b_dz*c_dx*d_y + b_dz*c_y*d_dx + b_y*c_dx*d_dz - b_y*c_dz*d_dx - b_dx*c_dy*d_z + b_dx*c_z*d_dy + b_dy*c_dx*d_z - b_dy*c_z*d_dx - b_z*c_dx*d_dy + b_z*c_dy*d_dx
    var c: Double = a_dz*b_x*c_y - a_dz*b_y*c_x - a_x*b_dz*c_y + a_x*b_y*c_dz + a_y*b_dz*c_x - a_y*b_x*c_dz - a_dy*b_x*c_z + a_dy*b_z*c_x + a_x*b_dy*c_z - a_x*b_z*c_dy - a_z*b_dy*c_x + a_z*b_x*c_dy + a_dx*b_y*c_z - a_dx*b_z*c_y - a_y*b_dx*c_z + a_y*b_z*c_dx + a_z*b_dx*c_y - a_z*b_y*c_dx - a_dz*b_x*d_y + a_dz*b_y*d_x + a_x*b_dz*d_y - a_x*b_y*d_dz - a_y*b_dz*d_x + a_y*b_x*d_dz + a_dy*b_x*d_z - a_dy*b_z*d_x - a_x*b_dy*d_z + a_x*b_z*d_dy + a_z*b_dy*d_x - a_z*b_x*d_dy - a_dx*b_y*d_z + a_dx*b_z*d_y + a_y*b_dx*d_z - a_y*b_z*d_dx - a_z*b_dx*d_y + a_z*b_y*d_dx + a_dz*c_x*d_y - a_dz*c_y*d_x - a_x*c_dz*d_y + a_x*c_y*d_dz + a_y*c_dz*d_x - a_y*c_x*d_dz - a_dy*c_x*d_z + a_dy*c_z*d_x + a_x*c_dy*d_z - a_x*c_z*d_dy - a_z*c_dy*d_x + a_z*c_x*d_dy + a_dx*c_y*d_z - a_dx*c_z*d_y - a_y*c_dx*d_z + a_y*c_z*d_dx + a_z*c_dx*d_y - a_z*c_y*d_dx - b_dz*c_x*d_y + b_dz*c_y*d_x + b_x*c_dz*d_y - b_x*c_y*d_dz - b_y*c_dz*d_x + b_y*c_x*d_dz + b_dy*c_x*d_z - b_dy*c_z*d_x - b_x*c_dy*d_z + b_x*c_z*d_dy + b_z*c_dy*d_x - b_z*c_x*d_dy - b_dx*c_y*d_z + b_dx*c_z*d_y + b_y*c_dx*d_z - b_y*c_z*d_dx - b_z*c_dx*d_y + b_z*c_y*d_dx
    var d: Double = a_x*b_y*c_z - a_x*b_z*c_y - a_y*b_x*c_z + a_y*b_z*c_x + a_z*b_x*c_y - a_z*b_y*c_x - a_x*b_y*d_z + a_x*b_z*d_y + a_y*b_x*d_z - a_y*b_z*d_x - a_z*b_x*d_y + a_z*b_y*d_x + a_x*c_y*d_z - a_x*c_z*d_y - a_y*c_x*d_z + a_y*c_z*d_x + a_z*c_x*d_y - a_z*c_y*d_x - b_x*c_y*d_z + b_x*c_z*d_y + b_y*c_x*d_z - b_y*c_z*d_x - b_z*c_x*d_y + b_z*c_y*d_x
    
    if (abs(a).isLessThanOrEqualTo(1.0e-10)) {
        return get_smallest_pos_quad_zero(a: b, b: c, c: d)
    }
    
    // normalize it all
    b /= a
    c /= a
    d /= a
    var res: [Double] = .init(repeating: 0.0, count: 3)
    let real_roots_num: Int = SolveP3(x: &res, a: b, b: c, c: d)
    switch (real_roots_num) {
    case 1:
        return (res[0] >= 0) ? res[0] : .infinity
    case 2:
        let max_root: Double = max(res[0], res[1])
        let min_root: Double = min(res[0], res[1])
        if (min_root > 0) { return min_root }
        if (max_root > 0) { return max_root }
        return .infinity
    case 3:
        res.sort()
        if (res[0] > 0) { return res[0] }
        if (res[1] > 0) { return res[1] }
        if (res[2] > 0) { return res[2] }
        return .infinity
    default:
        fatalError("unexpected value")
    }
}

public func compute_max_step_from_singularities<MV: Matrix, MF: Matrix>(uv: MV, F: MF, d: inout MV) -> Double where MV.Element == Double, MF.Element == Int {
    var max_step: Double = .infinity
    
    // The if statement is outside the for loops to avoid branching/ease parallelizing
    if (uv.cols == 2) {
        for f in 0..<F.rows {
            let min_positive_root: Double = get_min_pos_root_2D(uv: uv, F: F, d: &d, f: f)
            max_step = min(max_step, min_positive_root)
        }
    } else {
        // volumetric deformation
        for f in 0..<F.rows {
            let min_positive_root: Double = get_min_pos_root_3D(uv: uv, F: F, direc: &d, f: f)
            max_step = min(max_step, min_positive_root)
        }
    }
    return max_step
}



// A bisection line search for a mesh based energy that avoids triangle flips as suggested in
  //         "Bijective Parameterization with Free Boundaries" (Smith J. and Schaefer S., 2015).
  //
  // The user specifies an initial vertices position (that has no flips) and target one (that my have flipped triangles).
  // This method first computes the largest step in direction of the destination vertices that does not incur flips,
  // and then minimizes a given energy using this maximal step and a bisection linesearch (see igl::line_search).
  //
  // Supports both triangle and tet meshes.
  //
  // Inputs:
  //   F  #F by 3/4                 list of mesh faces or tets
  //   cur_v                          #V by dim list of variables
  //   dst_v                          #V by dim list of target vertices. This mesh may have flipped triangles
  //   energy                       A function to compute the mesh-based energy (return an energy that is bigger than 0)
  //   cur_energy(OPTIONAL)         The energy at the given point. Helps save redundant computations.
  //                                This is optional. If not specified, the function will compute it.
  // Outputs:
  //        cur_v                          #V by dim list of variables at the new location
  // Returns the energy at the new point
public func flip_avoiding_line_search<MF: Matrix, MV: Matrix>(F: MF, cur_v: inout MV, dst_v: MV, energy: (MV) -> Double, cur_energy: Double = -1.0) -> Double where MF.Element == Int, MV.Element == Double {
    var d: MV = dst_v - cur_v
    
    let min_step_to_singularity: Double = compute_max_step_from_singularities(uv: cur_v, F: F, d: &d)
    let max_step_size: Double = min(1.0, min_step_to_singularity * 0.8)
    
    return line_search(x: &cur_v, d: d, step_size: max_step_size, energy: energy, cur_energy: cur_energy)
}
