//
//  CategoryCollectionViewCell.swift
//  MTest
//
//  Created by Sachin George on 27/05/23.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryImage: UIImageView!
    
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var imageContainer: UIView!
    
    private var imageURL: URL!
    private var loadImageTask: URLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageContainer.layer.masksToBounds = true
        imageContainer.layer.cornerRadius = imageContainer.frame.height/2
    }
    
    func configureCell(with imageURL: String) {
        self.imageURL = URL(string: imageURL)!
        
        // Reset image to a placeholder
        categoryImage.image = UIImage(named: "placeholder")
        
        if let cachedImage = ImageCache.shared.image(forKey: self.imageURL.absoluteString) {
            // Use cached image if available
            categoryImage.image = cachedImage
        } else {
            // Download image asynchronously
            loadImageTask = URLSession.shared.dataTask(with: self.imageURL) { [weak self] (data, response, error) in
                guard let self = self, let data = data, let image = UIImage(data: data) else {
                    return
                }
                
                // Cache the downloaded image
                ImageCache.shared.setImage(image, forKey: self.imageURL.absoluteString)
                
                DispatchQueue.main.async {
                    // Check if the current image URL matches the downloaded URL
                    if self.imageURL.absoluteString == imageURL {
                        self.categoryImage.image = image
                    }
                }
            }
            
            loadImageTask?.resume()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Cancel the image loading task if cell is reused
        loadImageTask?.cancel()
    }

}
