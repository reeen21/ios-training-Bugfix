//
//  WeatherError.swift
//  Example
//
//  Created by 渡部 陽太 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import Foundation

enum WeatherError: Error {
    case jsonEncodeError
    case jsonDecodeError
    case unknownError
    case invalidParameterError
}

extension WeatherError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .jsonEncodeError:
            "Encoding conversion is failure."
        case .jsonDecodeError:
            "Decoding conversion is failure"
        case .unknownError:
            "Unknown error occurred."
        case .invalidParameterError:
            "Invalid parameter error occurred."
        }
    }
}
