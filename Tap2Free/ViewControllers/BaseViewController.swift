//
//  BaseViewController.swift
//  Tap2Free
//
//  Created by Serhii Haponov.

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showRatingController(){
        let storyboard = UIStoryboard(name: StoryboardName.Main.getName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: ControllerID.ratingViewController.getID) as? RatingViewController
        vc?.modalPresentationStyle = .overFullScreen
        vc?.modalTransitionStyle = .crossDissolve
        present(vc!, animated: true, completion: nil)
    }
    
    
}
