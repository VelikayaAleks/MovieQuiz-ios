import Foundation

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func didReceiveNextQuestion(question: QuizQuestion?){
        
    }
    func showLoadingIndicator(){
        
    }
    func hideLoadingIndicator(){
        
    }
    func showNetworkError(message: String){
        
    }
    func didLoadDataFromServer(){
        
    }
    func didFailToLoadData(with error: Error){
        
    }
    func highlightImageBorder(isCorrectAnswer: Bool){
        
    }
    func show(quiz step: QuizStepViewModel){
        
    }
    func show(quiz result: QuizResultsViewModel){
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
         XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
