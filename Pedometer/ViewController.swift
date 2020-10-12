//
//  ViewController.swift
//  Pedometer
//
//  Created by Jered Leisey on 10/11/20.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
	
	var pedometer = CMPedometer()
	var pedometerData = CMPedometerData()
	
	let goBlue = UIColor(cgColor: CGColor(genericCMYKCyan: 0.8, magenta: 0.7, yellow: 0.21, black: 0.12, alpha: 0.83))
	let stopWhite = UIColor(cgColor: CGColor(genericCMYKCyan: 0.06, magenta: 0.1, yellow: 0.04, black: 0.0, alpha: 0.83))
	var numberOfSteps: Int! = nil{
		didSet{
			// stepsLabel.text = String(format: "Steps %i", numberOfSteps)
		}
	}
	
	var timer = Timer()
	var distance = 0.0
	var pace = 0.0
	var elapsedSeconds = 0.0
	let interval = 0.1
	
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var stepsLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var paceLabel: UILabel!
	@IBOutlet weak var startStopPedometer: UIButton!
	
	@IBAction func startStopPedometer(_ sender: UIButton) {
		if sender.titleLabel?.text == "Start" {
			statusLabel.text = "Status: Running"
			sender.setTitle("Stop", for: .normal)
			sender.setTitleColor(goBlue, for: .normal)
			sender.backgroundColor = stopWhite
			if CMPedometer.isStepCountingAvailable() {
				startTimer()
				pedometer.startUpdates(from: Date()) { (pedometerData, error) in
					if let pedometerData = pedometerData {
						self.pedometerData = pedometerData
						self.numberOfSteps = Int(truncating: pedometerData.numberOfSteps)

//						self.stepsLabel.text = "Steps: \(pedometerData.numberOfSteps)"
//						print("\(Date()) -- \(pedometerData.numberOfSteps)")
					}
				}
			} else {
				print("Step counting is not available")
			}
		} else {
			pedometer.stopUpdates()
			stopTimer()
			statusLabel.text = "Status: Stopped"
			sender.setTitle("Start", for: .normal)
			sender.setTitleColor(stopWhite, for: .normal)
			sender.backgroundColor = goBlue
		}
	}
	
	func minutesSeconds(_ seconds: Double) -> String {
		let minutePart = Int(seconds) / 60
		let secondsPart = Int(seconds) % 60
		return String(format: "%02i:%02i", minutePart, secondsPart)
	}
	
	func startTimer() {
		print("Started Timer \(Date())")
		if !timer.isValid {
			timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { (timer) in
				self.displayPedometerData()
				self.elapsedSeconds += self.interval
			})
		}
	}
	
	func stopTimer() {
		timer.invalidate()
		displayPedometerData()
	}
	
	func calculatedPace() -> Double {
		if distance > 0 {
			return elapsedSeconds / distance
		} else {
			return 0
		}
	}
	
	func displayPedometerData() {
		statusLabel.text = "Pedometer On: " + minutesSeconds(elapsedSeconds)
		
		if let numberOfSteps = numberOfSteps{
			stepsLabel.text = String(format: "Steps: %i", numberOfSteps)
			print("\(Date()) -- \(stepsLabel.text!)")
		}
		
		if let pedDistance = pedometerData.distance {
			distance = pedDistance as! Double
			distanceLabel.text = String(format: "Distance: %6.2f m", distance)
			print("\(distanceLabel.text!)")
		}
		
		let minutesPerMile = 26.82
		
		if CMPedometer.isPaceAvailable() {
			if pedometerData.averageActivePace != nil {
				pace = pedometerData.averageActivePace as! Double
				paceLabel.text = String(format: "Pace: %6.2f min/mi", minutesSeconds(pace * minutesPerMile))
			} else {
				paceLabel.text = "Pace: N/A"
			}
			print("\(paceLabel.text!)")
		} else {
			paceLabel.text = "Avg. Pace: " + minutesSeconds(calculatedPace() * minutesPerMile)
			print("\(paceLabel.text!)")
//			paceLabel.text = "Pace: Not Supported"
//			print("Device not supported for tracking pace")
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		startStopPedometer.backgroundColor = goBlue
		stepsLabel.text = "Steps: Not Available"
		
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}
