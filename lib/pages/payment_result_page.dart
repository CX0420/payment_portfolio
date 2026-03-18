import 'package:flutter/material.dart';
import 'package:payment_portfolio/pages/home_page.dart';
import 'package:payment_portfolio/pages/main_page.dart';

class PaymentResult extends StatelessWidget {
  final bool success;
  final Map<String, dynamic>? cardData;

  const PaymentResult({super.key, required this.success, this.cardData});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Result'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage(
                      success ? 'assets/Success.png' : 'assets/Failed.png'),
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),
                Text(
                  success
                      ? 'Your payment was successful!'
                      : 'Your payment failed. Please try again.',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                if (success && cardData != null) ...[
                  const SizedBox(height: 20),
                  _buildCardInfo(),
                ],
                if (success) ...[
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () {
                          print("Send Receipt button pressed");
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          child: Text(
                            'Send Receipt',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () {
                        print("Make Another Payment button pressed");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainPage(child: HomePage()),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Text(
                          'Make Another Payment',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardInfo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Card Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (cardData!['pan'] != null) ...[
                _buildInfoRow('Card Number', _maskCardNumber(cardData!['pan'])),
              ],
              if (cardData!['cardholderName'] != null) ...[
                _buildInfoRow('Cardholder Name', cardData!['cardholderName']),
              ],
              if (cardData!['expiryDate'] != null) ...[
                _buildInfoRow('Expiry Date', cardData!['expiryDate']),
              ],
              if (cardData!['application'] != null) ...[
                _buildInfoRow(
                    'Card Type', _getCardType(cardData!['application'])),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _maskCardNumber(String pan) {
    if (pan.length < 4) return pan;
    final lastFour = pan.substring(pan.length - 4);
    final masked = '**** **** **** $lastFour';
    return masked;
  }

  String _getCardType(String aid) {
    switch (aid) {
      case 'A0000000031010':
        return 'Visa';
      case 'A0000000041010':
        return 'Mastercard';
      case 'A00000002501':
        return 'American Express';
      case 'A0000003241010':
        return 'Discover';
      default:
        return 'Unknown';
    }
  }
}
