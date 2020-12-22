//
//  LocationServerTableViewCell.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import UIKit
import OptimalLabelTextSize
import SDWebImage

class LocationServerTableViewCell: UITableViewCell {

    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var signalNetwork: UIImageView!
    @IBOutlet weak var pingSignal: UIImageView!
    @IBOutlet weak var statusView: DesignableView!
    @IBOutlet weak var fastView: DesignableView?
    @IBOutlet weak var statusLabel: TextSizeDevice!
    @IBOutlet weak var content: UIView!
    
    weak var dataCell: LocationServerCellViewModelType?{
        willSet(dataCell){
            locationName.text = dataCell?.serverName
           
            if let url = dataCell?.urlImageFlag{
                flag.sd_setImage(with: url, placeholderImage: UIImage(named: ""), options: SDWebImageOptions(rawValue: 0), completed: nil)
            }else{
                flag.image = nil
            }
            
            statusView.isHidden = dataCell?.isHiddenStatusView ?? true
            statusView.backgroundColor = dataCell?.backgroundColorStatusView
            statusLabel.text = dataCell?.status
            content.backgroundColor = dataCell?.contentBackground
            pingSignal.image = dataCell?.signalPing
            if let fastView = fastView{
                fastView.isHidden = dataCell?.isFast ?? false
            }
        }
    }
    
}


