// lib/screens/sales_history_screen.dart
import 'package:flutter/material.dart';
import 'package:payment_portfolio/pages/sales_history_details.dart';

class SalesHistory extends StatelessWidget {
  const SalesHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SalesHistoryDetails(),
                ),
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text('${index + 1}'),
              ),
              title: Text('Sale #${index + 1}'),
              subtitle: Text(
                  'Date: ${DateTime.now().subtract(Duration(days: index)).toLocal().toString().split(' ')[0]}'),
              trailing: Text(
                '\$${(index + 1) * 10}.99',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Settlement button pressed");
          _showSettlementDialog(context);
        },
        tooltip: 'Settlement',
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.payment,
          size: 40,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showSettlementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settlement'),
          content: const Text('Are you sure you want to perform settlement?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 执行结算逻辑
                print("Settlement confirmed");

                // 可以显示一个SnackBar提示
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settlement completed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
