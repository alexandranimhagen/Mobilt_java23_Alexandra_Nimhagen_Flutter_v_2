import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importera SharedPreferences
import 'api.dart';
import 'weather.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const HomePage({super.key, required this.onThemeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiResponse? response;
  bool inProgress = false;
  final TextEditingController _controller = TextEditingController();
  String savedLocation = ""; // Variabel för sparad plats
  String message = "Ange en plats för att få väderdata"; // Standardmeddelande

  // Variabler för RangeSlider (temperaturintervall)
  double _minTemp = 0.0;
  double _maxTemp = 40.0;
  RangeValues _currentRangeValues = const RangeValues(10, 30); // Standardintervall

  @override
  void initState() {
    super.initState();
    _loadSavedLocation(); // Ladda den sparade platsen när appen startas
  }

  // Hämta sparad plats från SharedPreferences
  _loadSavedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedLocation = prefs.getString('location') ?? "";  // Hämta plats, om ingen finns, använd tom sträng
      _controller.text = savedLocation;  // Visa den sparade platsen i TextFormField
    });
  }

  // Spara plats till SharedPreferences
  _saveLocation(String location) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('location', location);  // Spara platsen
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Weather App'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // TextFormField för att mata in en plats
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Ange en plats',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Statisk text som visas mellan TextFormField och Sök-knappen
              const Text(
                "Ange en plats för att få väderdata",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 10),

              // ElevatedButton för att söka efter väderdata och spara platsen
              ElevatedButton(
                onPressed: () {
                  _getWeatherData(_controller.text);
                  _saveLocation(_controller.text);  // Spara platsen när användaren söker
                },
                child: const Text('Sök'),
              ),
              const SizedBox(height: 10),

              // RangeSlider för att välja temperaturintervall
              Text(
                  "Välj temperaturintervall: ${_currentRangeValues.start.round()}°C - ${_currentRangeValues.end.round()}°C"),
              RangeSlider(
                values: _currentRangeValues,
                min: _minTemp,
                max: _maxTemp,
                divisions: 8, // Delningar i sliden
                labels: RangeLabels(
                  _currentRangeValues.start.round().toString(),
                  _currentRangeValues.end.round().toString(),
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _currentRangeValues = values;
                    _applyTemperatureFilter(); // Anropa automatiskt filter-logik
                  });
                },
              ),

              const SizedBox(height: 20),

              // TextButton för att rensa textfältet och återställa slidern
              TextButton(
                onPressed: () {
                  _controller.clear();  // Rensa textfältet
                  setState(() {
                    _currentRangeValues = const RangeValues(10, 30);  // Återställ slidern
                    message = "Ange en plats för att få väderdata";  // Återställ meddelandet
                  });
                },
                child: const Text('Rensa'),
              ),
              const SizedBox(height: 20),

              if (inProgress)
                const CircularProgressIndicator()
              else
                Expanded(
                  child: SingleChildScrollView(child: _buildWeatherWidget()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherWidget() {
    if (response == null) {
      return Text(message);  // Visa meddelandet om inget svar finns
    } else {
      // Kontrollera om temperaturen ligger inom det valda intervallet
      double currentTemp = response?.current?.tempC ?? 0.0;

      if (currentTemp >= _currentRangeValues.start && currentTemp <= _currentRangeValues.end) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 50,
                ),
                Text(
                  response?.location?.name ?? "",
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    response?.location?.country ?? "",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${response?.current?.tempC.toString() ?? ""}°C",
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  (response?.current?.condition?.text.toString() ?? ""),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Center(
              child: SizedBox(
                height: 200,
                child: Image.network(
                  "https:${response?.current?.condition?.icon}"
                      .replaceAll("64x64", "128x128"),
                  scale: 0.7,
                ),
              ),
            ),
            Card(
              elevation: 4,
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _dataAndTitleWidget("Luftfuktighet",
                          response?.current?.humidity?.toString() ?? ""),
                      _dataAndTitleWidget("Vindhastighet",
                          "${response?.current?.windKph?.toString() ?? ""} km/h"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _dataAndTitleWidget(
                          "UV-index", response?.current?.uv?.toString() ?? ""),
                      _dataAndTitleWidget("Nederbörd",
                          "${response?.current?.precipMm?.toString() ?? ""} mm"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _dataAndTitleWidget("Lokal tid",
                          response?.location?.localtime?.split(" ").last ?? ""),
                      _dataAndTitleWidget("Datum",
                          response?.location?.localtime?.split(" ").first ?? ""),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      } else {
        // Visa meddelande om temperaturen ligger utanför intervallet
        return const Text("Inget resultat att visa för valt temperaturintervall.");
      }
    }
  }

  Widget _dataAndTitleWidget(String title, String data) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Text(
            data,
            style: const TextStyle(
              fontSize: 27,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Funktion för att tillämpa det valda temperaturintervallet
  _applyTemperatureFilter() {
    print("Temperaturintervallet är ${_currentRangeValues.start}°C till ${_currentRangeValues.end}°C");
    // Här kan du lägga till logik för att filtrera väderdata baserat på det valda intervallet
  }

  _getWeatherData(String location) async {
    setState(() {
      inProgress = true;
    });

    try {
      response = await WeatherApi().getCurrentWeather(location);
    } catch (e) {
      setState(() {
        message = "Det gick inte att hämta väderdata";
        response = null;
      });
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }
}
