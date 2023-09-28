//
//  Config.swift
//  PanGalacticMealLogger
//
//  Created by Tobias Ritzau on 2023-09-28.
//

import Foundation

let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

let dbUrlString =
    "http://www7.slv.se/apilivsmedel/LivsmedelService.svc/Livsmedel/Naringsvarde/20230613"
