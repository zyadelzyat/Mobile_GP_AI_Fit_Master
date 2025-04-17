import 'package:flutter/material.dart';
import '00_home_page.dart';

// Product model with overridden == and hashCode for correct Map functionality
class Product {
  final String name;
  final String price;
  final String category;
  final String description;
  final String imageUrl;
  int quantity; // لإحتساب الكمية المطلوبة لكل منتج

  Product({
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.imageUrl,
    this.quantity = 1,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.name == name && other.price == price;
  }

  @override
  int get hashCode => name.hashCode ^ price.hashCode;
}

class SupplementsStorePage extends StatefulWidget {
  const SupplementsStorePage({super.key});

  @override
  _SupplementsStorePageState createState() => _SupplementsStorePageState();
}

class _SupplementsStorePageState extends State<SupplementsStorePage> {
  final Color customPurple = const Color(0xFFB892FF);
  final Color backgroundColor = const Color(0xFF232323);
  final Color cardColor = Colors.white;
  final Color textColor = Colors.black;

  final TextEditingController searchController = TextEditingController();
  String selectedCategory = 'All'; // Default to 'All' category

  // Product list with images
  List<Product> products = [
    Product(
      name: 'Creatine Monohydrate',
      price: '1200 EG',
      category: 'Bulking',
      description: 'Improves strength and workout performance.',
      imageUrl: 'assets/images/creatine.jpg',
    ),
    Product(
      name: 'Optimum Nutrition Gold Standard 100% Whey',
      price: '5000 EG',
      category: 'Bulking',
      description: 'High-quality protein for muscle building.',
      imageUrl: 'assets/images/whey.jpg',
    ),
    Product(
      name: 'Hexagonal Dumbbell Two Pieces Each Weighing 5 Kg',
      price: '999 EG',
      category: 'Equipment',
      description: 'Perfect for home workouts and strength training.',
      imageUrl: 'assets/images/dumbbells.jpg',
    ),
    Product(
      name: 'Adidas Performance Sport Bag For Women',
      price: '500 EG',
      category: 'Accessories',
      description: 'Stylish and functional gym bag.',
      imageUrl: 'assets/images/bag.jpg',
    ),
  ];

  // Shopping cart: يخزن الكمية المطلوبة لكل منتج
  Map<Product, int> cart = {};

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

  // Filtered product list based on search and category
  List<Product> get filteredProducts {
    final query = searchController.text.toLowerCase();
    return products.where((product) {
      final matchesCategory = selectedCategory == 'All' || product.category == selectedCategory;
      final matchesSearch = product.name.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Add product to cart (بناءً على الكمية المحددة للمنتج)
  void addToCart(Product product) {
    setState(() {
      if (cart.containsKey(product)) {
        cart[product] = cart[product]! + 1;
      } else {
        cart[product] = 1;
      }
    });
  }

  // Remove product from cart
  void removeFromCart(Product product) {
    setState(() {
      if (cart.containsKey(product) && cart[product]! > 1) {
        cart[product] = cart[product]! - 1;
      } else {
        cart.remove(product);
      }
    });
  }
// تفريغ السلة
  void clearCart() {
    setState(() {
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

  // عرض نافذة الدفع
  void showPaymentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You chose to pay by Cash')),
                  );

                  clearCart(); // ✅ تصفير السلة بعد الدفع كاش
                },
                child: const Text('Cash'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  showVisaPaymentDialog(); // Show Visa form
                },
                child: const Text('Visa'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // نافذة إدخال بيانات الفيزا
  void showVisaPaymentDialog() {
    TextEditingController cardNumberController = TextEditingController();
    TextEditingController expiryDateController = TextEditingController();
    TextEditingController cvvController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Visa Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: cardNumberController,
                  decoration: const InputDecoration(
                    hintText: 'Card Number',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: expiryDateController,
                  decoration: const InputDecoration(
                    hintText: 'Expiry Date (MM/YY)',
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cvvController,
                  decoration: const InputDecoration(
                    hintText: 'CVV',
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close form
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // تقدر تضيف هنا تحقق من البيانات إذا حبيت

                Navigator.pop(context); // Close form

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Visa Payment Details Submitted')),
                );

                clearCart(); // ✅ تصفير السلة بعد الدفع بالفيزا
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Your Cart'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...cart.entries.map((entry) => ListTile(
                                title: Text(entry.key.name),
                                subtitle: Text('${entry.key.price} x ${entry.value}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => removeFromCart(entry.key),
                                ),
                              )),
                              const Divider(),
                              Text('Total: ${calculateTotal()}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Dismiss dialog
                              },
                              child: const Text('Continue Shopping'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                showPaymentDialog(); // Show payment options
                              },
                              child: const Text('Checkout'),
                            ),
                          ],
                        );
                      },
                    );
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
          // Category Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryButton('All'),
                  _buildCategoryButton('Bulking'),
                  _buildCategoryButton('Equipment'),
                  _buildCategoryButton('Accessories'),
                ],
              ),
            ),
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

          // Product List
          Expanded(
            child: ListView.builder(
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
                              ],
                            ),
                          ),

                          // Product Image and Details Button
                          Column(
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Image.asset(
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
                                onPressed: () {
                                  // Show product details in a dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(product.name),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 200,
                                                child: Image.asset(
                                                  product.imageUrl,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[300],
                                                      child: const Icon(Icons.image_not_supported, size: 50),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text('Price: ${product.price}', style: const TextStyle(fontSize: 18)),
                                              const SizedBox(height: 8),
                                              Text('Category: ${product.category}'),
                                              const SizedBox(height: 8),
                                              Text('Description: ${product.description}'),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Close'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              addToCart(product);
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('${product.name} added to cart')),
                                              );
                                            },
                                            child: const Text('Add to Cart'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
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
                                onPressed: () => addToCart(product),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Checkout Button at bottom right
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (cart.isNotEmpty) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Checkout'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...cart.entries.map((entry) => ListTile(
                        title: Text(entry.key.name),
                        subtitle: Text('${entry.key.price} x ${entry.value}'),
                      )),
                      const Divider(),
                      Text('Total: ${calculateTotal()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Continue Shopping'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showPaymentDialog();
                      },
                      child: const Text('Proceed to Payment'),
                    ),
                  ],
                );
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Your cart is empty')),
            );
          }
        },
        backgroundColor: customPurple,
        label: Text('Checkout (${totalItemsInCart()})'),
        icon: const Icon(Icons.shopping_cart),
      ),
    );
  }
}