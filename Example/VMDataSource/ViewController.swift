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
        dataSource.clearCache()
        dataSource.fetch(from: 0) { result in
            switch result {
            case .success(let model):
                print(model[2])
                let superHeroDetails = self.dataSource.fetch(superHero: model[2])
                print(superHeroDetails)
                
                let superHeroDetails1 = self.dataSource.fetch(superHero: model[8])
                print(superHeroDetails1)
                
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

