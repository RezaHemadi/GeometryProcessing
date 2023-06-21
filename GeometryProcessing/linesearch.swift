//
//  linesearch.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

import Foundation

// Implement a bisection linesearch to minimize a mesh-based energy on vertices given at 'x' at a search direction 'd',
  // with initial step size. Stops when a point with lower energy is found, or after maximal iterations have been reached.
  //
  // Inputs:
  //   x                          #X by dim list of variables
  //   d                          #X by dim list of a given search direction
  //   i_step_size              initial step size
  //   energy                   A function to compute the mesh-based energy (return an energy that is bigger than 0)
  //   cur_energy(OPTIONAL)     The energy at the given point. Helps save redundant computations.
  //                            This is optional. If not specified, the function will compute it.
  // Outputs:
  //        x                          #X by dim list of variables at the new location
  // Returns the energy at the new point 'x'
public func line_search<MV: Matrix, MD: Matrix>(x: inout MV, d: MD, step_size: Double, energy: (MV) -> Double, cur_energy: Double = -1) -> Double where MV.Element == Double, MD.Element == Double {
    let old_energy: Double
    if (cur_energy > 0) {
        old_energy = cur_energy
    } else {
        old_energy = energy(x) // no energy was given -> need to compute the current energy
    }
    
    var new_energy = old_energy
    var cur_iter: Int = 0
    let MAX_STEP_SIZE_ITER = 12
    
    var step_size = step_size
    while (new_energy >= old_energy && cur_iter < MAX_STEP_SIZE_ITER) {
        let new_x: MV = x + step_size * d
        
        let cur_e: Double = energy(new_x)
        if (cur_e >= old_energy) {
            step_size /= 2
        } else {
            x = new_x
            new_energy = cur_e
        }
        cur_iter += 1
    }
    return new_energy
}
