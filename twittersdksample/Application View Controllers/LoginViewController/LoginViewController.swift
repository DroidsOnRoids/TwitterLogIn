//
//  LoginViewController.swift
//  twittersdksample
//
//  Created by Paweł Sternik on 07.12.2015.
//  Copyright © 2015 Paweł Sternik. All rights reserved.
//

// Frameworks
import UIKit
import ChameleonFramework
import Parse
import ParseUI
import ParseTwitterUtils
import MBProgressHUD
import pop


class LoginViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signInButton: LoginButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var signInWithoutParseControllerButton: LoginButton!
    @IBOutlet weak var twitterLogoImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var logOutButton: UIButton!
    
    private let twitterAPIUserDetailsURL = "https://api.twitter.com/1.1/users/show.json?screen_name="
    
    let changeAlphaLabel: (UILabel, CGFloat) -> () = { (label, newAlpha) in
        label.alpha = newAlpha
    }
    
// MARK: View Controller life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
// MARK: Setup
    
    func viewDidLoadSetup() {
        // Apperance
        welcomeLabel.alpha = 0.0
        avatarImageView.alpha = 0.0
        logOutButton.alpha = 0.0
        
        avatarImageView.layer.cornerRadius = CGRectGetWidth(avatarImageView.frame) / 2.0
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.borderWidth = 1.0
        avatarImageView.layer.borderColor = UIColor.twitterColor().CGColor
        
        twitterLogoImageView.image = twitterLogoImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
        twitterLogoImageView.tintColor = .twitterColor()
        twitterLogoImageView.backgroundColor = .whiteColor()
        titleLabel.textColor = UIColor(red: 0.35, green: 0.42, blue: 0.47, alpha: 1.0)
        
        // Texts
        signInButton.setTitle("Parse Controller", forState: .Normal)
        logOutButton.setTitle("Log out", forState: .Normal)
        signInWithoutParseControllerButton.setTitle("Login in", forState: .Normal)
        
        // Image view tap gesture recognizer
        twitterLogoImageView.userInteractionEnabled = true
        let twitterLogoTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTapRecognizer:"))
        twitterLogoImageView.addGestureRecognizer(twitterLogoTapRecognizer)
    }
    
// MARK: Success login alert
    
    func loggedUserAlert() {
        let alertController = UIAlertController(title: "Success!", message: "You are logged in", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
// MARK: Animations
    
    func showAvatarAnimation(imageData: NSData) {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            self.avatarImageView.image = UIImage(data: imageData)
            
            UIView.animateWithDuration(0.3, animations: {
                self.avatarImageView.alpha = 1.0
            })
        })
    }
    
    func hideAvatarAnimation() {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            UIView.animateWithDuration(0.3, animations: {
                self.avatarImageView.alpha = 0.0
            })
        }
    }
    
    func showWelcomeLabelAnimation(twitterName: String) {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            self.welcomeLabel.text = "Welcome " + twitterName
            UIView.animateWithDuration(0.3, animations: { self.changeAlphaLabel(self.titleLabel, 0.0) },
                                            completion: { _ in self.changeAlphaLabel(self.welcomeLabel, 1.0)
                                                               self.logOutButton.alpha = 1.0})
        })
    }
    
    func hideWelcomeLabelAnimation() {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            UIView.animateWithDuration(0.3, animations: { self.changeAlphaLabel(self.welcomeLabel, 0.0) },
                                            completion: { _ in self.changeAlphaLabel(self.titleLabel, 1.0) })
            })
    }
    
// MARK: Parse Login View Controller delegate methods
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        dismissViewControllerAnimated(true, completion: nil)
        loggedUserAlert()
        showWelcomeLabelAnimation(user.username!)
    }
    
// MARK: Recognize tap and animate logo
    
    func handleTapRecognizer(gestureRecognizer: UIGestureRecognizer) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            let resizeValue: CGFloat = 1.4
            let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
            scaleAnimation.fromValue = NSValue(CGSize: CGSizeMake(1.0, 1.0))
            scaleAnimation.toValue = NSValue(CGSize: CGSizeMake(resizeValue, resizeValue))
            scaleAnimation.springBounciness = 10.0
            
            scaleAnimation.completionBlock = { (POPAnimation animation, Bool finished) in
                let scaleReverseAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
                scaleReverseAnimation.fromValue = NSValue(CGSize: CGSizeMake(resizeValue, resizeValue))
                scaleReverseAnimation.toValue = NSValue(CGSize: CGSizeMake(1.0, 1.0))
                
                scaleReverseAnimation.completionBlock = { (POPAnimation animation, Bool finished) in
                    self.twitterLogoImageView.pop_removeAllAnimations()
                }
                
                self.twitterLogoImageView.layer.pop_addAnimation(scaleReverseAnimation, forKey: "scaleReverseAnimation")
            }
            
            self.twitterLogoImageView.layer.pop_addAnimation(scaleAnimation, forKey: "scaleAnimation")
        }
    }
    
// MARK: Actions methods
    
    @IBAction func signInButtonAction(sender: UIButton) {
        if PFUser.currentUser() == nil {
            let parseAutomaticViewController = PFLogInViewController()
            parseAutomaticViewController.fields = [.Twitter, .DismissButton]
            parseAutomaticViewController.delegate = self
            presentViewController(parseAutomaticViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func signInWithoutParseControllerButtonAction(sender: UIButton) {
        PFTwitterUtils.logInWithBlock { (user, error) in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in with Twitter!")
                    self.processTwiterUser()
                } else {
                    print("User logged in with Twitter!")
                    self.processTwiterUser()
                }
            } else {
                print("Uh oh. The user cancelled the Twitter login.")
            }
        }
    }
    
    func processTwiterUser() {
        let activityIndicator = MBProgressHUD.showHUDAddedTo(view, animated: true)
        activityIndicator.labelText = "Loading"
        activityIndicator.detailsLabelText = "Please wait..."
        
        if let twitterUsername = PFTwitterUtils.twitter()?.screenName {
            let userDetailsURL = twitterAPIUserDetailsURL + twitterUsername
            let request = NSMutableURLRequest(URL: NSURL(string: userDetailsURL)!)
            request.HTTPMethod = "GET"
            PFTwitterUtils.twitter()!.signRequest(request)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
                if error != nil {
                    activityIndicator.hide(true)
                    PFUser.logOut()
                    self.showAlertController("Error", message: error!.localizedDescription)
                } else {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                        if let parseJSON = json {
                            if let profileImageURL = parseJSON["profile_image_url"] as? String {
                                let profilePictureData = NSData(contentsOfURL: NSURL(string: profileImageURL)!)
                                if profilePictureData != nil {
                                    let profileFileObject = PFFile(data: profilePictureData!)
                                    PFUser.currentUser()?.setObject(profileFileObject!, forKey: "profile_picture")
                                    self.showAvatarAnimation(profilePictureData!)
                                }
                                
                                PFUser.currentUser()?.username = twitterUsername
                                PFUser.currentUser()?.setObject(twitterUsername, forKey: "first_name")
                                PFUser.currentUser()?.setObject(" ", forKey: "last_name")
                                
                                self.showWelcomeLabelAnimation(twitterUsername)
                                
                                PFUser.currentUser()?.saveInBackgroundWithBlock({ (success, error) in
                                    activityIndicator.hide(true)
                                    
                                    if error != nil {
                                        self.showAlertController("Error", message: error!.localizedDescription)
                                        PFUser.logOut()
                                    } else {
                                        NSUserDefaults.standardUserDefaults().setObject(twitterUsername, forKey: "userName")
                                        NSUserDefaults.standardUserDefaults().synchronize()
                                    }
                                })
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    @IBAction func logOutButtonAction(sender: UIButton) {
        PFUser.logOut()
        hideAvatarAnimation()
        hideWelcomeLabelAnimation()
        logOutButton.alpha = 0.0
    }
    
    func showAlertController(title: String, message: String) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in 
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
