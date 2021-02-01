//
//  ViewController.swift
//  Fruitful
//
//  Created by David Bauducco on 7/14/20.
//  Copyright © 2020 David Bauducco. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var promodoLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
    var currentStrokeLayer = CAShapeLayer()
    var currentState = "FOCUS"
    var currentPromodo = 0
    var totalPromodos = 4
    
    var isPaused = false
    
    var currentTimer = Timer()
    var timeLeft = 0.0
    var totalTime = 0.0
    
    // UI CONSTANTS
    let focusColor = UIColor.red.cgColor
    let breakColor = UIColor.green.cgColor
    let pausedColor = UIColor.blue.cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Create Stroke Layer
        currentStrokeLayer = CAShapeLayer()
        currentStrokeLayer.fillColor = UIColor.clear.cgColor
        currentStrokeLayer.strokeColor = UIColor.clear.cgColor
        currentStrokeLayer.lineWidth = 60
        currentStrokeLayer.path = CGPath.init(rect: progressView.bounds, transform: nil)
        
        progressView.layer.addSublayer(currentStrokeLayer)
        
        goToNextState()
        
    }

    @IBAction func screenTapped(_ sender: Any) {
        pauseTimer()
    }
    
    @IBAction func screenSwipped(_ sender: Any) {
        goToNextState()
    }
    
    func pauseTimer() {
        isPaused = !isPaused
        
        if (isPaused) {
            currentStrokeLayer.strokeColor = pausedColor
        } else {
            currentStrokeLayer.strokeColor = (currentState == "FOCUS" ? focusColor : breakColor);
        }
    }
    
    @IBAction func longPressDetected(_ sender: Any) {
        // Reset Timer
        currentPromodo = 0
        goToNextState()
    }
    
    func goToNextState() {
        
        // Make sure to invalidate current timer and remove animation layers
        currentTimer.invalidate()
        
        // Vibrate Device + Play Sound
        AudioServicesPlaySystemSound(1009)
        
        // Check if we have reached the end
        if (currentState == "BREAK" && totalPromodos == currentPromodo) {
            currentPromodo = 0
        }
        
        
        // Increase current promodo by one if we are in a break or at the beginning and switch the state
        if (currentState == "BREAK" || currentPromodo == 0)
        {
            currentPromodo += 1
            currentState = "FOCUS"
            startTimer(length: 60*25)
            
        } else if (currentState == "FOCUS" && currentPromodo == totalPromodos) {
            
            // Have a longer break time if we are on the last break
            currentState = "BREAK"
            startTimer(length: 60*25)
            
        } else {
            currentState = "BREAK"
            startTimer(length: 60*5)
        }
        
        stateLabel.text = currentState
        minuteLabel.text = "--"
        secondsLabel.text = "--"
        promodoLabel.text = "\(currentPromodo)/\(totalPromodos)"
        
    }
    
    func startTimer(length: Double) {
        // Set time
        timeLeft = length
        totalTime = length

        // Prepare progress view
        let strokeColor = (currentState == "FOCUS" ? focusColor : breakColor);
        setupProgressView(totalTime: length, strokeColor: strokeColor)
        
        // Start timer
        currentTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerRan), userInfo: nil, repeats: true)

    }
    
    @objc func timerRan() {
        
        // If the timer is paused, skip all the code
        if (isPaused) {return}
        
        // Subtract time left by 0.1 seconds
        timeLeft -= 0.1
        
        if (timeLeft <= 0) {
            goToNextState()
            return
        }
        
        // Update time label
        let (minutesLeft, secondsLeft) = Int(timeLeft.rounded(.up)).quotientAndRemainder(dividingBy: 60)
        minuteLabel.text = String(format: "%02d", minutesLeft)
        secondsLabel.text = String(format: "%02d", secondsLeft)
        
        // Border Color Pulse
        currentStrokeLayer.opacity = abs(sin((1/4) * Float(timeLeft)) * 0.4) + 0.6
        currentStrokeLayer.strokeEnd = CGFloat(timeLeft/totalTime)
        
        // Flash background on last 10 seconds
        if (secondsLeft <= 10 && minutesLeft == 0) {
            if (secondsLeft % 2 == 0) {
                // Time is even
                currentStrokeLayer.fillColor = UIColor.clear.cgColor
            } else {
                // Time is odd
                currentStrokeLayer.fillColor = currentStrokeLayer.strokeColor
            }
        }
        
    }
    
    func setupProgressView(totalTime: Double, strokeColor: CGColor) {

        currentStrokeLayer.strokeColor = isPaused ? pausedColor : strokeColor
        currentStrokeLayer.fillColor = UIColor.clear.cgColor
        currentStrokeLayer.strokeStart = 0
        currentStrokeLayer.strokeEnd = 1

    }
    
}

