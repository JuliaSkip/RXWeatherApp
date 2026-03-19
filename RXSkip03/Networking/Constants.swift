//
//  Constants.swift
//  RXSkip03
//
//  Created by Скіп Юлія Ярославівна on 09.02.2026.
//
struct Constants {
    static let API_KEY: String = "API_KEY"
    static let BASE_URL: String = "https://api.openweathermap.org"
    static let GeocodingMockResponce: String = """
        [{
            "name": "Ternopil",
            "local_names": {
                "et": "Ternopil",
                "eo": "Ternopilo",
                "uk": "Тернопіль",
                "it": "Ternopil'",
                "ml": "ടെർനോപിൽ",
                "io": "Ternopil",
                "en": "Ternopil",
                "es": "Ternópil",
                "ko": "테르노필",
                "ro": "Ternopil",
                "lt": "Ternopilis",
                "pl": "Tarnopol",
                "sr": "Тернопољ",
                "he": "טרנופול",
                "de": "Ternopil",
                "fr": "Ternopil",
                "hr": "Ternopilj",
                "hu": "Ternopil",
                "nl": "Ternopil"
            },
            "lat": 49.553516,
            "lon": 25.594767,
            "country": "UA",
            "state": "Ternopil Oblast"
        }]
        """
    static let WeatherMockResponce: String = """
        {
          "list": [
                  {
                      "dt": 1771243200,
                      "main": {
                          "temp": -5.9,
                          "feels_like": -9.49,
                          "temp_min": -5.9,
                          "temp_max": -5.9,
                          "pressure": 1009,
                          "sea_level": 1009,
                          "grnd_level": 966,
                          "humidity": 83,
                          "temp_kf": 0
                      },
                      "weather": [
                          {
                              "id": 804,
                              "main": "Clouds",
                              "description": "хмарно",
                              "icon": "04d"
                          }
                      ],
                      "clouds": {
                          "all": 93
                      },
                      "wind": {
                          "speed": 2.11,
                          "deg": 329,
                          "gust": 2.39
                      },
                      "visibility": 10000,
                      "pop": 0,
                      "sys": {
                          "pod": "d"
                      },
                      "dt_txt": "2026-02-16 12:00:00"
                  },
                  {
                      "dt": 1771254000,
                      "main": {
                          "temp": -6.11,
                          "feels_like": -9.02,
                          "temp_min": -6.52,
                          "temp_max": -6.11,
                          "pressure": 1009,
                          "sea_level": 1009,
                          "grnd_level": 965,
                          "humidity": 86,
                          "temp_kf": 0.41
                      },
                      "weather": [
                          {
                              "id": 804,
                              "main": "Clouds",
                              "description": "хмарно",
                              "icon": "04d"
                          }
                      ],
                      "clouds": {
                          "all": 95
                      },
                      "wind": {
                          "speed": 1.66,
                          "deg": 55,
                          "gust": 2.1
                      },
                      "visibility": 10000,
                      "pop": 0,
                      "sys": {
                          "pod": "d"
                      },
                      "dt_txt": "2026-02-16 15:00:00"
                  }
        ],
        "city": {
                "id": 691650,
                "name": "Ternopil",
                "coord": {
                    "lat": 49.5535,
                    "lon": 25.5948
                },
                "country": "UA",
                "population": 235676,
                "timezone": 7200,
                "sunrise": 1771219568,
                "sunset": 1771256254
            }
        }
        """
}
