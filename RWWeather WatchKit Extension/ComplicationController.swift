//
//  ComplicationController.swift
//  RWWeather WatchKit Extension
//
//  Created by Anmol Raibhandare on 11/13/20.
//  Copyright © 2020 Razewre LLC. All rights reserved.
//

import Foundation
import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        handler(nil)
    }
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {

        if complication.family == .utilitarianSmall {
        let template = CLKComplicationTemplateUtilitarianSmallFlat()

        template.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "Sunny")!)
        template.textProvider = CLKSimpleTextProvider(text: "30°")

        handler(template)
      }

    }

}


