import 'package:flutter/material.dart';
import 'package:payment_portfolio/pages/scanning_page.dart';
import 'package:payment_portfolio/pages/payment_result_page.dart';

class Amount extends StatefulWidget {
  final String paymentType;

  const Amount({super.key, required this.paymentType});

  @override
  State<Amount> createState() => _AmountState();
}

class _AmountState extends State<Amount> {
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.paymentType} - Enter Amount'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter amount for ${widget.paymentType}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Handle proceed action, e.g., navigate to next page or process payment
                final amount = _amountController.text;
                if (amount.isNotEmpty) {
                  // For now, just show a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Processing $amount for ${widget.paymentType}')),
                  );
                }

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Scanning()));
              },
              child: const Text('Proceed'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
