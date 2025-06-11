import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Home__Page/00_home_page.dart';
import '../AI/chatbot.dart';
import '../Profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Home__Page/favorite_page.dart';

// Product model with overridden == and hashCode for correct Map functionality
class Product {
  final String id;
  final String name;
  final String price;
  final String category;
  final String description;
  final String imageUrl;
  int stock; // Added stock field
  int quantity; // For cart quantity

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.imageUrl,
    this.stock = 0, // Default stock to 0
    this.quantity = 1,
  });

  // Factory constructor to create Product from Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Product',
      // Convert the price to string with EG suffix
      price: '${data['price']?.toString() ?? '0'} EG',
      category: data['category'] ?? 'Other',
      description: data['description'] ?? 'No description available',
      imageUrl: data['imageUrl'] ?? 'assets/images/placeholder.jpg',
      stock: data['stock'] ?? 0, // Get stock from Firebase
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class SupplementsStorePage extends StatefulWidget {
  const SupplementsStorePage({super.key});

  @override
  _SupplementsStorePageState createState() => _SupplementsStorePageState();
}

class _SupplementsStorePageState extends State<SupplementsStorePage> {
  final Color customPurple = const Color(0xFF6A5ACD);
  final Color backgroundColor = const Color(0xFF232323);
  final Color cardColor = Colors.white;
  final Color textColor = Colors.black;
  final TextEditingController searchController = TextEditingController();
  String selectedCategory = 'All'; // Default to 'All' category
  int _currentNavIndex = 1; // Set to 1 since this is the Store page

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Shopping cart: يخزن الكمية المطلوبة لكل منتج
  Map<Product, int> cart = {};

  // List to store all available categories
  List<String> categories = ['All'];

  // Navigation method
  void _onItemTapped(int index) {
    if (index == _currentNavIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
      // Already on Store page, do nothing
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              userId: FirebaseAuth.instance.currentUser?.uid ?? '',
            ),
          ),
        );
        break;
    }
    setState(() {
      _currentNavIndex = index;
    });
  }

  // دالة لبناء أزرار الفئات
  Widget _buildCategoryButton(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedCategory == category ? customPurple : Colors.grey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          setState(() {
            selectedCategory = category;
          });
        },
        child: Text(
          category,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Add product to cart (بناءً على الكمية المحددة للمنتج)
  void addToCart(Product product) {
    // Check if there's enough stock before adding to cart
    if (product.stock > 0) {
      setState(() {
        if (cart.containsKey(product)) {
          // Only add if the current cart quantity is less than available stock
          if (cart[product]! < product.stock) {
            cart[product] = cart[product]! + 1;
            // Update the stock in Firebase (optional - if you want to decrease stock when adding to cart)
            _firestore.collection('products').doc(product.id).update({
              'stock': FieldValue.increment(-1)
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot add more of this item - stock limit reached')),
            );
          }
        } else {
          cart[product] = 1;
          // Update the stock in Firebase (optional)
          _firestore.collection('products').doc(product.id).update({
            'stock': FieldValue.increment(-1)
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This product is out of stock')),
      );
    }
  }

  // Remove product from cart
  void removeFromCart(Product product) {
    setState(() {
      if (cart.containsKey(product) && cart[product]! > 1) {
        cart[product] = cart[product]! - 1;
        // Update the stock in Firebase (optional - if you decreased stock when adding to cart)
        _firestore.collection('products').doc(product.id).update({
          'stock': FieldValue.increment(1)
        });
      } else {
        if (cart.containsKey(product)) {
          // Update the stock in Firebase (optional)
          _firestore.collection('products').doc(product.id).update({
            'stock': FieldValue.increment(1)
          });
        }
        cart.remove(product);
      }
    });
  }

  void _confirmCashPayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Cash Payment"),
        content: const Text("Are you sure you want to proceed with cash payment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الديالوج
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Order placed successfully (Cash Payment)")),
              );
              clearCart(); // تفريغ السلة
              Navigator.pop(context); // العودة للشاشة السابقة (اختياري)
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  // تفريغ السلة
  void clearCart() {
    // استعادة الكمية للمنتجات (اختياري)
    cart.forEach((product, quantity) {
      _firestore.collection('products').doc(product.id).update({
        'stock': FieldValue.increment(quantity),
      });
    });
    setState(() { // ← هذا يجعل الواجهة تُحدث نفسها
      cart.clear();
    });
  }

  // حساب إجمالي عدد المنتجات في السلة
  int totalItemsInCart() {
    return cart.values.fold(0, (prev, amount) => prev + amount);
  }

  // حساب المجموع الكلي للسلة
  String calculateTotal() {
    double total = 0;
    cart.forEach((product, quantity) {
      final price = double.parse(product.price.replaceAll(RegExp(r'[^0-9.]'), ''));
      total += price * quantity;
    });
    return '${total.toStringAsFixed(2)} EG';
  }

  // عرض نافذة الدفع بالفيزا
  void showVisaPaymentDialog() {
    TextEditingController cardNumberController = TextEditingController();
    TextEditingController cardHolderController = TextEditingController();
    TextEditingController expiryDateController = TextEditingController();
    TextEditingController cvvController = TextEditingController();

    // Calculate total items and amount for display
    int totalItems = 0;
    double totalAmount = 0;
    cart.forEach((product, quantity) {
      totalItems += quantity;
      final price = double.parse(product.price.replaceAll(RegExp(r'[^0-9.]'), ''));
      totalAmount += price * quantity;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFF232323),
          appBar: AppBar(
            backgroundColor: const Color(0xFF232323),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.green),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.purple),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.purple),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.purple),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // VISA logo
                            Container(
                              width: 120,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Center(
                                child: Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2560px-Visa_Inc._logo.svg.png',
                                  width: 80,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text(
                                      'VISA',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Card Number
                            TextField(
                              controller: cardNumberController,
                              decoration: InputDecoration(
                                hintText: 'Card Number',
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            // Cardholder Name
                            TextField(
                              controller: cardHolderController,
                              decoration: InputDecoration(
                                hintText: 'Cardholder Name',
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Expiry Date and CVV in a row
                            Row(
                              children: [
                                // Expiry Date
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: expiryDateController,
                                    decoration: InputDecoration(
                                      hintText: 'Expiry Date',
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                    keyboardType: TextInputType.datetime,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // CVV
                                Expanded(
                                  child: TextField(
                                    controller: cvvController,
                                    decoration: InputDecoration(
                                      hintText: 'CVV',
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            // Order summary
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  // Display items in cart with quantity
                                  ...cart.entries.take(2).map((entry) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${entry.value} x ${entry.key.name.length > 15 ? '${entry.key.name.substring(0, 15)}...' : entry.key.name}',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            '${double.parse(entry.key.price.replaceAll(RegExp(r'[^0-9.]'), '')) * entry.value}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  const Divider(),
                                  // Total
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Submit button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE2F163),
                                foregroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                // 1. تحقق من صحة بيانات الدفع (يمكن إضافة المزيد من التحقق هنا)
                                if (cardNumberController.text.isEmpty ||
                                    cardHolderController.text.isEmpty ||
                                    expiryDateController.text.isEmpty ||
                                    cvvController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please fill all payment details')),
                                  );
                                  return;
                                }
                                // 2. إذا كانت البيانات صحيحة، نفذ الدفع
                                Navigator.pop(context); // أغلق شاشة الدفع
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Payment successful!')),
                                );
                                // 3. **أضف هذا السطر لتفريغ العربة بعد الدفع**
                                clearCart(); // ← هذا هو الحل
                              },
                              child: const Text('Submit', style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom navigation
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFB29BFF),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentNavIndex,
                  onTap: _onItemTapped,
                  backgroundColor: Colors.transparent,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white60,
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  elevation: 0,
                  iconSize: 28,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: ImageIcon(AssetImage('assets/icons/home.png')),
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Icon(Icons.shopping_cart), // Store icon
                      ),
                      label: 'Store',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: ImageIcon(AssetImage('assets/icons/chat.png')),
                      ),
                      label: 'Chat',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: ImageIcon(AssetImage('assets/icons/User.png')),
                      ),
                      label: 'Profile',
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

  // Show product details screen
  void showProductDetails(Product product) {
    // Create a stream to listen for stock updates
    StreamSubscription? stockSubscription;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          // Set up the stock listener when the screen is built
          stockSubscription = _firestore.collection('products').doc(product.id)
              .snapshots().listen((snapshot) {
            if (snapshot.exists) {
              final data = snapshot.data() as Map<String, dynamic>;
              setState(() {
                product.stock = data['stock'] ?? 0;
              });
            }
          });

          return Scaffold(
            backgroundColor: const Color(0xFF232323),
            appBar: AppBar(
              backgroundColor: const Color(0xFF232323),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.green),
                onPressed: () {
                  // Cancel the subscription when navigating back
                  stockSubscription?.cancel();
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.purple),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.purple),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.purple),
                  onPressed: () {},
                ),
              ],
            ),
            body: StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('products').doc(product.id).snapshots(),
              builder: (context, snapshot) {
                // Update stock value if data is available
                if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  product.stock = data['stock'] ?? 0;
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product image with star
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(20),
                                  height: 250,
                                  child: product.imageUrl.startsWith('http') || product.imageUrl.startsWith('https')
                                      ? Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image_not_supported, size: 50),
                                      );
                                    },
                                  )
                                      : Image.asset(
                                    product.imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image_not_supported, size: 50),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 20,
                                  right: 20,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.yellow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.star, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            // Product name
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Product details in gray containers
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Updated In Stock container with real-time data
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF333333),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'In Stock: ${product.stock}',
                                      style: const TextStyle(color: Colors.lime),
                                    ),
                                  ),
                                  // Category container
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF333333),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Category: ${product.category}',
                                      style: const TextStyle(color: Colors.lime),
                                    ),
                                  ),
                                  // Price container
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF333333),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Price: ${product.price}',
                                      style: const TextStyle(color: Colors.lime),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bottom action buttons
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                stockSubscription?.cancel();
                                Navigator.pop(context);
                              },
                              child: const Text('Delete'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE2F163),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                if (product.stock > 0) {
                                  addToCart(product);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${product.name} added to cart')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Product out of stock')),
                                  );
                                }
                              },
                              child: const Text('Add To Cart'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bottom navigation bar
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFB29BFF),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: BottomNavigationBar(
                        currentIndex: _currentNavIndex,
                        onTap: _onItemTapped,
                        backgroundColor: Colors.transparent,
                        selectedItemColor: Colors.white,
                        unselectedItemColor: Colors.white60,
                        type: BottomNavigationBarType.fixed,
                        showSelectedLabels: false,
                        showUnselectedLabels: false,
                        elevation: 0,
                        iconSize: 28,
                        items: const [
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: ImageIcon(AssetImage('assets/icons/home.png')),
                            ),
                            label: 'Home',
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Icon(Icons.shopping_cart),
                            ),
                            label: 'Store',
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: ImageIcon(AssetImage('assets/icons/chat.png')),
                            ),
                            label: 'Chat',
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: ImageIcon(AssetImage('assets/icons/User.png')),
                            ),
                            label: 'Profile',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Show cart screen
  void showCartScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFF232323),
          appBar: AppBar(
            backgroundColor: const Color(0xFF232323),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.green),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.purple),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.purple),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.purple),
                onPressed: () {},
              ),
            ],
            title: const Text(
              'My Cart',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Cart items list
              Expanded(
                child: cart.isEmpty
                    ? const Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final product = cart.keys.elementAt(index);
                    final quantity = cart[product];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Product info
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('In Stock: ${product.stock}'),
                                  const SizedBox(height: 4),
                                  Text('Price: ${product.price}'),
                                ],
                              ),
                            ),
                          ),
                          // Product image
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 80,
                              padding: const EdgeInsets.all(8),
                              child: product.imageUrl.startsWith('http') || product.imageUrl.startsWith('https')
                                  ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported),
                                  );
                                },
                              )
                                  : Image.asset(
                                product.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Delete button
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  // Update stock when removing from cart
                                  _firestore.collection('products').doc(product.id).update({
                                    'stock': FieldValue.increment(cart[product] ?? 0)
                                  });
                                  cart.remove(product);
                                });
                                // Refresh the cart screen
                                Navigator.pop(context);
                                showCartScreen();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              ),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Calculate total and payment buttons
              if (cart.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Calculate total button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE2F163),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          setState(() {
                            // Just trigger a rebuild to show the total
                          });
                        },
                        child: const Text(
                          'Calculate total',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // لون مختلف للتمييز
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          // تأكيد الطلب مع الدفع نقدًا
                          _confirmCashPayment(context);
                        },
                        child: const Text(
                          'Pay With Cash',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Total display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          calculateTotal(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Pay with Visa button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A5ACD),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          showVisaPaymentDialog();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Pay With ',
                              style: TextStyle(fontSize: 18),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'VISA',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // Bottom navigation
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFB29BFF),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentNavIndex,
                  onTap: _onItemTapped,
                  backgroundColor: Colors.transparent,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white60,
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  elevation: 0,
                  iconSize: 28,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: ImageIcon(AssetImage('assets/icons/home.png')),
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Icon(Icons.shopping_cart),
                      ),
                      label: 'Store',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: ImageIcon(AssetImage('assets/icons/chat.png')),
                      ),
                      label: 'Chat',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: ImageIcon(AssetImage('assets/icons/User.png')),
                      ),
                      label: 'Profile',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          // أيقونة السلة مع عرض عدد المنتجات
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  if (cart.isNotEmpty) {
                    showCartScreen();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Your cart is empty')),
                    );
                  }
                },
              ),
              if (totalItemsInCart() > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      totalItemsInCart().toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories from Firestore
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading categories'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // Extract unique categories
              Set<String> categorySet = {'All'};
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['category'] != null) {
                  categorySet.add(data['category'].toString());
                }
              }

              List<String> availableCategories = categorySet.toList();

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: availableCategories.map((category) => _buildCategoryButton(category)).toList(),
                  ),
                ),
              );
            },
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),

          // Product List from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No products available'));
                }

                // Convert to Product objects
                List<Product> allProducts = snapshot.data!.docs
                    .map((doc) => Product.fromFirestore(doc))
                    .toList();

                // Filter products based on search and category
                List<Product> filteredProducts = allProducts.where((product) {
                  final matchesCategory = selectedCategory == 'All' ||
                      product.category == selectedCategory;
                  final matchesSearch = product.name.toLowerCase()
                      .contains(searchController.text.toLowerCase());
                  return matchesCategory && matchesSearch;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(child: Text('No products match your criteria'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    Product product = filteredProducts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Product ID
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Product Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Price: ${product.price}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'In Stock: ${product.stock}',
                                      style: TextStyle(
                                        color: product.stock > 0 ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Product Image and Details Button
                              Column(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: product.imageUrl.startsWith('http') || product.imageUrl.startsWith('https')
                                        ? Image.network(
                                      product.imageUrl,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image_not_supported),
                                        );
                                      },
                                    )
                                        : Image.asset(
                                      product.imageUrl,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image_not_supported),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => showProductDetails(product),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: customPurple,
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    ),
                                    child: const Text('View Details'),
                                  ),
                                ],
                              ),
                              // Quantity Control (+ / -)
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                    onPressed: () => removeFromCart(product),
                                  ),
                                  Text(cart[product]?.toString() ?? '0'),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                    onPressed: product.stock > 0 ? () => addToCart(product) : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Replace floatingActionButton with bottomNavigationBar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFB29BFF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          iconSize: 28,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ImageIcon(AssetImage('assets/icons/home.png')),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Icon(Icons.shopping_cart), // Store icon
              ),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ImageIcon(AssetImage('assets/icons/chat.png')),
              ),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ImageIcon(AssetImage('assets/icons/User.png')),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
