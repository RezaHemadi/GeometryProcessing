//
//  PerVertexSmoothing.swift
//  GeometryProcessing
//
//  Created by Reza on 6/21/23.
//

import Foundation
import Matrix

// Smooth vertex attributes using uniform Laplacian
// Inputs:
//   Ain  #V by #A eigen Matrix of mesh vertex attributes (each vertex has #A attributes)
//   F    #F by 3 eigne Matrix of face (triangle) indices
// Output:
//   Aout #V by #A eigen Matrix of mesh vertex attributes
public func perVertexAttributeSmoothing(_ Ain: Mat<Float>,
                                 _ F: Mat<Int>,
                                 _ n: Int = 1) -> Mat<Float> {
    var denominator: [Float] = .init(repeating: .zero, count: Ain.rows)
    var output: Mat<Float> = .Zero(Ain.rows, Ain.cols)
    var input: Mat<Float> = .init(Ain, Ain.rows, Ain.cols)
    
    for i in 0..<n {
        for i in 0..<F.rows {
            for j in 0..<3 {
                let j1: Int = (j + 1) % 3
                let j2: Int = (j + 2) % 3
                output.row(F[i, j]) += (input.row(F[i, j1]) + input.row(F[i, j2]))
                denominator[F[i, j]] += 2
            }
        }
        
        for i in 0..<Ain.rows {
            output.row(i) /= denominator[i]
        }
        
        guard i != (n - 1) else { continue }
        denominator = .init(repeating: .zero, count: Ain.rows)
        input = .init(output, output.rows, output.cols)
        output = .Zero(Ain.rows, Ain.cols)
    }
    
    
    return output
}

