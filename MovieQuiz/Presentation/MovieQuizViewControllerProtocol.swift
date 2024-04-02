import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
    func highlightImageBorder(isCorrect: Bool)
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    //func answerYes()
    //func answerNo()
}
