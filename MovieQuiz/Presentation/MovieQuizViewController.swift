import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
        
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
        
    var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
            
        yesButton.isEnabled = false
        noButton.isEnabled = false
        alertPresenter = AlertPresenter(delegate: self)
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
    }
        
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
        
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
        
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
        
    func showNetworkError(message: String) {
        hideLoadingIndicator()
            
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
                    
            self.presenter.resetQuestionIndex()
            self.presenter.correctAnswers = 0
            self.presenter.restartGame()
        }
        let alert = AlertPresenter(delegate: self)
        alert.show(alertModel: model)
    }
        
    func didLoadDataFromServer() {
            
        activityIndicator.isHidden = true
        self.presenter.restartGame()
    }

    func didFailToLoadData(with error: Error) {
            
        showNetworkError(message: error.localizedDescription)
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
        noButton.isEnabled = true
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
    }
    
    func show(quiz result: QuizResultsViewModel) {
            let message = presenter.makeResultsMessage()

            let alert = UIAlertController(
                title: result.title,
                message: message,
                preferredStyle: .alert)

                let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                    guard let self = self else { return }

                    self.presenter.restartGame()
                }

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func answerYes(_ sender: UIButton) {
        presenter.answerYes()
        yesButton.isEnabled = false
    }
            
    @IBAction private func answerNo(_ sender: UIButton) {
        presenter.answerNo()
        noButton.isEnabled = false
    }
}
