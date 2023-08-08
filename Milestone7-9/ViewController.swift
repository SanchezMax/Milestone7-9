//
//  ViewController.swift
//  Milestone7-9
//
//  Created by Aleksey Novikov on 07.08.2023.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var attemptsLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var usedCharsLabel: UILabel!
    
    @IBOutlet var charTextField: UITextField!
    
    @IBOutlet var tryButton: UIButton!
    
    var allWords = [String]()
    var wrongAnswers = 7 {
        didSet {
            attemptsLabel.text = "Attempts left: \(wrongAnswers)"
        }
    }
    var word = "silkworm"
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var usedLetters = [Character]() {
        didSet {
            var answer = ""
            for letter in word {
                if usedLetters.contains(where: { $0 == letter }) {
                    answer.append(String(letter).capitalized + " ")
                } else {
                    answer.append("_ ")
                }
            }
            answer.removeLast()
            wordLabel.text = answer
            
            if !usedLetters.isEmpty {
                usedLetters.sort()
                var text = ""
                for char in usedLetters {
                    text.append(String(char).capitalized + ", ")
                }
                text.removeLast(2)
                usedCharsLabel.text = text
            } else {
                usedCharsLabel.text = "None"
            }
            
            if !answer.contains(where: { $0 == "_"}) {
                showAlert(title: "Congratulations!", message: "You have successfully guessed the word") { [self] _ in
                    score += 1
                    resetGame()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    
        charTextField.delegate = self
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.fetchWords()
            
            DispatchQueue.main.async {
                self?.chooseWord()
            }
        }
    }
    
    func fetchWords() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
    }
    
    func chooseWord() {
        word = allWords.randomElement() ?? "silkworm"
        print("Word: \(word)")
    }
    
    func showAlert(title: String?, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: handler)
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    func attemptsDecrease() {
        wrongAnswers -= 1
        
        if wrongAnswers == 0 {
            showAlert(title: "You failed", message: "Try again?") { _ in
                self.resetGame()
            }
        }
    }
    
    func resetGame() {
        wrongAnswers = 7
        chooseWord()
        usedLetters.removeAll()
    }
    
    @IBAction func tryTapped(_ sender: Any) {
        guard let text = charTextField.text, !text.isEmpty else {
            showAlert(title: "Error", message: "Textfield is empty")
            return
        }
        
        let char = Character(text.lowercased())
        charTextField.text = ""
        
        guard !usedLetters.contains(where: { $0 == char }) else {
            showAlert(title: "Error", message: "You have used this letter")
            return
        }
        
        if !word.contains(where: { $0 == char }) {
            attemptsDecrease()
        }
        usedLetters.append(char)
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return self.textLimit(existingText: textField.text, newText: string, limit: 1)
    }
    
    private func textLimit(existingText: String?, newText: String, limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
}
