import 'package:flutter/material.dart';
import 'package:untitled/Home__Page/CalorieCalculator.dart';
import '00_home_page.dart';

// Product model with overridden == and hashCode for correct Map functionality
class Product {
  final String name;
  final String price;
  final String category;
  final String description;
  final String imageUrl; // Added image URL property

  Product({
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.imageUrl, // Required image URL
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.name == name && other.price == price;
  }

  @override
  int get hashCode => name.hashCode ^ price.hashCode;
}

// Main supplements store page
class SupplementsStorePage extends StatefulWidget {
  @override
  _SupplementsStorePageState createState() => _SupplementsStorePageState();
}

class _SupplementsStorePageState extends State<SupplementsStorePage> {
  // Custom colors
  final Color customPurple = const Color(0xFFB892FF);
  final Color backgroundColor = Colors.black;
  final Color cardColor = Colors.white;
  final Color textColor = Colors.black;

  // Search controller
  final TextEditingController searchController = TextEditingController();

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
    // Additional products can be added here
  ];

  // Shopping cart
  Map<Product, int> cart = {};

  // Add product to cart
  void addToCart(Product product) {
    setState(() {
      if (cart.containsKey(product)) {
        cart[product] = cart[product]! + 1;
      } else {
        cart[product] = 1;
      }
    });
  }

  // Total items in cart
  int totalItemsInCart() {
    return cart.values.fold(0, (prev, amount) => prev + amount);
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
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              if (cart.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckoutPage(cart: cart)),
                ).then((_) => setState(() {}));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Your cart is empty')),
                );
              }
            },
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
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Text(
              'Our Products',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Search bar
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
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),

          // Product list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                Product product = products[index];
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),

                          // Product info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Price: ${product.price}',
                                  style: TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Product image and more button
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                child: Image.asset(
                                  product.imageUrl,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: Icon(Icons.image_not_supported),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  addToCart(product);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: customPurple,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  'More...',
                                  style: TextStyle(color: Colors.black),
                                ),
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

          // Bottom navigation bar
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: customPurple,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.home, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.star, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.person, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Checkout page
class CheckoutPage extends StatefulWidget {
  final Map<Product, int> cart;
  const CheckoutPage({Key? key, required this.cart}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Map<Product, int> checkoutCart;
  final Color customPurple = const Color(0xFFB892FF);

  @override
  void initState() {
    super.initState();
    checkoutCart = Map.from(widget.cart);
  }

  double calculateTotal() {
    double total = 0;
    checkoutCart.forEach((product, quantity) {
      double price = double.tryParse(product.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      total += price * quantity;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: customPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: checkoutCart.keys.length,
              itemBuilder: (context, index) {
                Product product = checkoutCart.keys.elementAt(index);
                int quantity = checkoutCart[product]!;
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(product.name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      product.price,
                      style: TextStyle(color: customPurple),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, color: customPurple),
                          onPressed: () {
                            setState(() {
                              if (quantity > 1) {
                                checkoutCart[product] = quantity - 1;
                              } else {
                                checkoutCart.remove(product);
                              }
                            });
                          },
                        ),
                        Text(
                          quantity.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: customPurple),
                          onPressed: () {
                            setState(() {
                              checkoutCart[product] = quantity + 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: EGP ${calculateTotal().toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Order Confirmed'),
                        content: const Text('Your order has been placed successfully!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Return to previous page
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Confirm Order',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}