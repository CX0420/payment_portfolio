import 'package:flutter/material.dart';

class SalesHistoryDetails extends StatefulWidget {
  const SalesHistoryDetails({super.key});

  @override
  State<SalesHistoryDetails> createState() => _SalesHistoryDetailsState();
}

class _SalesHistoryDetailsState extends State<SalesHistoryDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History Details'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Image(image: AssetImage('assets/VISA_logo.png'), height: 50),
              ListTile(
                title: Text('Transaction ID: 123456789'),
                subtitle: Text('Date: 2024-06-01'),
              ),
              ListTile(
                title: Text('Amount: \$100.00'),
                subtitle: Text('Status: Completed'),
              ),
              ListTile(
                title: Text('Payment Method: Visa'),
                subtitle: Text('Card Ending: 1234'),
              ),
              ListTile(
                title: Text('Merchant: ABC Store'),
                subtitle: Text('Location: New York, NY'),
              ),
              ListTile(
                title: Text('Notes'),
                subtitle: Text('This was a test transaction.'),
              ),
              Spacer(),
              Container(
                margin: EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        print("Void button pressed");
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Void Transaction',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    InkWell(
                      onTap: () {
                        print("Resend Receipt button pressed");
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Resend Receipt',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
