import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(SalesProApp());
}

// Language Manager
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
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Color(0xFF2563EB),
            scaffoldBackgroundColor: Color(0xFFF8FAFC),
            appBarTheme: AppBarTheme(
              elevation: 0,
              backgroundColor: Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          home: HomePage(appLanguage: _appLanguage),
        );
      },
    );
  }
}

class Sale {
  String id;
  String customerName;
  String shopName;
  String phone;
  String address;
  String productName;
  int quantity;
  double pricePerUnit;
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
    required this.productName,
    required this.quantity,
    required this.pricePerUnit,
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

class HomePage extends StatefulWidget {
  final AppLanguage appLanguage;

  HomePage({required this.appLanguage});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Sale> sales = [];
  List<Sale> filteredSales = [];
  String searchQuery = '';
  String filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadDemoData();
  }

  String t(String key) {
    return AppTranslations.translate(key, widget.appLanguage.currentLanguage);
  }

  void _loadDemoData() {
    sales = [
      Sale(
        id: '1',
        customerName: 'Rajesh Kumar',
        shopName: 'Kumar General Store',
        phone: '9876543210',
        address: 'Main Market, Ludhiana',
        productName: 'Rice Bags (25kg)',
        quantity: 50,
        pricePerUnit: 1200,
        totalAmount: 60000,
        paidAmount: 40000,
        pendingAmount: 20000,
        paymentMethod: 'Cash',
        date: DateTime.now().subtract(Duration(days: 8)),
        status: 'pending',
        notes: 'Delivery completed',
      ),
      Sale(
        id: '2',
        customerName: 'Priya Sharma',
        shopName: 'Sharma Trading Co.',
        phone: '9876543211',
        address: 'Mall Road, Ludhiana',
        productName: 'Wheat Flour (10kg)',
        quantity: 100,
        pricePerUnit: 400,
        totalAmount: 40000,
        paidAmount: 40000,
        pendingAmount: 0,
        paymentMethod: 'Online',
        date: DateTime.now().subtract(Duration(days: 3)),
        status: 'paid',
        notes: 'Paid in full',
      ),
    ];
    filteredSales = sales;
  }

  void _filterSales() {
    setState(() {
      filteredSales = sales.where((sale) {
        bool matchesSearch = sale.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            sale.shopName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            sale.productName.toLowerCase().contains(searchQuery.toLowerCase());

        bool matchesStatus = filterStatus == 'all' || sale.status == filterStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _addSale(Sale sale) {
    setState(() {
      sales.insert(0, sale);
      _filterSales();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t('sale_added'))),
    );
  }

  void _updateSale(Sale updatedSale) {
    setState(() {
      int index = sales.indexWhere((s) => s.id == updatedSale.id);
      if (index != -1) {
        sales[index] = updatedSale;
        _filterSales();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t('sale_updated'))),
    );
  }

  void _deleteSale(String id) {
    setState(() {
      sales.removeWhere((s) => s.id == id);
      _filterSales();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t('sale_deleted'))),
    );
  }

  double _getTotalPending() {
    return sales.fold(0, (sum, sale) => sum + sale.pendingAmount);
  }

  double _getTotalSales() {
    return sales.fold(0, (sum, sale) => sum + sale.totalAmount);
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  setState(() {});
                },
              ),
              title: Text('English'),
              onTap: () {
                widget.appLanguage.setLanguage('en');
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              leading: Radio<String>(
                value: 'hi',
                groupValue: widget.appLanguage.currentLanguage,
                onChanged: (value) {
                  widget.appLanguage.setLanguage('hi');
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              title: Text('हिंदी'),
              onTap: () {
                widget.appLanguage.setLanguage('hi');
                Navigator.pop(context);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    sales: sales,
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
          // Stats Cards
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    t('total_sales'),
                    '₹${_getTotalSales().toStringAsFixed(0)}',
                    Colors.blue,
                    Icons.trending_up,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    t('pending'),
                    '₹${_getTotalPending().toStringAsFixed(0)}',
                    Colors.orange,
                    Icons.pending,
                  ),
                ),
              ],
            ),
          ),

          // Search and Filter
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: t('search_hint'),
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        _filterSales();
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() {
                      filterStatus = value;
                      _filterSales();
                    });
                  },
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

          // Sales List
          Expanded(
            child: filteredSales.isEmpty
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
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredSales.length,
              itemBuilder: (context, index) {
                return _buildSaleCard(filteredSales[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
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
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SaleDetailPage(
                sale: sale,
                onUpdate: _updateSale,
                onDelete: _deleteSale,
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
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          sale.shopName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sale.status == 'paid' ? Colors.green[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sale.status == 'paid' ? t('paid') : t('pending'),
                      style: TextStyle(
                        color: sale.status == 'paid' ? Colors.green[700] : Colors.orange[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.shopping_cart, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    sale.productName,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '(${sale.quantity} ${t('quantity')})',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '₹${sale.totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
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
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          '₹${sale.pendingAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 8),
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

// Add Edit Sale Page
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
  late TextEditingController _productNameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _paidController;
  late TextEditingController _notesController;

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
    _productNameController = TextEditingController(text: widget.sale?.productName ?? '');
    _quantityController = TextEditingController(text: widget.sale?.quantity.toString() ?? '');
    _priceController = TextEditingController(text: widget.sale?.pricePerUnit.toString() ?? '');
    _paidController = TextEditingController(text: widget.sale?.paidAmount.toString() ?? '');
    _notesController = TextEditingController(text: widget.sale?.notes ?? '');
    _paymentMethod = widget.sale?.paymentMethod ?? 'Cash';
  }

  String t(String key) {
    return AppTranslations.translate(key, widget.appLanguage.currentLanguage);
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
    showModalBottomSheet(
      context: context,
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
    if (_formKey.currentState!.validate()) {
      int quantity = int.parse(_quantityController.text);
      double pricePerUnit = double.parse(_priceController.text);
      double totalAmount = quantity * pricePerUnit;
      double paidAmount = double.parse(_paidController.text);
      double pendingAmount = totalAmount - paidAmount;

      Sale newSale = Sale(
        id: widget.sale?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: _customerNameController.text,
        shopName: _shopNameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        productName: _productNameController.text,
        quantity: quantity,
        pricePerUnit: pricePerUnit,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        pendingAmount: pendingAmount,
        paymentMethod: _paymentMethod,
        date: widget.sale?.date ?? DateTime.now(),
        status: pendingAmount == 0 ? 'paid' : 'pending',
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
            // Customer Information Section
            Text(
              t('customer_info'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: t('customer_name'),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t('required_field');
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: t('phone'),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t('required_field');
                }
                if (value.length != 10) {
                  return t('invalid_phone');
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: t('address'),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t('required_field');
                }
                return null;
              },
            ),

            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 24),

            // Product Information Section
            Text(
              t('product_info'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _productNameController,
              decoration: InputDecoration(
                labelText: t('product_name'),
                prefixIcon: Icon(Icons.shopping_cart),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t('required_field');
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: t('quantity'),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t('required_field');
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: t('price_per_unit'),
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t('required_field');
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Product Image
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('product_image'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    if (_productImage != null || widget.sale?.productImagePath != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _productImage != null
                                ? Image.file(_productImage!, height: 200, width: double.infinity, fit: BoxFit.cover)
                                : Image.file(File(widget.sale!.productImagePath!), height: 200, width: double.infinity, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _productImage = null;
                                });
                              },

                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: Icon(Icons.add_photo_alternate),
                      label: Text(_productImage == null && widget.sale?.productImagePath == null
                          ? t('add_image')
                          : t('change_image')),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 24),

            // Payment Information Section
            Text(
              t('payment_info'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _paidController,
              decoration: InputDecoration(
                labelText: t('paid_amount'),
                prefixIcon: Icon(Icons.payment),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t('required_field');
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: InputDecoration(
                labelText: t('payment_method'),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              items: [
                DropdownMenuItem(value: 'Cash', child: Text(t('cash'))),
                DropdownMenuItem(value: 'Online', child: Text(t('online'))),
                DropdownMenuItem(value: 'Cheque', child: Text(t('cheque'))),
              ],
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: t('notes'),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),

            SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t('cancel')),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(0, 48),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSale,
                    child: Text(t('save')),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(0, 48),
                    ),
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

// Sale Detail Page
class SaleDetailPage extends StatelessWidget {
  final Sale sale;
  final Function(Sale) onUpdate;
  final Function(String) onDelete;
  final AppLanguage appLanguage;

  SaleDetailPage({
    required this.sale,
    required this.onUpdate,
    required this.onDelete,
    required this.appLanguage,
  });

  String t(String key) {
    return AppTranslations.translate(key, appLanguage.currentLanguage);
  }

  void _showDeleteDialog(BuildContext context) {
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
          ElevatedButton(
            onPressed: () {
              onDelete(sale.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            // style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(t('yes')),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(t('product_image')),
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Image.file(File(sale.productImagePath!)),
            ),
          ],
        ),
      ),
    );
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
                    sale: sale,
                    onSave: onUpdate,
                    appLanguage: appLanguage,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Status Badge
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: sale.status == 'paid' ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                sale.status == 'paid' ? t('paid') : t('pending'),
                style: TextStyle(
                  color: sale.status == 'paid' ? Colors.green[700] : Colors.orange[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          SizedBox(height: 24),

          // Customer Information
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('customer_info'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow(Icons.person, t('customer_name'), sale.customerName),
                  _buildInfoRow(Icons.store, t('shop_name'), sale.shopName),
                  _buildInfoRow(Icons.phone, t('phone'), sale.phone),
                  _buildInfoRow(Icons.location_on, t('address'), sale.address),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Product Information
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('product_info'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow(Icons.shopping_cart, t('product_name'), sale.productName),
                  _buildInfoRow(Icons.numbers, t('quantity'), sale.quantity.toString()),
                  _buildInfoRow(Icons.currency_rupee, t('price_per_unit'), '₹${sale.pricePerUnit.toStringAsFixed(2)}'),

                  if (sale.productImagePath != null) ...[
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () => _showImageDialog(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(sale.productImagePath!),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _showImageDialog(context),
                        icon: Icon(Icons.zoom_in),
                        label: Text(t('view_image')),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Payment Information
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('payment_info'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildAmountRow(t('total_amount'), sale.totalAmount, Colors.blue),
                  _buildAmountRow(t('paid_amount'), sale.paidAmount, Colors.green),
                  _buildAmountRow(t('pending_amount'), sale.pendingAmount, Colors.orange),
                  Divider(height: 24),
                  _buildInfoRow(Icons.account_balance_wallet, t('payment_method'), sale.paymentMethod),
                  _buildInfoRow(Icons.calendar_today, t('date'), DateFormat('dd MMM yyyy').format(sale.date)),
                  if (sale.notes.isNotEmpty)
                    _buildInfoRow(Icons.note, t('notes'), sale.notes),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: () {
              // Download slip functionality would go here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${t('download_slip')} - Feature coming soon!')),
              );
            },
            icon: Icon(Icons.download),
            label: Text(t('download_slip')),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),
            ),
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
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// History Page
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
      if (!groupedSales.containsKey(monthYear)) {
        groupedSales[monthYear] = [];
      }
      groupedSales[monthYear]!.add(sale);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t('history')),
      ),
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
              title: Text(
                month,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${t('total_records')}: ${monthSales.length}'),
              trailing: Text(
                '₹${monthTotal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue[700],
                ),
              ),
              children: monthSales.map((sale) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: sale.status == 'paid' ? Colors.green[100] : Colors.orange[100],
                    child: Icon(
                      Icons.shopping_bag,
                      color: sale.status == 'paid' ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                  title: Text(sale.customerName),
                  subtitle: Text('${sale.productName} - ${DateFormat('dd MMM').format(sale.date)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${sale.totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (sale.pendingAmount > 0)
                        Text(
                          '₹${sale.pendingAmount.toStringAsFixed(0)} ${t('pending')}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[700],
                          ),
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