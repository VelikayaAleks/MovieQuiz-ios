import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yesButton.isEnabled = true
        noButton.isEnabled = false
        
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
        
        questionFactory?.requestNextQuestion()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
            
    }
        
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
            
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
        
    private func showNextQuestionOrResults() {
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
            
        if currentQuestionIndex == questionsAmount - 1 {
            showFinalResults()
        } else {
            currentQuestionIndex += 1
            yesButton.isEnabled = true
            noButton.isEnabled = true
                
            questionFactory?.requestNextQuestion()
        }
    }
        
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
        
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
        
    private func showFinalResults () {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
         
         let alertModel = AlertModel(
             title: "Этот раунд окончен!",
             message: makeResultMessage(),
             buttonText: "Сыграть еще раз",
             completion: { [weak self] in
                 self?.currentQuestionIndex = 0
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
                                Ваш результат: \(correctAnswers)/\(questionsAmount)
                                Количество сыгранных квизов: \(statisticService.gamesCount)
                                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString)
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
