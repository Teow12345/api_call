import 'exchange_rate_service.dart';

// Function to calculate the highest exchange rate from a list of rates.
String calculateHighestRate(List<dynamic> rates) {
  // Initialize the highestRate with the rate from the first item in the list.
  double highestRate = rates.first['rate']['middle_rate'];

  // Loop through the rates to find the highest rate.
  for (final rate in rates) {
    final middleRate = rate['rate']['middle_rate'];

    // Update the highestRate if a higher rate is found.
    if (middleRate > highestRate) {
      highestRate = middleRate;
    }
  }

  // Return the highest rate as a string with 4 decimal places.
  return highestRate.toStringAsFixed(4);
}

// Function to calculate the lowest exchange rate from a list of rates.
String calculateLowestRate(List<dynamic> rates) {
  // Initialize the lowestRate with the rate from the first item in the list.
  double lowestRate = rates.first['rate']['middle_rate'];

  // Loop through the rates to find the lowest rate.
  for (final rate in rates) {
    final middleRate = rate['rate']['middle_rate'];

    // Update the lowestRate if a lower rate is found.
    if (middleRate < lowestRate) {
      lowestRate = middleRate;
    }
  }

  // Return the lowest rate as a string with 4 decimal places.
  return lowestRate.toStringAsFixed(4);
}

// Function to calculate the average exchange rate from a list of rates.
String calculateAverageRate(List<dynamic> rates) {
  double totalRate = 0.0;

  // Loop through the rates to calculate the total rate.
  for (final rate in rates) {
    totalRate += rate['rate']['middle_rate'];
  }

  // Calculate the average rate.
  final averageRate = totalRate / rates.length;

  // Return the average rate as a string with 4 decimal places.
  return averageRate.toStringAsFixed(4);
}

// Main function to calculate various rates and display information.
void calculateRates(List<dynamic> rates) {
  // Create maps to store highest, lowest, total rates, and rate counts for each currency.
  Map<String, double?> highestRates = {};
  Map<String, double?> lowestRates = {};
  Map<String, double?> totalRates = {};
  Map<String, int?> rateCounts = {};

  // Loop through the rates to perform calculations and gather data.
  for (final rate in rates) {
    final currencyCode = rate['currency_code'];
    final middleRate = rate['rate']['middle_rate'];
    final date = rate['rate']['date'];

    // Calculate highest rate
    if (!highestRates.containsKey(currencyCode) || middleRate > (highestRates[currencyCode] ?? double.negativeInfinity)) {
      highestRates[currencyCode] = middleRate;
    }

    // Calculate lowest rate
    if (!lowestRates.containsKey(currencyCode) || middleRate < (lowestRates[currencyCode] ?? double.infinity)) {
      lowestRates[currencyCode] = middleRate;
    }

    // Calculate total rate
    totalRates[currencyCode] = (totalRates[currencyCode] ?? 0.0) + middleRate;

    // Increment rate count
    rateCounts[currencyCode] = (rateCounts[currencyCode] ?? 0) + 1;

    // Display session, currency, and middle rate information.
    print('Session: $date, Currency: $currencyCode, Middle Rate: $middleRate');
  }

  // Calculate and display the highest, lowest, and average rates for each currency.
  for (final currencyCode in highestRates.keys) {
    final highestRate = highestRates[currencyCode] ?? 0.0;
    final lowestRate = lowestRates[currencyCode] ?? 0.0;
    final rateCount = rateCounts[currencyCode] ?? 0;
    final averageRate = rateCount > 0 ? (totalRates[currencyCode] ?? 0.0) / rateCount : 0.0;

    print('Currency: $currencyCode');
    print('Session with Highest Rate: ${getSessionWithRate(rates, currencyCode, highestRate)}');
    print('Session with Lowest Rate: ${getSessionWithRate(rates, currencyCode, lowestRate)}');
    print('Average Rate: ${averageRate.toStringAsFixed(4)}');
    print('------------------------');
  }
}

// Function to find and return a session with a specific rate for a given currency.
String getSessionWithRate(List<dynamic> rates, String currencyCode, double rateToFind) {
  for (final rate in rates) {
    final middleRate = rate['rate']['middle_rate'];

    // Check if the currency code matches and the middle rate is equal to the rate to find.
    if (rate['currency_code'] == currencyCode && middleRate == rateToFind) {
      final date = rate['rate']['date'];
      return 'Session: $date, Rate: $rateToFind';
    }
  }

  // Return "Not found" if the rate is not found for the given currency.
  return 'Not found';
}