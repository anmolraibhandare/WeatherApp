//
//  WeatherDetailsInterfaceController.swift
//  RWWeather WatchKit Extension
//
//  Created by Anmol Raibhandare on 11/13/20.
//  Copyright © 2020 Razewre LLC. All rights reserved.
//

import WatchKit
import Foundation


class WeatherDetailsInterfaceController: WKInterfaceController {

    @IBOutlet var intervalLabel: WKInterfaceLabel!
    @IBOutlet var temperatureLabel: WKInterfaceLabel!
    @IBOutlet var conditionImage: WKInterfaceImage!
    @IBOutlet var conditionLabel: WKInterfaceLabel!
    @IBOutlet var feelsLikeLabel: WKInterfaceLabel!
    @IBOutlet var windLabel: WKInterfaceLabel!
    @IBOutlet var highTemperatureLabel: WKInterfaceLabel!
    @IBOutlet var lowTemperatureLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
