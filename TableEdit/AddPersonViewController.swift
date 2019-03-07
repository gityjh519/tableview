//
//  AddPersonViewController.swift
//  StudyApp
//
//  Created by yaojinhai on 2018/8/7.
//  Copyright © 2018年 yaojinhai. All rights reserved.
//

import UIKit

class AddPersonViewController: PopBaseViewController {
    
    private var textField: UITextField!
    
    private var backView: UIView!
    
    var finishedDone: ((_ model: PersonModel) -> Void)!
    private var model = PersonModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5);
        
        
        backView = createView(rect: .init(x: 20, y: (height() - 280)/2 - 100, width: width() - 40, height: 280));
        backView.backgroundColor = UIColor.white;
        backView.layer.cornerRadius = 6;
        backView.layer.masksToBounds = true;
        backView.autoresizingMask = [.flexibleLeftMargin,.flexibleRightMargin,.flexibleBottomMargin];
        
        let titleLabel = UILabel(frame: .init(x: 0, y: 20, width: backView.width, height: 20));
        backView.addSubview(titleLabel);
        titleLabel.textColor = UIColor.darkText;
        titleLabel.textAlignment = .center;
        titleLabel.text = "添加人员";
        titleLabel.autoresizingMask = .flexibleWidth;

        textField = createTextField(rect: .init(x: 20, y: titleLabel.maxY + 25, width: backView.width - 40, height: 40));
        backView.addSubview(textField);
//        textField.delegate = self;
        textField.borderStyle = .roundedRect;
        textField.placeholder = "请输入姓名";
        textField.autoresizingMask = .flexibleWidth;

        
     

        
        let configBtn = createButton(rect: .init(x: textField.minX, y: textField.maxY + 36, width: textField.width, height: textField.height), text: "确定");
        configBtn.setTitleColor(UIColor.white, for: .normal);
        configBtn.backgroundColor = UIColor.orange;
        backView.addSubview(configBtn);
        configBtn.addTarget(self, action: #selector(buttonAction(btn:)), for: .touchUpInside);
        configBtn.layer.cornerRadius = 6;
        configBtn.autoresizingMask = .flexibleWidth;

        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        textField.becomeFirstResponder();
    }
    
    

    

    @objc func buttonAction(btn: UIButton) {
        model.name = textField.text ?? "";
        dismiss(animated: true) {
            
        }
        finishedDone?(model);
    }
    


}
