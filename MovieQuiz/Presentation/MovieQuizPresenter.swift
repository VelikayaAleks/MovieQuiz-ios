import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var currentQuestionIndex: Int = 0
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    //private weak var viewController: MovieQuizViewControllerProtocol?
    private weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticService!
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
        
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
        
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
     }
     
    
    func answerYes() {
        didAnswer(isYes: true)
        viewController?.yesButton.isEnabled = false
    }
    
    func answerNo() {
        didAnswer(isYes: false)
        viewController?.noButton.isEnabled = false
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
            
        let givenAnswer = isYes
            
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
            
        viewController?.imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func proceedToNextQuestionOrResults() {
        viewController?.imageView.layer.borderColor = UIColor.ypBlack.cgColor
        if self.isLastQuestion()  {
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: makeResultsMessage(),
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    self?.resetQuestionIndex()
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                }
            )
                 
            viewController?.alertPresenter?.show(alertModel: alertModel)
        } else {
            self.switchToNextQuestion()
            viewController?.yesButton.isEnabled = true
            viewController?.noButton.isEnabled = true
            questionFactory?.requestNextQuestion()
        }
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
                    
        let resultMessage = """
                                    Ваш результат: \(correctAnswers)/\(self.questionsAmount)
                                    Количество сыгранных квизов: \(statisticService.gamesCount)
                                    Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                                """
        return resultMessage
    }
     
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
}
