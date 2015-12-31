//
//  ImageUtility.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/11/23.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class ImageUtility: NSObject {
    
    static func convertProfilePictureImage(originalImage : UIImage) -> UIImage {
        // 表示用にリサイズする
        return ImageUtility.resizeAspectFitWithSize(originalImage, size: CGSizeMake(150, 150))
    }
    
    static func photoThumbnail(originalImage : UIImage) -> UIImage {
        // 表示用にリサイズする
        return ImageUtility.resizeAspectFitWithSize(originalImage, size: CGSizeMake(360, 360))
    }
    
    static func resizeAspectFitWithSize(srcImg : UIImage, size : CGSize) -> UIImage {
        let widthRatio  = size.width  / srcImg.size.width
        let heightRatio = size.height / srcImg.size.height
        let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
        
        let resizedSize = CGSizeMake(srcImg.size.width*ratio, srcImg.size.height*ratio)
        
        UIGraphicsBeginImageContext(resizedSize)
        srcImg.drawInRect(CGRectMake(0, 0, resizedSize.width, resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resizedImage
    }

    static func blankImage(size : CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let blank  = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return blank
    }
}
