import Foundation

struct Request: Decodable {
    let area: String
    let date: Date
}

struct Response: Encodable {
    let weather: String
    let maxTemp: Int
    let minTemp: Int
    let date: Date
}

enum Weather: String, CaseIterable {
    case sunny
    case cloudy
    case rainy
}

public enum YumemiWeatherError: Swift.Error {
    case invalidParameterError
    case jsonDecodeError
    case unknownError
}

final public class YumemiWeather {
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter
    }()
    
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }()
    
    
    /// 引数の値でResponse構造体を作成する。引数がnilの場合はランダムに値を作成する。
    /// - Parameters:
    ///   - weather: 天気を表すenum
    ///   - maxTemp: 最高気温
    ///   - minTemp: 最低気温
    ///   - date: 日付
    /// - Returns: Response構造体
    private static func makeRandomResponse(weather: Weather? = nil, maxTemp: Int? = nil, minTemp: Int? = nil, date: Date? = nil) -> Response {
        let weather = weather ?? Weather.allCases.randomElement()!
        let maxTemp = maxTemp ?? Int.random(in: 10...40)
        let minTemp = minTemp ?? Int.random(in: -40..<maxTemp)
        let date = date ?? Date()
        
        return Response(
            weather: weather.rawValue,
            maxTemp: maxTemp,
            minTemp: minTemp,
            date: date
        )
    }
    
    /// 擬似 天気予報API 同期版
    /// - Parameter jsonString: 地域と日付を含むJson文字列
    /// example:
    /// {
    ///   "area": "tokyo",
    ///   "date": "2020-04-01T12:00:00+09:00"
    /// }
    /// - Throws: YumemiWeatherError パラメータが正常でもランダムにエラーが発生する
    /// - Returns: Json文字列
    /// example: {"max_temp":25,"date":"2020-04-01T12:00:00+09:00","min_temp":7,"weather":"cloudy"}
    public static func fetchWeather(_ jsonString: String) throws -> String {
        guard let requestData = jsonString.data(using: .utf8) else {
            throw YumemiWeatherError.invalidParameterError
        }
        
        let request: Request
        do {
            request = try decoder.decode(Request.self, from: requestData)
        }
        catch {
            throw YumemiWeatherError.jsonDecodeError
        }
        
        let response = makeRandomResponse(date: request.date)
        let responseData = try encoder.encode(response)
        
        if Int.random(in: 0...4) == 4 {
            throw YumemiWeatherError.unknownError
        }
        
        return String(data: responseData, encoding: .utf8)!
    }

    /// 擬似 天気予報API 非同期版
    /// - Parameters:
    ///   - jsonString: 地域と日付を含むJson文字列
    /// example:
    /// {
    ///   "area": "tokyo",
    ///   "date": "2020-04-01T12:00:00+09:00"
    /// }
    ///   - completion: 完了コールバック
    public static func fetchWeather(_ jsonString: String, completion: @escaping (Result<String, YumemiWeatherError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            do {
                let response = try fetchWeather(jsonString)
                completion(Result.success(response))
            }
            catch let error where error is YumemiWeatherError {
                completion(Result.failure(error as! YumemiWeatherError))
            }
            catch {
                fatalError()
            }
        }
    }
}
