import 'package:flutter/material.dart';
import 'exchange_rate_helpers.dart'; // Import exchange_rate_helpers.dart


class MyApp extends StatelessWidget {
  final List<dynamic> allExchangeRates = []; // Define or fetch your exchange rate data here

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
          '${calculateHighestRate(exchangeRates)}', // Use calculateHighestRate from exchange_rate_helpers.dart
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text(
          'Lowest USD Middle Rate:',
          style: TextStyle(fontSize: 20),
        ),
        Text(
          '${calculateLowestRate(exchangeRates)}', // Use calculateLowestRate from exchange_rate_helpers.dart
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text(
          'Average USD Middle Rate:',
          style: TextStyle(fontSize: 20),
        ),
        Text(
          '${calculateAverageRate(exchangeRates)}', // Use calculateAverageRate from exchange_rate_helpers.dart
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
