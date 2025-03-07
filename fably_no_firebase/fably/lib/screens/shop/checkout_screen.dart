import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';  // Import dotenv
import '../auth/login.dart';
import '../home/home.dart';
import '../../utils/requests.dart';
import '../../utils/prefs.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expirationController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  String selectedPaymentMethod = "Card";

  bool processingCheckout = false;

  @override
  void initState(dynamic dotenv) {
    super.initState();
    // Initialize Stripe with publishable key from .env
    Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
  }

  void _showMessage(String message) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> submitOrder() async {
    if (processingCheckout) {
      return;
    }
    setState(() {
      processingCheckout = true;
    });
    _showMessage("Processing...");

    try {
      // Request payment intent from your Flask backend
      final response = await http.post(
        Uri.parse('http://your-backend-url/create-payment-intent'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"amount": 1000}),  // Amount in cents
      );

      final paymentIntentData = jsonDecode(response.body);

      // Initialize Stripe PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['clientSecret'],
          merchantDisplayName: 'Fably',
        ),
      );

      // Present the PaymentSheet to the user
      await Stripe.instance.presentPaymentSheet();
      _showMessage("Payment successful!");

      // Save order details to MongoDB after successful payment
      await http.post(
        Uri.parse('http://your-backend-url/save-order'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text,
          "name": nameController.text,
          "amount": 1000,
          "payment_method": "Card",
          "status": "Paid"
        }),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );

    } catch (e) {
      _showMessage("Payment failed: $e");
    }

    setState(() {
      processingCheckout = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Card(
                color: Colors.black.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 2) {
                      setState(() {
                        _currentStep += 1;
                      });
                    } else {
                      submitOrder();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep -= 1;
                      });
                    } else {
                      Navigator.of(context).pop(); // Navigate back if on first step
                    }
                  },
                  steps: [
                    Step(
                      title: _stepTitle("Payment Method"),
                      content: _paymentMethodSelector(),
                    ),
                    Step(
                      title: _stepTitle("Card Details"),
                      content: Column(
                        children: [
                          _buildTextField(cardNumberController, "Card Number", r'^[0-9]{16}\$', "Enter a valid 16-digit card number"),
                          _buildTextField(expirationController, "Expiration (MM/YY)", r'^(0[1-9]|1[0-2])/[0-9]{2}\$', "Enter a valid expiration date (MM/YY)"),
                          _buildTextField(cvvController, "CVV", r'^[0-9]{3,4}\$', "Enter a valid CVV (3 or 4 digits)"),
                        ],
                      ),
                    ),
                    Step(
                      title: _stepTitle("Review & Confirm"),
                      content: Column(
                        children: [
                          _buildTextField(nameController, "Full Name"),
                          _buildTextField(emailController, "E-mail", r'^[^@\s]+@[^@\s]+\.[^@\s]+\$', "Enter a valid email address"),
                          _buildTextField(addressController, "Address"),
                          _buildTextField(phoneController, "Phone Number", r'^\+?[0-9]{10,15}\$', "Enter a valid phone number"),
                          _buildTextField(postalCodeController, "Postal Code", r'^[0-9]{4,10}$', "Enter a valid postal code"),
                          SizedBox(height: 20),
                          _submitButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepTitle(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _paymentMethodSelector() {
    return Column(
      children: [
        _customRadioTile("Card", Icons.credit_card, Colors.blue),
        _customRadioTile("PayPal", Icons.paypal, Colors.yellow),
        _customRadioTile("Apple Pay", Icons.apple, Colors.white),
      ],
    );
  }

  Widget _customRadioTile(String title, IconData icon, Color color) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
      leading: Icon(icon, color: color),
      trailing: Radio(
        value: title,
        groupValue: selectedPaymentMethod,
        onChanged: (value) {
          setState(() {
            selectedPaymentMethod = value.toString();
          });
        },
        activeColor: color,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [String? pattern, String? errorMessage]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.tealAccent),
          ),
        ),
        style: TextStyle(color: Colors.white),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          if (pattern != null && !RegExp(pattern).hasMatch(value)) {
            return errorMessage;
          }
          return null;
        },
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: submitOrder,
      child: Text(processingCheckout ? 'Processing...' : 'Confirm Order'),
    );
  }
}
