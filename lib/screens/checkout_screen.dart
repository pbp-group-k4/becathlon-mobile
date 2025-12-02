import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import 'order_list_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  String _selectedCountry = 'Indonesia';
  String _selectedPaymentMethod = 'CREDIT_CARD';

  final List<String> _countries = [
    'Indonesia',
    'Malaysia',
    'Singapore',
    'Thailand',
    'Philippines'
  ];

  final Map<String, String> _paymentMethods = {
    'CREDIT_CARD': 'Credit Card',
    'BANK_TRANSFER': 'Bank Transfer',
    'E_WALLET': 'E-Wallet',
    'COD': 'Cash on Delivery',
  };

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final request = context.read<CookieRequest>();
    
    try {
      final response = await request.postJson(
        ApiConstants.checkoutEndpoint,
        jsonEncode({
          'full_name': _fullNameController.text,
          'phone_number': _phoneController.text,
          'address_line1': _address1Controller.text,
          'address_line2': _address2Controller.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'postal_code': _postalCodeController.text,
          'country': _selectedCountry,
          'payment_method': _selectedPaymentMethod,
        }),
      );

      if (!mounted) return;

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to Order List and remove all previous routes (Cart, Checkout)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OrderListScreen()),
          (route) => route.isFirst,
        );
      } else {
        String errorMessage = response['message'] ?? 'Checkout failed';
        if (response['errors'] != null) {
          final errors = response['errors'] as Map;
          errorMessage += '\n${errors.values.join('\n')}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Full Name
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your name';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Phone Number
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter phone number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Address Line 1
            TextFormField(
              controller: _address1Controller,
              decoration: const InputDecoration(
                labelText: 'Address Line 1',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter address';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Address Line 2
            TextFormField(
              controller: _address2Controller,
              decoration: const InputDecoration(
                labelText: 'Address Line 2 (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.apartment),
              ),
            ),
            const SizedBox(height: 16),
            
            // City & State
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State/Province',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Postal Code & Country
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Postal Code',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                    ),
                    items: _countries.map((String country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCountry = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Payment Methods
            ..._paymentMethods.entries.map((entry) => RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _selectedPaymentMethod,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                }
              },
              activeColor: Theme.of(context).primaryColor,
              contentPadding: EdgeInsets.zero,
            )),
            
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
