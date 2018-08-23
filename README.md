# TwitterLogIn
Currently, most mobile applications have the option to login by social networks. This sample Swift project was created to show simple and fast solution for login by Twitter using Parse service. 
So, with a few lines of code I have created complete login view like this:

![alt tag](https://github.com/DroidsOnRoids/TwitterLogIn/blob/master/PopUpViewController.gif)

```swift
@IBAction func signInButtonAction(sender: UIButton) {
        if PFUser.currentUser() == nil {
            let parseAutomaticViewController = PFLogInViewController()
            parseAutomaticViewController.fields = [.Twitter, .DismissButton]
            parseAutomaticViewController.delegate = self
            presentViewController(parseAutomaticViewController, animated: true, completion: nil)
        }
    }
```
You can find complete description and alternative solution on
[Droids On Roids Blog](http://www.thedroidsonroids.com/blog)

Contact: opensource@droidsonroids.pl
