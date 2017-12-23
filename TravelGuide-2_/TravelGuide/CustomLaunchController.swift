//
//  ViewController.swift
//  TravelGuide
//
//  Created by Bobby Jasuja on 10/04/17.
//  Copyright © 2017 Syracuse University. All rights reserved.
//

import UIKit
import AVFoundation

class CustomLaunchController:  UIappViewController {
    var audioPlayer:AVAudioPlayer!
    @IBOutlet var image:UIImageView!
    @IBOutlet var planeimage:UIImageView!
    @IBOutlet var cloud1:UIImageView!
    @IBOutlet var cloud2:UIImageView!
    @IBOutlet var car:UIImageView!
    @IBOutlet var restaurant:UIImageView!
    @IBOutlet var mall:UIImageView!
    @IBOutlet var label:UILabel!
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var text: NSAttributedString = {
        let font = UIFont(name: "Georgia", size: 22.0) ?? UIFont.systemFontOfSize(22.0)
        return NSAttributedString(string: "If you like travelling", attributes: [NSFontAttributeName: font])
    }()
    
    var text2: NSAttributedString = {
        let font = UIFont(name: "Georgia", size: 22.0) ?? UIFont.systemFontOfSize(22.0)
        return NSAttributedString(string: "... and eating at some of the best \nrestaurants, food courts and cuisines \nnear you", attributes: [NSFontAttributeName: font])
    }()
    
    var text3: NSAttributedString = {
        let font = UIFont(name: "Georgia", size: 22.0) ?? UIFont.systemFontOfSize(22.0)
        return NSAttributedString(string: "or if you like going for shopping \nthen this app is for you", attributes: [NSFontAttributeName: font])
    }()
    
    var transitionManager:TransitionManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playSound()
        planeimage.alpha=0
        cloud1.alpha=0
        cloud2.alpha=0
        car.alpha=0
        restaurant.alpha=0
        mall.alpha=0
        transitionManager = TransitionManager()
    }
    
   
    override func viewWillAppear(animated: Bool) {
        car.center.x -= view.bounds.width
    
    }
    
    override func viewDidAppear(animated: Bool)
    {
       UIView.animateWithDuration(0.8, delay: 0.0, options: [], animations: {
        self.view.backgroundColor = UIColor(red:0.39, green:0.72, blue:0.91, alpha:1.0)
        
        self.image.alpha=0
        self.cloud1.alpha=1
        self.cloud2.alpha=1
                }, completion:
        {
            animationFinished in
            self.speak("If you like travelling")
            let _ = Timer(interval: 0.03) {i -> Bool in
                self.label.attributedText = self.text.attributedSubstringFromRange(NSRange(location: 0, length: i+1))
                
                return i + 1 < self.text.string.characters.count
                
            }
            self.animateplane()
       })
    }
    
    
    
    override func viewWillDisappear(animated: Bool)
    {
       stopSound();
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    func animateplane()
    {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            print("complete")
            self.animatefood();
            
        })
       
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 56,y: 39))
        path.addCurveToPoint(CGPoint(x: 301, y: 39), controlPoint1: CGPoint(x: 250, y:50), controlPoint2: CGPoint(x: 200, y: 55))
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.path = path.CGPath
        anim.rotationMode = kCAAnimationRotateAuto
        anim.duration = 2.0
        planeimage.alpha=1
        planeimage.layer.addAnimation(anim, forKey: "animate position along path")
        CATransaction.commit()
    }
    
    
    func animatefood()
    {
        self.planeimage.alpha=0
        let rectShape = CAShapeLayer()
        label.text=nil
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            print("complete")
            self.cloud1.alpha=0
            self.cloud2.alpha=0
            self.view.backgroundColor = UIColor.yellowColor()
            rectShape.removeFromSuperlayer()
            
            self.animatecar()
            
        })
        
        let bounds = CGRect(x: 10, y: 50, width: 100, height: 100)
        
        rectShape.bounds = bounds
        rectShape.position = view.center
        rectShape.cornerRadius = bounds.width / 2
        view.layer.addSublayer(rectShape)
        let startShape = UIBezierPath(roundedRect: bounds, cornerRadius: 50).CGPath
        let endShape = UIBezierPath(roundedRect: CGRect(x: -450, y: -450, width: 1000, height: 1000), cornerRadius: 500).CGPath
        
        rectShape.path = startShape
        rectShape.fillColor = UIColor.yellowColor().CGColor
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = endShape
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeBoth
        animation.removedOnCompletion = false
        rectShape.addAnimation(animation, forKey: animation.keyPath)
        CATransaction.commit()
    }
    

    func animatecar()
    {
        restaurant.alpha=1
        UIView.animateWithDuration(1.3, delay: 1.0, options: [], animations: {
            
            let _ = Timer(interval: 0.03) {i -> Bool in
                
                self.label.attributedText = self.text2.attributedSubstringFromRange(NSRange(location: 0, length: i+1))
                return i + 1 < self.text2.string.characters.count
            }
            self.speak("... and eating at some of the best restaurants, food courts and cuisines near you")
            self.car.alpha=1
            self.car.center.x += self.view.bounds.width
            
            }, completion:
            {
                animationFinished in
                    self.animatemall()
                        })
    }
    
    
    func animatemall()
    {
        UIView.animateWithDuration(1.0, delay: 2.0, options: [], animations:
        {
            self.mall.alpha=1
            self.speak("or even if you like going for shopping then this app is for you")
            }, completion: {
                animationFinished in
                let _ = Timer(interval: 0.03) {j -> Bool in
                    self.label.attributedText = self.text3.attributedSubstringFromRange(NSRange(location: 0, length: j+1))
                    return j + 1 < self.text3.string.characters.count
                }
                
                self.cloud1.alpha=1
                self.cloud2.alpha=1
                let viewController: UINavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("navigate") as! UINavigationController
                
                let delay = 4.5 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue())
                { () -> Void in
                    viewController.transitioningDelegate = self.transitionManager
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    appDelegate.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("navigate")
                    self.presentViewController(viewController, animated: true, completion: nil)
                }
                print("complete")
        })
    }
    
    
    func speak(s:String)
    {
        let speechUtterance = AVSpeechUtterance(string: s)
        
        speechUtterance.rate = 0.37
        speechUtterance.pitchMultiplier = 1.0
        speechUtterance.volume = 1.0
        
        speechSynthesizer.speakUtterance(speechUtterance)
    }
    
    func playSound() {
        let audioFilePath = NSBundle.mainBundle().pathForResource("Tourist", ofType: "mp3")
        if audioFilePath != nil {
            let audioFileUrl = NSURL.fileURLWithPath(audioFilePath!)
            
            do
            {
                audioPlayer = try AVAudioPlayer(contentsOfURL: audioFileUrl)
                audioPlayer.play()
            }
            catch{ print("could not load audio")}
        }
        else {
            print("audio file is not found")
        }
    }
    
    func stopSound()
    {
        if(audioPlayer != nil)
        {
            audioPlayer.stop();
            audioPlayer = nil;
        }
    }
}


class Timer {
    typealias TimerFunction = (Int)->Bool
    private var handler: TimerFunction
    private var i = 0
    
    init(interval: NSTimeInterval, handler: TimerFunction) {
        self.handler = handler
        NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(Timer.timerFired(_:)), userInfo: nil, repeats: true)
    }
    
    @objc
    private func timerFired(timer:NSTimer) {
        if !handler(i++) {
            
            timer.invalidate()
        }
    }
}
