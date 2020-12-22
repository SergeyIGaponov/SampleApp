//
//  DesignableUIViewCorners.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import UIKit

@IBDesignable class DesignableUIViewCorners: UIView {
    
    @IBInspectable var borderRadius: CGFloat = 0.0 {
        didSet{
            if top{
                roundCornersNew(topLeft: borderRadius, topRight: borderRadius, bottomLeft: 0.0, bottomRight: 0.0)
            }else{
                if bottom && leftTop{
                    roundCornersNew(topLeft: borderRadius, topRight: 0.0, bottomLeft: borderRadius, bottomRight: borderRadius)
                }else{
                    if bottom{
                        roundCornersNew(topLeft: 0.0, topRight: 0.0, bottomLeft: borderRadius, bottomRight: borderRadius)
                    }
                }
            }
        }
    }
    
    @IBInspectable var leftTop: Bool = false{
        didSet{
            if top{
                roundCornersNew(topLeft: borderRadius, topRight: borderRadius, bottomLeft: 0.0, bottomRight: 0.0)
            }else{
                if bottom && leftTop{
                    roundCornersNew(topLeft: borderRadius, topRight: 0.0, bottomLeft: borderRadius, bottomRight: borderRadius)
                }else{
                    if bottom{
                        roundCornersNew(topLeft: 0.0, topRight: 0.0, bottomLeft: borderRadius, bottomRight: borderRadius)
                    }
                }
            }
        }
    }
    
    @IBInspectable var top: Bool = false{
        didSet{
            if top{
                roundCornersNew(topLeft: borderRadius, topRight: borderRadius, bottomLeft: 0.0, bottomRight: 0.0)
            }
        }
    }
    
    @IBInspectable var bottom: Bool = false{
        didSet{
            if bottom{
                roundCornersNew(topLeft: 0.0, topRight: 0.0, bottomLeft: borderRadius, bottomRight: borderRadius)
            }
        }
    }
    
    
    func roundCornersNew(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {//(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        let topLeftRadius = CGSize(width: topLeft, height: topLeft)
        let topRightRadius = CGSize(width: topRight, height: topRight)
        let bottomLeftRadius = CGSize(width: bottomLeft, height: bottomLeft)
        let bottomRightRadius = CGSize(width: bottomRight, height: bottomRight)
        let maskPath = UIBezierPath(shouldRoundRect: bounds, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius)
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        
        layer.mask = shape
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if top{
            roundCornersNew(topLeft: borderRadius, topRight: borderRadius, bottomLeft: 0.0, bottomRight: 0.0)
        }else{
            if bottom && leftTop{
                roundCornersNew(topLeft: borderRadius, topRight: 0.0, bottomLeft: borderRadius, bottomRight: borderRadius)
            }else{
                if bottom{
                    roundCornersNew(topLeft: 0.0, topRight: 0.0, bottomLeft: borderRadius, bottomRight: borderRadius)
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if top{
            roundCornersNew(topLeft: borderRadius, topRight: borderRadius, bottomLeft: 0.0, bottomRight: 0.0)
        }else{
            if bottom && leftTop{
                roundCornersNew(topLeft: borderRadius, topRight: 0.0, bottomLeft: borderRadius, bottomRight: borderRadius)
            }else{
                if bottom{
                    roundCornersNew(topLeft: 0.0, topRight: 0.0, bottomLeft: borderRadius, bottomRight: borderRadius)
                }
            }
        }
    }
    
}
