//
//  Flow.swift
//  QuizEngine
//
//  Created by Rafael Freitas on 14/02/21.
//

import Foundation

protocol Router {
    associatedtype Question: Hashable
    associatedtype Answer
    typealias AnswerCallBack = (Answer) -> Void
    func route(to question: Question, answerCallback: @escaping AnswerCallBack)
    func routeTo(result: [Question: Answer])
}

class Flow<Question, Answer, R: Router> where R.Question == Question, R.Answer == Answer {
    var router: R
    var questions: [Question]
    var result: [Question: Answer] = [:]
    
    init(questions: [Question], router: R) {
        self.router = router
        self.questions = questions
    }
    
    func start() {
        if let question = questions.first {
            router.route(to: question, answerCallback: nextCallback(question: question))
        } else {
            router.routeTo(result: result)
        }
    }
    
    private func nextCallback(question: Question) -> R.AnswerCallBack {
        return { [weak self] in self?.routeNext(question, $0) }
    }
    
    private func routeNext(_ question: Question, _ answer: Answer) {
        if let currentQuestionIndex = questions.firstIndex(of: question) {
            result[question] = answer
            
            let nextQuestionIndex = currentQuestionIndex + 1
            if  nextQuestionIndex < questions.count {
                let nextQuestion = questions[nextQuestionIndex]
                router.route(to: nextQuestion, answerCallback: nextCallback(question: nextQuestion))
            } else {
                router.routeTo(result: result)
            }
        }
    }
}
