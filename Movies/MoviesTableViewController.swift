//
//  MoviesTableViewController.swift
//  Movies
//
//  Created by Toleen Jaradat on 2/15/17.
//  Copyright © 2017 Toleen Jaradat. All rights reserved.
//

import UIKit

class MoviesTableViewController: UITableViewController {
    
    // related to API
    var i = 1
    var numberOfPages = 0
    
    var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadRestaurants()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)

    
        //Update UI
        
        let queue = DispatchQueue.global()
        var image = UIImage()
        
        queue.async {
            
            if (self.movies[indexPath.row].poster == "N/A") {
                
                image = UIImage(named: "movie.jpg")!
                
            } else {
            
                guard let imageURL = URL(string: self.movies[indexPath.row].poster!) else {
                    fatalError("Invalid URL")
            }
            
                let imageData = try? Data(contentsOf: imageURL)
                
                if (imageData != nil) {
                    
                    image = UIImage(data: imageData!)!
                    
                } else {
                    
                    image = UIImage(named: "movie.jpg")!
                    
                }
                
               // print(imageURL)
                
                DispatchQueue.main.async(execute: {
                    
                    cell.textLabel?.text = self.movies[indexPath.row].title
                    cell.imageView?.image = image
                    self.resizeCellImageView(cell)
                    
                })
            
            let x = self.movies[indexPath.row].imdbID!
            self.downloadMovieRating(imdbID: x, completion: { (rating) in
                cell.detailTextLabel?.text = "⭐️ " + rating
            })

            }
        }
        //
        
        return cell
    }
    
    func resizeCellImageView(_ cell: UITableViewCell) {
        
        let itemSize = CGSize(width: 55.0, height: 55.0) //pixels
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
        let imageRect = CGRect(x:0, y:0, width: itemSize.width,height: itemSize.height)
        cell.imageView?.image?.draw(in: imageRect)
        cell.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        
        //add rounded corners - radius
        cell.imageView?.layer.cornerRadius = 55/2
        cell.imageView?.layer.masksToBounds = true
        UIGraphicsEndImageContext()
    }
    
    // MARK: - Populate movies

    fileprivate func downloadRestaurants() {
       
        let moviesAPI = "http://www.omdbapi.com/?s=Harry_Potter&page=\(i)"

        guard let url = URL(string: moviesAPI) else {
            fatalError("Invalid URL")
        }
        
        let session = URLSession.shared
        
        session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?,err: Error?) in
            
            //results --> array of dictionaries for resaurants
            
            let jsonMoviesDictionary = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            //------
            
            if (self.i == 1) {
            let jsonMoviestotalResults = jsonMoviesDictionary.value(forKey: "totalResults") as! String
            print (jsonMoviestotalResults)
            self.numberOfPages = Int(jsonMoviestotalResults)!/10
            }
            
            self.i += 1
            
            let jsonMoviesArray = jsonMoviesDictionary.value(forKey: "Search") as! [AnyObject]
            
            for movieItem in jsonMoviesArray {
                
                let movie = Movie()
                
                movie.title = movieItem.value(forKey: "Title") as? String
                movie.year = movieItem.value(forKey: "Year") as? String
                movie.imdbID = movieItem.value(forKey: "imdbID") as? String
                movie.type = movieItem.value(forKey: "Type") as? String
                movie.poster = movieItem.value(forKey: "Poster") as? String
                
            self.movies.append(movie)
            
            
            }
            if (self.i < self.numberOfPages){
                
                self.downloadRestaurants()
            } else {
            //print(jsonMoviesArray)
            
            // Update UI
            
            DispatchQueue.main.async(execute: {
                
                self.tableView.reloadData()
                
            })
            //
            
            }     } ) .resume() //end of the task
        
    }
    
    // Download Rating another query
    fileprivate func downloadMovieRating(imdbID: String, completion: @escaping (_ rating:String) -> ()) {
        
        var rating = String()
        let moviesAPI = "http://www.omdbapi.com/?i=\(imdbID)&plot=short&r=json"
        
        guard let url = URL(string: moviesAPI) else {
            fatalError("Invalid URL")
        }
        
        let session = URLSession.shared
        
        session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?,err: Error?) in
            
            
            //results --> array of dictionaries for resaurants
            let jsonMoviesDictionary = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary //{
            
            rating = (jsonMoviesDictionary.value(forKey: "imdbRating") as? String)!
            completion(rating) // as return , pass back the value
            
        } ) .resume() //end of the task
        
       //print(rating)
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ToMovieWebVC" {
            
            guard let indexPath = self.tableView.indexPathForSelectedRow else {
                fatalError("Invalid IndexPath")
            }
            
            let movie = self.movies[indexPath.row]
            
            guard let movieViewController = segue.destination as? MovieWebViewController else {
                fatalError("Destination controller not found")
            }
            
            movieViewController.movie = movie
            
            }

        }


   }
