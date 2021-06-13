import Foundation
//API key: f3bf15e9069d7ccfb7cb55f6afef3228
//https://openweathermap.org/current

protocol VremeaDelegate {
    func didUpdateWeather(_ vremea: Vremea, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct Vremea {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=cf66c92ab1cee20dd18979bc0634791c&units=metric"
    
    var delegate: VremeaDelegate?
    
    func fetchWeather(cityName: String) {
            let urlString = "\(weatherURL)&q=\(cityName)"
            performRequest(with: urlString)
        }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url){ (data, response, error) in
                if error != nil {
                    print("Eroare la URL handler,\(error!).")
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            task.resume()
        }
        
    }
    
    func parseJSON(_ vremeaData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(VremeaData.self, from: vremeaData)
            
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            print(String(format: "%@%@", "Cerul in Bucuresti: ", weather.conditionName))
            return weather
            
            
        } catch {
            print("Eroare la decodarea JSON-ului, \(error)")
            delegate?.didFailWithError(error: error)
            return nil }
    }
    
}
