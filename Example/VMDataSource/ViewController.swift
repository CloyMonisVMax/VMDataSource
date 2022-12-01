//
//  ViewController.swift
//  VMDataSource
//
//  Created by CloyMonisVMax on 12/01/2022.
//  Copyright (c) 2022 CloyMonisVMax. All rights reserved.
//

import UIKit
import VMDataSource

class ViewController: UIViewController {

    let dataSource = MarvelDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dataSource.fetch(from: 0) { result in
            switch result {
            case .success(let model):
                print(model)
                let comics = self.dataSource.fetch(superHero: model[0])
                let comics2 = self.dataSource.fetch(superHero: model[1])
                let comics3 = self.dataSource.fetch(superHero: model[2])
                let comics4 = self.dataSource.fetch(superHero: model[3])
                print("hello")
            case .failure(let error):
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

