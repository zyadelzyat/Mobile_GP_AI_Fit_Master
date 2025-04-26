import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  String? _currentImageUrl;

  // Color constants - updated to match the new design
  final Color purpleColor = const Color(0xFFB3A0FF);
  final Color darkColor = const Color(0xFF232323);
  final Color yellowColor = const Color(0xFFE2F163);
  final Color lightGrayColor = const Color(0xFFE0E0E0);

  int _currentIndex = 0;

  // Method to get the admin's name dynamically
  String _getAdminName() {
    final User? user = _auth.currentUser;
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        return user.displayName!;
      } else if (user.email != null && user.email!.isNotEmpty) {
        return user.email!.split('@')[0];
      }
    }
    return "Admin";
  }

  @override
  Widget build(BuildContext context) {
    final String userName = _getAdminName();

    return Scaffold(
      backgroundColor: darkColor,
      appBar: AppBar(
        backgroundColor: darkColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, $userName',
              style: TextStyle(
                color: purpleColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'It\'s time to challenge your limits.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: purpleColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: purpleColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person, color: purpleColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation tabs - updated to match new design with dividers
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton('User Management', Icons.people, 0),
                Container(
                  height: 20,
                  width: 1,
                  color: Colors.grey[700],
                ),
                _buildNavButton('Product Payment', Icons.payment, 1),
                Container(
                  height: 20,
                  width: 1,
                  color: Colors.grey[700],
                ),
                _buildNavButton('Products', Icons.shopping_bag, 2),
              ],
            ),
          ),

          // Stats cards - redesigned with softer colors
          Container(
            decoration: BoxDecoration(
              color: purpleColor.withOpacity(0.3),
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildMembersStatsCard(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard("Revenue", "\$200"),
                ),
              ],
            ),
          ),

          // Overview section - updated with yellow title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              "Overview",
              style: TextStyle(
                color: yellowColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // User table or other sections
          Expanded(
            child: _currentIndex == 0
                ? _buildUsersTable()
                : _currentIndex == 1
                    ? _buildPaymentsSection()
                    : _buildProductsSection(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: purpleColor.withOpacity(0.8),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: ""),
        ],
        onTap: (index) {},
      ),
    );
  }

  Widget _buildNavButton(String title, IconData icon, int index) {
    bool isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? purpleColor : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? purpleColor : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersStatsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildStatsCard("Members", "Error");
        }

        if (!snapshot.hasData) {
          return _buildStatsCard("Members", "Loading...");
        }

        final memberCount = snapshot.data!.docs.length.toString();
        return _buildStatsCard("Members", memberCount);
      },
    );
  }

  Widget _buildStatsCard(String title, String value) {
    // Updated to match the new design
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightGrayColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable() {
    // Updated table design to match screenshot
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.black)));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(
                child: Text('No users found',
                    style: TextStyle(color: Colors.black)));
          }

          return Column(
            children: [
              // Table header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Name',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Role',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Date',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Status',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Table rows
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final data = user.data() as Map<String, dynamic>;
                    final isActive =
                        data['status'] == 'active' || index % 2 == 0; // Demo logic
                    final createdAt = data['createdAt'] != null
                        ? (data['createdAt'] as Timestamp).toDate()
                        : DateTime.now();

                    return Container(
                      color: index % 2 == 0
                          ? Colors.grey[200]
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                data['displayName'] ??
                                    data['email']?.split('@')[0] ??
                                    'User',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                data['role'] ?? 'User',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                DateFormat('MMM dd, yyyy').format(createdAt),
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? purpleColor : Colors.grey,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  isActive ? 'Active' : 'Inactive',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentsSection() {
    return Center(
      child: Text(
        'Payment Management',
        style: TextStyle(color: purpleColor, fontSize: 24),
      ),
    );
  }

  Widget _buildProductsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white)));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;

        if (products.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No products found',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showAddProductDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purpleColor,
                ),
                child: const Text('Add New Product'),
              ),
            ],
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _showAddProductDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: purpleColor,
                ),
                child: const Text('Add New Product'),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final data = product.data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () => _showEditProductDialog(product),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              color: purpleColor.withOpacity(0.3),
                              child: data['imageUrl'] != null
                                  ? Image.network(
                                data['imageUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.image_not_supported,
                                        color: purpleColor),
                              )
                                  : Icon(Icons.image,
                                  size: 50, color: purpleColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'Unnamed Product',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${data['price']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(
                                    color: yellowColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white, size: 20),
                                      onPressed: () =>
                                          _showEditProductDialog(product),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.white, size: 20),
                                      onPressed: () => _deleteProduct(product.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      // Request necessary permissions first
      if (Platform.isAndroid) {
        // For Android 13+ (SDK 33+) we need photos permission
        if (await Permission.photos.status.isDenied) {
          await Permission.photos.request();
        }

        // For older Android versions, we need storage permission
        if (await Permission.storage.status.isDenied) {
          await Permission.storage.request();
        }
      }

      // Check if we have the permissions we need
      bool canProceed = false;
      if (Platform.isAndroid) {
        canProceed = await Permission.photos.isGranted ||
            await Permission.storage.isGranted;
      } else {
        // For iOS or other platforms
        canProceed = true;
      }

      if (canProceed) {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied. Cannot access photos.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String?> _uploadImage(String productId) async {
    if (_selectedImage == null) return null;

    try {
      final storageRef = _storage.ref().child('product_images/$productId.jpg');
      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();
      return imageUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  void _showAddProductDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    // Reset image selection
    setState(() {
      _selectedImage = null;
      _currentImageUrl = null;
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: darkColor,
          title: Text('Add New Product', style: TextStyle(color: purpleColor)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: purpleColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: purpleColor),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: purpleColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: purpleColor),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Required';
                      if (double.tryParse(value) == null)
                        return 'Enter a valid number';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: purpleColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: purpleColor),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                  ),
                  // Image picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Product Image:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: purpleColor),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_selectedImage!,
                                  fit: BoxFit.cover),
                            )
                                : Icon(Icons.image,
                                size: 50, color: purpleColor),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await _pickImage();
                                  // Update dialog UI
                                  setDialogState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: purpleColor,
                                ),
                                child: const Text('Pick Image'),
                              ),
                              if (_selectedImage != null)
                                TextButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                  child: Text(
                                    'Clear',
                                    style: TextStyle(color: purpleColor),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: purpleColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    // First add document to get an ID
                    final docRef = await _firestore.collection('products').add({
                      'name': nameController.text,
                      'price': double.parse(priceController.text),
                      'description': descController.text,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    // Then upload image if available
                    if (_selectedImage != null) {
                      final imageUrl = await _uploadImage(docRef.id);
                      if (imageUrl != null) {
                        await docRef.update({'imageUrl': imageUrl});
                      }
                    }

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Product added successfully'),
                        backgroundColor: purpleColor,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding product: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: purpleColor,
              ),
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      // Get product data to check if it has an image
      final productDoc =
      await _firestore.collection('products').doc(productId).get();
      final data = productDoc.data();

      // Delete the image from storage if it exists
      if (data != null && data['imageUrl'] != null) {
        try {
          await _storage.refFromURL(data['imageUrl']).delete();
        } catch (e) {
          // Log error but continue with document deletion
          print('Error deleting image: $e');
        }
      }

      // Delete the product document
      await _firestore.collection('products').doc(productId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Product deleted successfully'),
          backgroundColor: purpleColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  void _showEditProductDialog(DocumentSnapshot product) {
    final data = product.data() as Map<String, dynamic>;
    final TextEditingController nameController =
    TextEditingController(text: data['name']);
    final TextEditingController priceController =
    TextEditingController(text: data['price'].toString());
    final TextEditingController descController =
    TextEditingController(text: data['description'] ?? '');

    // Set current image URL if available
    setState(() {
      _selectedImage = null;
      _currentImageUrl = data['imageUrl'];
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: darkColor,
          title: Text('Edit Product', style: TextStyle(color: purpleColor)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: purpleColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: purpleColor),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: purpleColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: purpleColor),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Required';
                      if (double.tryParse(value) == null)
                        return 'Enter a valid number';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: purpleColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: purpleColor),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                  ),
                  // Image picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Product Image:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: purpleColor),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_selectedImage!,
                                  fit: BoxFit.cover),
                            )
                                : _currentImageUrl != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _currentImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                    Icon(Icons.image,
                                        size: 50,
                                        color: purpleColor),
                              ),
                            )
                                : Icon(Icons.image,
                                size: 50, color: purpleColor),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await _pickImage();
                                  // Update dialog UI
                                  setDialogState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: purpleColor,
                                ),
                                child: const Text('Pick Image'),
                              ),
                              if (_selectedImage != null || _currentImageUrl != null)
                                TextButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      _selectedImage = null;
                                      _currentImageUrl = null;
                                    });
                                  },
                                  child: Text(
                                    'Clear',
                                    style: TextStyle(color: purpleColor),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: purpleColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    // Prepare update data
                    Map<String, dynamic> updateData = {
                      'name': nameController.text,
                      'price': double.parse(priceController.text),
                      'description': descController.text,
                      'updatedAt': FieldValue.serverTimestamp(),
                    };

                    // Handle image update if new image selected
                    if (_selectedImage != null) {
                      final imageUrl = await _uploadImage(product.id);
                      if (imageUrl != null) {
                        updateData['imageUrl'] = imageUrl;
                      }
                    } else if (_currentImageUrl == null) {
                      // Image was cleared
                      updateData['imageUrl'] = FieldValue.delete();

                      // Also try to delete the old image from storage if it exists
                      try {
                        final oldImageUrl = data['imageUrl'];
                        if (oldImageUrl != null) {
                          await _storage.refFromURL(oldImageUrl).delete();
                        }
                      } catch (e) {
                        print('Error deleting old image: $e');
                      }
                    }

                    // Update the product
                    await _firestore
                        .collection('products')
                        .doc(product.id)
                        .update(updateData);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Product updated successfully'),
                        backgroundColor: purpleColor,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating product: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: purpleColor,
              ),
              child: const Text('Update Product'),
            ),
          ],
        ),
      ),
    );
  }
}