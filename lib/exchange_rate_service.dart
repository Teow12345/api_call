import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'exchange_rate_info.dart';
import 'exchange_rate_helpers.dart';

// Define a class for fetching exchange rate data from an API.
class ExchangeRateService {
  final String apiUrl;

  // Constructor that takes the API URL as a parameter.
  ExchangeRateService(this.apiUrl);

  // Method for fetching exchange rates for a given year and time zones.
  Future<List<dynamic>> fetchExchangeRatesForDateAndTimeZone(int year, List<String> timeZones) async {
    // Create an empty list to store exchange rate data.
    List<dynamic> exchangeRates = [];

    // Loop through each month (1 to 12).
    for (int month = 1; month <= 12; month++) {
      // Loop through each day (1 to 31).
      for (int day = 1; day <= 31; day++) {
        // Create a date string in the format "year/month/day".
        final String date = '$year/${_twoDigits(month)}/${_twoDigits(day)}';

        // Loop through each provided time zone.
        for (final timeZone in timeZones) {
          // Print a message indicating that data is being fetched for a specific time zone.
          //print('Fetching data for time zone: $timeZone');

          // Make an HTTP GET request to the API for the specified date and time zone.
          final response = await http.get(Uri.parse('$apiUrl/$date/$timeZone.json'));

          // Check if the HTTP response status code is 200 (OK).
          if (response.statusCode == 200) {
            // Parse the JSON response into a list of dynamic objects.
            final List<dynamic> jsonData = json.decode(response.body);

            // Filter and extract exchange rate data for USD (United States Dollar).
            final usdData = jsonData.where((item) => item['currency_code'] == 'USD').toList();

            // Add the extracted USD exchange rate data to the exchangeRates list.
            exchangeRates.addAll(usdData);
          }
        }
      }
    }

    // Return the list of exchange rates for the specified year and time zones.
    return exchangeRates;
  }

  // Helper function to format a number with two digits (e.g., 1 becomes "01").
  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    } else {
      return '0$n';
    }
  }
}

// Define the main ExchangeRateApp widget.
class ExchangeRateApp extends StatefulWidget {
  @override
  _ExchangeRateAppState createState() => _ExchangeRateAppState();
}

// Define the state for the ExchangeRateApp widget.
class _ExchangeRateAppState extends State<ExchangeRateApp> {
  // Define the API URL for exchange rate data.
  final apiUrl = 'http://172.16.7.103/bnm-exchange-rate'; // Replace with your API URL

  // Declare an instance of ExchangeRateService.
  late ExchangeRateService exchangeRateService;

  // Define the desired year and time zones for exchange rate data.
  final year = 2022; // Replace with your desired year
  final timeZones = ["0900", "1200", "1700"]; // Replace with your time zones

  // Initialize lists to store exchange rate data and error messages.
  List<dynamic> allExchangeRates = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Initialize the exchangeRateService with the API URL.
    exchangeRateService = ExchangeRateService(apiUrl);

    // Call the fetchExchangeRates method when the app is initialized.
    fetchExchangeRates();
  }

  // Function to fetch exchange rate data.
  void fetchExchangeRates() async {
    try {
      // Call the fetchExchangeRatesForDateAndTimeZone method from the exchangeRateService.
      final rates = await exchangeRateService.fetchExchangeRatesForDateAndTimeZone(year, timeZones);

      // Check if exchange rates were returned.
      if (rates.isNotEmpty) {
        setState(() {
          // Update the allExchangeRates list with the fetched rates.
          allExchangeRates = rates;
        });

        // Call the calculateRates function (custom logic) here if needed.
        calculateRates(rates);
      } else {
        setState(() {
          // Set an error message if no USD exchange rates were found.
          errorMessage = 'No USD exchange rates found for the specified year and time zones.';
        });
      }
    } catch (error) {
      setState(() {
        // Set an error message if an error occurred during data fetching.
        errorMessage = 'Error fetching exchange rates: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exchange Rate App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Exchange Rate App'),
        ),
        body: ExchangeRateInfo(allExchangeRates), // Use ExchangeRateInfo widget
      ),
    );
  }
}
