//
//  ProductCollectionViewCell.swift
//  MTest
//
//  Created by Sachin George on 27/05/23.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var offerLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var expressImage: UIImageView!
    @IBOutlet weak var actualPrice: UILabel!
    @IBOutlet weak var offerPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    private var imageURL: URL!
    private var loadImageTask: URLSessionDataTask?
    
    var cellData: ValueArray?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addButton.layer.cornerRadius = 5
        
        // Applying shadow to the container view
        containerView.clipsToBounds = true
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = .zero
        containerView.layer.shadowRadius = 5
        containerView.layer.shouldRasterize = true
//        containerView.layer.rasterizationScale = UIScreen.main.scale
        containerView.layer.shadowOpacity = 1
        containerView.layer.cornerRadius = 5
    }
    
    func configureCell(with cellData: ValueArray) {
        
        if let name = cellData.name {
            self.productName.text = name
        }
        
        if cellData.isExpress! {
            self.expressImage.isHidden = false
        } else {
            self.expressImage.isHidden = true
        }
        
        if let offer = cellData.offer {
            if offer > 0 {
                self.offerLabel.isHidden = false
                self.offerLabel.text = " \(offer)% OFF "
            } else {
                self.offerLabel.isHidden = true
            }
        }
        
        if cellData.actualPrice == cellData.offerPrice {
            self.offerPrice.isHidden = true
            self.actualPrice.text = cellData.actualPrice
            self.actualPrice.textColor = .label
        } else {
            
            // Attributed string with a strikethrough style
            let actualPrice: NSMutableAttributedString = NSMutableAttributedString(string: cellData.actualPrice ?? "")
            actualPrice.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSRange(location: 0, length: actualPrice.length))
            
            self.offerPrice.isHidden = false
            self.offerPrice.text = cellData.offerPrice
            self.actualPrice.attributedText = actualPrice
            self.actualPrice.textColor = .systemGray
        }
        
        self.imageURL = URL(string: cellData.image ?? "")!
        
        // Reset image to a placeholder
        productImage.image = UIImage(named: "placeholder")
        
        if let cachedImage = ImageCache.shared.image(forKey: self.imageURL.absoluteString) {
            // Use cached image if available
            productImage.image = cachedImage
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
                    if self.imageURL.absoluteString == cellData.image ?? "" {
                        self.productImage.image = image
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
