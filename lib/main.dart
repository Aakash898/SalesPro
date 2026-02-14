import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:async';
// ──────────────────────────────────────────────
// REMOVED: part 'main.g.dart';
// Using manual adapters instead of code generation
// ──────────────────────────────────────────────

// ──────────────────────────────────────────────
// Models (REMOVED annotations)
// ──────────────────────────────────────────────
class AppSettings {
  bool isDark;
  String language;

  AppSettings({
    this.isDark = true,
    this.language = 'en',
  });
}

class Product {
  String name;
  int quantity;
  double pricePerUnit;

  Product({required this.name, required this.quantity, required this.pricePerUnit});
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

// ──────────────────────────────────────────────
// Hive Adapters (All Manual)
// ──────────────────────────────────────────────
class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final typeId = 3;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      isDark: fields[0] as bool? ?? true,
      language: fields[1] as String? ?? 'en',
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(2)  // number of fields
      ..writeByte(0)
      ..write(obj.isDark)
      ..writeByte(1)
      ..write(obj.language);
  }
}

class SaleAdapter extends TypeAdapter<Sale> {
  @override
  final typeId = 0;

  @override
  Sale read(BinaryReader reader) {
    final id = reader.readString();
    final customerName = reader.readString();
    final shopName = reader.readString();
    final phone = reader.readString();
    final address = reader.readString();
    final products = reader.readList().cast<Product>();
    final totalAmount = reader.readDouble();
    final paidAmount = reader.readDouble();
    final pendingAmount = reader.readDouble();
    final paymentMethod = reader.readString();
    final date = DateTime.parse(reader.readString());
    final status = reader.readString();
    final notes = reader.readString();
    final productImagePath = reader.readString();

    return Sale(
      id: id,
      customerName: customerName,
      shopName: shopName,
      phone: phone,
      address: address,
      products: products,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      pendingAmount: pendingAmount,
      paymentMethod: paymentMethod,
      date: date,
      status: status,
      notes: notes,
      productImagePath: productImagePath.isEmpty ? null : productImagePath,
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

// ──────────────────────────────────────────────
// Main - FIXED initialization
// ──────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);

  // Register adapters
  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(PaymentAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  // Open boxes
  await Hive.openBox<Sale>('sales');
  await Hive.openBox<Payment>('payments');
  await Hive.openBox<AppSettings>('settings');  // ADDED: Open settings box

  runApp(const SalesProApp());
}

// ──────────────────────────────────────────────
// App Manager (Language + Theme)
// ──────────────────────────────────────────────
class AppManager extends ChangeNotifier {
  late Box<AppSettings> _settingsBox;

  bool _isDark = true;
  String _currentLanguage = 'en';

  bool get isDark => _isDark;
  String get currentLanguage => _currentLanguage;

  FutureOr<void> init() async {
    _settingsBox = Hive.box<AppSettings>('settings');  // FIXED: Use already opened box

    final saved = _settingsBox.get('app');
    if (saved != null) {
      _isDark = saved.isDark;
      _currentLanguage = saved.language;
    }
    notifyListeners();
  }

  FutureOr<void> setLanguage(String lang) async {
    _currentLanguage = lang;
    await _save();
    notifyListeners();
  }

  FutureOr<void> toggleTheme() async {
    _isDark = !_isDark;
    await _save();
    notifyListeners();
  }

  FutureOr<void> _save() async {
    await _settingsBox.put(
      'app',
      AppSettings(
        isDark: _isDark,
        language: _currentLanguage,
      ),
    );
  }
}

// Translations
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
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'select_date': 'Select Date',
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
      'theme': 'थीम',
      'light': 'लाइट',
      'dark': 'डार्क',
      'select_date': 'तारीख चुनें',
    },
  };

  static String translate(String key, String language) {
    return _translations[language]?[key] ?? key;
  }
}

// ──────────────────────────────────────────────
// Main App Entry - FIXED initialization
// ──────────────────────────────────────────────
class SalesProApp extends StatelessWidget {
  const SalesProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SalesProAppContent();
  }
}

class SalesProAppContent extends StatefulWidget {
  const SalesProAppContent({super.key});

  @override
  State<SalesProAppContent> createState() => _SalesProAppContentState();
}

class _SalesProAppContentState extends State<SalesProAppContent> {
  final AppManager _appManager = AppManager();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  FutureOr<void> _initializeApp() async {
    await _appManager.init();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _appManager,
      builder: (context, _) {
        return MaterialApp(
          title: AppTranslations.translate('app_name', _appManager.currentLanguage),
          debugShowCheckedModeBanner: false,
          theme: _appManager.isDark
              ? ThemeData.dark().copyWith(
            primaryColor: const Color(0xFF2563EB),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: CardTheme(
              color: Color(0xFF1E1E1E),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
              : ThemeData.light().copyWith(
            primaryColor: const Color(0xFF2563EB),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: CardTheme(
              color: const Color(0xFF1E1E1E),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          home: HomePage(appManager: _appManager),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────
// Home Page (Main Screen)
// ──────────────────────────────────────────────
class HomePage extends StatefulWidget {
  final AppManager appManager;

  const HomePage({super.key, required this.appManager});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Box<Sale> _salesBox = Hive.box<Sale>('sales');
  final Box<Payment> _paymentsBox = Hive.box<Payment>('payments');
  DateTime _currentMonth = DateTime.now();
  String searchQuery = '';
  String filterStatus = 'all';

  late ScrollController _scrollController;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isFabVisible) setState(() => _isFabVisible = false);
      }
      if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_isFabVisible) setState(() => _isFabVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String t(String key) => AppTranslations.translate(key, widget.appManager.currentLanguage);

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + delta,
      );
    });
  }

  List<Sale> get filteredMonthlySales {
    return _salesBox.values.where((sale) {
      final matchesMonth = sale.date.year == _currentMonth.year && sale.date.month == _currentMonth.month;
      final matchesSearch = searchQuery.isEmpty ||
          sale.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          sale.shopName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          sale.products.any((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()));
      final matchesFilter = filterStatus == 'all' || sale.status == filterStatus;

      return matchesMonth && matchesSearch && matchesFilter;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<DateTime, List<Sale>> get groupedByDay {
    final map = <DateTime, List<Sale>>{};
    for (var sale in filteredMonthlySales) {
      final day = DateTime(sale.date.year, sale.date.month, sale.date.day);
      map.putIfAbsent(day, () => []).add(sale);
    }
    return map;
  }

  double get totalSalesThisMonth => filteredMonthlySales.fold(0.0, (sum, s) => sum + s.totalAmount);
  double get totalPaidThisMonth => filteredMonthlySales.fold(0.0, (sum, s) => sum + s.paidAmount);
  double get totalPendingOverall => _salesBox.values.fold(0.0, (sum, s) => sum + s.pendingAmount);

  @override
  Widget build(BuildContext context) {
    final grouped = groupedByDay;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shopping_bag_outlined),
            const SizedBox(width: 8),
            Text(t('app_name')),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(widget.appManager.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.appManager.toggleTheme,
            tooltip: t('theme'),
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(t('language')),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('English'),
                          leading: Radio<String>(
                            value: 'en',
                            groupValue: widget.appManager.currentLanguage,
                            onChanged: (v) {
                              widget.appManager.setLanguage('en');
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('हिंदी'),
                          leading: Radio<String>(
                            value: 'hi',
                            groupValue: widget.appManager.currentLanguage,
                            onChanged: (v) {
                              widget.appManager.setLanguage('hi');
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryPage(
                    sales: _salesBox.values.toList(),
                    appManager: widget.appManager,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Navigation + Summary
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_currentMonth),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryCard(t('total_sales'), totalSalesThisMonth, Colors.green),
                    _buildSummaryCard(t('paid'), totalPaidThisMonth, Colors.blue),
                    _buildSummaryCard(t('pending'), totalPendingOverall, Colors.orange),
                  ],
                ),
              ],
            ),
          ),

          // Search + Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: t('search_hint'),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
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

          const SizedBox(height: 8),

          // Sales List
          Expanded(
            child: grouped.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(t('no_sales'), style: const TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final dayKey = grouped.keys.elementAt(index);
                final daySales = grouped[dayKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        DateFormat('dd MMM, EEEE').format(dayKey),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      floatingActionButton: _isFabVisible
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditSalePage(
                onSave: (sale) {
                  _salesBox.add(sale);
                  setState(() {});
                },
                appManager: widget.appManager,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(t('add_sale')),
      )
          : null,
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 6),
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SaleDetailPage(
                sale: sale,
                onUpdate: (updated) {
                  final key = _salesBox.keys.firstWhere((k) => _salesBox.get(k)!.id == updated.id);
                  _salesBox.put(key, updated);
                  setState(() {});
                },
                onDelete: (id) {
                  final key = _salesBox.keys.firstWhere((k) => _salesBox.get(k)!.id == id);
                  _salesBox.delete(key);
                  setState(() {});
                },
                onAddPayment: (payment) {
                  _paymentsBox.add(payment);
                  final saleKey = _salesBox.keys.firstWhere((k) => _salesBox.get(k)!.id == payment.saleId);
                  final s = _salesBox.get(saleKey)!;
                  s.paidAmount += payment.amount;
                  s.pendingAmount -= payment.amount;
                  s.status = s.pendingAmount <= 0 ? 'paid' : 'pending';
                  _salesBox.put(saleKey, s);
                  setState(() {});
                },
                appManager: widget.appManager,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.customerName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sale.shopName,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sale.status == 'paid' ? Colors.green[700] : Colors.orange[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sale.status == 'paid' ? t('paid') : t('pending'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                sale.products.map((p) => '${p.name} (${p.quantity})').join(', '),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('total_amount'), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(
                        '₹${sale.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  if (sale.pendingAmount > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(t('pending'), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text(
                          '₹${sale.pendingAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('dd MMM yyyy').format(sale.date),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Add / Edit Sale Page (with Date Picker)
// ──────────────────────────────────────────────
class AddEditSalePage extends StatefulWidget {
  final Sale? sale;
  final Function(Sale) onSave;
  final AppManager appManager;

  const AddEditSalePage({
    super.key,
    this.sale,
    required this.onSave,
    required this.appManager,
  });

  @override
  State<AddEditSalePage> createState() => _AddEditSalePageState();
}

class _AddEditSalePageState extends State<AddEditSalePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _customerNameCtrl;
  late TextEditingController _shopNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _paidCtrl;
  late TextEditingController _notesCtrl;

  List<Product> _products = [];
  String _paymentMethod = 'Cash';
  File? _imageFile;
  DateTime _selectedDate = DateTime.now();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _customerNameCtrl = TextEditingController(text: widget.sale?.customerName);
    _shopNameCtrl = TextEditingController(text: widget.sale?.shopName);
    _phoneCtrl = TextEditingController(text: widget.sale?.phone);
    _addressCtrl = TextEditingController(text: widget.sale?.address);
    _paidCtrl = TextEditingController(text: widget.sale?.paidAmount.toStringAsFixed(0) ?? '0');
    _notesCtrl = TextEditingController(text: widget.sale?.notes);

    _paymentMethod = widget.sale?.paymentMethod ?? 'Cash';
    _products = widget.sale?.products ?? [];
    _selectedDate = widget.sale?.date ?? DateTime.now();

    if (widget.sale?.productImagePath != null && widget.sale!.productImagePath!.isNotEmpty) {
      _imageFile = File(widget.sale!.productImagePath!);
    }

    // Add at least one product field if empty
    if (_products.isEmpty) {
      _products.add(Product(name: '', quantity: 0, pricePerUnit: 0));
    }
  }

  String t(String key) => AppTranslations.translate(key, widget.appManager.currentLanguage);

  FutureOr<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  FutureOr<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _imageFile = File(file.path);
      });
    }
  }

  void _addProduct() {
    setState(() {
      _products.add(Product(name: '', quantity: 0, pricePerUnit: 0));
    });
  }

  void _removeProduct(int index) {
    if (_products.length > 1) {
      setState(() {
        _products.removeAt(index);
      });
    }
  }

  void _saveSale() {
    if (!_formKey.currentState!.validate()) return;

    double total = 0;
    for (var p in _products) {
      total += p.quantity * p.pricePerUnit;
    }

    double paid = double.tryParse(_paidCtrl.text) ?? 0;
    double pending = total - paid;

    final sale = Sale(
      id: widget.sale?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: _customerNameCtrl.text.trim(),
      shopName: _shopNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      products: _products.where((p) => p.name.trim().isNotEmpty).toList(),
      totalAmount: total,
      paidAmount: paid,
      pendingAmount: pending,
      paymentMethod: _paymentMethod,
      date: _selectedDate,
      status: pending <= 0 ? 'paid' : 'pending',
      notes: _notesCtrl.text.trim(),
      productImagePath: _imageFile?.path,
    );

    widget.onSave(sale);
    Navigator.pop(context);
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
          padding: const EdgeInsets.all(16),
          children: [
            // Date Picker
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(t('select_date')),
                subtitle: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _pickDate,
              ),
            ),

            const SizedBox(height: 16),

            // Customer Info
            Text(t('customer_info'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: _customerNameCtrl,
              decoration: InputDecoration(labelText: t('customer_name')),
              validator: (v) => v!.trim().isEmpty ? t('required_field') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _shopNameCtrl,
              decoration: InputDecoration(labelText: t('shop_name')),
              validator: (v) => v!.trim().isEmpty ? t('required_field') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              decoration: InputDecoration(labelText: t('phone')),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.length != 10 ? t('invalid_phone') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressCtrl,
              decoration: InputDecoration(labelText: t('address')),
              maxLines: 2,
            ),

            const Divider(height: 32),

            // Products Section
            Text(t('product_info'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...List.generate(_products.length, (index) {
              final p = _products[index];
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: p.name,
                          decoration: InputDecoration(labelText: '${t('product_name')} ${index + 1}'),
                          onChanged: (v) => p.name = v,
                          validator: (v) => v!.trim().isEmpty ? t('required_field') : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: p.quantity > 0 ? p.quantity.toString() : '',
                          decoration: InputDecoration(labelText: t('quantity')),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => p.quantity = int.tryParse(v) ?? 0,
                          validator: (v) => v!.isEmpty ? t('required_field') : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: p.pricePerUnit > 0 ? p.pricePerUnit.toStringAsFixed(0) : '',
                          decoration: InputDecoration(labelText: t('price_per_unit')),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => p.pricePerUnit = double.tryParse(v) ?? 0,
                          validator: (v) => v!.isEmpty ? t('required_field') : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _removeProduct(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),

            OutlinedButton.icon(
              onPressed: _addProduct,
              icon: const Icon(Icons.add),
              label: Text(t('add_product')),
            ),

            const Divider(height: 32),

            // Image Picker
            if (_imageFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_imageFile!, height: 180, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_imageFile == null ? t('add_image') : t('change_image')),
            ),

            const Divider(height: 32),

            // Payment Info
            Text(t('payment_info'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: _paidCtrl,
              decoration: InputDecoration(labelText: t('paid_amount')),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: InputDecoration(labelText: t('payment_method')),
              items: ['Cash', 'Online', 'Cheque']
                  .map((method) => DropdownMenuItem(
                value: method,
                child: Text(t(method.toLowerCase())),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: InputDecoration(labelText: t('notes')),
              maxLines: 3,
            ),

            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t('cancel')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSale,
                    child: Text(t('save')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Sale Detail Page
// ──────────────────────────────────────────────
class SaleDetailPage extends StatefulWidget {
  final Sale sale;
  final Function(Sale) onUpdate;
  final Function(String) onDelete;
  final Function(Payment) onAddPayment;
  final AppManager appManager;

  const SaleDetailPage({
    super.key,
    required this.sale,
    required this.onUpdate,
    required this.onDelete,
    required this.onAddPayment,
    required this.appManager,
  });

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  String t(String key) => AppTranslations.translate(key, widget.appManager.currentLanguage);

  final Box<Payment> _paymentBox = Hive.box<Payment>('payments');

  List<Payment> get payments {
    return _paymentBox.values.where((p) => p.saleId == widget.sale.id).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _showAddPaymentDialog() {
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t('add_payment')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountCtrl,
                decoration: InputDecoration(labelText: t('amount')),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: notesCtrl,
                decoration: InputDecoration(labelText: t('notes')),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (amount > 0 && amount <= widget.sale.pendingAmount) {
                  widget.onAddPayment(Payment(
                    saleId: widget.sale.id,
                    amount: amount,
                    date: DateTime.now(),
                    notes: notesCtrl.text.trim(),
                  ));
                  Navigator.pop(context);
                }
              },
              child: Text(t('save')),
            ),
          ],
        );
      },
    );
  }

  FutureOr<void> _generateAndShareSlip() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Sale Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Customer: ${widget.sale.customerName}'),
              pw.Text('Shop: ${widget.sale.shopName}'),
              pw.Text('Phone: ${widget.sale.phone}'),
              pw.Text('Address: ${widget.sale.address}'),
              pw.SizedBox(height: 20),
              pw.Text('Products:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ...widget.sale.products.map(
                    (p) => pw.Text('${p.name} × ${p.quantity} @ ₹${p.pricePerUnit.toStringAsFixed(0)}'),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Total Amount: ₹${widget.sale.totalAmount.toStringAsFixed(0)}'),
              pw.Text('Paid Amount: ₹${widget.sale.paidAmount.toStringAsFixed(0)}'),
              pw.Text('Pending Amount: ₹${widget.sale.pendingAmount.toStringAsFixed(0)}'),
              pw.SizedBox(height: 20),
              pw.Text('Payment History:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ...payments.map(
                    (p) => pw.Text(
                  '${DateFormat('dd MMM yyyy | HH:mm').format(p.date)} : ₹${p.amount.toStringAsFixed(0)} ${p.notes.isNotEmpty ? '(${p.notes})' : ''}',
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text('Generated on: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}'),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'sale_${widget.sale.id}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('sale_details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditSalePage(
                    sale: widget.sale,
                    onSave: widget.onUpdate,
                    appManager: widget.appManager,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(t('delete_confirm')),
                  content: Text(t('delete_message')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(t('no')),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onDelete(widget.sale.id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(t('yes'), style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Center(
              child: Chip(
                label: Text(
                  widget.sale.status == 'paid' ? t('paid') : t('pending'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: widget.sale.status == 'paid' ? Colors.green : Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              ),
            ),

            const SizedBox(height: 24),

            // Customer Info
            _buildSectionCard(
              title: t('customer_info'),
              children: [
                _buildRow(Icons.person, t('customer_name'), widget.sale.customerName),
                _buildRow(Icons.store, t('shop_name'), widget.sale.shopName),
                _buildRow(Icons.phone, t('phone'), widget.sale.phone),
                _buildRow(Icons.location_on, t('address'), widget.sale.address),
              ],
            ),

            const SizedBox(height: 16),

            // Products
            _buildSectionCard(
              title: t('product_info'),
              children: [
                ...widget.sale.products.map(
                      (p) => _buildRow(
                    Icons.shopping_cart,
                    p.name,
                    '${p.quantity} × ₹${p.pricePerUnit.toStringAsFixed(0)}',
                  ),
                ),
                if (widget.sale.productImagePath != null && widget.sale.productImagePath!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(widget.sale.productImagePath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Payment Info
            _buildSectionCard(
              title: t('payment_info'),
              children: [
                _buildAmountRow(t('total_amount'), widget.sale.totalAmount, Colors.blue),
                _buildAmountRow(t('paid_amount'), widget.sale.paidAmount, Colors.green),
                _buildAmountRow(t('pending_amount'), widget.sale.pendingAmount, Colors.orange),
                const Divider(),
                _buildRow(Icons.calendar_today, t('date'), DateFormat('dd MMM yyyy').format(widget.sale.date)),
                if (widget.sale.notes.isNotEmpty) _buildRow(Icons.note, t('notes'), widget.sale.notes),
              ],
            ),

            const SizedBox(height: 24),

            // Payment History
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t('payment_history'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (widget.sale.pendingAmount > 0)
                          OutlinedButton.icon(
                            onPressed: _showAddPaymentDialog,
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(t('add_payment')),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<Box<Payment>>(
                      valueListenable: _paymentBox.listenable(),
                      builder: (context, box, _) {
                        final payments = _getPaymentsForSale(widget.sale.id);
                        if (payments.isEmpty) {
                          return const Text('No payments recorded yet.', style: TextStyle(color: Colors.grey));
                        }
                        return Column(
                          children: payments.map((p) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                '${DateFormat('dd MMM yyyy | HH:mm').format(p.date)} : ₹${p.amount.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: p.notes.isNotEmpty ? Text(p.notes) : null,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Download Slip
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateAndShareSlip,
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(t('download_slip')),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  List<Payment> _getPaymentsForSale(String saleId) {
    return _paymentBox.values.where((p) => p.saleId == saleId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}

// ──────────────────────────────────────────────
// History Page
// ──────────────────────────────────────────────
class HistoryPage extends StatelessWidget {
  final List<Sale> sales;
  final AppManager appManager;

  const HistoryPage({super.key, required this.sales, required this.appManager});

  String t(String key) => AppTranslations.translate(key, appManager.currentLanguage);

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Sale>>{};

    for (var sale in sales) {
      final key = DateFormat('MMMM yyyy').format(sale.date);
      grouped.putIfAbsent(key, () => []).add(sale);
    }

    return Scaffold(
      appBar: AppBar(title: Text(t('history'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final month = grouped.keys.elementAt(index);
          final monthSales = grouped[month]!;
          final total = monthSales.fold<double>(0, (sum, s) => sum + s.totalAmount);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text(month, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${t('total_records')}: ${monthSales.length}'),
              trailing: Text(
                '₹${total.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
              ),
              children: monthSales.map((sale) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: sale.status == 'paid' ? Colors.green[100] : Colors.orange[100],
                    child: Icon(
                      Icons.receipt,
                      color: sale.status == 'paid' ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(sale.customerName),
                  subtitle: Text(
                    '${sale.products.map((p) => p.name).join(', ')} • ${DateFormat('dd MMM').format(sale.date)}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${sale.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (sale.pendingAmount > 0)
                        Text(
                          '₹${sale.pendingAmount.toStringAsFixed(0)} ${t('pending')}',
                          style: TextStyle(color: Colors.orange[800], fontSize: 12),
                        ),
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
// import 'package:flutter/rendering.dart';
// import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart' as path_provider;
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
//
// part 'main.g.dart'; // ← You need to run:  flutter pub run build_runner build
//
// @HiveType(typeId: 3)
// class AppSettings {
//   @HiveField(0)
//   bool isDark;
//
//   @HiveField(1)
//   String language;
//
//   AppSettings({
//     this.isDark = true,
//     this.language = 'en',
//   });
// }
//
// class AppSettingsAdapter extends TypeAdapter<AppSettings> {
//   @override
//   final typeId = 3;
//
//   @override
//   AppSettings read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return AppSettings(
//       isDark: fields[0] as bool? ?? true,
//       language: fields[1] as String? ?? 'en',
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, AppSettings obj) {
//     writer
//       ..writeByte(2)
//       ..writeByte(0)
//       ..write(obj.isDark)
//       ..writeByte(1)
//       ..write(obj.language);
//   }
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final appDir = await path_provider.getApplicationDocumentsDirectory();
//   await Hive.initFlutter(appDir.path);
//   Hive.registerAdapter(SaleAdapter());
//   Hive.registerAdapter(ProductAdapter());
//   Hive.registerAdapter(PaymentAdapter());
//   Hive.registerAdapter(AppSettingsAdapter());   // ← NEW
//   await Hive.openBox<Sale>('sales');
//   await Hive.openBox<Payment>('payments');
//   runApp(const SalesProApp());
// }
//
// // ──────────────────────────────────────────────
// // Hive Adapters
// // ──────────────────────────────────────────────
// class SaleAdapter extends TypeAdapter<Sale> {
//   @override
//   final typeId = 0;
//
//   @override
//   Sale read(BinaryReader reader) {
//     final id = reader.readString();
//     final customerName = reader.readString();
//     final shopName = reader.readString();
//     final phone = reader.readString();
//     final address = reader.readString();
//     final products = reader.readList().cast<Product>();
//     final totalAmount = reader.readDouble();
//     final paidAmount = reader.readDouble();
//     final pendingAmount = reader.readDouble();
//     final paymentMethod = reader.readString();
//     final date = DateTime.parse(reader.readString());
//     final status = reader.readString();
//     final notes = reader.readString();
//     final productImagePath = reader.readString();
//
//     return Sale(
//       id: id,
//       customerName: customerName,
//       shopName: shopName,
//       phone: phone,
//       address: address,
//       products: products,
//       totalAmount: totalAmount,
//       paidAmount: paidAmount,
//       pendingAmount: pendingAmount,
//       paymentMethod: paymentMethod,
//       date: date,
//       status: status,
//       notes: notes,
//       productImagePath: productImagePath.isEmpty ? null : productImagePath,
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, Sale obj) {
//     writer.writeString(obj.id);
//     writer.writeString(obj.customerName);
//     writer.writeString(obj.shopName);
//     writer.writeString(obj.phone);
//     writer.writeString(obj.address);
//     writer.writeList(obj.products);
//     writer.writeDouble(obj.totalAmount);
//     writer.writeDouble(obj.paidAmount);
//     writer.writeDouble(obj.pendingAmount);
//     writer.writeString(obj.paymentMethod);
//     writer.writeString(obj.date.toIso8601String());
//     writer.writeString(obj.status);
//     writer.writeString(obj.notes);
//     writer.writeString(obj.productImagePath ?? '');
//   }
// }
//
// class ProductAdapter extends TypeAdapter<Product> {
//   @override
//   final typeId = 1;
//
//   @override
//   Product read(BinaryReader reader) {
//     return Product(
//       name: reader.readString(),
//       quantity: reader.readInt(),
//       pricePerUnit: reader.readDouble(),
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, Product obj) {
//     writer.writeString(obj.name);
//     writer.writeInt(obj.quantity);
//     writer.writeDouble(obj.pricePerUnit);
//   }
// }
//
// class PaymentAdapter extends TypeAdapter<Payment> {
//   @override
//   final typeId = 2;
//
//   @override
//   Payment read(BinaryReader reader) {
//     return Payment(
//       saleId: reader.readString(),
//       amount: reader.readDouble(),
//       date: DateTime.parse(reader.readString()),
//       notes: reader.readString(),
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, Payment obj) {
//     writer.writeString(obj.saleId);
//     writer.writeDouble(obj.amount);
//     writer.writeString(obj.date.toIso8601String());
//     writer.writeString(obj.notes);
//   }
// }
//
// // ──────────────────────────────────────────────
// // Models
// // ──────────────────────────────────────────────
// class Product {
//   String name;
//   int quantity;
//   double pricePerUnit;
//
//   Product({required this.name, required this.quantity, required this.pricePerUnit});
// }
//
// class Sale {
//   String id;
//   String customerName;
//   String shopName;
//   String phone;
//   String address;
//   List<Product> products;
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
//     required this.products,
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
// class Payment {
//   String saleId;
//   double amount;
//   DateTime date;
//   String notes;
//
//   Payment({
//     required this.saleId,
//     required this.amount,
//     required this.date,
//     required this.notes,
//   });
// }
//
// // ──────────────────────────────────────────────
// // App Manager (Language + Theme)
// // ──────────────────────────────────────────────
// class AppManager extends ChangeNotifier {
//   late Box<AppSettings> _settingsBox;
//
//   bool _isDark = true;
//   String _currentLanguage = 'en';
//
//   bool get isDark => _isDark;
//   String get currentLanguage => _currentLanguage;
//
//   Future<void> init() async {
//     _settingsBox = await Hive.openBox<AppSettings>('settings');
//
//     final saved = _settingsBox.get('app');
//     if (saved != null) {
//       _isDark = saved.isDark;
//       _currentLanguage = saved.language;
//     }
//     notifyListeners();
//   }
//
//   Future<void> setLanguage(String lang) async {
//     _currentLanguage = lang;
//     await _save();
//     notifyListeners();
//   }
//
//   Future<void> toggleTheme() async {
//     _isDark = !_isDark;
//     await _save();
//     notifyListeners();
//   }
//
//   Future<void> _save() async {
//     await _settingsBox.put(
//       'app',
//       AppSettings(
//         isDark: _isDark,
//         language: _currentLanguage,
//       ),
//     );
//   }
// }
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
//       'add_product': 'Add Product',
//       'add_payment': 'Add Payment',
//       'payment_history': 'Payment History',
//       'amount': 'Amount',
//       'payment_added': 'Payment added successfully',
//       'theme': 'Theme',
//       'light': 'Light',
//       'dark': 'Dark',
//       'select_date': 'Select Date',
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
//       'add_product': 'उत्पाद जोड़ें',
//       'add_payment': 'भुगतान जोड़ें',
//       'payment_history': 'भुगतान इतिहास',
//       'amount': 'राशि',
//       'payment_added': 'भुगतान सफलतापूर्वक जोड़ा गया',
//       'theme': 'थीम',
//       'light': 'लाइट',
//       'dark': 'डार्क',
//       'select_date': 'तारीख चुनें',
//     },
//   };
//
//   static String translate(String key, String language) {
//     return _translations[language]?[key] ?? key;
//   }
// }
//
// // ──────────────────────────────────────────────
// // Main App Entry
// // ──────────────────────────────────────────────
// class SalesProApp extends StatelessWidget {
//   const SalesProApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const SalesProAppContent();
//   }
// }
//
// class SalesProAppContent extends StatefulWidget {
//   const SalesProAppContent({super.key});
//
//   @override
//   State<SalesProAppContent> createState() => _SalesProAppContentState();
// }
//
// class _SalesProAppContentState extends State<SalesProAppContent> {
//   final AppManager _appManager = AppManager();
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _appManager,
//       builder: (context, _) {
//         return MaterialApp(
//           title: AppTranslations.translate('app_name', _appManager.currentLanguage),
//           debugShowCheckedModeBanner: false,
//           theme: _appManager.isDark
//               ? ThemeData.dark().copyWith(
//             primaryColor: const Color(0xFF2563EB),
//             scaffoldBackgroundColor: const Color(0xFF121212),
//             appBarTheme: const AppBarTheme(
//               backgroundColor: Color(0xFF1E1E1E),
//               foregroundColor: Colors.white,
//               elevation: 0,
//             ),
//             cardTheme: CardTheme(
//               color: const Color(0xFF1E1E1E),
//               elevation: 2,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             inputDecorationTheme: InputDecorationTheme(
//               filled: true,
//               fillColor: const Color(0xFF2A2A2A),
//               border: OutlineInputBorder(
//                 borderSide: BorderSide.none,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           )
//               : ThemeData.light().copyWith(
//             primaryColor: const Color(0xFF2563EB),
//             scaffoldBackgroundColor: Colors.white,
//             appBarTheme: const AppBarTheme(
//               backgroundColor: Color(0xFF2563EB),
//               foregroundColor: Colors.white,
//               elevation: 0,
//             ),
//             cardTheme: CardTheme(
//               elevation: 4,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             inputDecorationTheme: InputDecorationTheme(
//               filled: true,
//               fillColor: Colors.white,
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//           home: HomePage(appManager: _appManager),
//         );
//       },
//     );
//   }
// }
//
// // ──────────────────────────────────────────────
// // Home Page (Main Screen)
// // ──────────────────────────────────────────────
// class HomePage extends StatefulWidget {
//   final AppManager appManager;
//
//   const HomePage({super.key, required this.appManager});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final Box<Sale> _salesBox = Hive.box<Sale>('sales');
//   final Box<Payment> _paymentsBox = Hive.box<Payment>('payments');
//   DateTime _currentMonth = DateTime.now();
//   String searchQuery = '';
//   String filterStatus = 'all';
//
//   late ScrollController _scrollController;
//   bool _isFabVisible = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _scrollController.addListener(() {
//       if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
//         if (_isFabVisible) setState(() => _isFabVisible = false);
//       }
//       if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
//         if (!_isFabVisible) setState(() => _isFabVisible = true);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   String t(String key) => AppTranslations.translate(key, widget.appManager.currentLanguage);
//
//   void _changeMonth(int delta) {
//     setState(() {
//       _currentMonth = DateTime(
//         _currentMonth.year,
//         _currentMonth.month + delta,
//       );
//     });
//   }
//
//   List<Sale> get filteredMonthlySales {
//     return _salesBox.values.where((sale) {
//       final matchesMonth = sale.date.year == _currentMonth.year && sale.date.month == _currentMonth.month;
//       final matchesSearch = searchQuery.isEmpty ||
//           sale.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
//           sale.shopName.toLowerCase().contains(searchQuery.toLowerCase()) ||
//           sale.products.any((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()));
//       final matchesFilter = filterStatus == 'all' || sale.status == filterStatus;
//
//       return matchesMonth && matchesSearch && matchesFilter;
//     }).toList()
//       ..sort((a, b) => b.date.compareTo(a.date));
//   }
//
//   Map<DateTime, List<Sale>> get groupedByDay {
//     final map = <DateTime, List<Sale>>{};
//     for (var sale in filteredMonthlySales) {
//       final day = DateTime(sale.date.year, sale.date.month, sale.date.day);
//       map.putIfAbsent(day, () => []).add(sale);
//     }
//     return map;
//   }
//
//   double get totalSalesThisMonth => filteredMonthlySales.fold(0.0, (sum, s) => sum + s.totalAmount);
//   double get totalPaidThisMonth => filteredMonthlySales.fold(0.0, (sum, s) => sum + s.paidAmount);
//   double get totalPendingOverall => _salesBox.values.fold(0.0, (sum, s) => sum + s.pendingAmount);
//
//   @override
//   Widget build(BuildContext context) {
//     final grouped = groupedByDay;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             const Icon(Icons.shopping_bag_outlined),
//             const SizedBox(width: 8),
//             Text(t('app_name')),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(widget.appManager.isDark ? Icons.light_mode : Icons.dark_mode),
//             onPressed: widget.appManager.toggleTheme,
//             tooltip: t('theme'),
//           ),
//           IconButton(
//             icon: const Icon(Icons.language),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: Text(t('language')),
//                     content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         ListTile(
//                           title: const Text('English'),
//                           leading: Radio<String>(
//                             value: 'en',
//                             groupValue: widget.appManager.currentLanguage,
//                             onChanged: (v) {
//                               widget.appManager.setLanguage('en');
//                               Navigator.pop(context);
//                             },
//                           ),
//                         ),
//                         ListTile(
//                           title: const Text('हिंदी'),
//                           leading: Radio<String>(
//                             value: 'hi',
//                             groupValue: widget.appManager.currentLanguage,
//                             onChanged: (v) {
//                               widget.appManager.setLanguage('hi');
//                               Navigator.pop(context);
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.history),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => HistoryPage(
//                     sales: _salesBox.values.toList(),
//                     appManager: widget.appManager,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Month Navigation + Summary
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.chevron_left),
//                       onPressed: () => _changeMonth(-1),
//                     ),
//                     Text(
//                       DateFormat('MMMM yyyy').format(_currentMonth),
//                       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.chevron_right),
//                       onPressed: () => _changeMonth(1),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     _buildSummaryCard(t('total_sales'), totalSalesThisMonth, Colors.green),
//                     _buildSummaryCard(t('paid'), totalPaidThisMonth, Colors.blue),
//                     _buildSummaryCard(t('pending'), totalPendingOverall, Colors.orange),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // Search + Filter
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
//                     decoration: InputDecoration(
//                       hintText: t('search_hint'),
//                       prefixIcon: const Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 PopupMenuButton<String>(
//                   icon: const Icon(Icons.filter_list),
//                   onSelected: (value) => setState(() => filterStatus = value),
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
//           const SizedBox(height: 8),
//
//           // Sales List
//           Expanded(
//             child: grouped.isEmpty
//                 ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
//                   const SizedBox(height: 16),
//                   Text(t('no_sales'), style: const TextStyle(fontSize: 18, color: Colors.grey)),
//                 ],
//               ),
//             )
//                 : ListView.builder(
//               controller: _scrollController,
//               itemCount: grouped.length,
//               itemBuilder: (context, index) {
//                 final dayKey = grouped.keys.elementAt(index);
//                 final daySales = grouped[dayKey]!;
//
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//                       child: Text(
//                         DateFormat('dd MMM, EEEE').format(dayKey),
//                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     ...daySales.map((sale) => _buildSaleCard(sale)),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: _isFabVisible
//           ? FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => AddEditSalePage(
//                 onSave: (sale) {
//                   _salesBox.add(sale);
//                   setState(() {});
//                 },
//                 appManager: widget.appManager,
//               ),
//             ),
//           );
//         },
//         icon: const Icon(Icons.add),
//         label: Text(t('add_sale')),
//       )
//           : null,
//     );
//   }
//
//   Widget _buildSummaryCard(String title, double value, Color color) {
//     return Column(
//       children: [
//         Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
//         const SizedBox(height: 6),
//         Text(
//           '₹${value.toStringAsFixed(0)}',
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSaleCard(Sale sale) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => SaleDetailPage(
//                 sale: sale,
//                 onUpdate: (updated) {
//                   final key = _salesBox.keys.firstWhere((k) => _salesBox.get(k)!.id == updated.id);
//                   _salesBox.put(key, updated);
//                   setState(() {});
//                 },
//                 onDelete: (id) {
//                   final key = _salesBox.keys.firstWhere((k) => _salesBox.get(k)!.id == id);
//                   _salesBox.delete(key);
//                   setState(() {});
//                 },
//                 onAddPayment: (payment) {
//                   _paymentsBox.add(payment);
//                   final saleKey = _salesBox.keys.firstWhere((k) => _salesBox.get(k)!.id == payment.saleId);
//                   final s = _salesBox.get(saleKey)!;
//                   s.paidAmount += payment.amount;
//                   s.pendingAmount -= payment.amount;
//                   s.status = s.pendingAmount <= 0 ? 'paid' : 'pending';
//                   _salesBox.put(saleKey, s);
//                   setState(() {});
//                 },
//                 appManager: widget.appManager,
//               ),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         sale.customerName,
//                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         sale.shopName,
//                         style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: sale.status == 'paid' ? Colors.green[700] : Colors.orange[700],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       sale.status == 'paid' ? t('paid') : t('pending'),
//                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
//                     ),
//                   ),
//                 ],
//               ),
//               const Divider(height: 24),
//               Text(
//                 sale.products.map((p) => '${p.name} (${p.quantity})').join(', '),
//                 style: const TextStyle(fontSize: 14),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(t('total_amount'), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                       Text(
//                         '₹${sale.totalAmount.toStringAsFixed(0)}',
//                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
//                       ),
//                     ],
//                   ),
//                   if (sale.pendingAmount > 0)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(t('pending'), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                         Text(
//                           '₹${sale.pendingAmount.toStringAsFixed(0)}',
//                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 DateFormat('dd MMM yyyy').format(sale.date),
//                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ──────────────────────────────────────────────
// // Add / Edit Sale Page (with Date Picker)
// // ──────────────────────────────────────────────
// class AddEditSalePage extends StatefulWidget {
//   final Sale? sale;
//   final Function(Sale) onSave;
//   final AppManager appManager;
//
//   const AddEditSalePage({
//     super.key,
//     this.sale,
//     required this.onSave,
//     required this.appManager,
//   });
//
//   @override
//   State<AddEditSalePage> createState() => _AddEditSalePageState();
// }
//
// class _AddEditSalePageState extends State<AddEditSalePage> {
//   final _formKey = GlobalKey<FormState>();
//
//   late TextEditingController _customerNameCtrl;
//   late TextEditingController _shopNameCtrl;
//   late TextEditingController _phoneCtrl;
//   late TextEditingController _addressCtrl;
//   late TextEditingController _paidCtrl;
//   late TextEditingController _notesCtrl;
//
//   List<Product> _products = [];
//   String _paymentMethod = 'Cash';
//   File? _imageFile;
//   DateTime _selectedDate = DateTime.now();
//
//   final ImagePicker _picker = ImagePicker();
//
//   @override
//   void initState() {
//     super.initState();
//     _customerNameCtrl = TextEditingController(text: widget.sale?.customerName);
//     _shopNameCtrl = TextEditingController(text: widget.sale?.shopName);
//     _phoneCtrl = TextEditingController(text: widget.sale?.phone);
//     _addressCtrl = TextEditingController(text: widget.sale?.address);
//     _paidCtrl = TextEditingController(text: widget.sale?.paidAmount.toStringAsFixed(0) ?? '0');
//     _notesCtrl = TextEditingController(text: widget.sale?.notes);
//
//     _paymentMethod = widget.sale?.paymentMethod ?? 'Cash';
//     _products = widget.sale?.products ?? [];
//     _selectedDate = widget.sale?.date ?? DateTime.now();
//
//     if (widget.sale?.productImagePath != null && widget.sale!.productImagePath!.isNotEmpty) {
//       _imageFile = File(widget.sale!.productImagePath!);
//     }
//
//     // Add at least one product field if empty
//     if (_products.isEmpty) {
//       _products.add(Product(name: '', quantity: 0, pricePerUnit: 0));
//     }
//   }
//
//   String t(String key) => AppTranslations.translate(key, widget.appManager.currentLanguage);
//
//   Future<void> _pickDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
//
//   Future<void> _pickImage() async {
//     final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
//     if (file != null) {
//       setState(() {
//         _imageFile = File(file.path);
//       });
//     }
//   }
//
//   void _addProduct() {
//     setState(() {
//       _products.add(Product(name: '', quantity: 0, pricePerUnit: 0));
//     });
//   }
//
//   void _removeProduct(int index) {
//     if (_products.length > 1) {
//       setState(() {
//         _products.removeAt(index);
//       });
//     }
//   }
//
//   void _saveSale() {
//     if (!_formKey.currentState!.validate()) return;
//
//     double total = 0;
//     for (var p in _products) {
//       total += p.quantity * p.pricePerUnit;
//     }
//
//     double paid = double.tryParse(_paidCtrl.text) ?? 0;
//     double pending = total - paid;
//
//     final sale = Sale(
//       id: widget.sale?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
//       customerName: _customerNameCtrl.text.trim(),
//       shopName: _shopNameCtrl.text.trim(),
//       phone: _phoneCtrl.text.trim(),
//       address: _addressCtrl.text.trim(),
//       products: _products.where((p) => p.name.trim().isNotEmpty).toList(),
//       totalAmount: total,
//       paidAmount: paid,
//       pendingAmount: pending,
//       paymentMethod: _paymentMethod,
//       date: _selectedDate,
//       status: pending <= 0 ? 'paid' : 'pending',
//       notes: _notesCtrl.text.trim(),
//       productImagePath: _imageFile?.path,
//     );
//
//     widget.onSave(sale);
//     Navigator.pop(context);
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
//           padding: const EdgeInsets.all(16),
//           children: [
//             // Date Picker
//             Card(
//               child: ListTile(
//                 leading: const Icon(Icons.calendar_today),
//                 title: Text(t('select_date')),
//                 subtitle: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
//                 trailing: const Icon(Icons.edit_calendar),
//                 onTap: _pickDate,
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             // Customer Info
//             Text(t('customer_info'), style: Theme.of(context).textTheme.titleLarge),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _customerNameCtrl,
//               decoration: InputDecoration(labelText: t('customer_name')),
//               validator: (v) => v!.trim().isEmpty ? t('required_field') : null,
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _shopNameCtrl,
//               decoration: InputDecoration(labelText: t('shop_name')),
//               validator: (v) => v!.trim().isEmpty ? t('required_field') : null,
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _phoneCtrl,
//               decoration: InputDecoration(labelText: t('phone')),
//               keyboardType: TextInputType.phone,
//               validator: (v) => v!.length != 10 ? t('invalid_phone') : null,
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _addressCtrl,
//               decoration: InputDecoration(labelText: t('address')),
//               maxLines: 2,
//             ),
//
//             const Divider(height: 32),
//
//             // Products Section
//             Text(t('product_info'), style: Theme.of(context).textTheme.titleLarge),
//             const SizedBox(height: 12),
//             ...List.generate(_products.length, (index) {
//               final p = _products[index];
//               return Column(
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         flex: 3,
//                         child: TextFormField(
//                           initialValue: p.name,
//                           decoration: InputDecoration(labelText: '${t('product_name')} ${index + 1}'),
//                           onChanged: (v) => p.name = v,
//                           validator: (v) => v!.trim().isEmpty ? t('required_field') : null,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           initialValue: p.quantity > 0 ? p.quantity.toString() : '',
//                           decoration: InputDecoration(labelText: t('quantity')),
//                           keyboardType: TextInputType.number,
//                           onChanged: (v) => p.quantity = int.tryParse(v) ?? 0,
//                           validator: (v) => v!.isEmpty ? t('required_field') : null,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           initialValue: p.pricePerUnit > 0 ? p.pricePerUnit.toStringAsFixed(0) : '',
//                           decoration: InputDecoration(labelText: t('price_per_unit')),
//                           keyboardType: TextInputType.number,
//                           onChanged: (v) => p.pricePerUnit = double.tryParse(v) ?? 0,
//                           validator: (v) => v!.isEmpty ? t('required_field') : null,
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete_outline, color: Colors.red),
//                         onPressed: () => _removeProduct(index),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               );
//             }),
//
//             OutlinedButton.icon(
//               onPressed: _addProduct,
//               icon: const Icon(Icons.add),
//               label: Text(t('add_product')),
//             ),
//
//             const Divider(height: 32),
//
//             // Image Picker
//             if (_imageFile != null) ...[
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.file(_imageFile!, height: 180, fit: BoxFit.cover),
//               ),
//               const SizedBox(height: 12),
//             ],
//             OutlinedButton.icon(
//               onPressed: _pickImage,
//               icon: const Icon(Icons.image),
//               label: Text(_imageFile == null ? t('add_image') : t('change_image')),
//             ),
//
//             const Divider(height: 32),
//
//             // Payment Info
//             Text(t('payment_info'), style: Theme.of(context).textTheme.titleLarge),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _paidCtrl,
//               decoration: InputDecoration(labelText: t('paid_amount')),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               value: _paymentMethod,
//               decoration: InputDecoration(labelText: t('payment_method')),
//               items: ['Cash', 'Online', 'Cheque']
//                   .map((method) => DropdownMenuItem(
//                 value: method,
//                 child: Text(t(method.toLowerCase())),
//               ))
//                   .toList(),
//               onChanged: (v) => setState(() => _paymentMethod = v!),
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _notesCtrl,
//               decoration: InputDecoration(labelText: t('notes')),
//               maxLines: 3,
//             ),
//
//             const SizedBox(height: 40),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text(t('cancel')),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _saveSale,
//                     child: Text(t('save')),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ──────────────────────────────────────────────
// // Sale Detail Page
// // ──────────────────────────────────────────────
// class SaleDetailPage extends StatefulWidget {
//   final Sale sale;
//   final Function(Sale) onUpdate;
//   final Function(String) onDelete;
//   final Function(Payment) onAddPayment;
//   final AppManager appManager;
//
//   const SaleDetailPage({
//     super.key,
//     required this.sale,
//     required this.onUpdate,
//     required this.onDelete,
//     required this.onAddPayment,
//     required this.appManager,
//   });
//
//   @override
//   State<SaleDetailPage> createState() => _SaleDetailPageState();
// }
//
// class _SaleDetailPageState extends State<SaleDetailPage> {
//   String t(String key) => AppTranslations.translate(key, widget.appManager.currentLanguage);
//
//   final Box<Payment> _paymentBox = Hive.box<Payment>('payments');
//
//   List<Payment> get payments {
//     return _paymentBox.values.where((p) => p.saleId == widget.sale.id).toList()
//       ..sort((a, b) => b.date.compareTo(a.date));
//   }
//
//   void _showAddPaymentDialog() {
//     final amountCtrl = TextEditingController();
//     final notesCtrl = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(t('add_payment')),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextFormField(
//                 controller: amountCtrl,
//                 decoration: InputDecoration(labelText: t('amount')),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: notesCtrl,
//                 decoration: InputDecoration(labelText: t('notes')),
//                 maxLines: 2,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(t('cancel')),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final amount = double.tryParse(amountCtrl.text) ?? 0;
//                 if (amount > 0 && amount <= widget.sale.pendingAmount) {
//                   widget.onAddPayment(Payment(
//                     saleId: widget.sale.id,
//                     amount: amount,
//                     date: DateTime.now(),
//                     notes: notesCtrl.text.trim(),
//                   ));
//                   Navigator.pop(context);
//                 }
//               },
//               child: Text(t('save')),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _generateAndShareSlip() async {
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text('Sale Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
//               pw.SizedBox(height: 20),
//               pw.Text('Customer: ${widget.sale.customerName}'),
//               pw.Text('Shop: ${widget.sale.shopName}'),
//               pw.Text('Phone: ${widget.sale.phone}'),
//               pw.Text('Address: ${widget.sale.address}'),
//               pw.SizedBox(height: 20),
//               pw.Text('Products:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
//               ...widget.sale.products.map(
//                     (p) => pw.Text('${p.name} × ${p.quantity} @ ₹${p.pricePerUnit.toStringAsFixed(0)}'),
//               ),
//               pw.SizedBox(height: 20),
//               pw.Text('Total Amount: ₹${widget.sale.totalAmount.toStringAsFixed(0)}'),
//               pw.Text('Paid Amount: ₹${widget.sale.paidAmount.toStringAsFixed(0)}'),
//               pw.Text('Pending Amount: ₹${widget.sale.pendingAmount.toStringAsFixed(0)}'),
//               pw.SizedBox(height: 20),
//               pw.Text('Payment History:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
//               ...payments.map(
//                     (p) => pw.Text(
//                   '${DateFormat('dd MMM yyyy | HH:mm').format(p.date)} : ₹${p.amount.toStringAsFixed(0)} ${p.notes.isNotEmpty ? '(${p.notes})' : ''}',
//                 ),
//               ),
//               pw.SizedBox(height: 30),
//               pw.Text('Generated on: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}'),
//             ],
//           );
//         },
//       ),
//     );
//
//     final bytes = await pdf.save();
//     await Printing.sharePdf(bytes: bytes, filename: 'sale_${widget.sale.id}.pdf');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(t('sale_details')),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => AddEditSalePage(
//                     sale: widget.sale,
//                     onSave: widget.onUpdate,
//                     appManager: widget.appManager,
//                   ),
//                 ),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: Text(t('delete_confirm')),
//                   content: Text(t('delete_message')),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: Text(t('no')),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         widget.onDelete(widget.sale.id);
//                         Navigator.pop(context);
//                         Navigator.pop(context);
//                       },
//                       child: Text(t('yes'), style: const TextStyle(color: Colors.red)),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Status Badge
//             Center(
//               child: Chip(
//                 label: Text(
//                   widget.sale.status == 'paid' ? t('paid') : t('pending'),
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//                 backgroundColor: widget.sale.status == 'paid' ? Colors.green : Colors.orange,
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             // Customer Info
//             _buildSectionCard(
//               title: t('customer_info'),
//               children: [
//                 _buildRow(Icons.person, t('customer_name'), widget.sale.customerName),
//                 _buildRow(Icons.store, t('shop_name'), widget.sale.shopName),
//                 _buildRow(Icons.phone, t('phone'), widget.sale.phone),
//                 _buildRow(Icons.location_on, t('address'), widget.sale.address),
//               ],
//             ),
//
//             const SizedBox(height: 16),
//
//             // Products
//             _buildSectionCard(
//               title: t('product_info'),
//               children: [
//                 ...widget.sale.products.map(
//                       (p) => _buildRow(
//                     Icons.shopping_cart,
//                     p.name,
//                     '${p.quantity} × ₹${p.pricePerUnit.toStringAsFixed(0)}',
//                   ),
//                 ),
//                 if (widget.sale.productImagePath != null && widget.sale.productImagePath!.isNotEmpty) ...[
//                   const SizedBox(height: 16),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.file(
//                       File(widget.sale.productImagePath!),
//                       height: 200,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//
//             const SizedBox(height: 16),
//
//             // Payment Info
//             _buildSectionCard(
//               title: t('payment_info'),
//               children: [
//                 _buildAmountRow(t('total_amount'), widget.sale.totalAmount, Colors.blue),
//                 _buildAmountRow(t('paid_amount'), widget.sale.paidAmount, Colors.green),
//                 _buildAmountRow(t('pending_amount'), widget.sale.pendingAmount, Colors.orange),
//                 const Divider(),
//                 _buildRow(Icons.calendar_today, t('date'), DateFormat('dd MMM yyyy').format(widget.sale.date)),
//                 if (widget.sale.notes.isNotEmpty) _buildRow(Icons.note, t('notes'), widget.sale.notes),
//               ],
//             ),
//
//             const SizedBox(height: 24),
//
//             // Payment History
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           t('payment_history'),
//                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         if (widget.sale.pendingAmount > 0)
//                           OutlinedButton.icon(
//                             onPressed: _showAddPaymentDialog,
//                             icon: const Icon(Icons.add, size: 18),
//                             label: Text(t('add_payment')),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     ValueListenableBuilder<Box<Payment>>(
//                       valueListenable: _paymentBox.listenable(),
//                       builder: (context, box, _) {
//                         final payments = _getPaymentsForSale(widget.sale.id);
//                         if (payments.isEmpty) {
//                           return const Text('No payments recorded yet.', style: TextStyle(color: Colors.grey));
//                         }
//                         return Column(
//                           children: payments.map((p) {
//                             return ListTile(
//                               contentPadding: EdgeInsets.zero,
//                               title: Text(
//                                 '${DateFormat('dd MMM yyyy | HH:mm').format(p.date)} : ₹${p.amount.toStringAsFixed(0)}',
//                                 style: const TextStyle(fontWeight: FontWeight.w500),
//                               ),
//                               subtitle: p.notes.isNotEmpty ? Text(p.notes) : null,
//                             );
//                           }).toList(),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             // Download Slip
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _generateAndShareSlip,
//                 icon: const Icon(Icons.picture_as_pdf),
//                 label: Text(t('download_slip')),
//                 style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionCard({required String title, required List<Widget> children}) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey[600]),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                 const SizedBox(height: 4),
//                 Text(value, style: const TextStyle(fontSize: 15)),
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
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//           Text(
//             '₹${amount.toStringAsFixed(0)}',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
//           ),
//         ],
//       ),
//     );
//   }
//
//   List<Payment> _getPaymentsForSale(String saleId) {
//     return _paymentBox.values.where((p) => p.saleId == saleId).toList()
//       ..sort((a, b) => b.date.compareTo(a.date));
//   }
//
//   // Future<void> _generateAndShareSlip() async {
//   //   final pdf = pw.Document();
//   //
//   //   pdf.addPage(
//   //     pw.Page(
//   //       pageFormat: PdfPageFormat.a4,
//   //       build: (pw.Context context) {
//   //         return pw.Column(
//   //           crossAxisAlignment: pw.CrossAxisAlignment.start,
//   //           children: [
//   //             pw.Text('Sale Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
//   //             pw.SizedBox(height: 20),
//   //             pw.Text('Customer: ${widget.sale.customerName}'),
//   //             pw.Text('Shop: ${widget.sale.shopName}'),
//   //             pw.Text('Phone: ${widget.sale.phone}'),
//   //             pw.Text('Address: ${widget.sale.address}'),
//   //             pw.SizedBox(height: 20),
//   //             pw.Text('Products:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
//   //             ...widget.sale.products.map(
//   //                   (p) => pw.Text('${p.name} × ${p.quantity} @ ₹${p.pricePerUnit.toStringAsFixed(0)}'),
//   //             ),
//   //             pw.SizedBox(height: 20),
//   //             pw.Text('Total Amount: ₹${widget.sale.totalAmount.toStringAsFixed(0)}'),
//   //             pw.Text('Paid Amount: ₹${widget.sale.paidAmount.toStringAsFixed(0)}'),
//   //             pw.Text('Pending Amount: ₹${widget.sale.pendingAmount.toStringAsFixed(0)}'),
//   //             pw.SizedBox(height: 20),
//   //             pw.Text('Payment History:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
//   //             ..._getPaymentsForSale(widget.sale.id).map(
//   //                   (p) => pw.Text(
//   //                 '${DateFormat('dd MMM yyyy | HH:mm').format(p.date)} : ₹${p.amount.toStringAsFixed(0)} ${p.notes.isNotEmpty ? '(${p.notes})' : ''}',
//   //               ),
//   //             ),
//   //             pw.SizedBox(height: 30),
//   //             pw.Text('Generated on: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}'),
//   //           ],
//   //         );
//   //       },
//   //     ),
//   //   );
//   //
//   //   final bytes = await pdf.save();
//   //   await Printing.sharePdf(bytes: bytes, filename: 'sale_${widget.sale.id}.pdf');
//   // }
// }
//
// // ──────────────────────────────────────────────
// // History Page
// // ──────────────────────────────────────────────
// class HistoryPage extends StatelessWidget {
//   final List<Sale> sales;
//   final AppManager appManager;
//
//   const HistoryPage({super.key, required this.sales, required this.appManager});
//
//   String t(String key) => AppTranslations.translate(key, appManager.currentLanguage);
//
//   @override
//   Widget build(BuildContext context) {
//     final grouped = <String, List<Sale>>{};
//
//     for (var sale in sales) {
//       final key = DateFormat('MMMM yyyy').format(sale.date);
//       grouped.putIfAbsent(key, () => []).add(sale);
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: Text(t('history'))),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: grouped.length,
//         itemBuilder: (context, index) {
//           final month = grouped.keys.elementAt(index);
//           final monthSales = grouped[month]!;
//           final total = monthSales.fold<double>(0, (sum, s) => sum + s.totalAmount);
//
//           return Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: ExpansionTile(
//               title: Text(month, style: const TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Text('${t('total_records')}: ${monthSales.length}'),
//               trailing: Text(
//                 '₹${total.toStringAsFixed(0)}',
//                 style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
//               ),
//               children: monthSales.map((sale) {
//                 return ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: sale.status == 'paid' ? Colors.green[100] : Colors.orange[100],
//                     child: Icon(
//                       Icons.receipt,
//                       color: sale.status == 'paid' ? Colors.green : Colors.orange,
//                     ),
//                   ),
//                   title: Text(sale.customerName),
//                   subtitle: Text(
//                     '${sale.products.map((p) => p.name).join(', ')} • ${DateFormat('dd MMM').format(sale.date)}',
//                   ),
//                   trailing: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text('₹${sale.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
//                       if (sale.pendingAmount > 0)
//                         Text(
//                           '₹${sale.pendingAmount.toStringAsFixed(0)} ${t('pending')}',
//                           style: TextStyle(color: Colors.orange[800], fontSize: 12),
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