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
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Initialize Firebase Storage
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>(); // Form key for user edit dialog
  final _addProductFormKey = GlobalKey<FormState>(); // Form key for add product dialog
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker(); // Initialize Image Picker

  // State variable for the picked image file for adding/editing products
  File? _pickedProductImage;

  // Controllers for adding/editing product details
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  // We will handle image separately, so URL controller is less needed for upload flow


  // Color constants
  final Color purpleColor = const Color(0xFFB3A0FF);
  final Color darkColor = const Color(0xFF232323);
  final Color yellowColor = const Color(0xFFE2F163);
  final Color lightGrayColor = const Color(0xFFE0E0E0);

  // 0: Home, 1: User Management (Full), 2: Product Payment, 3: Products
  int _currentPageIndex = 0; // Start on the Home page

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _searchController.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    // Note: Controllers in dialogs are typically disposed when the dialog is closed,
    // but if you use state variables for them or keep references, dispose them here.
    super.dispose();
  }

  // --- Permission Handling ---
  Future<bool> _requestPhotosPermission() async {
    // Determine the appropriate permission based on the platform and Android version
    Permission permission;
    if (Platform.isAndroid) {
      // Check Android SDK version (API level)
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      int sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ (API 33+): Use granular media permissions
        permission = Permission.photos;
      } else {
        // Android 12 and below (API 32 and lower): Use legacy storage permission
        permission = Permission.storage;
      }
    } else {
      // iOS: Use photos permission
      permission = Permission.photos;
    }

    // Check current permission status
    PermissionStatus status = await permission.status;

    if (status.isGranted) {
      return true;
    } else if (status.isLimited) {
      // Limited access (e.g., iOS partial access or Android 14+ partial media access)
      // You can proceed with limited access or prompt the user to grant full access
      return true; // Adjust based on your app's needs
    } else if (status.isDenied) {
      // Request permission
      status = await permission.request();
      if (status.isGranted || status.isLimited) {
        return true;
      }
    }

    // Handle denied or permanently denied cases
    if (status.isPermanentlyDenied) {
      // Show dialog to guide user to settings
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: darkColor,
          title: Text('Permission Required', style: TextStyle(color: purpleColor)),
          content: Text(
            'This app needs access to your photos to upload images. Please enable it in settings.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: purpleColor)),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              child: Text('Open Settings', style: TextStyle(color: purpleColor)),
            ),
          ],
        ),
      );
      return false;
    } else {
      // Show a snackbar for temporary denial
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photos permission is required to upload images.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _requestPhotosPermission(), // Retry permission request
          ),
        ),
      );
      return false;
    }
  }


  // --- Image Picking ---
  Future<void> _pickImage() async {
    // Check and request permission
    bool granted = await _requestPhotosPermission();
    if (!granted) {
      return; // Permission error is handled in _requestPhotosPermission
    }

    try {
      // Pick image from gallery
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Reduce file size (optional, adjust as needed)
      );

      if (pickedFile != null) {
        // Verify file accessibility
        File imageFile = File(pickedFile.path);
        if (await imageFile.exists()) {
          setState(() {
            _pickedProductImage = imageFile; // Store the picked file
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected image is not accessible. Please try another.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // --- Image Upload to Firebase Storage ---
  Future<String?> _uploadImage(File imageFile) async {
    try {
      // Verify file exists before upload
      if (!await imageFile.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected image file is not accessible.')),
        );
        return null;
      }

      // Create a unique file name
      String fileName =
          'product_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      Reference storageReference = _storage.ref().child(fileName);

      // Upload the file
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image. Please try again.')),
      );
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
        return user.email!.split('@')[0];
      }
    }
    return "Admin";
  }

  // Helper to get the title for the current page
  String _getPageTitle() {
    switch (_currentPageIndex) {
      case 1:
        return 'User Management';
      case 2:
        return 'Product Payment';
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
              'Hi, $userName', // Always show "Hi, [Name]" in the AppBar
              style: TextStyle(
                color: purpleColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Show the tagline only on the Home page
            if (_currentPageIndex == 0)
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
              // Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: purpleColor),
            onPressed: () {
              // Implement notifications functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: purpleColor),
            onPressed: () {
              // Implement profile functionality
            },
          ),
        ],
      ),
      body: Column( // Use a column for the main body content structure
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Navigation tabs - Always visible below stats/appbar
          // Moved this up above the stats
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Buttons navigate to indices 1, 2, 3
                _buildNavButton('User Management', Icons.people, 1),
                Container(height: 20, width: 1, color: Colors.grey[700]),
                _buildNavButton('Product Payment', Icons.payment, 2),
                Container(height: 20, width: 1, color: Colors.grey[700]),
                _buildNavButton('Products', Icons.shopping_bag, 3),
              ],
            ),
          ),
          // Stats cards - Visible only on Home page (_currentPageIndex == 0)
          if (_currentPageIndex == 0)
            Container(
              decoration: BoxDecoration(
                color: purpleColor,
                borderRadius: BorderRadius.zero,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  Expanded(child: _buildMembersStatsCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatsCard("Revenue", "\$200")),
                ],
              ),
            ),

          // Dynamic Content Area (Overview/Tables/Sections)
          Expanded(
            child: _getContentBasedOnIndex(), // This method returns the content for the lower part
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: purpleColor.withOpacity(0.8),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        // Highlight the Home item if on the Home page (_currentPageIndex == 0)
        currentIndex: _currentPageIndex == 0 ? 0 : 1, // This can be adjusted based on which bottom nav item you want to highlight when not on Home
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Menu"), // Assuming this is for other options
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"), // Can potentially link to User Management directly
        ],
        onTap: (index) {
          // Handle bottom navigation taps
          if (index == 0) {
            setState(() {
              _currentPageIndex = 0; // Go to Home page
            });
          }
          // Add logic for other bottom nav items if they should navigate
          // Example: if index == 2, setState(() { _currentPageIndex = 1; }); // Go to User Management
        },
      ),
      // FloatingActionButton for adding products, visible only on the Products page
      floatingActionButton: _currentPageIndex == 3
          ? FloatingActionButton(
        onPressed: _showAddProductDialog, // Call the method to show the add product dialog
        backgroundColor: yellowColor,
        child: Icon(Icons.add, color: darkColor),
      )
          : null, // Hide FAB on other pages
    );
  }

  // Dynamic Content based on _currentPageIndex
  Widget _getContentBasedOnIndex() {
    if (_currentPageIndex == 0) {
      // Home Page specific content below the top navigation (Overview Title + Simplified Table)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview section title - Only on Home page
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

          // Simplified User Table on Home Page
          Expanded(
            child: _buildUsersTable(showFullDetails: false),
          ),
          // Removed the "View All Users" button as requested
        ],
      );
    } else if (_currentPageIndex == 1) {
      // User Management Page: Full User Table
      return _buildUsersTable(showFullDetails: true);
    } else if (_currentPageIndex == 2) {
      // Product Payment Page
      return _buildPaymentsSection();
    } else if (_currentPageIndex == 3) {
      // Products Page
      return _buildProductsSection();
    }
    return Container(); // Default empty container
  }

  // Updated _buildNavButton to use _currentPageIndex for highlighting
  Widget _buildNavButton(String title, IconData icon, int index) {
    // Highlight if the current page index matches the button's index
    // Note: This highlights buttons for pages 1, 2, 3. Home (index 0) is not highlighted by these buttons.
    bool isSelected = _currentPageIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _currentPageIndex = index; // Update to the selected page index (1, 2, or 3)
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightGrayColor,
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

  // Modified _buildUsersTable to use Creation Date and update simplified columns
  Widget _buildUsersTable({required bool showFullDetails}) {
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

          return Scrollbar(
            thumbVisibility: true,
            thickness: 6.0,
            radius: const Radius.circular(10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                  dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08);
                        }
                        return null;
                      }),
                  columnSpacing: 20,
                  horizontalMargin: 20,
                  headingRowHeight: 50,
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 60,
                  showCheckboxColumn: false,
                  columns: showFullDetails ? [
                    const DataColumn(
                        label: Text('Name',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('Gender',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('Goal',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('Height',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('Weight',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('Phone',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('Coach',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('Role',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('Diseases',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('Email',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('Date of Birth', // Keep Date of Birth
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('Creation Date', // Added Creation Date column
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('Actions',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ] : [
                    // Simplified columns: Name, Role, Date (Creation), Email
                    const DataColumn(
                        label: Text('Name',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('Role',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                        label: Text('Date', // This will show Creation Date
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(
                      // Using 'Email' as requested originally
                        label: Text('Email',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: List<DataRow>.generate(
                    users.length,
                        (index) {
                      final user = users[index];
                      final data = user.data() as Map<String, dynamic>;

                      // --- Get Date of Birth ---
                      final dateOfBirth = data['dateOfBirth'] != null
                          ? (data['dateOfBirth'] is Timestamp
                          ? (data['dateOfBirth'] as Timestamp).toDate()
                          : DateTime.tryParse(data['dateOfBirth'].toString()))
                          : null;
                      final formattedFullDob = dateOfBirth != null
                          ? DateFormat('MMM dd,yyyy').format(dateOfBirth)
                          : 'N/A';

                      // --- Get Creation Date ---
                      // Assuming 'createdAt' field exists and is a Timestamp
                      final creationDate = data['createdAt'] != null
                          ? (data['createdAt'] is Timestamp
                          ? (data['createdAt'] as Timestamp).toDate()
                          : null) // Handle cases where it might not be a Timestamp
                          : null;
                      final formattedCreationDate = creationDate != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(creationDate) // Format for creation date
                          : 'N/A';


                      String diseases = 'N/A';
                      if (data['disease'] != null) {
                        diseases = data['disease'].toString();
                      } else if (data['diseases'] != null) {
                        if (data['diseases'] is String) {
                          diseases = data['diseases'];
                        } else if (data['diseases'] is List) {
                          diseases = (data['diseases'] as List).join(', ');
                        } else {
                          diseases = data['diseases'].toString();
                        }
                      }

                      String phoneNumber = 'N/A';
                      if (data['phone'] != null) {
                        phoneNumber = data['phone'].toString();
                      } else if (data['phoneNumber'] != null) {
                        phoneNumber = data['phoneNumber'].toString();
                      }

                      final userName = data['displayName'] ??
                          data['firstName'] ??
                          data['email']?.split('@')[0] ??
                          'User';

                      final userEmail = data['email'] ?? 'N/A';
                      final userRole = data['role'] ?? 'User';


                      if (showFullDetails) {
                        // Full table row with all columns for User Management
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                return index % 2 == 0
                                    ? Colors.grey.withOpacity(0.1)
                                    : Colors.white;
                              }),
                          cells: [
                            DataCell(SizedBox(
                              width: 100,
                              child: Text(
                                userName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                            DataCell(Text(data['gender'] ?? 'N/A')),
                            DataCell(SizedBox(
                              width: 100,
                              child: Text(
                                data['goal'] ?? 'N/A',
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                            DataCell(Text(data['height']?.toString() ?? 'N/A')),
                            DataCell(Text(data['weight']?.toString() ?? 'N/A')),
                            DataCell(Text(phoneNumber)),
                            DataCell(Text(data['coachName'] ?? 'None')),
                            DataCell(Text(userRole)),
                            DataCell(SizedBox(
                              width: 120,
                              child: Text(
                                diseases,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                            DataCell(SizedBox(
                              width: 150,
                              child: Text(
                                userEmail,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                            DataCell(Text(formattedFullDob)), // Full Date of Birth format
                            DataCell(Text(formattedCreationDate)), // Creation Date column
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.black, size: 20),
                                    onPressed: () => _showEditUserDialog(user),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.black, size: 20),
                                    onPressed: () => _deleteUser(user.id),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Simplified row for Home page (Name, Role, Date (Creation), Email)
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                return index % 2 == 0
                                    ? Colors.grey.withOpacity(0.1)
                                    : Colors.white;
                              }),
                          cells: [
                            DataCell(Text(userName)),
                            DataCell(Text(userRole)),
                            DataCell(Text(formattedCreationDate)), // Simplified "Date" is Creation Date
                            DataCell(Text(userEmail)), // Email column
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          );
        },
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

  // Corrected _buildProductsSection layout using StreamBuilder from Firestore
  Widget _buildProductsSection() {
    return StreamBuilder<QuerySnapshot>(
      // Use the stream from your Firestore 'products' collection
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

        // Get the list of product documents
        final products = snapshot.data!.docs;

        if (products.isEmpty) {
          return const Center(
              child: Text('No products found',
                  style: TextStyle(color: Colors.white)));
        }

        // Build the GridView using data from the snapshot
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.75, // Adjust aspect ratio as needed
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final productDocument = products[index];
            final productData = productDocument.data() as Map<String, dynamic>;

            // Extract data from the document (assuming fields like 'name', 'price', 'imageUrl')
            final productName = productData['name'] ?? 'No Name';
            final productPrice = productData['price']?.toString() ?? 'N/A';
            final productImageUrl = productData['imageUrl'] ?? ''; // Assuming imageUrl is a string URL

            return Card(
              color: lightGrayColor,
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
                      errorBuilder: (context, error, stackTrace) => Container( // Show a placeholder or error icon
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                    )
                        : Container( // Placeholder if no image URL
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)
                    ),
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
                          productPrice,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: darkColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Optional: Add buttons for actions like "Edit" or "Delete"
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min, // Correct use of MainAxisSize.min
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black54),
                          onPressed: () {
                            // Implement edit product functionality using productDocument.id
                            _showEditProductDialog(productDocument);
                          },
                          tooltip: 'Edit Product',
                          padding: EdgeInsets.zero, // Remove default padding
                          constraints: BoxConstraints(), // Remove default constraints
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            // Implement delete product functionality using productDocument.id
                            _deleteProduct(productDocument.id);
                          },
                          tooltip: 'Delete Product',
                          padding: EdgeInsets.zero, // Remove default padding
                          constraints: BoxConstraints(), // Remove default constraints
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

  // --- Product Action Methods ---

  void _showAddProductDialog() {
    _productNameController.clear();
    _productPriceController.clear();
    setState(() {
      _pickedProductImage = null;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _productPriceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Required';
                    if (double.tryParse(value) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image, color: darkColor),
                  label: Text('Pick Image from Gallery', style: TextStyle(color: darkColor)),
                  style: ElevatedButton.styleFrom(backgroundColor: yellowColor),
                ),
                if (_pickedProductImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.file(_pickedProductImage!, height: 100),
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
              if (_addProductFormKey.currentState!.validate() && _pickedProductImage != null) {
                try {
                  String? imageUrl = await _uploadImage(_pickedProductImage!);
                  if (imageUrl != null) {
                    Map<String, dynamic> newProductData = {
                      'name': _productNameController.text,
                      'price': double.tryParse(_productPriceController.text),
                      'imageUrl': imageUrl,
                      'createdAt': FieldValue.serverTimestamp(),
                    };
                    await _firestore.collection('products').add(newProductData);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product added successfully!')),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add product: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields and select an image.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: purpleColor),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((_) {
      _productNameController.clear();
      _productPriceController.clear();
      setState(() {
        _pickedProductImage = null;
      });
    });
  }


  void _showEditProductDialog(DocumentSnapshot product) {
    final productData = product.data() as Map<String, dynamic>;
    final TextEditingController editProductNameController = TextEditingController(text: productData['name']);
    final TextEditingController editProductPriceController = TextEditingController(text: productData['price']?.toString());
    File? _editPickedProductImage;
    String? _currentProductImageUrl = productData['imageUrl'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter dialogSetState) {
          return AlertDialog(
            backgroundColor: darkColor,
            title: Text('Edit Product', style: TextStyle(color: purpleColor)),
            content: SingleChildScrollView(
              child: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: editProductNameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: editProductPriceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Required';
                        if (double.tryParse(value) == null) return 'Enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _pickImage();
                        if (_pickedProductImage != null) {
                          dialogSetState(() {
                            _editPickedProductImage = _pickedProductImage;
                          });
                        }
                      },
                      icon: Icon(Icons.image, color: darkColor),
                      label: Text('Pick New Image', style: TextStyle(color: darkColor)),
                      style: ElevatedButton.styleFrom(backgroundColor: yellowColor),
                    ),
                    if (_editPickedProductImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.file(_editPickedProductImage!, height: 100),
                      )
                    else if (_currentProductImageUrl != null && _currentProductImageUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.network(
                          _currentProductImageUrl!,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
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
                  if (editProductNameController.text.isNotEmpty &&
                      editProductPriceController.text.isNotEmpty &&
                      double.tryParse(editProductPriceController.text) != null &&
                      (_editPickedProductImage != null || _currentProductImageUrl != null)) {
                    try {
                      String? imageUrl = _currentProductImageUrl;
                      if (_editPickedProductImage != null) {
                        imageUrl = await _uploadImage(_editPickedProductImage!);
                      }
                      if (imageUrl != null) {
                        Map<String, dynamic> updatedProductData = {
                          'name': editProductNameController.text,
                          'price': double.tryParse(editProductPriceController.text),
                          'imageUrl': imageUrl,
                          'updatedAt': FieldValue.serverTimestamp(),
                        };
                        await _firestore.collection('products').doc(product.id).update(updatedProductData);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product updated successfully!')),
                        );
                        Navigator.pop(context);
                        editProductNameController.dispose();
                        editProductPriceController.dispose();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to upload image.')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update product: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields and ensure an image is selected.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: purpleColor),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    ).then((_) {
      setState(() {
        _pickedProductImage = null;
      });
    });
  }

  Future<void> _deleteProduct(String productId) async {
    // Show a confirmation dialog before deleting
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkColor,
        title: Text('Confirm Delete', style: TextStyle(color: purpleColor)),
        content: const Text('Are you sure you want to delete this product?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: purpleColor)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false; // Return false if the dialog is dismissed

    if (confirmDelete) {
      try {
        // Optional: Delete the image from storage before deleting the document
        // You would need to fetch the document first to get the image URL/path
        // final productDoc = await _firestore.collection('products').doc(productId).get();
        // final imageUrlToDelete = productDoc.data()?['imageUrl'];
        // if (imageUrlToDelete != null && imageUrlToDelete.isNotEmpty) {
        //    try {
        //       // Assuming the URL is a direct download URL, extract the path
        //       final imageRef = FirebaseStorage.instance.refFromURL(imageUrlToDelete);
        //       await imageRef.delete();
        //       print('Deleted image from storage: ${imageRef.fullPath}');
        //    } catch (e) {
        //       print('Error deleting old image from storage: $e');
        //       // Continue with document deletion even if image deletion fails
        //    }
        // }


        await _firestore.collection('products').doc(productId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete product: $e')),
        );
      }
    }
  }


  // --- User Action Methods ---
  void _showEditUserDialog(DocumentSnapshot user) {
    final data = user.data() as Map<String, dynamic>;

    final String userName = data['displayName'] ??
        data['firstName'] ??
        data['email']?.split('@')[0] ??
        'User';
    final TextEditingController nameController =
    TextEditingController(text: userName);
    final TextEditingController genderController =
    TextEditingController(text: data['gender']);
    final TextEditingController goalController =
    TextEditingController(text: data['goal']);
    final TextEditingController heightController =
    TextEditingController(text: data['height']?.toString());
    final TextEditingController weightController =
    TextEditingController(text: data['weight']?.toString());

    String phoneNumber = data['phone'] ?? data['phoneNumber'] ?? '';
    final TextEditingController phoneController =
    TextEditingController(text: phoneNumber);

    final TextEditingController coachController =
    TextEditingController(text: data['coachName']);
    final TextEditingController roleController =
    TextEditingController(text: data['role'] ?? 'User');

    String diseases = '';
    if (data['disease'] != null) {
      diseases = data['disease'].toString();
    } else if (data['diseases'] != null) {
      diseases = data['diseases'] is List
          ? (data['diseases'] as List).join(', ')
          : data['diseases'].toString();
    }
    final TextEditingController diseasesController =
    TextEditingController(text: diseases);

    final TextEditingController emailController =
    TextEditingController(text: data['email']);

    DateTime? selectedDate;
    if (data['dateOfBirth'] != null) {
      selectedDate = data['dateOfBirth'] is Timestamp
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : DateTime.tryParse(data['dateOfBirth'].toString());
    }
    final TextEditingController dobController = TextEditingController(
      text: selectedDate != null ? DateFormat('MMM dd,yyyy').format(selectedDate) : '',
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
              mainAxisSize: MainAxisSize.min, // Correct use of MainAxisSize.min
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                    focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: genderController,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                    focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                TextFormField(
                  controller: goalController,
                  decoration: InputDecoration(
                    labelText: 'Goal',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                    focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                TextFormField(
                  controller: heightController,
                  decoration: InputDecoration(
                    labelText: 'Height (cm)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                    focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: weightController,
                  decoration: InputDecoration(
                    labelText: 'Weight (kg)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                    focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                    focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: coachController,
                  decoration: InputDecoration(
                    labelText: 'Coach Name (optional)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                    focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                TextFormField(
                  controller: roleController,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                    focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: diseasesController,
                  decoration: InputDecoration(
                    labelText: 'Diseases (comma-separated)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                    focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                    focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: purpleColor)),
                    prefixIcon: Icon(Icons.calendar_today, color: purpleColor),
                    hintText: 'Select your date of birth',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
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
                            colorScheme: ColorScheme.dark(
                              primary: purpleColor,
                              onPrimary: Colors.white,
                              surface: darkColor,
                              onSurface: Colors.white,
                            ),
                            dialogBackgroundColor: darkColor,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                        dobController.text = DateFormat('MMM dd,yyyy').format(picked);
                      });
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: purpleColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  Map<String, dynamic> updateData = {
                    'displayName': nameController.text,
                    'gender':
                    genderController.text.isEmpty ? null : genderController.text,
                    'goal': goalController.text.isEmpty ? null : goalController.text,
                    'height': heightController.text.isEmpty
                        ? null
                        : double.tryParse(heightController.text),
                    'weight': weightController.text.isEmpty
                        ? null
                        : double.tryParse(weightController.text),
                    'phone':
                    phoneController.text.isEmpty ? null : phoneController.text,
                    'phoneNumber': // Update both phone fields for consistency
                    phoneController.text.isEmpty ? null : phoneController.text,
                    'coachName':
                    coachController.text.isEmpty ? null : coachController.text,
                    'role': roleController.text,
                    'disease': // Update both disease fields for consistency
                    diseasesController.text.isEmpty ? null : diseasesController.text,
                    'diseases':
                    diseasesController.text.isEmpty ? null : diseasesController.text.split(',').map((e) => e.trim()).toList(), // Store diseases as a list
                    'email': emailController.text,
                    'dateOfBirth': selectedDate != null ? Timestamp.fromDate(selectedDate!) : null,
                    // Consider adding/updating 'isActive' or similar field if you use 'Status'
                    // 'isActive': true, // Example: Add or update status field
                    'updatedAt': FieldValue.serverTimestamp(), // Add or update 'updatedAt'
                  };

                  await _firestore.collection('users').doc(user.id).update(updateData);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User updated successfully!')),
                  );
                  Navigator.pop(context); // Close the dialog

                  // Dispose controllers after use
                  nameController.dispose();
                  genderController.dispose();
                  goalController.dispose();
                  heightController.dispose();
                  weightController.dispose();
                  phoneController.dispose();
                  coachController.dispose();
                  roleController.dispose();
                  diseasesController.dispose();
                  emailController.dispose();
                  dobController.dispose();

                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update user: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: purpleColor,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String userId) async {
    // Show a confirmation dialog before deleting
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkColor,
        title: Text('Confirm Delete', style: TextStyle(color: purpleColor)),
        content: const Text('Are you sure you want to delete this user?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: purpleColor)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false; // Return false if the dialog is dismissed

    if (confirmDelete) {
      try {
        await _firestore.collection('users').doc(userId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user: $e')),
        );
      }
    }
  }

} // End of _AdminDashboardState class