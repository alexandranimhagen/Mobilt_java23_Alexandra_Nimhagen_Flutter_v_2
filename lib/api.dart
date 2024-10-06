import 'dart:convert';
import 'weather.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;

class WeatherApi {
  final String baseUrl = "http://api.weatherapi.com/v1/current.json";

  Future<ApiResponse> getCurrentWeather(String location) async {
    String apiUrl = "$baseUrl?key=$apiKey&q=$location&lang=sv";  // Språkinställning till svenska
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var decodedData = utf8.decode(response.bodyBytes);
        ApiResponse apiResponse = ApiResponse.fromJson(jsonDecode(decodedData));

        // Kontrollera om location och country är null och mappa till Sverige om landet är Suède
        if (apiResponse.location != null && apiResponse.location!.country != null) {
          apiResponse.location!.country = _mapCountryName(apiResponse.location!.country!);
        }

        return apiResponse;
      } else {
        throw Exception("Det gick inte att ladda");
      }
    } catch (e) {
      throw Exception("Det gick inte att ladda");
    }
  }

  // Funktion för att mappa franska landsnamn till svenska (Sverige)
  String _mapCountryName(String country) {
    if (country == "Suède") {
      return "Sverige";
    }

    return country;
  }
}
