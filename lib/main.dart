import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(PaymentAdapter());
  await Hive.openBox<Sale>('sales');
  await Hive.openBox<Payment>('payments');
  runApp(SalesProApp());
}

// Adapters for Hive
class SaleAdapter extends TypeAdapter<Sale> {
  @override
  final typeId = 0;

  @override
  Sale read(BinaryReader reader) {
    return Sale(
      id: reader.readString(),
      customerName: reader.readString(),
      shopName: reader.readString(),
      phone: reader.readString(),
      address: reader.readString(),
      products: reader.readList().cast<Product>(),
      totalAmount: reader.readDouble(),
      paidAmount: reader.readDouble(),
      pendingAmount: reader.readDouble(),
      paymentMethod: reader.readString(),
      date: DateTime.parse(reader.readString()),
      status: reader.readString(),
      notes: reader.readString(),
      productImagePath: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Sale obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.customerName);
    writer.writeString(obj.shopName);
    writer.writeString(obj.phone);
    writer.writeString(obj.address);
    writer.writeList(obj.products);
    writer.writeDouble(obj.totalAmount);
    writer.writeDouble(obj.paidAmount);
    writer.writeDouble(obj.pendingAmount);
    writer.writeString(obj.paymentMethod);
    writer.writeString(obj.date.toIso8601String());
    writer.writeString(obj.status);
    writer.writeString(obj.notes);
    writer.writeString(obj.productImagePath ?? '');
  }
}

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final typeId = 1;

  @override
  Product read(BinaryReader reader) {
    return Product(
      name: reader.readString(),
      quantity: reader.readInt(),
      pricePerUnit: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer.writeString(obj.name);
    writer.writeInt(obj.quantity);
    writer.writeDouble(obj.pricePerUnit);
  }
}

class PaymentAdapter extends TypeAdapter<Payment> {
  @override
  final typeId = 2;

  @override
  Payment read(BinaryReader reader) {
    return Payment(
      saleId: reader.readString(),
      amount: reader.readDouble(),
      date: DateTime.parse(reader.readString()),
      notes: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Payment obj) {
    writer.writeString(obj.saleId);
    writer.writeDouble(obj.amount);
    writer.writeString(obj.date.toIso8601String());
    writer.writeString(obj.notes);
  }
}

// Models
class Product {
  String name;
  int quantity;
  double pricePerUnit;

  Product({
    required this.name,
    required this.quantity,
    required this.pricePerUnit,
  });
}

class Sale {
  String id;
  String customerName;
  String shopName;
  String phone;
  String address;
  List<Product> products;
  double totalAmount;
  double paidAmount;
  double pendingAmount;
  String paymentMethod;
  DateTime date;
  String status;
  String notes;
  String? productImagePath;

  Sale({
    required this.id,
    required this.customerName,
    required this.shopName,
    required this.phone,
    required this.address,
    required this.products,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.paymentMethod,
    required this.date,
    required this.status,
    required this.notes,
    this.productImagePath,
  });
}

class Payment {
  String saleId;
  double amount;
  DateTime date;
  String notes;

  Payment({
    required this.saleId,
    required this.amount,
    required this.date,
    required this.notes,
  });
}

// Language Manager and Translations (same as before)
class AppLanguage extends ChangeNotifier {
  String _currentLanguage = 'en'; // 'en' or 'hi'

  String get currentLanguage => _currentLanguage;
  bool get isHindi => _currentLanguage == 'hi';

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'en' ? 'hi' : 'en';
    notifyListeners();
  }

  void setLanguage(String lang) {
    _currentLanguage = lang;
    notifyListeners();
  }
}

class AppTranslations {
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'app_name': 'SalesPro',
      'total_sales': 'Total Sales',
      'pending': 'Pending',
      'paid': 'Paid',
      'search_hint': 'Search by customer, shop, product...',
      'all_sales': 'All Sales',
      'add_sale': 'Add Sale',
      'edit_sale': 'Edit Sale',
      'sale_details': 'Sale Details',
      'customer_info': 'Customer Information',
      'product_info': 'Product Information',
      'payment_info': 'Payment Information',
      'customer_name': 'Customer Name',
      'shop_name': 'Shop Name',
      'phone': 'Phone Number',
      'address': 'Address',
      'product_name': 'Product Name',
      'quantity': 'Quantity',
      'price_per_unit': 'Price Per Unit',
      'total_amount': 'Total Amount',
      'paid_amount': 'Paid Amount',
      'pending_amount': 'Pending Amount',
      'payment_method': 'Payment Method',
      'date': 'Date',
      'status': 'Status',
      'notes': 'Notes',
      'product_image': 'Product Image',
      'add_image': 'Add Image',
      'view_image': 'View Image',
      'change_image': 'Change Image',
      'save': 'Save',
      'cancel': 'Cancel',
      'edit': 'Edit',
      'delete': 'Delete',
      'delete_confirm': 'Delete Confirmation',
      'delete_message': 'Are you sure you want to delete this sale record?',
      'yes': 'Yes',
      'no': 'No',
      'cash': 'Cash',
      'online': 'Online',
      'cheque': 'Cheque',
      'history': 'History',
      'download_slip': 'Download Slip',
      'no_sales': 'No sales records found',
      'required_field': 'This field is required',
      'invalid_phone': 'Invalid phone number',
      'sale_added': 'Sale added successfully',
      'sale_updated': 'Sale updated successfully',
      'sale_deleted': 'Sale deleted successfully',
      'from_camera': 'From Camera',
      'from_gallery': 'From Gallery',
      'language': 'Language',
      'english': 'English',
      'hindi': 'हिंदी',
      'total_records': 'Total Records',
      'view_details': 'View Details',
      'settings': 'Settings',
      'add_product': 'Add Product',
      'add_payment': 'Add Payment',
      'payment_history': 'Payment History',
      'amount': 'Amount',
      'payment_added': 'Payment added successfully',
    },
    'hi': {
      'app_name': 'सेल्सप्रो',
      'total_sales': 'कुल बिक्री',
      'pending': 'बकाया',
      'paid': 'भुगतान',
      'search_hint': 'ग्राहक, दुकान, उत्पाद से खोजें...',
      'all_sales': 'सभी बिक्री',
      'add_sale': 'बिक्री जोड़ें',
      'edit_sale': 'बिक्री संपादित करें',
      'sale_details': 'बिक्री विवरण',
      'customer_info': 'ग्राहक जानकारी',
      'product_info': 'उत्पाद जानकारी',
      'payment_info': 'भुगतान जानकारी',
      'customer_name': 'ग्राहक का नाम',
      'shop_name': 'दुकान का नाम',
      'phone': 'फ़ोन नंबर',
      'address': 'पता',
      'product_name': 'उत्पाद का नाम',
      'quantity': 'मात्रा',
      'price_per_unit': 'प्रति यूनिट कीमत',
      'total_amount': 'कुल राशि',
      'paid_amount': 'भुगतान राशि',
      'pending_amount': 'बकाया राशि',
      'payment_method': 'भुगतान विधि',
      'date': 'तारीख',
      'status': 'स्थिति',
      'notes': 'नोट्स',
      'product_image': 'उत्पाद की तस्वीर',
      'add_image': 'तस्वीर जोड़ें',
      'view_image': 'तस्वीर देखें',
      'change_image': 'तस्वीर बदलें',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'edit': 'संपादित करें',
      'delete': 'हटाएं',
      'delete_confirm': 'हटाने की पुष्टि',
      'delete_message': 'क्या आप वाकई इस बिक्री रिकॉर्ड को हटाना चाहते हैं?',
      'yes': 'हां',
      'no': 'नहीं',
      'cash': 'नकद',
      'online': 'ऑनलाइन',
      'cheque': 'चेक',
      'history': 'इतिहास',
      'download_slip': 'रसीद डाउनलोड करें',
      'no_sales': 'कोई बिक्री रिकॉर्ड नहीं मिला',
      'required_field': 'यह फ़ील्ड आवश्यक है',
      'invalid_phone': 'अमान्य फ़ोन नंबर',
      'sale_added': 'बिक्री सफलतापूर्वक जोड़ी गई',
      'sale_updated': 'बिक्री सफलतापूर्वक अपडेट की गई',
      'sale_deleted': 'बिक्री सफलतापूर्वक हटाई गई',
      'from_camera': 'कैमरा से',
      'from_gallery': 'गैलरी से',
      'language': 'भाषा',
      'english': 'English',
      'hindi': 'हिंदी',
      'total_records': 'कुल रिकॉर्ड',
      'view_details': 'विवरण देखें',
      'settings': 'सेटिंग्स',
      'add_product': 'उत्पाद जोड़ें',
      'add_payment': 'भुगतान जोड़ें',
      'payment_history': 'भुगतान इतिहास',
      'amount': 'राशि',
      'payment_added': 'भुगतान सफलतापूर्वक जोड़ा गया',
    },
  };

  static String translate(String key, String language) {
    return _translations[language]?[key] ?? key;
  }
}

class SalesProApp extends StatefulWidget {
  @override
  _SalesProAppState createState() => _SalesProAppState();
}

class _SalesProAppState extends State<SalesProApp> {
  final AppLanguage _appLanguage = AppLanguage();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appLanguage,
      builder: (context, child) {
        return MaterialApp(
          title: AppTranslations.translate('app_name', _appLanguage.currentLanguage),
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            primaryColor: Color(0xFF2563EB),
            scaffoldBackgroundColor: Color(0xFF121212),
            appBarTheme: AppBarTheme(
              elevation: 0,
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
            ),
            cardTheme: CardTheme(
              elevation: 2,
              color: Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Color(0xFF2A2A2A),
            ),
          ),
          home: HomePage(appLanguage: _appLanguage),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final AppLanguage appLanguage;

  HomePage({required this.appLanguage});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Box<Sale> _salesBox = Hive.box<Sale>('sales');
  final Box<Payment> _paymentsBox = Hive.box<Payment>('payments');
  DateTime _currentMonth = DateTime.now();
  String searchQuery = '';
  String filterStatus = 'all';
  late ScrollController _scrollController;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    if (_salesBox.isEmpty) {
      _loadDemoData();
    }
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_showFab) setState(() => _showFab = false);
      } else {
        if (!_showFab) setState(() => _showFab = true);
      }
    });
  }

  String t(String key) {
    return AppTranslations.translate(key, widget.appLanguage.currentLanguage);
  }

  void _loadDemoData() {
    final demoSale = Sale(
      id: '1',
      customerName: 'Rajesh Kumar',
      shopName: 'Kumar General Store',
      phone: '9876543210',
      address: 'Main Market, Ludhiana',
      products: [Product(name: 'Rice Bags (25kg)', quantity: 50, pricePerUnit: 1200)],
      totalAmount: 60000,
      paidAmount: 40000,
      pendingAmount: 20000,
      paymentMethod: 'Cash',
      date: DateTime.now().subtract(Duration(days: 8)),
      status: 'pending',
      notes: 'Delivery completed',
      productImagePath: null,
    );
    _salesBox.add(demoSale);
    // Add more if needed
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
    });
  }

  List<Sale> get _monthlySales {
    return _salesBox.values.where((sale) {
      return sale.date.year == _currentMonth.year &&
          sale.date.month == _currentMonth.month &&
          (searchQuery.isEmpty ||
              sale.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
              sale.shopName.toLowerCase().contains(searchQuery.toLowerCase()) ||
              sale.products.any((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))) &&
          (filterStatus == 'all' || sale.status == filterStatus);
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<DateTime, List<Sale>> get _groupedByDay {
    final map = <DateTime, List<Sale>>{};
    for (var sale in _monthlySales) {
      final day = DateTime(sale.date.year, sale.date.month, sale.date.day);
      map.putIfAbsent(day, () => []).add(sale);
    }
    return map;
  }

  void _addSale(Sale sale) {
    _salesBox.add(sale);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('sale_added'))));
  }

  void _updateSale(Sale updatedSale) {
    final key = _salesBox.keys.firstWhere((k) => _salesBox.get(k)!.id == updatedSale.id);
    _salesBox.put(key, updatedSale);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('sale_updated'))));
  }

  void _deleteSale(String id) {
    final key = _salesBox.keys.firstWhere((k) => _salesBox.get(k)!.id == id);
    _salesBox.delete(key);
    // Delete associated payments
    _paymentsBox.values.where((p) => p.saleId == id).forEach((p) {
      final pKey = _paymentsBox.keys.firstWhere((k) => _paymentsBox.get(k) == p);
      _paymentsBox.delete(pKey);
    });
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('sale_deleted'))));
  }

  void _addPayment(Payment payment) {
    _paymentsBox.add(payment);
    // Update sale pending
    final saleKey = _salesBox.keys.firstWhere((k) => _salesBox.get(k)!.id == payment.saleId);
    final sale = _salesBox.get(saleKey)!;
    sale.paidAmount += payment.amount;
    sale.pendingAmount -= payment.amount;
    sale.status = sale.pendingAmount <= 0 ? 'paid' : 'pending';
    _salesBox.put(saleKey, sale);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('payment_added'))));
  }

  List<Payment> _getPaymentsForSale(String saleId) {
    return _paymentsBox.values.where((p) => p.saleId == saleId).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  double _getTotalSalesThisMonth() {
    return _monthlySales.fold(0, (sum, sale) => sum + sale.totalAmount);
  }

  double _getTotalPaidThisMonth() {
    return _monthlySales.fold(0, (sum, sale) => sum + sale.paidAmount);
  }

  double _getTotalPendingOverall() {
    return _salesBox.values.fold(0, (sum, sale) => sum + sale.pendingAmount);
  }

  void _showLanguageDialog() {
    // same as before
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text(t('language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Radio<String>(
                value: 'en',
                groupValue: widget.appLanguage.currentLanguage,
                onChanged: (value) {
                  widget.appLanguage.setLanguage('en');
                  Navigator.pop(context);
                },
              ),
              title: Text('English'),
              onTap: () {
                widget.appLanguage.setLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Radio<String>(
                value: 'hi',
                groupValue: widget.appLanguage.currentLanguage,
                onChanged: (value) {
                  widget.appLanguage.setLanguage('hi');
                  Navigator.pop(context);
                },
              ),
              title: Text('हिंदी'),
              onTap: () {
                widget.appLanguage.setLanguage('hi');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedByDay;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.shopping_bag, size: 28),
            SizedBox(width: 8),
            Text(t('app_name'), style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: _showLanguageDialog,
            tooltip: t('language'),
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPage(
                    sales: _salesBox.values.toList(),
                    appLanguage: widget.appLanguage,
                  ),
                ),
              );
            },
            tooltip: t('history'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      DateFormat('MMMM, yyyy').format(_currentMonth),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryItem(t('total_sales'), _getTotalSalesThisMonth(), Colors.green),
                    _buildSummaryItem(t('paid'), _getTotalPaidThisMonth(), Colors.blue),
                    _buildSummaryItem(t('pending'), _getTotalPendingOverall(), Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: t('search_hint'),
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),
                ),
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  color: Color(0xFF1E1E1E),
                  icon: Icon(Icons.filter_list, color: Colors.white),
                  onSelected: (value) => setState(() => filterStatus = value),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'all', child: Text(t('all_sales'))),
                    PopupMenuItem(value: 'pending', child: Text(t('pending'))),
                    PopupMenuItem(value: 'paid', child: Text(t('paid'))),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: grouped.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    t('no_sales'),
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final day = grouped.keys.elementAt(index);
                final daySales = grouped[day]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        DateFormat('MMM dd, EEEE').format(day),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                    ),
                    ...daySales.map((sale) => _buildSaleCard(sale)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditSalePage(
                onSave: _addSale,
                appLanguage: widget.appLanguage,
              ),
            ),
          );
        },
        icon: Icon(Icons.add),
        label: Text(t('add_sale')),
        backgroundColor: Color(0xFF2563EB),
      )
          : null,
    );
  }

  Widget _buildSummaryItem(String title, double value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return Card(
      margin: EdgeInsets.only(bottom: 12, left: 16, right: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SaleDetailPage(
                sale: sale,
                onUpdate: _updateSale,
                onDelete: _deleteSale,
                onAddPayment: _addPayment,
                payments: _getPaymentsForSale(sale.id),
                appLanguage: widget.appLanguage,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale.customerName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          sale.shopName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sale.status == 'paid' ? Colors.green[900] : Colors.orange[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sale.status == 'paid' ? t('paid') : t('pending'),
                      style: TextStyle(
                        color: sale.status == 'paid' ? Colors.green[300] : Colors.orange[300],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 24, color: Colors.grey[800]),
              Row(
                children: [
                  Icon(Icons.shopping_cart, size: 16, color: Colors.grey[400]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sale.products.map((p) => p.name).join(', '),
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('total_amount'),
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                      Text(
                        '₹${sale.totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[300],
                        ),
                      ),
                    ],
                  ),
                  if (sale.pendingAmount > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          t('pending'),
                          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                        Text(
                          '₹${sale.pendingAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[300],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                DateFormat('dd MMM yyyy').format(sale.date),
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add Edit Sale Page (updated for multiple products)
class AddEditSalePage extends StatefulWidget {
  final Sale? sale;
  final Function(Sale) onSave;
  final AppLanguage appLanguage;

  AddEditSalePage({this.sale, required this.onSave, required this.appLanguage});

  @override
  _AddEditSalePageState createState() => _AddEditSalePageState();
}

class _AddEditSalePageState extends State<AddEditSalePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerNameController;
  late TextEditingController _shopNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _paidController;
  late TextEditingController _notesController;

  List<Product> _products = [];
  String _paymentMethod = 'Cash';
  File? _productImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(text: widget.sale?.customerName ?? '');
    _shopNameController = TextEditingController(text: widget.sale?.shopName ?? '');
    _phoneController = TextEditingController(text: widget.sale?.phone ?? '');
    _addressController = TextEditingController(text: widget.sale?.address ?? '');
    _paidController = TextEditingController(text: widget.sale?.paidAmount.toString() ?? '');
    _notesController = TextEditingController(text: widget.sale?.notes ?? '');
    _paymentMethod = widget.sale?.paymentMethod ?? 'Cash';
    if (widget.sale != null) {
      _products = widget.sale!.products;
    } else {
      _products.add(Product(name: '', quantity: 0, pricePerUnit: 0));
    }
    if (widget.sale?.productImagePath != null) {
      _productImage = File(widget.sale!.productImagePath!);
    }
  }

  String t(String key) {
    return AppTranslations.translate(key, widget.appLanguage.currentLanguage);
  }

  void _addProduct() {
    setState(() {
      _products.add(Product(name: '', quantity: 0, pricePerUnit: 0));
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _productImage = File(image.path);
      });
    }
  }

  void _showImageSourceDialog() {
    // same as before
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1E1E),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text(t('from_camera')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text(t('from_gallery')),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveSale() {
    if (_formKey.currentState!.validate() && _products.every((p) => p.name.isNotEmpty && p.quantity > 0 && p.pricePerUnit > 0)) {
      double totalAmount = _products.fold(0, (sum, p) => sum + p.quantity * p.pricePerUnit);
      double paidAmount = double.tryParse(_paidController.text) ?? 0;
      double pendingAmount = totalAmount - paidAmount;

      Sale newSale = Sale(
        id: widget.sale?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: _customerNameController.text,
        shopName: _shopNameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        products: _products,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        pendingAmount: pendingAmount,
        paymentMethod: _paymentMethod,
        date: widget.sale?.date ?? DateTime.now(),
        status: pendingAmount <= 0 ? 'paid' : 'pending',
        notes: _notesController.text,
        productImagePath: _productImage?.path ?? widget.sale?.productImagePath,
      );

      widget.onSave(newSale);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sale == null ? t('add_sale') : t('edit_sale')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              t('customer_info'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[300]),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: InputDecoration(labelText: t('customer_name'), prefixIcon: Icon(Icons.person)),
              validator: (value) => value!.isEmpty ? t('required_field') : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _shopNameController,
              decoration: InputDecoration(labelText: t('shop_name'), prefixIcon: Icon(Icons.store)),
              validator: (value) => value!.isEmpty ? t('required_field') : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: t('phone'), prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? t('required_field') : (value.length != 10 ? t('invalid_phone') : null),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: t('address'), prefixIcon: Icon(Icons.location_on)),
              maxLines: 2,
              validator: (value) => value!.isEmpty ? t('required_field') : null,
            ),
            SizedBox(height: 24),
            Divider(color: Colors.grey[800]),
            SizedBox(height: 24),
            Text(
              t('product_info'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[300]),
            ),
            SizedBox(height: 16),
            ..._products.asMap().entries.map((entry) {
              int idx = entry.key;
              Product p = entry.value;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: p.name,
                          decoration: InputDecoration(labelText: '${t('product_name')} ${idx + 1}'),
                          onChanged: (v) => p.name = v,
                          validator: (v) => v!.isEmpty ? t('required_field') : null,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: _products.length > 1 ? () => _removeProduct(idx) : null,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: p.quantity.toString(),
                          decoration: InputDecoration(labelText: t('quantity')),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => p.quantity = int.tryParse(v) ?? 0,
                          validator: (v) => v!.isEmpty ? t('required_field') : null,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: p.pricePerUnit.toString(),
                          decoration: InputDecoration(labelText: t('price_per_unit')),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => p.pricePerUnit = double.tryParse(v) ?? 0,
                          validator: (v) => v!.isEmpty ? t('required_field') : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              );
            }),
            ElevatedButton.icon(
              onPressed: _addProduct,
              icon: Icon(Icons.add),
              label: Text(t('add_product')),
            ),
            SizedBox(height: 24),
            // Image section same as before
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('product_image'),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    SizedBox(height: 12),
                    if (_productImage != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_productImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () => setState(() => _productImage = null),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: Icon(Icons.add_photo_alternate),
                      label: Text(_productImage == null ? t('add_image') : t('change_image')),
                      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Divider(color: Colors.grey[800]),
            SizedBox(height: 24),
            Text(
              t('payment_info'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[300]),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _paidController,
              decoration: InputDecoration(labelText: t('paid_amount'), prefixIcon: Icon(Icons.payment)),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? t('required_field') : null,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: InputDecoration(labelText: t('payment_method'), prefixIcon: Icon(Icons.account_balance_wallet)),
              items: [
                DropdownMenuItem(value: 'Cash', child: Text(t('cash'))),
                DropdownMenuItem(value: 'Online', child: Text(t('online'))),
                DropdownMenuItem(value: 'Cheque', child: Text(t('cheque'))),
              ],
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(labelText: t('notes'), prefixIcon: Icon(Icons.note)),
              maxLines: 3,
            ),
            SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t('cancel')),
                    style: OutlinedButton.styleFrom(minimumSize: Size(0, 48)),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSale,
                    child: Text(t('save')),
                    style: ElevatedButton.styleFrom(minimumSize: Size(0, 48)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Sale Detail Page (added payment history and add payment)
class SaleDetailPage extends StatefulWidget {
  final Sale sale;
  final Function(Sale) onUpdate;
  final Function(String) onDelete;
  final Function(Payment) onAddPayment;
  final List<Payment> payments;
  final AppLanguage appLanguage;

  SaleDetailPage({
    required this.sale,
    required this.onUpdate,
    required this.onDelete,
    required this.onAddPayment,
    required this.payments,
    required this.appLanguage,
  });

  @override
  _SaleDetailPageState createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  String t(String key) {
    return AppTranslations.translate(key, widget.appLanguage.currentLanguage);
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text(t('delete_confirm')),
        content: Text(t('delete_message')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t('no'))),
          ElevatedButton(
            onPressed: () {
              widget.onDelete(widget.sale.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(t('yes')),
          ),
        ],
      ),
    );
  }

  void _showImageDialog() {
    if (widget.sale.productImagePath == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF1E1E1E),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(t('product_image')),
              leading: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Image.file(File(widget.sale.productImagePath!)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentDialog() {
    TextEditingController amountController = TextEditingController();
    TextEditingController notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text(t('add_payment')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: amountController,
              decoration: InputDecoration(labelText: t('amount')),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: notesController,
              decoration: InputDecoration(labelText: t('notes')),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () {
              double amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0 && amount <= widget.sale.pendingAmount) {
                widget.onAddPayment(Payment(
                  saleId: widget.sale.id,
                  amount: amount,
                  date: DateTime.now(),
                  notes: notesController.text,
                ));
                Navigator.pop(context);
                setState(() {}); // Refresh page
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadSlip() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Sale Slip', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Customer: ${widget.sale.customerName}'),
              pw.Text('Shop: ${widget.sale.shopName}'),
              pw.Text('Phone: ${widget.sale.phone}'),
              pw.Text('Address: ${widget.sale.address}'),
              pw.SizedBox(height: 20),
              pw.Text('Products:'),
              ...widget.sale.products.map((p) => pw.Text('${p.name} - ${p.quantity} x ₹${p.pricePerUnit}')),
              pw.SizedBox(height: 20),
              pw.Text('Total Amount: ₹${widget.sale.totalAmount}'),
              pw.Text('Paid: ₹${widget.sale.paidAmount}'),
              pw.Text('Pending: ₹${widget.sale.pendingAmount}'),
              pw.Text('Date: ${DateFormat('dd MMM yyyy').format(widget.sale.date)}'),
            ],
          );
        },
      ),
    );
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'sale_slip_${widget.sale.id}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('sale_details')),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditSalePage(
                    sale: widget.sale,
                    onSave: (updated) {
                      widget.onUpdate(updated);
                      setState(() {});
                    },
                    appLanguage: widget.appLanguage,
                  ),
                ),
              );
            },
          ),
          IconButton(icon: Icon(Icons.delete), onPressed: _showDeleteDialog),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: widget.sale.status == 'paid' ? Colors.green[900] : Colors.orange[900],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                widget.sale.status == 'paid' ? t('paid') : t('pending'),
                style: TextStyle(
                  color: widget.sale.status == 'paid' ? Colors.green[300] : Colors.orange[300],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('customer_info'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[300])),
                  SizedBox(height: 16),
                  _buildInfoRow(Icons.person, t('customer_name'), widget.sale.customerName),
                  _buildInfoRow(Icons.store, t('shop_name'), widget.sale.shopName),
                  _buildInfoRow(Icons.phone, t('phone'), widget.sale.phone),
                  _buildInfoRow(Icons.location_on, t('address'), widget.sale.address),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('product_info'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[300])),
                  SizedBox(height: 16),
                  ...widget.sale.products.map((p) => _buildInfoRow(Icons.shopping_cart, '${p.name} (${p.quantity} x ₹${p.pricePerUnit})', '')),
                  if (widget.sale.productImagePath != null) ...[
                    SizedBox(height: 16),
                    InkWell(
                      onTap: _showImageDialog,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(widget.sale.productImagePath!), height: 150, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(child: TextButton.icon(onPressed: _showImageDialog, icon: Icon(Icons.zoom_in), label: Text(t('view_image')))),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('payment_info'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[300])),
                  SizedBox(height: 16),
                  _buildAmountRow(t('total_amount'), widget.sale.totalAmount, Colors.blue),
                  _buildAmountRow(t('paid_amount'), widget.sale.paidAmount, Colors.green),
                  _buildAmountRow(t('pending_amount'), widget.sale.pendingAmount, Colors.orange),
                  Divider(height: 24, color: Colors.grey[800]),
                  _buildInfoRow(Icons.account_balance_wallet, t('payment_method'), t(widget.sale.paymentMethod.toLowerCase())),
                  _buildInfoRow(Icons.calendar_today, t('date'), DateFormat('dd MMM yyyy').format(widget.sale.date)),
                  if (widget.sale.notes.isNotEmpty) _buildInfoRow(Icons.note, t('notes'), widget.sale.notes),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          if (widget.sale.pendingAmount > 0)
            ElevatedButton.icon(
              onPressed: _showAddPaymentDialog,
              icon: Icon(Icons.add),
              label: Text(t('add_payment')),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
            ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('payment_history'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[300])),
                  SizedBox(height: 16),
                  if (widget.payments.isEmpty)
                    Text('No payments yet', style: TextStyle(color: Colors.grey[400])),
                  ...widget.payments.map((p) => ListTile(
                    title: Text('₹${p.amount} on ${DateFormat('dd MMM yyyy HH:mm').format(p.date)}'),
                    subtitle: Text(p.notes),
                  )),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _downloadSlip,
            icon: Icon(Icons.download),
            label: Text(t('download_slip')),
            style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
          Text('₹${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// History Page (same, with dark theme)
class HistoryPage extends StatelessWidget {
  final List<Sale> sales;
  final AppLanguage appLanguage;

  HistoryPage({required this.sales, required this.appLanguage});

  String t(String key) {
    return AppTranslations.translate(key, appLanguage.currentLanguage);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Sale>> groupedSales = {};
    for (var sale in sales) {
      String monthYear = DateFormat('MMMM yyyy').format(sale.date);
      groupedSales.putIfAbsent(monthYear, () => []).add(sale);
    }

    return Scaffold(
      appBar: AppBar(title: Text(t('history'))),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: groupedSales.length,
        itemBuilder: (context, index) {
          String month = groupedSales.keys.elementAt(index);
          List<Sale> monthSales = groupedSales[month]!;
          double monthTotal = monthSales.fold(0, (sum, sale) => sum + sale.totalAmount);

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(month, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text('${t('total_records')}: ${monthSales.length}'),
              trailing: Text('₹${monthTotal.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[300])),
              children: monthSales.map((sale) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: sale.status == 'paid' ? Colors.green[900] : Colors.orange[900],
                    child: Icon(Icons.shopping_bag, color: sale.status == 'paid' ? Colors.green[300] : Colors.orange[300]),
                  ),
                  title: Text(sale.customerName, style: TextStyle(color: Colors.white)),
                  subtitle: Text('${sale.products.map((p) => p.name).join(', ')} - ${DateFormat('dd MMM').format(sale.date)}', style: TextStyle(color: Colors.grey[400])),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${sale.totalAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      if (sale.pendingAmount > 0) Text('₹${sale.pendingAmount.toStringAsFixed(0)} ${t('pending')}', style: TextStyle(fontSize: 11, color: Colors.orange[300])),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
//
// void main() {
//   runApp(SalesProApp());
// }
//
// // Language Manager
// class AppLanguage extends ChangeNotifier {
//   String _currentLanguage = 'en'; // 'en' or 'hi'
//
//   String get currentLanguage => _currentLanguage;
//   bool get isHindi => _currentLanguage == 'hi';
//
//   void toggleLanguage() {
//     _currentLanguage = _currentLanguage == 'en' ? 'hi' : 'en';
//     notifyListeners();
//   }
//
//   void setLanguage(String lang) {
//     _currentLanguage = lang;
//     notifyListeners();
//   }
// }
//
// // Translations
// class AppTranslations {
//   static final Map<String, Map<String, String>> _translations = {
//     'en': {
//       'app_name': 'SalesPro',
//       'total_sales': 'Total Sales',
//       'pending': 'Pending',
//       'paid': 'Paid',
//       'search_hint': 'Search by customer, shop, product...',
//       'all_sales': 'All Sales',
//       'add_sale': 'Add Sale',
//       'edit_sale': 'Edit Sale',
//       'sale_details': 'Sale Details',
//       'customer_info': 'Customer Information',
//       'product_info': 'Product Information',
//       'payment_info': 'Payment Information',
//       'customer_name': 'Customer Name',
//       'shop_name': 'Shop Name',
//       'phone': 'Phone Number',
//       'address': 'Address',
//       'product_name': 'Product Name',
//       'quantity': 'Quantity',
//       'price_per_unit': 'Price Per Unit',
//       'total_amount': 'Total Amount',
//       'paid_amount': 'Paid Amount',
//       'pending_amount': 'Pending Amount',
//       'payment_method': 'Payment Method',
//       'date': 'Date',
//       'status': 'Status',
//       'notes': 'Notes',
//       'product_image': 'Product Image',
//       'add_image': 'Add Image',
//       'view_image': 'View Image',
//       'change_image': 'Change Image',
//       'save': 'Save',
//       'cancel': 'Cancel',
//       'edit': 'Edit',
//       'delete': 'Delete',
//       'delete_confirm': 'Delete Confirmation',
//       'delete_message': 'Are you sure you want to delete this sale record?',
//       'yes': 'Yes',
//       'no': 'No',
//       'cash': 'Cash',
//       'online': 'Online',
//       'cheque': 'Cheque',
//       'history': 'History',
//       'download_slip': 'Download Slip',
//       'no_sales': 'No sales records found',
//       'required_field': 'This field is required',
//       'invalid_phone': 'Invalid phone number',
//       'sale_added': 'Sale added successfully',
//       'sale_updated': 'Sale updated successfully',
//       'sale_deleted': 'Sale deleted successfully',
//       'from_camera': 'From Camera',
//       'from_gallery': 'From Gallery',
//       'language': 'Language',
//       'english': 'English',
//       'hindi': 'हिंदी',
//       'total_records': 'Total Records',
//       'view_details': 'View Details',
//       'settings': 'Settings',
//     },
//     'hi': {
//       'app_name': 'सेल्सप्रो',
//       'total_sales': 'कुल बिक्री',
//       'pending': 'बकाया',
//       'paid': 'भुगतान',
//       'search_hint': 'ग्राहक, दुकान, उत्पाद से खोजें...',
//       'all_sales': 'सभी बिक्री',
//       'add_sale': 'बिक्री जोड़ें',
//       'edit_sale': 'बिक्री संपादित करें',
//       'sale_details': 'बिक्री विवरण',
//       'customer_info': 'ग्राहक जानकारी',
//       'product_info': 'उत्पाद जानकारी',
//       'payment_info': 'भुगतान जानकारी',
//       'customer_name': 'ग्राहक का नाम',
//       'shop_name': 'दुकान का नाम',
//       'phone': 'फ़ोन नंबर',
//       'address': 'पता',
//       'product_name': 'उत्पाद का नाम',
//       'quantity': 'मात्रा',
//       'price_per_unit': 'प्रति यूनिट कीमत',
//       'total_amount': 'कुल राशि',
//       'paid_amount': 'भुगतान राशि',
//       'pending_amount': 'बकाया राशि',
//       'payment_method': 'भुगतान विधि',
//       'date': 'तारीख',
//       'status': 'स्थिति',
//       'notes': 'नोट्स',
//       'product_image': 'उत्पाद की तस्वीर',
//       'add_image': 'तस्वीर जोड़ें',
//       'view_image': 'तस्वीर देखें',
//       'change_image': 'तस्वीर बदलें',
//       'save': 'सहेजें',
//       'cancel': 'रद्द करें',
//       'edit': 'संपादित करें',
//       'delete': 'हटाएं',
//       'delete_confirm': 'हटाने की पुष्टि',
//       'delete_message': 'क्या आप वाकई इस बिक्री रिकॉर्ड को हटाना चाहते हैं?',
//       'yes': 'हां',
//       'no': 'नहीं',
//       'cash': 'नकद',
//       'online': 'ऑनलाइन',
//       'cheque': 'चेक',
//       'history': 'इतिहास',
//       'download_slip': 'रसीद डाउनलोड करें',
//       'no_sales': 'कोई बिक्री रिकॉर्ड नहीं मिला',
//       'required_field': 'यह फ़ील्ड आवश्यक है',
//       'invalid_phone': 'अमान्य फ़ोन नंबर',
//       'sale_added': 'बिक्री सफलतापूर्वक जोड़ी गई',
//       'sale_updated': 'बिक्री सफलतापूर्वक अपडेट की गई',
//       'sale_deleted': 'बिक्री सफलतापूर्वक हटाई गई',
//       'from_camera': 'कैमरा से',
//       'from_gallery': 'गैलरी से',
//       'language': 'भाषा',
//       'english': 'English',
//       'hindi': 'हिंदी',
//       'total_records': 'कुल रिकॉर्ड',
//       'view_details': 'विवरण देखें',
//       'settings': 'सेटिंग्स',
//     },
//   };
//
//   static String translate(String key, String language) {
//     return _translations[language]?[key] ?? key;
//   }
// }
//
// class SalesProApp extends StatefulWidget {
//   @override
//   _SalesProAppState createState() => _SalesProAppState();
// }
//
// class _SalesProAppState extends State<SalesProApp> {
//   final AppLanguage _appLanguage = AppLanguage();
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _appLanguage,
//       builder: (context, child) {
//         return MaterialApp(
//           title: AppTranslations.translate('app_name', _appLanguage.currentLanguage),
//           debugShowCheckedModeBanner: false,
//           theme: ThemeData.dark().copyWith(
//             primaryColor: Color(0xFF2563EB),
//             scaffoldBackgroundColor: Color(0xFF121212),
//             appBarTheme: AppBarTheme(
//               elevation: 0,
//               backgroundColor: Color(0xFF1E1E1E),
//               foregroundColor: Colors.white,
//             ),
//             cardTheme: CardTheme(
//               elevation: 2,
//               color: Color(0xFF1E1E1E),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             inputDecorationTheme: InputDecorationTheme(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide.none,
//               ),
//               filled: true,
//               fillColor: Color(0xFF2A2A2A),
//             ),
//           ),
//           home: HomePage(appLanguage: _appLanguage),
//         );
//       },
//     );
//   }
// }
//
// class Sale {
//   String id;
//   String customerName;
//   String shopName;
//   String phone;
//   String address;
//   String productName;
//   int quantity;
//   double pricePerUnit;
//   double totalAmount;
//   double paidAmount;
//   double pendingAmount;
//   String paymentMethod;
//   DateTime date;
//   String status;
//   String notes;
//   String? productImagePath;
//
//   Sale({
//     required this.id,
//     required this.customerName,
//     required this.shopName,
//     required this.phone,
//     required this.address,
//     required this.productName,
//     required this.quantity,
//     required this.pricePerUnit,
//     required this.totalAmount,
//     required this.paidAmount,
//     required this.pendingAmount,
//     required this.paymentMethod,
//     required this.date,
//     required this.status,
//     required this.notes,
//     this.productImagePath,
//   });
// }
//
// class HomePage extends StatefulWidget {
//   final AppLanguage appLanguage;
//
//   HomePage({required this.appLanguage});
//
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   List<Sale> sales = [];
//   List<Sale> filteredSales = [];
//   String searchQuery = '';
//   String filterStatus = 'all';
//   DateTime _currentMonth = DateTime.now();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDemoData();
//   }
//
//   String t(String key) {
//     return AppTranslations.translate(key, widget.appLanguage.currentLanguage);
//   }
//
//   void _loadDemoData() {
//     sales = [
//       Sale(
//         id: '1',
//         customerName: 'Rajesh Kumar',
//         shopName: 'Kumar General Store',
//         phone: '9876543210',
//         address: 'Main Market, Ludhiana',
//         productName: 'Rice Bags (25kg)',
//         quantity: 50,
//         pricePerUnit: 1200,
//         totalAmount: 60000,
//         paidAmount: 40000,
//         pendingAmount: 20000,
//         paymentMethod: 'Cash',
//         date: DateTime.now().subtract(Duration(days: 8)),
//         status: 'pending',
//         notes: 'Delivery completed',
//       ),
//       Sale(
//         id: '2',
//         customerName: 'Priya Sharma',
//         shopName: 'Sharma Trading Co.',
//         phone: '9876543211',
//         address: 'Mall Road, Ludhiana',
//         productName: 'Wheat Flour (10kg)',
//         quantity: 100,
//         pricePerUnit: 400,
//         totalAmount: 40000,
//         paidAmount: 40000,
//         pendingAmount: 0,
//         paymentMethod: 'Online',
//         date: DateTime.now().subtract(Duration(days: 3)),
//         status: 'paid',
//         notes: 'Paid in full',
//       ),
//       // Add more demo data if needed for testing day grouping
//       Sale(
//         id: '3',
//         customerName: 'Amit Verma',
//         shopName: 'Verma Kirana',
//         phone: '9876543212',
//         address: 'Near Park, Ludhiana',
//         productName: 'Sugar (50kg)',
//         quantity: 20,
//         pricePerUnit: 4500,
//         totalAmount: 90000,
//         paidAmount: 50000,
//         pendingAmount: 40000,
//         paymentMethod: 'Cash',
//         date: DateTime.now().subtract(Duration(days: 5)),
//         status: 'pending',
//         notes: 'Partial payment',
//       ),
//     ];
//     _filterSales();
//   }
//
//   void _changeMonth(int delta) {
//     setState(() {
//       _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
//       _filterSales(); // Re-filter for new month
//     });
//   }
//
//   List<Sale> get _monthlySales {
//     return sales.where((sale) {
//       return sale.date.year == _currentMonth.year &&
//           sale.date.month == _currentMonth.month &&
//           (searchQuery.isEmpty ||
//               sale.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
//               sale.shopName.toLowerCase().contains(searchQuery.toLowerCase()) ||
//               sale.productName.toLowerCase().contains(searchQuery.toLowerCase())) &&
//           (filterStatus == 'all' || sale.status == filterStatus);
//     }).toList()..sort((a, b) => b.date.compareTo(a.date));
//   }
//
//   Map<DateTime, List<Sale>> get _groupedByDay {
//     final map = <DateTime, List<Sale>>{};
//     for (var sale in _monthlySales) {
//       final day = DateTime(sale.date.year, sale.date.month, sale.date.day);
//       map.putIfAbsent(day, () => []).add(sale);
//     }
//     return map;
//   }
//
//   void _filterSales() {
//     setState(() {
//       filteredSales = _monthlySales;
//     });
//   }
//
//   void _addSale(Sale sale) {
//     setState(() {
//       sales.insert(0, sale);
//       _filterSales();
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(t('sale_added'))),
//     );
//   }
//
//   void _updateSale(Sale updatedSale) {
//     setState(() {
//       int index = sales.indexWhere((s) => s.id == updatedSale.id);
//       if (index != -1) {
//         sales[index] = updatedSale;
//         _filterSales();
//       }
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(t('sale_updated'))),
//     );
//   }
//
//   void _deleteSale(String id) {
//     setState(() {
//       sales.removeWhere((s) => s.id == id);
//       _filterSales();
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(t('sale_deleted'))),
//     );
//   }
//
//   double _getTotalSalesThisMonth() {
//     return _monthlySales.fold(0, (sum, sale) => sum + sale.totalAmount);
//   }
//
//   double _getTotalPaidThisMonth() {
//     return _monthlySales.fold(0, (sum, sale) => sum + sale.paidAmount);
//   }
//
//   double _getTotalPendingOverall() {
//     return sales.fold(0, (sum, sale) => sum + sale.pendingAmount);
//   }
//
//   void _showLanguageDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Color(0xFF1E1E1E),
//         title: Text(t('language')),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: Radio<String>(
//                 value: 'en',
//                 groupValue: widget.appLanguage.currentLanguage,
//                 onChanged: (value) {
//                   widget.appLanguage.setLanguage('en');
//                   Navigator.pop(context);
//                 },
//               ),
//               title: Text('English'),
//               onTap: () {
//                 widget.appLanguage.setLanguage('en');
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: Radio<String>(
//                 value: 'hi',
//                 groupValue: widget.appLanguage.currentLanguage,
//                 onChanged: (value) {
//                   widget.appLanguage.setLanguage('hi');
//                   Navigator.pop(context);
//                 },
//               ),
//               title: Text('हिंदी'),
//               onTap: () {
//                 widget.appLanguage.setLanguage('hi');
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final grouped = _groupedByDay;
//
//     return Scaffold(
//       backgroundColor: Color(0xFF121212),
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Icon(Icons.shopping_bag, size: 28),
//             SizedBox(width: 8),
//             Text(t('app_name'), style: TextStyle(fontWeight: FontWeight.bold)),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.language),
//             onPressed: _showLanguageDialog,
//             tooltip: t('language'),
//           ),
//           IconButton(
//             icon: Icon(Icons.history),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => HistoryPage(
//                     sales: sales,
//                     appLanguage: widget.appLanguage,
//                   ),
//                 ),
//               );
//             },
//             tooltip: t('history'),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Month Navigation + Summary (like MyMoney)
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.chevron_left, color: Colors.white),
//                       onPressed: () => _changeMonth(-1),
//                     ),
//                     Text(
//                       DateFormat('MMMM, yyyy').format(_currentMonth),
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.chevron_right, color: Colors.white),
//                       onPressed: () => _changeMonth(1),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildSummaryItem(t('total_sales'), _getTotalSalesThisMonth(), Colors.green),
//                     _buildSummaryItem(t('paid'), _getTotalPaidThisMonth(), Colors.blue),
//                     _buildSummaryItem(t('pending'), _getTotalPendingOverall(), Colors.orange),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // Search and Filter
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     style: TextStyle(color: Colors.white),
//                     decoration: InputDecoration(
//                       hintText: t('search_hint'),
//                       hintStyle: TextStyle(color: Colors.grey),
//                       prefixIcon: Icon(Icons.search, color: Colors.grey),
//                       contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         searchQuery = value;
//                         _filterSales();
//                       });
//                     },
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 PopupMenuButton<String>(
//                   color: Color(0xFF1E1E1E),
//                   icon: Icon(Icons.filter_list, color: Colors.white),
//                   onSelected: (value) {
//                     setState(() {
//                       filterStatus = value;
//                       _filterSales();
//                     });
//                   },
//                   itemBuilder: (context) => [
//                     PopupMenuItem(value: 'all', child: Text(t('all_sales'))),
//                     PopupMenuItem(value: 'pending', child: Text(t('pending'))),
//                     PopupMenuItem(value: 'paid', child: Text(t('paid'))),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(height: 16),
//
//           // Sales List (grouped by day)
//           Expanded(
//             child: grouped.isEmpty
//                 ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text(
//                     t('no_sales'),
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             )
//                 : ListView.builder(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               itemCount: grouped.length,
//               itemBuilder: (context, index) {
//                 final day = grouped.keys.elementAt(index);
//                 final daySales = grouped[day]!;
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
//                       child: Text(
//                         DateFormat('MMM dd, EEEE').format(day),
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
//                       ),
//                     ),
//                     ...daySales.map((sale) => _buildSaleCard(sale)).toList(),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AddEditSalePage(
//                 onSave: _addSale,
//                 appLanguage: widget.appLanguage,
//               ),
//             ),
//           );
//         },
//         icon: Icon(Icons.add),
//         label: Text(t('add_sale')),
//         backgroundColor: Color(0xFF2563EB),
//       ),
//     );
//   }
//
//   Widget _buildSummaryItem(String title, double value, Color color) {
//     return Column(
//       children: [
//         Text(
//           title,
//           style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500),
//         ),
//         SizedBox(height: 4),
//         Text(
//           '₹${value.toStringAsFixed(0)}',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSaleCard(Sale sale) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 12),
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SaleDetailPage(
//                 sale: sale,
//                 onUpdate: _updateSale,
//                 onDelete: _deleteSale,
//                 appLanguage: widget.appLanguage,
//               ),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           sale.customerName,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           sale.shopName,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[400],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: sale.status == 'paid' ? Colors.green[900] : Colors.orange[900],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       sale.status == 'paid' ? t('paid') : t('pending'),
//                       style: TextStyle(
//                         color: sale.status == 'paid' ? Colors.green[300] : Colors.orange[300],
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Divider(height: 24, color: Colors.grey[800]),
//               Row(
//                 children: [
//                   Icon(Icons.shopping_cart, size: 16, color: Colors.grey[400]),
//                   SizedBox(width: 8),
//                   Text(
//                     sale.productName,
//                     style: TextStyle(fontSize: 14, color: Colors.white70),
//                   ),
//                   SizedBox(width: 8),
//                   Text(
//                     '(${sale.quantity} ${t('quantity')})',
//                     style: TextStyle(fontSize: 14, color: Colors.grey[400]),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         t('total_amount'),
//                         style: TextStyle(fontSize: 12, color: Colors.grey[400]),
//                       ),
//                       Text(
//                         '₹${sale.totalAmount.toStringAsFixed(0)}',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue[300],
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (sale.pendingAmount > 0)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           t('pending'),
//                           style: TextStyle(fontSize: 12, color: Colors.grey[400]),
//                         ),
//                         Text(
//                           '₹${sale.pendingAmount.toStringAsFixed(0)}',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.orange[300],
//                           ),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//               SizedBox(height: 8),
//               Text(
//                 DateFormat('dd MMM yyyy').format(sale.date),
//                 style: TextStyle(fontSize: 12, color: Colors.grey[400]),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Add Edit Sale Page (updated for dark theme)
// class AddEditSalePage extends StatefulWidget {
//   final Sale? sale;
//   final Function(Sale) onSave;
//   final AppLanguage appLanguage;
//
//   AddEditSalePage({this.sale, required this.onSave, required this.appLanguage});
//
//   @override
//   _AddEditSalePageState createState() => _AddEditSalePageState();
// }
//
// class _AddEditSalePageState extends State<AddEditSalePage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _customerNameController;
//   late TextEditingController _shopNameController;
//   late TextEditingController _phoneController;
//   late TextEditingController _addressController;
//   late TextEditingController _productNameController;
//   late TextEditingController _quantityController;
//   late TextEditingController _priceController;
//   late TextEditingController _paidController;
//   late TextEditingController _notesController;
//
//   String _paymentMethod = 'Cash';
//   File? _productImage;
//   final ImagePicker _picker = ImagePicker();
//
//   @override
//   void initState() {
//     super.initState();
//     _customerNameController = TextEditingController(text: widget.sale?.customerName ?? '');
//     _shopNameController = TextEditingController(text: widget.sale?.shopName ?? '');
//     _phoneController = TextEditingController(text: widget.sale?.phone ?? '');
//     _addressController = TextEditingController(text: widget.sale?.address ?? '');
//     _productNameController = TextEditingController(text: widget.sale?.productName ?? '');
//     _quantityController = TextEditingController(text: widget.sale?.quantity.toString() ?? '');
//     _priceController = TextEditingController(text: widget.sale?.pricePerUnit.toString() ?? '');
//     _paidController = TextEditingController(text: widget.sale?.paidAmount.toString() ?? '');
//     _notesController = TextEditingController(text: widget.sale?.notes ?? '');
//     _paymentMethod = widget.sale?.paymentMethod ?? 'Cash';
//     if (widget.sale?.productImagePath != null) {
//       _productImage = File(widget.sale!.productImagePath!);
//     }
//   }
//
//   String t(String key) {
//     return AppTranslations.translate(key, widget.appLanguage.currentLanguage);
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//     final XFile? image = await _picker.pickImage(source: source);
//     if (image != null) {
//       setState(() {
//         _productImage = File(image.path);
//       });
//     }
//   }
//
//   void _showImageSourceDialog() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Color(0xFF1E1E1E),
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: Icon(Icons.camera_alt),
//               title: Text(t('from_camera')),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.camera);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.photo_library),
//               title: Text(t('from_gallery')),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.gallery);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _saveSale() {
//     if (_formKey.currentState!.validate()) {
//       int quantity = int.parse(_quantityController.text);
//       double pricePerUnit = double.parse(_priceController.text);
//       double totalAmount = quantity * pricePerUnit;
//       double paidAmount = double.parse(_paidController.text);
//       double pendingAmount = totalAmount - paidAmount;
//
//       Sale newSale = Sale(
//         id: widget.sale?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
//         customerName: _customerNameController.text,
//         shopName: _shopNameController.text,
//         phone: _phoneController.text,
//         address: _addressController.text,
//         productName: _productNameController.text,
//         quantity: quantity,
//         pricePerUnit: pricePerUnit,
//         totalAmount: totalAmount,
//         paidAmount: paidAmount,
//         pendingAmount: pendingAmount,
//         paymentMethod: _paymentMethod,
//         date: widget.sale?.date ?? DateTime.now(),
//         status: pendingAmount == 0 ? 'paid' : 'pending',
//         notes: _notesController.text,
//         productImagePath: _productImage?.path ?? widget.sale?.productImagePath,
//       );
//
//       widget.onSave(newSale);
//       Navigator.pop(context);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.sale == null ? t('add_sale') : t('edit_sale')),
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: EdgeInsets.all(16),
//           children: [
//             // Customer Information Section
//             Text(
//               t('customer_info'),
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue[300],
//               ),
//             ),
//             SizedBox(height: 16),
//             TextFormField(
//               controller: _customerNameController,
//               decoration: InputDecoration(
//                 labelText: t('customer_name'),
//                 prefixIcon: Icon(Icons.person),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return t('required_field');
//                 }
//                 return null;
//               },
//             ),
//             SizedBox(height: 16),
//             TextFormField(
//               controller: _phoneController,
//               decoration: InputDecoration(
//                 labelText: t('phone'),
//                 prefixIcon: Icon(Icons.phone),
//               ),
//               keyboardType: TextInputType.phone,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return t('required_field');
//                 }
//                 if (value.length != 10) {
//                   return t('invalid_phone');
//                 }
//                 return null;
//               },
//             ),
//             SizedBox(height: 16),
//             TextFormField(
//               controller: _addressController,
//               decoration: InputDecoration(
//                 labelText: t('address'),
//                 prefixIcon: Icon(Icons.location_on),
//               ),
//               maxLines: 2,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return t('required_field');
//                 }
//                 return null;
//               },
//             ),
//
//             SizedBox(height: 24),
//             Divider(color: Colors.grey[800]),
//             SizedBox(height: 24),
//
//             // Product Information Section
//             Text(
//               t('product_info'),
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue[300],
//               ),
//             ),
//             SizedBox(height: 16),
//             TextFormField(
//               controller: _productNameController,
//               decoration: InputDecoration(
//                 labelText: t('product_name'),
//                 prefixIcon: Icon(Icons.shopping_cart),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return t('required_field');
//                 }
//                 return null;
//               },
//             ),
//             SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: _quantityController,
//                     decoration: InputDecoration(
//                       labelText: t('quantity'),
//                       prefixIcon: Icon(Icons.numbers),
//                     ),
//                     keyboardType: TextInputType.number,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return t('required_field');
//                       }
//                       return null;
//                     },
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: TextFormField(
//                     controller: _priceController,
//                     decoration: InputDecoration(
//                       labelText: t('price_per_unit'),
//                       prefixIcon: Icon(Icons.currency_rupee),
//                     ),
//                     keyboardType: TextInputType.number,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return t('required_field');
//                       }
//                       return null;
//                     },
//                   ),
//                 ),
//               ],
//             ),
//
//             SizedBox(height: 16),
//
//             // Product Image
//             Card(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       t('product_image'),
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                     SizedBox(height: 12),
//                     if (_productImage != null)
//                       Stack(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: Image.file(_productImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
//                           ),
//                           Positioned(
//                             top: 8,
//                             right: 8,
//                             child: IconButton(
//                               icon: Icon(Icons.close, color: Colors.white),
//                               onPressed: () {
//                                 setState(() {
//                                   _productImage = null;
//                                 });
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     SizedBox(height: 12),
//                     ElevatedButton.icon(
//                       onPressed: _showImageSourceDialog,
//                       icon: Icon(Icons.add_photo_alternate),
//                       label: Text(_productImage == null
//                           ? t('add_image')
//                           : t('change_image')),
//                       style: ElevatedButton.styleFrom(
//                         minimumSize: Size(double.infinity, 48),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 24),
//             Divider(color: Colors.grey[800]),
//             SizedBox(height: 24),
//
//             // Payment Information Section
//             Text(
//               t('payment_info'),
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue[300],
//               ),
//             ),
//             SizedBox(height: 16),
//             TextFormField(
//               controller: _paidController,
//               decoration: InputDecoration(
//                 labelText: t('paid_amount'),
//                 prefixIcon: Icon(Icons.payment),
//               ),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return t('required_field');
//                 }
//                 return null;
//               },
//             ),
//             SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: _paymentMethod,
//               decoration: InputDecoration(
//                 labelText: t('payment_method'),
//                 prefixIcon: Icon(Icons.account_balance_wallet),
//               ),
//               items: [
//                 DropdownMenuItem(value: 'Cash', child: Text(t('cash'))),
//                 DropdownMenuItem(value: 'Online', child: Text(t('online'))),
//                 DropdownMenuItem(value: 'Cheque', child: Text(t('cheque'))),
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   _paymentMethod = value!;
//                 });
//               },
//             ),
//             SizedBox(height: 16),
//             TextFormField(
//               controller: _notesController,
//               decoration: InputDecoration(
//                 labelText: t('notes'),
//                 prefixIcon: Icon(Icons.note),
//               ),
//               maxLines: 3,
//             ),
//
//             SizedBox(height: 32),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text(t('cancel')),
//                     style: OutlinedButton.styleFrom(
//                       minimumSize: Size(0, 48),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _saveSale,
//                     child: Text(t('save')),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: Size(0, 48),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Sale Detail Page (dark theme updated)
// class SaleDetailPage extends StatelessWidget {
//   final Sale sale;
//   final Function(Sale) onUpdate;
//   final Function(String) onDelete;
//   final AppLanguage appLanguage;
//
//   SaleDetailPage({
//     required this.sale,
//     required this.onUpdate,
//     required this.onDelete,
//     required this.appLanguage,
//   });
//
//   String t(String key) {
//     return AppTranslations.translate(key, appLanguage.currentLanguage);
//   }
//
//   void _showDeleteDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Color(0xFF1E1E1E),
//         title: Text(t('delete_confirm')),
//         content: Text(t('delete_message')),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(t('no')),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               onDelete(sale.id);
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: Text(t('yes')),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showImageDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Color(0xFF1E1E1E),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             AppBar(
//               title: Text(t('product_image')),
//               leading: IconButton(
//                 icon: Icon(Icons.close),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(16),
//               child: Image.file(File(sale.productImagePath!)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t('sale_details')),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.edit),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => AddEditSalePage(
//                     sale: sale,
//                     onSave: onUpdate,
//                     appLanguage: appLanguage,
//                   ),
//                 ),
//               );
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: () => _showDeleteDialog(context),
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(16),
//         children: [
//           // Status Badge
//           Center(
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               decoration: BoxDecoration(
//                 color: sale.status == 'paid' ? Colors.green[900] : Colors.orange[900],
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: Text(
//                 sale.status == 'paid' ? t('paid') : t('pending'),
//                 style: TextStyle(
//                   color: sale.status == 'paid' ? Colors.green[300] : Colors.orange[300],
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//
//           SizedBox(height: 24),
//
//           // Customer Information
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     t('customer_info'),
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue[300],
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   _buildInfoRow(Icons.person, t('customer_name'), sale.customerName),
//                   _buildInfoRow(Icons.store, t('shop_name'), sale.shopName),
//                   _buildInfoRow(Icons.phone, t('phone'), sale.phone),
//                   _buildInfoRow(Icons.location_on, t('address'), sale.address),
//                 ],
//               ),
//             ),
//           ),
//
//           SizedBox(height: 16),
//
//           // Product Information
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     t('product_info'),
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue[300],
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   _buildInfoRow(Icons.shopping_cart, t('product_name'), sale.productName),
//                   _buildInfoRow(Icons.numbers, t('quantity'), sale.quantity.toString()),
//                   _buildInfoRow(Icons.currency_rupee, t('price_per_unit'), '₹${sale.pricePerUnit.toStringAsFixed(2)}'),
//
//                   if (sale.productImagePath != null) ...[
//                     SizedBox(height: 16),
//                     InkWell(
//                       onTap: () => _showImageDialog(context),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.file(
//                           File(sale.productImagePath!),
//                           height: 150,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Center(
//                       child: TextButton.icon(
//                         onPressed: () => _showImageDialog(context),
//                         icon: Icon(Icons.zoom_in),
//                         label: Text(t('view_image')),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//
//           SizedBox(height: 16),
//
//           // Payment Information
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     t('payment_info'),
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue[300],
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   _buildAmountRow(t('total_amount'), sale.totalAmount, Colors.blue),
//                   _buildAmountRow(t('paid_amount'), sale.paidAmount, Colors.green),
//                   _buildAmountRow(t('pending_amount'), sale.pendingAmount, Colors.orange),
//                   Divider(height: 24, color: Colors.grey[800]),
//                   _buildInfoRow(Icons.account_balance_wallet, t('payment_method'), t(sale.paymentMethod.toLowerCase())),
//                   _buildInfoRow(Icons.calendar_today, t('date'), DateFormat('dd MMM yyyy').format(sale.date)),
//                   if (sale.notes.isNotEmpty)
//                     _buildInfoRow(Icons.note, t('notes'), sale.notes),
//                 ],
//               ),
//             ),
//           ),
//
//           SizedBox(height: 24),
//
//           ElevatedButton.icon(
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('${t('download_slip')} - Feature coming soon!')),
//               );
//             },
//             icon: Icon(Icons.download),
//             label: Text(t('download_slip')),
//             style: ElevatedButton.styleFrom(
//               minimumSize: Size(double.infinity, 48),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 20, color: Colors.grey[400]),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[400],
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAmountRow(String label, double amount, Color color) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[400],
//             ),
//           ),
//           Text(
//             '₹${amount.toStringAsFixed(2)}',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // History Page (kept as is, minor dark adjustments)
// class HistoryPage extends StatelessWidget {
//   final List<Sale> sales;
//   final AppLanguage appLanguage;
//
//   HistoryPage({required this.sales, required this.appLanguage});
//
//   String t(String key) {
//     return AppTranslations.translate(key, appLanguage.currentLanguage);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Map<String, List<Sale>> groupedSales = {};
//
//     for (var sale in sales) {
//       String monthYear = DateFormat('MMMM yyyy').format(sale.date);
//       if (!groupedSales.containsKey(monthYear)) {
//         groupedSales[monthYear] = [];
//       }
//       groupedSales[monthYear]!.add(sale);
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t('history')),
//       ),
//       body: ListView.builder(
//         padding: EdgeInsets.all(16),
//         itemCount: groupedSales.length,
//         itemBuilder: (context, index) {
//           String month = groupedSales.keys.elementAt(index);
//           List<Sale> monthSales = groupedSales[month]!;
//           double monthTotal = monthSales.fold(0, (sum, sale) => sum + sale.totalAmount);
//
//           return Card(
//             margin: EdgeInsets.only(bottom: 16),
//             child: ExpansionTile(
//               title: Text(
//                 month,
//                 style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//               ),
//               subtitle: Text('${t('total_records')}: ${monthSales.length}'),
//               trailing: Text(
//                 '₹${monthTotal.toStringAsFixed(0)}',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: Colors.blue[300],
//                 ),
//               ),
//               children: monthSales.map((sale) {
//                 return ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: sale.status == 'paid' ? Colors.green[900] : Colors.orange[900],
//                     child: Icon(
//                       Icons.shopping_bag,
//                       color: sale.status == 'paid' ? Colors.green[300] : Colors.orange[300],
//                     ),
//                   ),
//                   title: Text(sale.customerName, style: TextStyle(color: Colors.white)),
//                   subtitle: Text('${sale.productName} - ${DateFormat('dd MMM').format(sale.date)}', style: TextStyle(color: Colors.grey[400])),
//                   trailing: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         '₹${sale.totalAmount.toStringAsFixed(0)}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       if (sale.pendingAmount > 0)
//                         Text(
//                           '₹${sale.pendingAmount.toStringAsFixed(0)} ${t('pending')}',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.orange[300],
//                           ),
//                         ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }