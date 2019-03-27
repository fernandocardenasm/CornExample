//
//  ViewController.swift
//  RxSwiftCornExample
//
//  Created by Fernando on 22.02.19.
//  Copyright © 2019 Fernando. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    lazy var textField: UITextField = {
        let tf = UITextField(frame: CGRect.init(x: 0, y: 0, width: 300, height: 100))
        tf.placeholder = "Start typing"
        tf.textAlignment = .center
        return tf
    }()
    
    lazy var activationButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 120, width: 300, height: 100))
        button.backgroundColor = .red
        button.setTitle("Activation Button", for: .normal)
        return button
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel(frame: CGRect.init(x: 0, y: 220, width: 300, height: 100))
        label.text = "Init Label"
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(textField)
        view.addSubview(activationButton)
        view.addSubview(textLabel)
        
        setupBindings()
    }
    
    func setupBindings() {
        textField.rx.text.orEmpty
        .map { !$0.isEmpty }
        .bind(to: activationButton.rx.isEnabled)
        .disposed(by: disposeBag)
        
        activationButton.rx.tap
        .withLatestFrom(textField.rx.text.orEmpty)
        .map { "Hey There: \($0)"}
        .bind(to: textLabel.rx.text)
        .disposed(by: disposeBag)
    }

}

class CornSorter {
    let barnStream: Observable<String>
    
    var currentStatePublisher: PublishSubject<State>? = PublishSubject<State>()
    var currentStateStream: Observable<String>?
    
    var oldValue: Bool?
    var newValue: Bool?
    
    var count: Int = 0
    
    let disposeBag = DisposeBag()
    
    init(tractorStream: Observable<String>) {
        barnStream = tractorStream
        setupBindings()
    }
    
    func sortedCorns() -> Observable<String>{
        return barnStream.filter { $0 == "corn"}
    }
    
    // An error is present when first comes a true and then a false
    func setupBindings() {
        currentStatePublisher?.subscribe({ [weak self] (state) in
            self?.count+=1
        }).disposed(by: disposeBag)
    }
    
    func hasError() -> Bool{
        return count % 2 == 0
    }
}

struct State {
    var isActive: Bool
}
