// lib/services/sales_service.dart
import '../models/sale_model.dart';
import '../config.dart'; // Import config to use environment-specific URLs

class SalesService {
  static final SalesService _instance = SalesService._internal();
  factory SalesService() => _instance;
  SalesService._internal();

  // Example of using config for API calls
  // final String apiUrl = Config.apiUrl;

  // Simulate API call - replace with actual API calls
  Future<List<SaleModel>> getSalesHistory() async {
    // Example API call:
    // final response = await http.get(Uri.parse('$apiUrl/sales'));
    // return (json.decode(response.body) as List)
    //     .map((data) => SaleModel.fromJson(data))
    //     .toList();

    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    // Return mock data for now
    return _getMockSalesData();
  }

  Future<SaleModel> getSaleById(String id) async {
    await Future.delayed(Duration(milliseconds: 500));
    // Implement actual logic
    return _getMockSalesData().firstWhere(
      (sale) => sale.id == id,
      orElse: () => throw Exception('Sale not found'),
    );
  }

  Future<List<SaleModel>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future.delayed(Duration(milliseconds: 800));
    // Filter mock data by date range
    return _getMockSalesData().where((sale) {
      return sale.date.isAfter(startDate) &&
          sale.date.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  // Mock data for testing
  List<SaleModel> _getMockSalesData() {
    return [
      SaleModel(
        id: '1',
        customerName: 'John Doe',
        totalAmount: 125.50,
        date: DateTime.now().subtract(Duration(days: 1)),
        status: 'Completed',
        items: [
          SaleItem(name: 'Product A', quantity: 2, price: 25.50),
          SaleItem(name: 'Product B', quantity: 1, price: 74.50),
        ],
      ),
      SaleModel(
        id: '2',
        customerName: 'Jane Smith',
        totalAmount: 89.99,
        date: DateTime.now().subtract(Duration(days: 3)),
        status: 'Completed',
        items: [
          SaleItem(name: 'Product C', quantity: 1, price: 89.99),
        ],
      ),
      SaleModel(
        id: '3',
        customerName: 'Bob Johnson',
        totalAmount: 234.50,
        date: DateTime.now().subtract(Duration(hours: 5)),
        status: 'Pending',
        items: [
          SaleItem(name: 'Product A', quantity: 3, price: 25.50),
          SaleItem(name: 'Product D', quantity: 2, price: 78.25),
        ],
      ),
    ];
  }
}
