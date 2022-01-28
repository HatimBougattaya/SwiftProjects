//
//  ViewController.swift
//  SimpleCalc
//
//  Created by Vincent Saluzzo on 29/03/2019.
//  Copyright © 2019 Vincent Saluzzo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var numberButtons: [UIButton]!
    
    var elements: [String] {
        return textView.text.split(separator: " ").map { "\($0)" }
    }
    
    // Error check computed variables
    var expressionIsCorrect: Bool {
        return elements.last != "+" && elements.last != "-"
    }
    
    var expressionHaveEnoughElement: Bool {
        return elements.count >= 3
    }
    
    var canAddOperator: Bool {
        return elements.last != "+" && elements.last != "-"
    }
    
    var expressionHaveResult: Bool {
        return textView.text.firstIndex(of: "=") != nil
    }
    
    var expressionHasNoZeroDivision: Bool = false
    
    // Parameter to round the result if not a decimal number
    var resultString:String!
    
    var operationsToReduce: [String]!
    
    // View Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    // View actions
    @IBAction func tappedNumberButton(_ sender: UIButton) {
        guard let numberText = sender.title(for: .normal) else {
            return
        }
        
        if expressionHaveResult {
            textView.text = ""
        }
        
        textView.text.append(numberText)
    }
    
    @IBAction func tappedAdditionButton(_ sender: UIButton) {
        if canAddOperator {
            textView.text.append(" + ")
        } else {
            let alertVC = UIAlertController(title: "Zéro!", message: "Un operateur est déja mis !", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func tappedSubstractionButton(_ sender: UIButton) {
        if canAddOperator {
            textView.text.append(" - ")
        } else {
            let alertVC = UIAlertController(title: "Zéro!", message: "Un operateur est déja mis !", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
    }

    
    @IBAction func tappedMultiplicationButton(_ sender: UIButton) {
        if canAddOperator {
            textView.text.append(" * ")
        } else {
            let alertVC = UIAlertController(title: "Zéro!", message: "Un operateur est déja mis !", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func tappedVirguleButton(_ sender: UIButton) {
        guard let numberText = sender.title(for: .normal) else {
            return
        }
        
        if expressionHaveResult {
            textView.text = ""
        }
        
        textView.text.append(numberText)
    }
    
    
    @IBAction func tappedACButton(_ sender: UIButton) {
        textView.text = ""
    }
    
    @IBAction func tappedDivisionButton(_ sender: Any) {
        if canAddOperator {
            textView.text.append(" / ")
        } else {
            let alertVC = UIAlertController(title: "Zéro!", message: "Un operateur est déja mis !", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func tappedEqualButton(_ sender: UIButton) {
        guard expressionIsCorrect else {
            let alertVC = UIAlertController(title: "Zéro!", message: "Entrez une expression correcte !", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return self.present(alertVC, animated: true, completion: nil)
        }
        
        guard expressionHaveEnoughElement else {
            let alertVC = UIAlertController(title: "Zéro!", message: "Démarrez un nouveau calcul !", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return self.present(alertVC, animated: true, completion: nil)
        }
        
        operationsToReduce = elements
        
        if expressionHaveResult {
            textView.text = ""
                } else {
                    zeroDivision()
                    
                    if expressionHasNoZeroDivision == false {
                        
                        // Iterate over operations while an operand still here
                        while operationsToReduce.count > 1 {
                            // Priority to multiplication and division
                            multiplicationDivisionResult(orepand: "/")
                                                
                            // Then, priority to multiplication and division
                            multiplicationDivisionResult(orepand: "*")
                                                
                            // Check if addition and substractions are still in the array
                            additionAndSubstractionResult()
                        }
                        textView.text.append(" = \(operationsToReduce.first!)")
                    }
                    
                }
        
    }
    
    func zeroDivision(){
            for i in 0...(elements.count-1) {
                if i > 1 && i <= elements.count-1 {
                    // Find the divisions and check if followed by zero
                    if elements[i-1] == "/" && elements[i] == "0" {
                        print("Division par zéro impossible")
                        let alertVC = UIAlertController(title: "Zéro!", message: "Division par zéro impossible !", preferredStyle: .alert)
                        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        textView.text = ""
                        expressionHasNoZeroDivision = true
                        return self.present(alertVC, animated: true, completion: nil)
                    } else {
                        expressionHasNoZeroDivision = false
                    }
                }
            }
        }
    
    func roundResult(result: Double) {
            if result == Double(Int(result)) {
                let roundResult = Int(result)
                resultString = String(roundResult)
            } else {
                resultString = String(result)
            }
        
    }
    
    func multiplicationDivisionResult(orepand: String){
            while operationsToReduce.contains(orepand){
                for i in 0...(operationsToReduce.count-1) {
                    // Make sure i is still in the range
                    if i > 1 && i <= operationsToReduce.count-1 {

                        // Find the multiplication and divisions
                        if operationsToReduce[i-1] == orepand {
                            
                            // Assign the numbers and operand of the local operation
                            let left = Double(operationsToReduce[i-2])!
                            let operand = operationsToReduce[i-1]
                            let right = Double(operationsToReduce[i])!
                            
                            //Make the local operation
                            var result: Double
                            switch operand {
                            case "*": result = left * right
                            case "/": result = left / right
                            default: fatalError("Unknown operator !")
                            }
                            
                            // Round the result if no decimal needed
                            roundResult(result: result)
                            operationsToReduce.insert(resultString, at: i+1)
                            
                            operationsToReduce.remove(at: i)
                            operationsToReduce.remove(at: i-1)
                            operationsToReduce.remove(at: i-2)
                        }
                    }
                }
            }
        }
    
    func additionAndSubstractionResult(){
            if operationsToReduce.count >= 3 {
                let left = Double(operationsToReduce[0])!
                let operand = operationsToReduce[1]
                let right = Double(operationsToReduce[2])!
                
                var result: Double
                switch operand {
                case "+": result = left + right
                case "-": result = left - right
                case "=": return
                default: fatalError("Unknown operator !")
                }
                
                operationsToReduce = Array(operationsToReduce.dropFirst(3))
                
                roundResult(result: result)
                operationsToReduce.insert(resultString, at: 0)
            }
        }
}

