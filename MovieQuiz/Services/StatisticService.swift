//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Александра Великая on 13.03.2024.
//

import Foundation

protocol StatisticService {
    
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
}
