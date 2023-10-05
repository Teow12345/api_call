import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(ExchangeRateApp());
}


class ExchangeRateService {
  final String apiUrl;

  ExchangeRateService(this.apiUrl);

  Future<List<dynamic>> fetchExchangeRatesForDateAndTimeZone(int year, List<String> timeZones) async {
    List<dynamic> exchangeRates = [];

    for (int month = 1; month <= 12; month++) {
      for (int day = 1; day <= 31; day++) {
        final String date = '$year/${_twoDigits(month)}/${_twoDigits(day)}';

        for (final timeZone in timeZones) {
          final response = await http.get(Uri.parse('$apiUrl/$date/$timeZone.json'));

          if (response.statusCode == 200) {
            final List<dynamic> jsonData = json.decode(response.body);
            final usdData = jsonData.where((item) => item['currency_code'] == 'USD').toList();
            exchangeRates.addAll(usdData);
          }
        }
      }
    }
    print(exchangeRates);
    return exchangeRates;
  }

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    } else {
      return '0$n';
    }
  }
}

class ExchangeRateApp extends StatefulWidget {
  @override
  _ExchangeRateAppState createState() => _ExchangeRateAppState();
}

class _ExchangeRateAppState extends State<ExchangeRateApp> {
  final apiUrl = 'http://172.16.7.103/bnm-exchange-rate'; // Replace with your API URL
  late ExchangeRateService exchangeRateService; // Declare it here

  final year = 2022; // Replace with your desired year
  final timeZones = ["0900", "1200", "1700"]; // Replace with your time zones

  List<dynamic> allExchangeRates = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    exchangeRateService = ExchangeRateService(apiUrl); // Initialize it here
    fetchExchangeRates();
  }

  void fetchExchangeRates() async {
    try {
      final rates = await exchangeRateService.fetchExchangeRatesForDateAndTimeZone(year, timeZones);
      print(rates);
      if (rates.isNotEmpty) {
        setState(() {
          allExchangeRates = rates;
        });

        // Print JSON data for debugging
        for (final rate in rates) {
          // print("Currency Code: ${rate.currencyCode}");
          // print("Unit: ${rate.unit}");
          print("Rate: ${rate['rate']['middle_rate']}");
          print(""); // Add an empty line for separation
        }
      } else {
        setState(() {
          errorMessage = 'No USD exchange rates found for the specified year and time zones.';
        });
      }
    } catch (error) {
      setState(() {
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
        body: Center(
          child: errorMessage.isNotEmpty
              ? Text(errorMessage)
              : ExchangeRateInfo(allExchangeRates),
        ),
      ),
    );
  }
}

class ExchangeRateInfo extends StatelessWidget {
  final List<dynamic> exchangeRates;

  ExchangeRateInfo(this.exchangeRates);

  @override
  Widget build(BuildContext context) {
    if (exchangeRates.isEmpty) {
      return CircularProgressIndicator();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Highest USD Middle Rate:',
          style: TextStyle(fontSize: 20),
        ),
        Text(
          '${calculateHighestRate(exchangeRates)}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text(
          'Lowest USD Middle Rate:',
          style: TextStyle(fontSize: 20),
        ),
        Text(
          '${calculateLowestRate(exchangeRates)}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text(
          'Average USD Middle Rate:',
          style: TextStyle(fontSize: 20),
        ),
        Text(
          '${calculateAverageRate(exchangeRates)}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
String calculateHighestRate(List<dynamic> rates) {
  double highestRate = rates.first['rate']['middle_rate'];
  print(rates);
  for (final rate in rates) {
    final middleRate = rate['rate']['middle_rate'];
    if (middleRate > highestRate) {
      highestRate = middleRate;
    }
  }
  return highestRate.toStringAsFixed(4);
}

String calculateLowestRate(List<dynamic> rates) {
  double lowestRate = rates.first['rate']['middle_rate'];

  for (final rate in rates) {
    final middleRate = rate['rate']['middle_rate'];
    if (middleRate < lowestRate) {
      lowestRate = middleRate;
    }
  }
  return lowestRate.toStringAsFixed(4);
}

String calculateAverageRate(List<dynamic> rates) {
  double totalRate = 0.0;
  for (final rate in rates) {
    totalRate += rate['rate']['middle_rate'];
  }
  final averageRate = totalRate / rates.length;
  return averageRate.toStringAsFixed(4);
}