/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet var conditionsImage: WKInterfaceImage!
    @IBOutlet var windSpeedLabel: WKInterfaceLabel!
    @IBOutlet var temperatureLabel: WKInterfaceLabel!
    @IBOutlet var feelsLikeLabel: WKInterfaceLabel!
    @IBOutlet var conditionsLabel: WKInterfaceLabel!
    @IBOutlet var shortTermForecastLabel1: WKInterfaceLabel!
    @IBOutlet var shortTermForecastLabel2: WKInterfaceLabel!
    @IBOutlet var shortTermForecastLabel3: WKInterfaceLabel!
    @IBOutlet var longTermForecastTable: WKInterfaceTable!
    
    lazy var dataSource: WeatherDataSource = {
        let defaultSystem = UserDefaults.standard.string(forKey: "MeasurementSystem") ?? "Metric"
        if defaultSystem == "Metric" {
            return WeatherDataSource(measurementSystem: .Metric)
        }
        return WeatherDataSource(measurementSystem: .USCustomary)
    }()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        updatAllForecasts()
    }
    
    // Helper function to update all forecasts
    func updatAllForecasts() {
        updateCurrentForecast()
        updateShortTermForecast()
        updateLongTermForecast()
    }
    

    
    // Updating the current forecast values
    func updateCurrentForecast() {
        let weather = dataSource.currentWeather
        temperatureLabel.setText(weather.temperatureString)
        feelsLikeLabel.setText(weather.feelTemperatureString)
        windSpeedLabel.setText(weather.windString)
        conditionsLabel.setText(weather.weatherConditionString)
        conditionsImage.setImageNamed(weather.weatherConditionImageName)
    }
    
    // Updating the short term forecast
    func updateShortTermForecast() {
        let labels = [shortTermForecastLabel1, shortTermForecastLabel2,
        shortTermForecastLabel3]
        let weatherData = [dataSource.shortTermWeather[0],
        dataSource.shortTermWeather[dataSource.shortTermWeather.count/2],
        dataSource.shortTermWeather[dataSource.shortTermWeather.count-1]]
        for i in 0...2 {
            let label = labels[i]
            let weather = weatherData[i]
            label?.setText("\(weather.intervalString)\n" +
            "\(weather.temperatureString)")
        }
    }
    
    // Updating the long term table forecast
    func updateLongTermForecast(){
        longTermForecastTable.setNumberOfRows(dataSource.longTermWeather.count, withRowType: "longTermForecastRow")
        
        for (index, weather) in dataSource.longTermWeather.enumerated(){
            if let row = longTermForecastTable.rowController(at: index) as? LongTermForecastRowController {
                row.dateLabel.setText(weather.intervalString)
                row.temperatureLabel.setText(weather.temperatureString)
                row.conditionsLabel.setText(weather.weatherConditionString)
                row.conditionsImage.setImageNamed(
                weather.weatherConditionImageName)
            }
        }
    }
    
    // Send the context information along the segue
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        if segueIdentifier == "WeatherDetailsSegue" {
            let context: NSDictionary = [
                // dataSource is a class and can be sent
                "dataSource": dataSource,
                "longTermForecastIndex": rowIndex
            ]
            return context // Context sent to segue
        }
        return nil
    }
    
    
    
    // Metric Menu Action
    @IBAction func switchToMetric() {
        dataSource = WeatherDataSource(measurementSystem: .Metric)
        updatAllForecasts()
        // Storing Data - when app opens it will be set to the value set previously
        UserDefaults.standard.set("Metric", forKey: "MeasurementSystem")
        UserDefaults.standard.synchronize()
    }
    
    // Customary Menu Action
    @IBAction func switchToUSCustomary() {
        dataSource = WeatherDataSource(measurementSystem: .USCustomary)
        updatAllForecasts()
        // Storing Data - when app opens it will be set to the value set previously
        UserDefaults.standard.set("USCustomary", forKey: "MeasurementSystem")
        UserDefaults.standard.synchronize()
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
