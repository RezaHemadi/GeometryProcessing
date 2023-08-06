//
//  unique_simplices.swift
//  GeometryProcessing
//
//  Created by Reza on 8/4/23.
//

import Foundation
import Matrix

// Find *combinatorially* unique simplices in F.  **Order independent**
//
// Inputs:
//   F  #F by simplex-size list of simplices
// Outputs:
//   FF  #FF by simplex-size list of unique simplices in F
//   IA  #FF index vector so that FF == sort(F(IA,:),2);
//   IC  #F index vector so that sort(F,2) == FF(IC,:);
func unique_simplices<MFF: Matrix>
(_ F: Mati, _ FF: inout MFF, _ IA: inout Vec<Int>, _ IC: inout Vec<Int>)
where MFF.Element == Int
{
    var sortF = Mati()
    var unusedI = Mati()
    geom_sort(F, 2, true, &sortF, &unusedI)
    // find unique faces
    var C = Mati()
    unique_rows(sortF, &C, &IA, &IC)
    FF.resize(IA.count, F.cols)
    let mff: Int = FF.rows
    for i in 0..<mff {
        FF.row(i) <<== F.row(IA[i])
    }
}

func unique_simplices(_ F: Mati, _ FF: inout Mati) {
    var IA = Veci()
    var IC = Veci()
    
    return unique_simplices(F, &FF, &IA, &IC)
}
