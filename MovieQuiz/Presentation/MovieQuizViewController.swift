import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    private let presenter = MovieQuizPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        
        yesButton.isEnabled = true
        noButton.isEnabled = false
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
                
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
                
            self.questionFactory?.requestNextQuestion()
        }
        let alert = AlertPresenter(delegate: self)
        alert.show(alertModel: model)
    }
    
    func didLoadDataFromServer() {
        
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        
        showNetworkError(message: error.localizedDescription)
    }
        
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
        
    private func showNextQuestionOrResults() {
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
            
        if presenter.isLastQuestion() {
            showFinalResults()
        } else {
            presenter.switchToNextQuestion()
            yesButton.isEnabled = true
            noButton.isEnabled = true
                
            questionFactory?.requestNextQuestion()
        }
    }
        
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
        
    private func showFinalResults () {
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
         
         let alertModel = AlertModel(
             title: "Этот раунд окончен!",
             message: makeResultMessage(),
             buttonText: "Сыграть еще раз",
             completion: { [weak self] in
                 self?.presenter.resetQuestionIndex()
                 self?.correctAnswers = 0
                 self?.questionFactory?.requestNextQuestion()
             }
         )
         
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func makeResultMessage() -> String {
        
        guard let statisticService = statisticService else {
            
            return ""
        }
                
        let resultMessage = """
                                Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                                Количество сыгранных квизов: \(statisticService.gamesCount)
                                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                            """
        return resultMessage
    }
        
    @IBAction private func answerYes(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        yesButton.isEnabled = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
        
    @IBAction private func answerNo(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        noButton.isEnabled = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
