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
    
    @IBOutlet var shortTermForecastGroup1: WKInterfaceGroup!
    @IBOutlet var shortTermForecastGroup2: WKInterfaceGroup!
    
    @IBOutlet var shortTermForecastLabel1: WKInterfaceLabel!
    @IBOutlet var shortTermForecastLabel2: WKInterfaceLabel!
    @IBOutlet var shortTermForecastLabel3: WKInterfaceLabel!
    @IBOutlet var shortTermForecastLabel4: WKInterfaceLabel!
    @IBOutlet var shortTermForecastLabel5: WKInterfaceLabel!
    @IBOutlet var shortTermForecastLabel6: WKInterfaceLabel!

    
    @IBOutlet var longTermForecastTable: WKInterfaceTable!

    @IBOutlet var loadingImage: WKInterfaceImage!
    @IBOutlet var containerGroup: WKInterfaceGroup!
    
    lazy var dataSource: WeatherDataSource = {
        let defaultSystem = UserDefaults.standard.string(forKey: "MeasurementSystem") ?? "Metric"
        if defaultSystem == "Metric" {
            return WeatherDataSource(measurementSystem: .Metric)
        }
        return WeatherDataSource(measurementSystem: .USCustomary)
    }()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        loadingImage.startAnimating()
        containerGroup.setHidden(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.animate(withDuration: 0.5) {
                self.containerGroup.setHidden(false)
                self.loadingImage.setAlpha(0)
                self.loadingImage.setHeight(0)
                self.updatAllForecasts()
            }
        }
    }
    
    // Helper function to update all forecasts
    func updatAllForecasts() {
        updateCurrentForecast()
        updateShortTermForecast()
        updateLongTermForecast()
        drawShortTermForecastGraph()
    }
    
    // Helper function to draw forecast graph
    func drawShortTermForecastGraph() {
        
        //create an array of temperatures
        let temperatures = dataSource.shortTermWeather.map {
            CGFloat($0.temperature)
        }
        // boilerplate code to set up core graphics context
        let graphWidth: CGFloat = 312
        let graphHeight: CGFloat = 88
        
        // create an image context
        UIGraphicsBeginImageContext(CGSize(width: graphWidth, height: graphHeight))
        // get reference to context
        let context = UIGraphicsGetCurrentContext()
    
        defer {
            UIGraphicsEndImageContext()
        }
        
        // draw in context
        let path = UIBezierPath()
        path.lineWidth = 1
        UIColor.green.withAlphaComponent(0.9).setStroke()

        // real line graph code starts here
        guard let maxTemperature = temperatures.max(), let minTemperature = temperatures.min() else {
          return
        }
        let temperatureSpread = maxTemperature - minTemperature

        func xCoordinateForIndex(index: Int) -> CGFloat {
          return graphWidth * CGFloat(index) / CGFloat(temperatures.count - 1)
        }
        func yCoordinateForTemperature(temperature: CGFloat) -> CGFloat {
          return graphHeight - (graphHeight * (temperature - minTemperature) / temperatureSpread)
        }

        path.move(to: CGPoint(x: 0, y: yCoordinateForTemperature(temperature: temperatures[0])))

        for (i, temperature) in temperatures.enumerated() {
            let x: CGFloat = xCoordinateForIndex(index: i)
            let y: CGFloat = yCoordinateForTemperature(temperature: temperature)
            print("\(i) (\(x), \(y))")
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.stroke()
        
        // end drawing code
        if let cgImage = context?.makeImage() {
            let uiImage = UIImage(cgImage: cgImage)
          shortTermForecastGroup1.setBackgroundImage(uiImage)
            shortTermForecastGroup2.setBackgroundImage(uiImage)
        }
    }
    
    
    @IBAction func showSecondPage() {
        animate(withDuration: 0.5) {
            self.shortTermForecastGroup1.setRelativeWidth(0,
            withAdjustment: 0)
            self.shortTermForecastGroup1.setAlpha(0)
        }
    }

    @IBAction func showFirstPage() {
        animate(withDuration: 0.5) {
            self.shortTermForecastGroup1.setRelativeWidth(1,
            withAdjustment: 0)
            self.shortTermForecastGroup1.setAlpha(1)
        }
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
        shortTermForecastLabel3, shortTermForecastLabel4, shortTermForecastLabel5, shortTermForecastLabel6]
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
    
    // Push Segues from code
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let context: NSDictionary = [
            "dataSource": dataSource,
            "longTermForecastIndex": rowIndex
        ]
        pushController(withName: "WeatherDetailsInterface", context: context)
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
    
    @IBAction func shortTermWeather1() {
        showShortTermForecastForIndex(index: 0)
    }
    
    @IBAction func shortTermWeather2() {
        showShortTermForecastForIndex(index: dataSource.shortTermWeather.count/2)
    }
    
    @IBAction func shortTermWeather3() {
        showShortTermForecastForIndex(index: dataSource.shortTermWeather.count-1)
    }
    
    // Modal Pages for weather details interface
    func showShortTermForecastForIndex(index: Int) {
        presentController(withNamesAndContexts: [(name: "WeatherDetailsInterface", context: ["dataSource": dataSource, "shortTermForecastIndex": 0, "active": index == 0]) as! (name: String, context: AnyObject),
                                                 (name: "WeatherDetailsInterface", context: ["dataSource": dataSource, "shortTermForecastIndex": dataSource.shortTermWeather.count/2, "active": index == dataSource.shortTermWeather.count/2]) as! (name: String, context: AnyObject),
                                                 (name: "WeatherDetailsInterface", context: ["dataSource": dataSource, "shortTermForecastIndex": dataSource.shortTermWeather.count-1, "active": index == dataSource.shortTermWeather.count-1]) as! (name: String, context: AnyObject)
        ])
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
