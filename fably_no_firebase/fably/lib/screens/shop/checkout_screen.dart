import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool processingCheckout = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> makePayment() async {
    setState(() {
      processingCheckout = true;
    });

    try {
      //  Request a PaymentIntent from the backend
      final response = await http.post(
        Uri.parse("https://your-backend.com/create-payment-intent"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"amount": 5000, "currency": "usd"}), // Adjust amount
      );

      final paymentIntentData = jsonDecode(response.body);

      if (paymentIntentData['clientSecret'] == null) {
        throw Exception("Failed to get client secret");
      }
      // Initialize Stripe's Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['clientSecret'],
          merchantDisplayName: "Your App Name",
        ),
      );

      // Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      _showMessage("Payment Successful!");
    } catch (e) {
      _showMessage("Payment failed: $e");
    } finally {
      setState(() {
        processingCheckout = false;
      });
    }
  }

