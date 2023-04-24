//
//  ViewController.swift
//  miniBootcampChallenge
//

import UIKit

class ViewController: UICollectionViewController {
    
    private struct Constants {
        static let title = "Mini Bootcamp Challenge"
        static let cellID = "imageCell"
        static let cellSpacing: CGFloat = 1
        static let columns: CGFloat = 3
        static var cellSize: CGFloat?
    }
    
    private lazy var urls: [URL] = URLProvider.urls
    let activityIndicator =  UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
        setupSubview()
        
        //For the second function
        downloadImages(urls: urls) {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
            }
        }
    }
    
    func setupSubview() {
        self.view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
    }
    
    
    // TODO: 1.- Implement a function that allows the app downloading the images without freezing the UI or causing it to work unexpected way
    // For non-file URLS, using the dataTask(with:completionHandler:) method of the URLSession is a better option. Then, loading the image in DispatchQueue.main.async loads the images asynchronously.
    
    func getImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    // TODO: 2.- Implement a function that allows to fill the collection view only when all photos have been downloaded, adding an animation for waiting the completion of the task.
    // Use the dataTask(with:completionHandler:) method of the URLSession and creating a dispatch queue to keep track of when all downloads are complete
    //  and save to FileManager. After download has been completed, it send the data to the completion handler.
    func downloadImages(urls: [URL], completion: @escaping () -> Void) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Create a DispatchGroup to keep track of when all downloads are complete
        let group = DispatchGroup()
        
        for (index, url) in urls.enumerated() {
            group.enter()
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { group.leave() }
                
                guard let data = data else {
                    return
                }
                
                let fileName = "\(index).jpg"
                let fileURL = documentsDirectory.appendingPathComponent(fileName)
                
                do {
                    try data.write(to: fileURL)
                    print("Downloaded and saved image to \(fileURL)")
                } catch {
                    print("Error saving image to file: \(error)")
                }
            }.resume()
        }
        
        // Notify the completion handler when all downloads are complete
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
}

// MARK: - UICollectionView DataSource, Delegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        urls.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        
        // Implementation for the first function
//        let url = urls[indexPath.row]
//        getImage(url: url) { image in
//            self.activityIndicator.stopAnimating()
//            cell.display(image)
//        }
        
        // Implementation for the second function
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(indexPath.row).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if let image = UIImage(contentsOfFile: fileURL.path) {
            cell.display(image)
        }
        
        return cell
    }
}


// MARK: - UICollectionView FlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if Constants.cellSize == nil {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let emptySpace = layout.sectionInset.left + layout.sectionInset.right + (Constants.columns * Constants.cellSpacing - 1)
            Constants.cellSize = (view.frame.size.width - emptySpace) / Constants.columns
        }
        return CGSize(width: Constants.cellSize!, height: Constants.cellSize!)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }
}
