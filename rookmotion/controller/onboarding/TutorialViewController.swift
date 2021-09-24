//
//  TutorialViewController.swift
//  rockmotion
//
//  Created by John A. Cristobal on 6/11/19.
//  Copyright © 2019 rockmotion. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var butonStart: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var tutorialPageViewController: OnboardingViewController? {
        didSet {
            tutorialPageViewController?.tutorialDelegate = self
        }
    }
    
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     if let tutorialPageViewController = segue.destination as? OnboardingViewController {
     OnboardingViewController.tutorialDelegate = self
     }
     }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        butonStart.isHidden = true
        
        // Do any additional setup after loading the view.
        pageControl.addTarget(self, action: "didChangePageControlValue", for: .valueChanged)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didChangePageControlValue() {
        tutorialPageViewController?.scrollToViewController(index: pageControl.currentPage)
        print("Aqui change")
    }
    
    
    @IBAction func launchMain(_ sender: Any) {
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tutorialPageViewController = segue.destination as? OnboardingViewController {
            //tutorialPageViewController.tutorialDelegate = self as! OnboardingViewControllerDelegate
            self.tutorialPageViewController = tutorialPageViewController
        }
                
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

extension TutorialViewController: OnboardingViewControllerDelegate {
    
    func onboardingViewController(tutorialPageViewController: OnboardingViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func onboardingViewController(tutorialPageViewController: OnboardingViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
        
        if index == 3 {
            butonStart.isHidden = false
        }else{
            butonStart.isHidden = true
        }
        
        print("Aqui...\(index)")
    }
    
}
