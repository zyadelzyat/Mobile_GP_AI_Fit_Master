// [File: admin_dashboard.dart]

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage

import 'package:image_picker/image_picker.dart'; // Import Image Picker

import 'package:permission_handler/permission_handler.dart'; // Import Permission Handler

import 'package:intl/intl.dart'; // Used for date formatting

import 'package:device_info_plus/device_info_plus.dart';

import 'dart:io' show Platform;

class AdminDashboard extends StatefulWidget {

  const AdminDashboard({super.key});

  @override

  State createState() => _AdminDashboardState();

}

class _AdminDashboardState extends State {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance; // Initialize Firebase Storage

  final FirebaseAuth _auth = FirebaseAuth.instance;
// ... (other final fields remain the same)
  final _formKey = GlobalKey<FormState>(); // Form key for user edit dialog

  final _addProductFormKey = GlobalKey<FormState>(); // Form key for add product dialog

  final TextEditingController _searchController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker(); // Initialize Image Picker

// State variable for the picked image file for adding/editing products

  File? _pickedProductImage;

// Controllers for adding/editing product details

  final TextEditingController _productNameController = TextEditingController();

  final TextEditingController _productPriceController = TextEditingController();

// Color constants

  final Color purpleColor = const Color(0xFFB3A0FF);

  final Color darkColor = const Color(0xFF232323);

  final Color yellowColor = const Color(0xFFE2F163);

  final Color lightGrayColor = const Color(0xFFE0E0E0);

// 0: Home, 1: User Management (Full), 2: Product Payment, 3: Products

  int _currentPageIndex = 0; // Start on the Home page

  @override

  void dispose() {
// ... (dispose methods remain the same)
    _searchController.dispose();

    _productNameController.dispose();

    _productPriceController.dispose();

    super.dispose();

  }

// --- Permission Handling ---

  Future _requestPhotosPermission() async {

    Permission permission;

    if (Platform.isAndroid) {

      var androidInfo = await DeviceInfoPlugin().androidInfo;

      int sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) { // Android 13+

        permission = Permission.photos;

      } else { // Older Android versions

        permission = Permission.storage;

      }
    } else { // iOS or other platforms

      permission = Permission.photos;

    }

    PermissionStatus status = await permission.status;

    if (status.isGranted || status.isLimited) {

      return true;

    } else {

      status = await permission.request();

      if (status.isGranted || status.isLimited) {

        return true;

      } else {

        if (status.isPermanentlyDenied) {

          if (mounted) {

            await showDialog(

              context: context,

              builder: (context) => AlertDialog(

                backgroundColor: darkColor,
// ... (rest of permission dialog remains the same)
                title: Text('Permission Required', style: TextStyle(color: purpleColor)),

                content: Text(

                    'This app needs access to your photos to upload images. Please enable it in settings.',

                    style: TextStyle(color: Colors.white70)),

                actions: [

                  TextButton(

                      onPressed: () => Navigator.pop(context),

                      child: Text('Cancel', style: TextStyle(color: purpleColor))),

                  TextButton(

                      onPressed: () {

                        openAppSettings();

                        Navigator.pop(context);

                      },

                      child: Text('Open Settings', style: TextStyle(color: purpleColor))),

                ],

              ),

            );

          }
        } else {

          if (mounted) {

            ScaffoldMessenger.of(context).showSnackBar(

              SnackBar(

                content: Text('Photos permission is required to upload images.'),

                action: SnackBarAction(

                  label: 'Retry',

                  onPressed: () => _requestPhotosPermission(),

                ),

              ),

            );

          }
        }
        return false;

      }
    }
  }

// --- Image Picking ---

  Future _pickImage() async {

    bool granted = await _requestPhotosPermission();

    if (!granted) {

      return;

    }

    try {

      final pickedFile = await _imagePicker.pickImage(
// ... (rest of image picking logic remains the same)
        source: ImageSource.gallery,

        imageQuality: 80, // Compress image to 80% quality

      );

      if (pickedFile != null) {

        File imageFile = File(pickedFile.path);

// Check if the file exists and is readable

        if (await imageFile.exists()) {

          setState(() {

            _pickedProductImage = imageFile;

          });

        } else {

          if (mounted) {

            ScaffoldMessenger.of(context).showSnackBar(

              const SnackBar(content: Text('Selected image is not accessible. Please try another.')),

            );

          }
        }
      }
    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(content: Text('Error picking image: $e')),

        );

      }
    }
  }

// --- Image Upload to Firebase Storage ---

  Future<String?> _uploadImage(File imageFile) async {

    try {

      if (!await imageFile.exists()) {

        if (mounted) {

          ScaffoldMessenger.of(context).showSnackBar(

            const SnackBar(content: Text('Selected image file is not accessible.')),

          );

        }
        return null;

      }

      String fileName = 'product_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
// ... (rest of image upload logic remains the same)
      Reference storageReference = _storage.ref().child(fileName);

      UploadTask uploadTask = storageReference.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(content: Text('Failed to upload image. Please try again.')),

        );

      }
      print('Error uploading image: $e');

      return null;

    }
  }

// Method to get the admin's name dynamically

  String _getAdminName() {

    final User? user = _auth.currentUser;

    if (user != null) {

      if (user.displayName != null && user.displayName!.isNotEmpty) {

        return user.displayName!;

      } else if (user.email != null && user.email!.isNotEmpty) {

// Fallback to part of the email if display name is not set

        return user.email!.split('@')[0];

      }
    }
    return "Admin"; // Default name if no user info is available

  }

// Helper to get the title for the current page

  String _getPageTitle() {
// ... (getPageTitle logic remains the same)
    switch (_currentPageIndex) {

      case 1:

        return 'User Management';

      case 2:

        return 'Product Payment'; // Placeholder title

      case 3:

        return 'Products';

      case 0:

      default:

        return 'Admin Dashboard';

    }
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

            if (_currentPageIndex == 0) // Show subtitle only on Home

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

            onPressed: () {

/* Implement search */

            },

          ),

          IconButton(

            icon: Icon(Icons.notifications, color: purpleColor),

            onPressed: () {
// ... (rest of AppBar actions remain the same)
/* Implement notifications */

            },

          ),

          IconButton(

            icon: Icon(Icons.person, color: purpleColor),

            onPressed: () {

/* Implement profile */

            },

          ),

        ],

      ),

      body: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

// Horizontal Navigation Buttons

          Container(

            padding: const EdgeInsets.symmetric(vertical: 16.0),

            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [

                _buildNavButton('User Management', Icons.people, 1),

                Container(height: 20, width: 1, color: Colors.grey[700]),

                _buildNavButton('Product Payment', Icons.payment, 2), // Placeholder

                Container(height: 20, width: 1, color: Colors.grey[700]),

                _buildNavButton('Products', Icons.shopping_bag, 3),

              ],

            ),

          ),

// Stats Cards - Only show on Home Page (_currentPageIndex == 0)

          if (_currentPageIndex == 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // MODIFIED: Added margin
              decoration: BoxDecoration(
                color: purpleColor, // Purple background for the stats row
                borderRadius: BorderRadius.circular(12.0), // MODIFIED: Changed to rounded corners
              ),
// ... (padding and child Row remain the same)
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),

              child: Row(

                children: [

                  Expanded(child: _buildMembersStatsCard()),

                  const SizedBox(width: 16),

                  Expanded(child: _buildMembershipRevenueStatsCard()),

                ],

              ),

            ),

// Content Area

          Expanded(

            child: _getContentBasedOnIndex(),

          ),

        ],

      ),

      bottomNavigationBar: BottomNavigationBar(

        backgroundColor: purpleColor.withOpacity(0.8),

        selectedItemColor: Colors.white,

        unselectedItemColor: Colors.white70,

        currentIndex: _currentPageIndex == 0 ? 0 : (_currentPageIndex == 1 ? 2 : 1), // Basic logic to highlight a relevant icon

        items: const [

          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"), // Generic menu

          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),

        ],

        onTap: (index) {

          if (index == 0) { // Home icon

            setState(() {

              _currentPageIndex = 0;

            });

          } else if (index == 2) { // Users icon navigates to User Management
// ... (rest of bottomNavigationBar onTap logic remains the same)
            setState(() {

              _currentPageIndex = 1;

            });

          }

// Add logic for other bottom nav items if needed

        },

      ),

      floatingActionButton: _currentPageIndex == 3 // Show FAB only on Products page

          ? FloatingActionButton(

        onPressed: _showAddProductDialog,

        backgroundColor: yellowColor,

        child: Icon(Icons.add, color: darkColor),

      )

          : null,

    );

  }

  Widget _getContentBasedOnIndex() {

    if (_currentPageIndex == 0) { // Home Page

      return Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Padding(

            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),

            child: Text(

              "Overview", // Title for the user table on home page

              style: TextStyle(

                color: yellowColor, // Use yellow for standout titles

                fontSize: 24,

                fontWeight: FontWeight.bold,

              ),

            ),

          ),

          Expanded(

            child: _buildUsersTable(showFullDetails: false), // Show summarized table

          ),

        ],

      );

    } else if (_currentPageIndex == 1) { // User Management

      return _buildUsersTable(showFullDetails: true); // Show detailed table
// ... (rest of _getContentBasedOnIndex logic remains the same)
    } else if (_currentPageIndex == 2) { // Product Payment

      return _buildPaymentsSection(); // Placeholder

    } else if (_currentPageIndex == 3) { // Products

      return _buildProductsSection();

    }

// Fallback for any other index

    return Container();

  }

  Widget _buildNavButton(String title, IconData icon, int index) {

    bool isSelected = _currentPageIndex == index;

    return InkWell(

      onTap: () {

        setState(() {

          _currentPageIndex = index;

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
// ... (rest of _buildMembersStatsCard logic remains the same)
// Assuming each document in 'users' collection is a member

        final memberCount = snapshot.data!.docs.length.toString();

        return _buildStatsCard("Members", memberCount);

      },

    );

  }

// Updated Revenue Card to calculate total membership revenue

  Widget _buildMembershipRevenueStatsCard() {

    return StreamBuilder<QuerySnapshot>(

      stream: _firestore.collection('users').snapshots(),

      builder: (context, snapshot) {

        if (snapshot.hasError) {

          return _buildStatsCard("Revenue (USD)", "Error");

        }

        if (!snapshot.hasData) {

          return _buildStatsCard("Revenue (USD)", "Loading...");

        }

// Calculate total revenue based on membership fees

        double totalRevenue = 0;

        for (var doc in snapshot.data!.docs) {

          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

// Check if user has an active membership

          if (userData['membershipStatus'] == 'active') {

// You can set different prices based on membership type or use a default

            double membershipFee = 0;

            String membershipType = userData['membershipType'] ?? 'basic';
// ... (rest of _buildMembershipRevenueStatsCard logic remains the same)
// Set different prices based on membership type

            switch (membershipType.toLowerCase()) {

              case 'premium':

                membershipFee = 50; // Example price

                break;

              case 'standard':

                membershipFee = 30; // Example price

                break;

              case 'basic':

              default:

                membershipFee = 20; // Example price

                break;

            }

            totalRevenue += membershipFee;

          }
        }
// Format revenue with dollar sign

        final formattedRevenue = '\$${totalRevenue.toStringAsFixed(0)}';

        return _buildStatsCard("Revenue (USD)", formattedRevenue);

      },

    );

  }

  Widget _buildStatsCard(String title, String value) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: lightGrayColor, // Use light gray for card background

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

// fontWeight: FontWeight.w600, // Slightly bolder title

            ),

          ),

          const SizedBox(height: 8),

          Text(
// ... (rest of _buildStatsCard logic remains the same)
            value,

            style: const TextStyle(

              color: Colors.black, // Darker value text for contrast

              fontSize: 32,

              fontWeight: FontWeight.bold,

            ),

          ),

        ],

      ),

    );

  }

  Widget _buildUsersTable({required bool showFullDetails}) {

    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 16),

      decoration: BoxDecoration(

        color: Colors.white.withOpacity(0.9), // Slightly transparent white

        borderRadius: BorderRadius.circular(12),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.1),

            blurRadius: 8,

            offset: const Offset(0, 4),

          ),

        ],

      ),

      child: ClipRRect( // Clip content to rounded corners

        borderRadius: BorderRadius.circular(12),

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
// ... (rest of _buildUsersTable logic remains the same)
            final users = snapshot.data!.docs;

            if (users.isEmpty) {

              return const Center(

                  child: Text('No users found', style: TextStyle(color: Colors.black)));

            }

            return Scrollbar( // Added Scrollbar for better UX on web/desktop

              thumbVisibility: true, // Always show scrollbar when scrollable

              thickness: 6.0,

              radius: const Radius.circular(10),

              child: SingleChildScrollView( // For vertical scroll if content overflows

                scrollDirection: Axis.horizontal, // Enable horizontal scrolling for the table

                child: SingleChildScrollView( // For vertical scrolling of the table itself

                  child: DataTable(

                    headingRowColor: MaterialStateProperty.all(Colors.grey[200]), // Light grey header

                    dataRowColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {

                      if (states.contains(MaterialState.selected)) {

                        return Theme.of(context).colorScheme.primary.withOpacity(0.08);

                      }

                      return null; // Use default value for other states and odd/even rows

                    }),

                    columnSpacing: 20, // Spacing between columns
// ... (rest of DataTable properties and columns/rows logic remains the same)
                    horizontalMargin: 20, // Margin at the start and end of rows

                    headingRowHeight: 50, // Height of the header row

                    dataRowMinHeight: 60, // Min height of data rows

                    dataRowMaxHeight: 60, // Max height of data rows

                    showCheckboxColumn: false, // No checkboxes

                    columns: showFullDetails

                        ? [

                      const DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Goal', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Height', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Weight', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Coach', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
// ... (rest of full details columns remain the same)
                      const DataColumn(label: Text('Payment Type', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Membership Status', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Diseases', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Creation Date', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),

                    ]

                        : [ // Summarized view columns

                      const DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),

                      const DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))), // e.g., creation date
// ... (rest of summarized columns remain the same)
                      const DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),

                    ],

                    rows: List.generate(

                      users.length,

                          (index) {

                        final user = users[index];

                        final data = user.data() as Map<String, dynamic>;

// Safely parse dateOfBirth

                        final dateOfBirth = data['dateOfBirth'] != null

                            ? (data['dateOfBirth'] is Timestamp

                            ? (data['dateOfBirth'] as Timestamp).toDate()

                            : DateTime.tryParse(data['dateOfBirth'].toString()))

                            : null;

                        final formattedFullDob = dateOfBirth != null ? DateFormat('MMM dd, yyyy').format(dateOfBirth) : 'N/A';

                        final creationDate = data['createdAt'] != null

                            ? (data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : null)

                            : null;

                        final formattedCreationDate = creationDate != null ? DateFormat('yyyy-MM-dd HH:mm').format(creationDate) : 'N/A';

// Handle 'disease' and 'diseases' fields

                        String diseases = 'N/A';

                        if (data['disease'] != null) {

                          diseases = data['disease'].toString();

                        } else if (data['diseases'] != null) {
// ... (rest of data parsing logic remains the same)
                          if (data['diseases'] is String) {

                            diseases = data['diseases'];

                          } else if (data['diseases'] is List) {

                            diseases = (data['diseases'] as List).join(', ');

                          } else {

                            diseases = data['diseases'].toString();

                          }
                        }
                        String phoneNumber = data['phone'] ?? data['phoneNumber'] ?? 'N/A';

                        final userName = data['displayName'] ?? data['firstName'] ?? data['email']?.split('@')[0] ?? 'User';

                        final userEmail = data['email'] ?? 'N/A';

                        final userRole = data['role'] ?? 'User';

                        final membershipPaymentType = data['membershipPaymentType'] ?? 'N/A';

                        final membershipStatus = data['membershipStatus'] ?? 'N/A';

                        if (showFullDetails) {

                          return DataRow(

                            color: MaterialStateProperty.resolveWith((Set<MaterialState> states) {

                              return index % 2 == 0 ? Colors.grey.withOpacity(0.1) : Colors.white; // Zebra striping

                            }),

                            cells: [

                              DataCell(SizedBox(width: 100, child: Text(userName, overflow: TextOverflow.ellipsis))),

                              DataCell(Text(data['gender'] ?? 'N/A')),
// ... (rest of full details DataCell widgets remain the same)
                              DataCell(SizedBox(width: 100, child: Text(data['goal'] ?? 'N/A', overflow: TextOverflow.ellipsis))),

                              DataCell(Text(data['height']?.toString() ?? 'N/A')),

                              DataCell(Text(data['weight']?.toString() ?? 'N/A')),

                              DataCell(Text(phoneNumber)),

                              DataCell(Text(data['coachName'] ?? 'None')),

                              DataCell(Text(userRole)),

                              DataCell(Text(membershipPaymentType)),

                              DataCell(Text(membershipStatus)),

                              DataCell(SizedBox(width: 120, child: Text(diseases, overflow: TextOverflow.ellipsis))),

                              DataCell(SizedBox(width: 150, child: Text(userEmail, overflow: TextOverflow.ellipsis))),

                              DataCell(Text(formattedFullDob)),

                              DataCell(Text(formattedCreationDate)),

                              DataCell(

                                Row(

                                  mainAxisSize: MainAxisSize.min,

                                  children: [

                                    IconButton(

                                      icon: const Icon(Icons.edit, color: Colors.black, size: 20),

                                      onPressed: () => _showEditUserDialog(user),

                                      constraints: const BoxConstraints(), // Remove extra padding

                                      padding: const EdgeInsets.all(8), // Minimal padding

                                    ),

                                    IconButton(
// ... (rest of action IconButtons remain the same)
                                      icon: const Icon(Icons.delete, color: Colors.black, size: 20),

                                      onPressed: () => _deleteUser(user.id),

                                      constraints: const BoxConstraints(),

                                      padding: const EdgeInsets.all(8),

                                    ),

                                    if (membershipPaymentType == 'cash' && membershipStatus == 'pending_approval')

                                      Padding(

                                        padding: const EdgeInsets.only(left: 8.0),

                                        child: ElevatedButton(

                                          onPressed: () => _approveCashMembership(user.id),

                                          style: ElevatedButton.styleFrom(

                                            backgroundColor: Colors.green,

                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Smaller button

                                          ),

                                          child: Text('Approve', style: TextStyle(fontSize: 12, color: Colors.white)),

                                        ),

                                      ),

                                  ],

                                ),

                              ),

                            ],

                          );

                        } else { // Summarized view

                          return DataRow(

                            color: MaterialStateProperty.resolveWith((Set<MaterialState> states) {

                              return index % 2 == 0 ? Colors.grey.withOpacity(0.1) : Colors.white; // Zebra striping

                            }),

                            cells: [

                              DataCell(Text(userName)),

                              DataCell(Text(userRole)),

                              DataCell(Text(formattedCreationDate)),

                              DataCell(Text(userEmail)),

                            ],

                          );

                        }
                      },

                    ),

                  ),

                ),

              ),
// ... (end of _buildUsersTable)
            );

          },

        ),

      ),

    );

  }

  Widget _buildPaymentsSection() {

// Placeholder for Product Payment section

    return Center(

      child: Text(

        'Product Payment Section',

        style: TextStyle(color: Colors.white, fontSize: 20),

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

          return const Center(

              child: Text('No products found',

                  style: TextStyle(color: Colors.white)));

        }

        return GridView.builder(

          padding: const EdgeInsets.all(16.0),

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(

            crossAxisCount: 2, // Number of columns

            crossAxisSpacing: 16.0, // Horizontal space between cards
// ... (rest of _buildProductsSection and dialogs logic remains the same, unchanged from original)
            mainAxisSpacing: 16.0, // Vertical space between cards

            childAspectRatio: 0.75, // Width to height ratio of cards

          ),

          itemCount: products.length,

          itemBuilder: (context, index) {

            final productDocument = products[index];

            final productData = productDocument.data() as Map<String, dynamic>;

            final productName = productData['name'] ?? 'No Name';

            final productPrice = productData['price']?.toString() ?? 'N/A';

            final productImageUrl = productData['imageUrl'] ?? ''; // Handle null or empty URL

            return Card(

              color: lightGrayColor, // Light background for product cards

              elevation: 4.0,

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(8.0),

              ),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [

                  Expanded(

                    child: productImageUrl.isNotEmpty

                        ? Image.network(

                      productImageUrl,

                      fit: BoxFit.cover,

                      loadingBuilder: (BuildContext context, Widget child,

                          ImageChunkEvent? loadingProgress) {

                        if (loadingProgress == null) return child;

                        return Center(
                          child: CircularProgressIndicator(

                            value: loadingProgress.expectedTotalBytes != null

                                ? loadingProgress.cumulativeBytesLoaded /

                                loadingProgress.expectedTotalBytes!

                                : null,

                          ),

                        );

                      },

                      errorBuilder: (context, error, stackTrace) =>

                          Container( // Placeholder for image load error

                              color: Colors.grey[300],

                              child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),

                    )

                        : Container( // Placeholder if no image URL

                        color: Colors.grey[300],

                        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),

                  ),

                  Padding(

                    padding: const EdgeInsets.all(8.0),

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text(

                          productName,

                          style: const TextStyle(

                            fontWeight: FontWeight.bold,

                            fontSize: 16.0,

                            color: Colors.black87,

                          ),

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                        ),

                        const SizedBox(height: 4.0),

                        Text(

                          'Price: $productPrice',

                          style: TextStyle(

                            fontSize: 14.0,

                            color: darkColor, // Dark text for price

                          ),

                        ),
                        const SizedBox(height: 4.0),

                        Text(

                          'Stock: ${productData['stock'] ?? 0}',

                          style: TextStyle(

                            fontSize: 14.0,

                            color: (productData['stock'] ?? 0) > 0 ? Colors.green : Colors.red,

                          ),

                        ),

                      ],

                    ),

                  ),

                  Padding(

                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),

                    child: Row(

                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align icons

                      mainAxisSize: MainAxisSize.min,

                      children: [

                        IconButton(

                          icon: const Icon(Icons.edit, color: Colors.black54),

                          onPressed: () {

                            _showEditProductDialog(productDocument);

                          },

                          tooltip: 'Edit Product',

                          padding: EdgeInsets.zero, // Remove default padding

                          constraints: BoxConstraints(), // Remove default constraints

                        ),

                        IconButton(

                          icon: const Icon(Icons.delete, color: Colors.redAccent),

                          onPressed: () {

                            _deleteProduct(productDocument.id);

                          },

                          tooltip: 'Delete Product',

                          padding: EdgeInsets.zero,

                          constraints: BoxConstraints(),

                        ),

                      ],

                    ),

                  ),

                ],

              ),

            );

          },

        );

      },

    );

  }

  void _showAddProductDialog() {
    _productNameController.clear();

    _productPriceController.clear();

    _pickedProductImage = null; // Reset picked image

    final TextEditingController _imageUrlController = TextEditingController(); // For URL input

    final TextEditingController _stockController = TextEditingController();

    String _previewImageUrl = ''; // State for URL preview

    bool _isPreviewVisible = false;

    showDialog(

      context: context,

      builder: (context) => StatefulBuilder( // Use StatefulBuilder for dialog internal state

        builder: (BuildContext context, StateSetter dialogSetState) {

          return AlertDialog(

            backgroundColor: darkColor,

            title: Text('Add New Product', style: TextStyle(color: purpleColor)),

            content: SingleChildScrollView(

              child: Form(

                key: _addProductFormKey,

                child: Column(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    TextFormField(

                      controller: _productNameController,
                      decoration: InputDecoration(labelText: 'Product Name', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))),

                      style: const TextStyle(color: Colors.white),

                      validator: (value) => value!.isEmpty ? 'Required' : null,

                    ),

                    TextFormField(

                      controller: _productPriceController,

                      decoration: InputDecoration(labelText: 'Price', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))),

                      style: const TextStyle(color: Colors.white),

                      keyboardType: TextInputType.number,

                      validator: (value) {

                        if (value!.isEmpty) return 'Required';

                        if (double.tryParse(value) == null) return 'Enter a valid number';

                        return null;

                      },

                    ),

                    TextFormField(

                      controller: _stockController,
                      decoration: InputDecoration(labelText: 'Stock Quantity', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))),

                      style: const TextStyle(color: Colors.white),

                      keyboardType: TextInputType.number,

                      validator: (value) {

                        if (value!.isEmpty) return 'Required';

                        if (int.tryParse(value) == null) return 'Enter a valid number';

                        return null;

                      },

                    ),

                    const SizedBox(height: 16),

// Image URL input

                    TextFormField(

                      controller: _imageUrlController,

                      decoration: InputDecoration(labelText: 'Image URL', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))),

                      style: const TextStyle(color: Colors.white),

                      validator: (value) => value!.isEmpty ? 'Required' : null,

                    ),

                    const SizedBox(height: 8),
                    ElevatedButton(

                      onPressed: () {

                        dialogSetState(() { // Update dialog state

                          _previewImageUrl = _imageUrlController.text;

                          _isPreviewVisible = true;

                        });

                      },

                      style: ElevatedButton.styleFrom(backgroundColor: yellowColor),

                      child: Text('Preview Image', style: TextStyle(color: darkColor)),

                    ),

                    if (_isPreviewVisible)

                      Container(

                        height: 150,

                        width: double.infinity,

                        margin: const EdgeInsets.only(top: 10),

                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),

                        child: _previewImageUrl.isNotEmpty

                            ? Image.network(

                          _previewImageUrl,

                          fit: BoxFit.contain,

                          loadingBuilder: (context, child, loadingProgress) {

                            if (loadingProgress == null) return child;

                            return Center(child: CircularProgressIndicator());

                          },

                          errorBuilder: (context, error, stackTrace) => Center(child: Text('Invalid image URL', style: TextStyle(color: Colors.red))),

                        )

                            : Center(child: Text('Enter a URL to preview', style: TextStyle(color: Colors.grey))),

                      ),

                  ],

                ),

              ),
            ),

            actions: [

              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: purpleColor))),

              ElevatedButton(

                onPressed: () async {

                  if (_addProductFormKey.currentState!.validate()) {

// String? imageUrl = _pickedProductImage != null ? await _uploadImage(_pickedProductImage!) : null;

                    String imageUrl = _imageUrlController.text; // Use URL directly

                    if (imageUrl.isNotEmpty) { // Check if URL is provided

                      try {

                        Map<String, dynamic> newProductData = {

                          'name': _productNameController.text,

                          'price': double.tryParse(_productPriceController.text),

                          'imageUrl': imageUrl,

                          'stock': int.tryParse(_stockController.text) ?? 0,

                          'createdAt': FieldValue.serverTimestamp(),

                        };

                        await _firestore.collection('products').add(newProductData);

                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added successfully!')));

                        if (mounted) Navigator.pop(context);

                      } catch (e) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add product: $e')));

                      }

                    } else {

                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image URL is required.')));

                    }
                  } else {

                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));

                  }
                },

                style: ElevatedButton.styleFrom(backgroundColor: purpleColor),

                child: const Text('Save', style: TextStyle(color: Colors.white)),

              ),

            ],

          );

        },

      ),

    ).then((_) { // Clear controllers when dialog is dismissed

      _productNameController.clear();

      _productPriceController.clear();

// _imageUrlController.clear(); // This is local to dialog

// _stockController.clear(); // This is local to dialog

      _pickedProductImage = null; // Reset

    });

  }

  void _showEditProductDialog(DocumentSnapshot product) {

    final productData = product.data() as Map<String, dynamic>;
    final TextEditingController editProductNameController = TextEditingController(text: productData['name']);

    final TextEditingController editProductPriceController = TextEditingController(text: productData['price']?.toString());

    final TextEditingController editImageUrlController = TextEditingController(text: productData['imageUrl']); // For URL

    final TextEditingController editStockController = TextEditingController(text: productData['stock']?.toString() ?? '0');

    _pickedProductImage = null; // Reset for editing

    String _previewImageUrl = productData['imageUrl'] ?? ''; // State for URL preview

    bool _isPreviewVisible = true; // Show existing image initially

    showDialog(

      context: context,

      builder: (context) => StatefulBuilder( // Use StatefulBuilder for dialog internal state

        builder: (BuildContext context, StateSetter dialogSetState) {

          return AlertDialog(

            backgroundColor: darkColor,

            title: Text('Edit Product', style: TextStyle(color: purpleColor)),

            content: SingleChildScrollView(
              child: Form( // Added Form for validation if needed

                child: Column(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    TextFormField(

                      controller: editProductNameController,

                      decoration: InputDecoration(labelText: 'Product Name', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))),

                      style: const TextStyle(color: Colors.white),

                      validator: (value) => value!.isEmpty ? 'Required' : null,

                    ),

                    TextFormField(

                      controller: editProductPriceController,

                      decoration: InputDecoration(labelText: 'Price', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))),

                      style: const TextStyle(color: Colors.white),

                      keyboardType: TextInputType.number,

                      validator: (value) {
                        if (value!.isEmpty) return 'Required';

                        if (double.tryParse(value) == null) return 'Enter a valid number';

                        return null;

                      },

                    ),

                    TextFormField(

                      controller: editStockController,

                      decoration: InputDecoration(labelText: 'Stock Quantity', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))),

                      style: const TextStyle(color: Colors.white),

                      keyboardType: TextInputType.number,

                      validator: (value) {

                        if (value!.isEmpty) return 'Required';

                        if (int.tryParse(value) == null) return 'Enter a valid number';

                        return null;

                      },

                    ),

                    const SizedBox(height: 16),

// Image URL input for editing

                    TextFormField(

                      controller: editImageUrlController,
                      decoration: InputDecoration(labelText: 'Image URL', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))),

                      style: const TextStyle(color: Colors.white),

                      validator: (value) => value!.isEmpty ? 'Required' : null,

                    ),

                    const SizedBox(height: 8),

                    ElevatedButton(

                      onPressed: () {

                        dialogSetState(() { // Update dialog state

                          _previewImageUrl = editImageUrlController.text;

                          _isPreviewVisible = true;

                        });

                      },

                      style: ElevatedButton.styleFrom(backgroundColor: yellowColor),

                      child: Text('Preview Image', style: TextStyle(color: darkColor)),

                    ),

                    if (_isPreviewVisible)

                      Container(

                        height: 150,

                        width: double.infinity,

                        margin: const EdgeInsets.only(top: 10),

                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),

                        child: _previewImageUrl.isNotEmpty

                            ? Image.network(

                          _previewImageUrl,
                          fit: BoxFit.contain,

                          loadingBuilder: (context, child, loadingProgress) {

                            if (loadingProgress == null) return child;

                            return Center(child: CircularProgressIndicator());

                          },

                          errorBuilder: (context, error, stackTrace) => Center(child: Text('Invalid image URL', style: TextStyle(color: Colors.red))),

                        )

                            : Center(child: Text('Enter a URL to preview', style: TextStyle(color: Colors.grey))),

                      ),

                  ],

                ),

              ),

            ),

            actions: [

              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: purpleColor))),

              ElevatedButton(

                onPressed: () async {

// Basic validation for demonstration

                  if (editProductNameController.text.isNotEmpty &&

                      editProductPriceController.text.isNotEmpty && double.tryParse(editProductPriceController.text) != null &&

                      editStockController.text.isNotEmpty && int.tryParse(editStockController.text) != null &&

                      editImageUrlController.text.isNotEmpty

                  ) {

// String? newImageUrl;

// if (_pickedProductImage != null) {
// newImageUrl = await _uploadImage(_pickedProductImage!);

// }

                    String newImageUrl = editImageUrlController.text; // Use URL directly

                    if (newImageUrl.isNotEmpty) {

                      try {

                        Map<String, dynamic> updatedProductData = {

                          'name': editProductNameController.text,

                          'price': double.tryParse(editProductPriceController.text),

                          'imageUrl': newImageUrl, // Use new or existing URL

                          'stock': int.tryParse(editStockController.text) ?? 0,

                          'updatedAt': FieldValue.serverTimestamp(),

                        };

                        await _firestore.collection('products').doc(product.id).update(updatedProductData);

                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product updated successfully!')));

                        if (mounted) Navigator.pop(context);

                      } catch (e) {

                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update product: $e')));

                      }
                    } else {

                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image URL is required.')));

                    }
                  } else {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields correctly.')));

                  }
                },

                style: ElevatedButton.styleFrom(backgroundColor: purpleColor),

                child: const Text('Save', style: TextStyle(color: Colors.white)),

              ),

            ],

          );

        },

      ),

    );

  }

  Future<void> _deleteProduct(String productId) async {

    final bool confirmDelete = await showDialog<bool>(

      context: context,

      builder: (context) => AlertDialog(

        backgroundColor: darkColor,

        title: Text('Confirm Delete', style: TextStyle(color: purpleColor)),

        content: const Text('Are you sure you want to delete this product?', style: TextStyle(color: Colors.white70)),

        actions: [

          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: TextStyle(color: purpleColor))),

          ElevatedButton(

            onPressed: () => Navigator.pop(context, true),

            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),

            child: const Text('Delete', style: TextStyle(color: Colors.white)),

          ),

        ],

      ),
    ) ?? false;

    if (confirmDelete) {

      try {

        await _firestore.collection('products').doc(productId).delete();

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted successfully!')));

      } catch (e) {

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete product: $e')));

      }
    }
  }

  void _showEditUserDialog(DocumentSnapshot user) {

    final data = user.data() as Map<String, dynamic>;

    final String userName = data['displayName'] ?? data['firstName'] ?? data['email']?.split('@')[0] ?? 'User';

    final TextEditingController nameController = TextEditingController(text: userName);

    final TextEditingController genderController = TextEditingController(text: data['gender']);

    final TextEditingController goalController = TextEditingController(text: data['goal']);

    final TextEditingController heightController = TextEditingController(text: data['height']?.toString());
    final TextEditingController weightController = TextEditingController(text: data['weight']?.toString());

    String phoneNumber = data['phone'] ?? data['phoneNumber'] ?? '';

    final TextEditingController phoneController = TextEditingController(text: phoneNumber);

    final TextEditingController coachController = TextEditingController(text: data['coachName']);

    final TextEditingController roleController = TextEditingController(text: data['role'] ?? 'User');

// New controllers for membership fields

    final TextEditingController paymentTypeController = TextEditingController(text: data['membershipPaymentType'] ?? '');

    final TextEditingController membershipStatusController = TextEditingController(text: data['membershipStatus'] ?? '');

    final TextEditingController membershipTypeController = TextEditingController(text: data['membershipType'] ?? 'basic'); // Default to basic if null

    String diseases = '';

    if (data['disease'] != null) {

      diseases = data['disease'].toString();
    } else if (data['diseases'] != null) {

      diseases = data['diseases'] is List ? (data['diseases'] as List).join(', ') : data['diseases'].toString();

    }

    final TextEditingController diseasesController = TextEditingController(text: diseases);

    final TextEditingController emailController = TextEditingController(text: data['email']);

    DateTime? selectedDate;

    if (data['dateOfBirth'] != null) {

      selectedDate = data['dateOfBirth'] is Timestamp

          ? (data['dateOfBirth'] as Timestamp).toDate()

          : DateTime.tryParse(data['dateOfBirth'].toString());

    }

    final TextEditingController dobController = TextEditingController(

      text: selectedDate != null ? DateFormat('MMM dd, yyyy').format(selectedDate) : '',

    );

    showDialog(

      context: context,

      builder: (context) => AlertDialog(

        backgroundColor: darkColor,

        title: Text('Edit User', style: TextStyle(color: purpleColor)),

        content: SingleChildScrollView(

          child: Form(

            key: _formKey,

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: [
                TextFormField(controller: nameController, decoration: InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))), style: const TextStyle(color: Colors.white), validator: (value) => value!.isEmpty ? 'Required' : null),

                TextFormField(controller: genderController, decoration: InputDecoration(labelText: 'Gender', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))), style: const TextStyle(color: Colors.white)),
                TextFormField(controller: goalController, decoration: InputDecoration(labelText: 'Goal', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))), style: const TextStyle(color: Colors.white)),

                TextFormField(controller: heightController, decoration: InputDecoration(labelText: 'Height (cm)', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number),
                TextFormField(controller: weightController, decoration: InputDecoration(labelText: 'Weight (kg)', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number),

                TextFormField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone Number', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.phone),
                TextFormField(controller: coachController, decoration: InputDecoration(labelText: 'Coach Name (optional)', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))), style: const TextStyle(color: Colors.white)),

                TextFormField(controller: roleController, decoration: InputDecoration(labelText: 'Role', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))), style: const TextStyle(color: Colors.white), validator: (value) => value!.isEmpty ? 'Required' : null),

// Membership Fields
                TextFormField(controller: paymentTypeController, decoration: InputDecoration(labelText: 'Payment Type (e.g., cash, visa)', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))), style: const TextStyle(color: Colors.white)),

                TextFormField(controller: membershipStatusController, decoration: InputDecoration(labelText: 'Membership Status (e.g., active, pending_approval)', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))), style: const TextStyle(color: Colors.white)),
                TextFormField(controller: membershipTypeController, decoration: InputDecoration(labelText: 'Membership Type (e.g., basic, standard, premium)', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))), style: const TextStyle(color: Colors.white)),

                TextFormField(controller: diseasesController, decoration: InputDecoration(labelText: 'Diseases (comma-separated)', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))), style: const TextStyle(color: Colors.white)),
                TextFormField(controller: emailController, decoration: InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor))), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.emailAddress, validator: (value) => value!.isEmpty ? 'Required' : null),

                TextFormField(

                  controller: dobController,

                  readOnly: true,

                  decoration: InputDecoration(labelText: 'Date of Birth', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)), prefixIcon: Icon(Icons.calendar_today, color: purpleColor), hintText: 'Select your date of birth', hintStyle: TextStyle(color: Colors.white54)),

                  style: const TextStyle(color: Colors.white),

                  onTap: () async {
                    final DateTime? picked = await showDatePicker(

                      context: context,

                      initialDate: selectedDate ?? DateTime.now(),

                      firstDate: DateTime(1900),

                      lastDate: DateTime.now(),

                      builder: (context, child) {

                        return Theme(

                          data: ThemeData.dark().copyWith(

                              colorScheme: ColorScheme.dark(primary: purpleColor, onPrimary: Colors.white, surface: darkColor, onSurface: Colors.white),

                              dialogBackgroundColor: darkColor

                          ),

                          child: child!,

                        );

                      },

                    );

                    if (picked != null) {

// No need for setState here as dobController is updated directly

                      selectedDate = picked;

                      dobController.text = DateFormat('MMM dd, yyyy').format(picked);

                    }
                  },

                  validator: (value) {

                    if (value!.isEmpty) return 'Date of birth is required';

                    return null;

                  },

                ),

              ],

            ),

          ),

        ),

        actions: [

          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: purpleColor))),

          ElevatedButton(

            onPressed: () async {

              if (_formKey.currentState!.validate()) {

                try {

                  Map<String, dynamic> updateData = {
                    'displayName': nameController.text,

                    'gender': genderController.text.isEmpty ? null : genderController.text,

                    'goal': goalController.text.isEmpty ? null : goalController.text,

                    'height': heightController.text.isEmpty ? null : double.tryParse(heightController.text),

                    'weight': weightController.text.isEmpty ? null : double.tryParse(weightController.text),

                    'phone': phoneController.text.isEmpty ? null : phoneController.text, // Use 'phone' for consistency

                    'phoneNumber': phoneController.text.isEmpty ? null : phoneController.text, // Keep both if needed by other parts

                    'coachName': coachController.text.isEmpty ? null : coachController.text,

                    'role': roleController.text,

                    'membershipPaymentType': paymentTypeController.text.isEmpty ? null : paymentTypeController.text,

                    'membershipStatus': membershipStatusController.text.isEmpty ? null : membershipStatusController.text,

                    'membershipType': membershipTypeController.text.isEmpty ? 'basic' : membershipTypeController.text,
                    'disease': diseasesController.text.isEmpty ? null : diseasesController.text, // Single string

                    'diseases': diseasesController.text.isEmpty ? null : diseasesController.text.split(',').map((e) => e.trim()).toList(), // List of strings

                    'email': emailController.text,

                    'dateOfBirth': selectedDate != null ? Timestamp.fromDate(selectedDate!) : null,

                    'updatedAt': FieldValue.serverTimestamp(),

                  };

                  await _firestore.collection('users').doc(user.id).update(updateData);

                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User updated successfully!')));

                  if (mounted) Navigator.pop(context);

// Dispose controllers

                  nameController.dispose(); genderController.dispose(); goalController.dispose();

                  heightController.dispose(); weightController.dispose(); phoneController.dispose();

                  coachController.dispose(); roleController.dispose(); diseasesController.dispose();

                  emailController.dispose(); dobController.dispose(); paymentTypeController.dispose();
                  membershipStatusController.dispose(); membershipTypeController.dispose();

                } catch (e) {

                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update user: $e')));

                }
              }
            },

            style: ElevatedButton.styleFrom(backgroundColor: purpleColor),

            child: const Text('Save', style: TextStyle(color: Colors.white)),

          ),

        ],

      ),

    );

  }

  Future<void> _deleteUser(String userId) async {

    final bool confirmDelete = await showDialog<bool>(

      context: context,

      builder: (context) => AlertDialog(

        backgroundColor: darkColor,

        title: Text('Confirm Delete', style: TextStyle(color: purpleColor)),

        content: const Text('Are you sure you want to delete this user?', style: TextStyle(color: Colors.white70)),

        actions: [

          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: TextStyle(color: purpleColor))),

          ElevatedButton(

            onPressed: () => Navigator.pop(context, true),

            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),

          ),

        ],

      ),

    ) ?? false;

    if (confirmDelete) {

      try {

// It's generally not recommended to delete Firebase Auth users directly from the client-side admin panel

// without proper backend security rules or a Cloud Function.

// This will only delete the Firestore document.

        await _firestore.collection('users').doc(userId).delete();

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User data deleted successfully from Firestore! Auth user may still exist.')));

      } catch (e) {

        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete user data: $e')));

      }
    }
  }

// Method to approve cash membership

  Future<void> _approveCashMembership(String userId) async {

    final bool confirmApprove = await showDialog<bool>(

      context: context,

      builder: (context) => AlertDialog(

        backgroundColor: darkColor,

        title: Text('Confirm Approval', style: TextStyle(color: purpleColor)),
        content: const Text(

          'Are you sure you want to approve this cash membership?',

          style: TextStyle(color: Colors.white70),

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(context, false),

            child: Text('Cancel', style: TextStyle(color: purpleColor)),

          ),

          ElevatedButton(

            onPressed: () => Navigator.pop(context, true),

            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

            child: const Text('Approve', style: TextStyle(color: Colors.white)),

          ),

        ],

      ),

    ) ?? false;

    if (confirmApprove) {

      try {

        await _firestore.collection('users').doc(userId).update({

          'membershipStatus': 'active', // Status changed to active

          'updatedAt': FieldValue.serverTimestamp(),

        });

        if (mounted) {

          ScaffoldMessenger.of(context).showSnackBar(

            const SnackBar(content: Text('Membership approved successfully!')),

          );

        }
      } catch (e) {

        if (mounted) {

          ScaffoldMessenger.of(context).showSnackBar(

            SnackBar(content: Text('Failed to approve membership: $e')),

          );

        }
      }
    }
  }
}
