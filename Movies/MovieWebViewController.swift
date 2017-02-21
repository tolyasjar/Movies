//
//  ViewController.swift
//  Movies
//
//  Created by Toleen Jaradat on 2/15/17.
//  Copyright © 2017 Toleen Jaradat. All rights reserved.
//

import UIKit

class MovieWebViewController: UIViewController {
    var movie = Movie()

    @IBOutlet weak var movieWeb: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = movie.title
        
        let  url = URL(string: "http://www.imdb.com/title/\(movie.imdbID!)/")
        let request = URLRequest (url: url!)
        movieWeb.loadRequest(request)

        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

