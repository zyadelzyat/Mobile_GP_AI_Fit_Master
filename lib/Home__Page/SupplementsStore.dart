import 'package:flutter/material.dart';
import 'package:untitled/Home__Page/CalorieCalculator.dart'; // تأكد من أن هذا المسار صحيح

// نموذج المنتج مع تجاوز (==) والـ hashCode ليعمل بشكل صحيح في Map
class Product {
  final String name;
  final String price; // السعر كنص مع رمز العملة (مثلاً "EGP 350")
  final String category;
  final String description;

  Product({
    required this.name,
    required this.price,
    required this.category,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.name == name && other.price == price;
  }

  @override
  int get hashCode => name.hashCode ^ price.hashCode;
}

// صفحة المتجر الرئيسية
class SupplementsStorePage extends StatefulWidget {
  @override
  _SupplementsStorePageState createState() => _SupplementsStorePageState();
}

class _SupplementsStorePageState extends State<SupplementsStorePage> {
  // اللون البنفسجي الفاتح المخصص
  final Color customPurple = const Color(0xFFB892FF);

  // قائمة التصنيفات مع إضافة تصنيف الفيتامينات
  List<String> categories = ['All', 'Bulking', 'Cutting', 'Vitamins'];
  String selectedCategory = 'All';

  // قائمة المنتجات مع إضافة منتجات جديدة ضمن فئة الفيتامينات وبعض المنتجات الإضافية
  List<Product> products = [
    // منتجات مكملات لبناء العضلات (Bulking)
    Product(
      name: 'Whey Protein',
      price: 'EGP 350',
      category: 'Bulking',
      description: 'High-quality protein for muscle building.',
    ),
    Product(
      name: 'Mass Gainer',
      price: 'EGP 400',
      category: 'Bulking',
      description: 'Increase calorie intake for weight gain.',
    ),
    // منتجات عامة
    Product(
      name: 'Creatine',
      price: 'EGP 200',
      category: 'All',
      description: 'Improves strength and workout performance.',
    ),
    // منتجات لتخسيس (Cutting)
    Product(
      name: 'Citrulline',
      price: 'EGP 250',
      category: 'Cutting',
      description: 'Enhances blood flow and reduces fatigue.',
    ),
    Product(
      name: 'Pre-Workout',
      price: 'EGP 300',
      category: 'Cutting',
      description: 'Boosts energy and focus before training.',
    ),
    // منتجات فيتامينات
    Product(
      name: 'Multivitamin',
      price: 'EGP 150',
      category: 'Vitamins',
      description: 'Supports overall health and wellness.',
    ),
    Product(
      name: 'Vitamin C',
      price: 'EGP 80',
      category: 'Vitamins',
      description: 'Boosts immune system and fights free radicals.',
    ),
    Product(
      name: 'Vitamin D',
      price: 'EGP 90',
      category: 'Vitamins',
      description: 'Promotes bone health and immune support.',
    ),
  ];

  // السلة: خريطة تربط كل منتج بالكمية المختارة
  Map<Product, int> cart = {};

  // دالة لإضافة المنتج للسلة أو زيادة الكمية إذا كان موجوداً
  void addToCart(Product product) {
    setState(() {
      if (cart.containsKey(product)) {
        cart[product] = cart[product]! + 1;
      } else {
        cart[product] = 1;
      }
    });
  }

  // دالة لزيادة كمية منتج معين
  void incrementProduct(Product product) {
    setState(() {
      if (cart.containsKey(product)) {
        cart[product] = cart[product]! + 1;
      }
    });
  }

  // دالة لإنقاص كمية منتج معين، وحذفه إذا أصبحت الكمية 0
  void decrementProduct(Product product) {
    setState(() {
      if (cart.containsKey(product)) {
        int current = cart[product]!;
        if (current > 1) {
          cart[product] = current - 1;
        } else {
          cart.remove(product);
        }
      }
    });
  }

  // دالة لحساب إجمالي عدد العناصر في السلة (للشارة)
  int totalItemsInCart() {
    return cart.values.fold(0, (prev, amount) => prev + amount);
  }

  @override
  Widget build(BuildContext context) {
    // تصفية المنتجات بحسب التصنيف المختار
    List<Product> displayedProducts = selectedCategory == 'All'
        ? products
        : products.where((p) => p.category == selectedCategory || p.category == 'All').toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // عند الضغط على السهم يتم الرجوع إلى صفحة CalorieCalculatorPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CalorieCalculatorPage(),
              ),
            );
          },
        ),
        title: const Text('Supplements Store'),
        backgroundColor: customPurple,
        actions: [
          // أيقونة السلة مع الشارة في أعلى اليمين
          IconButton(
            onPressed: () {
              if (cart.isEmpty) {
                // إذا كانت السلة فارغة، عرض رسالة تنبيه
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please add products to your cart.'),
                  ),
                );
              } else {
                // الانتقال إلى صفحة Checkout إذا كانت السلة غير فارغة
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(cart: cart),
                  ),
                ).then((_) {
                  // تحديث حالة السلة بعد العودة
                  setState(() {});
                });
              }
            },
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${totalItemsInCart()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط التصنيفات (Categories)
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                String category = categories[index];
                bool isSelected = category == selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? customPurple : Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // عرض المنتجات في شبكة (GridView)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // عمودين
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: displayedProducts.length,
              itemBuilder: (context, index) {
                Product product = displayedProducts[index];
                bool inCart = cart.containsKey(product);
                int quantity = inCart ? cart[product]! : 0;

                return Card(
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم المنتج
                        Text(
                          product.name,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        // السعر
                        Text(
                          product.price,
                          style: TextStyle(color: customPurple, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        // وصف مختصر
                        Text(
                          product.description,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const Spacer(),
                        // زر إضافة المنتج أو تعديل الكمية إذا كان موجوداً بالسلة
                        Center(
                          child: inCart
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove, color: customPurple),
                                onPressed: () {
                                  decrementProduct(product);
                                },
                              ),
                              Text(
                                quantity.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                icon: Icon(Icons.add, color: customPurple),
                                onPressed: () {
                                  incrementProduct(product);
                                },
                              ),
                            ],
                          )
                              : ElevatedButton(
                            onPressed: () {
                              addToCart(product);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: customPurple,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // قسم السلة في أسفل الصفحة مع السعر الإجمالي وزر "Checkout"
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
                  'Total: EGP ${cart.entries.fold(0.0, (total, entry) {
                    double price = double.tryParse(entry.key.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
                    return total + price * entry.value;
                  }).toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (cart.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please add products to your cart.'),
                        ),
                      );
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(cart: cart),
                        ),
                      );
                      setState(() {}); // تحديث حالة السلة بعد العودة
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Checkout',
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

// صفحة Checkout لعرض العناصر المختارة مع إمكانية تعديل الكميات
class CheckoutPage extends StatefulWidget {
  final Map<Product, int> cart;
  const CheckoutPage({Key? key, required this.cart}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // نسخة محلية من السلة للتعديل
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
          // عرض السعر الإجمالي وزر تأكيد الطلب
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
