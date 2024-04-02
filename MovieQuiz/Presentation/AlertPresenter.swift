import Foundation
import UIKit

protocol AlertPresenterProtocol {
    
    func show(alertModel: AlertModel)
}

final class AlertPresenter: AlertPresenterProtocol {
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
        
        alert.addAction(action)
        
        delegate?.present(alert, animated: true)
    }
}
