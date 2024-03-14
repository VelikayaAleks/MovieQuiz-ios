//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Александра Великая on 11.03.2024.
//

import Foundation
import UIKit

protocol AlertPresenterProtocol {
    
    func show(alertModel: AlertModel)
}

class AlertPresenter: AlertPresenterProtocol {
    private weak var delegate: UIViewController?
    
    init(delegate: UIViewController?) {
           self.delegate = delegate
    }
    
    func show(alertModel: AlertModel) {
        
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            
            alertModel.completion()
        }
        
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        } */
        
        alert.addAction(action)
        
        delegate?.present(alert, animated: true)
    }
}
