// detailed_profile_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for FieldValue

class DetailedProfilePage extends StatefulWidget {
  // Receive user data from the previous page
  final Map userData; // Use specific type if possible
  const DetailedProfilePage({super.key, required this.userData});

  @override
  State createState() => _DetailedProfilePageState();
}

class _DetailedProfilePageState extends State<DetailedProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatDOB() {
    final dob = widget.userData['dob'];
    if (dob == null || dob.isEmpty) return "N/A";
    try {
      // Assuming YYYY-MM-DD format from signup
      List parts = (dob as String).split('-');
      if (parts.length != 3) return dob; // Return original if format is wrong
      // Convert to DD / MM / YYYY
      return "${parts[2]} / ${parts[1]} / ${parts[0]}";
    } catch (e) {
      // Handle potential errors if dob is not a string or format is unexpected
      print("Error formatting DOB: $e");
      return dob is String ? dob : "Invalid Date";
    }
  }

  Widget _buildTextField(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A), // Dark input field background
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.transparent), // No visible border
        ),
        child: Text(
            value.isEmpty ? "N/A" : value, // Show N/A if value is empty
            style: const TextStyle(color: Colors.white, fontSize: 15)
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // Adjust top padding if needed
      child: Text(
          label,
          style: const TextStyle(color: Color(0xFF9D7BFF), fontSize: 14) // Purple label
      ),
    );
  }

  bool _canViewMembership() {
    final role = widget.userData['role']?.toString().toLowerCase() ?? '';
    // Only return true for 'trainee', not for 'self-trainee'
    return role == 'trainee';
  }

  bool _canEditMembership() {
    final role = widget.userData['role']?.toString() ?? '';
    // Prevent trainees from editing their membership
    return role != 'Self Trainee' && role != 'Trainee';
  }

  Widget _buildMembershipDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value.isEmpty ? "N/A" : value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showMembershipModal() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Format dates for display inside the modal
        String startDate = widget.userData['membershipStart'] ?? "N/A";
        String endDate = widget.userData['membershipEnd'] ?? "N/A";
        // Basic price formatting example (could be improved)
        String price = widget.userData['membershipPrice'] ?? "N/A";
        return AlertDialog(
          backgroundColor: const Color(0xFF232323),
          title: const Text("Membership Details", style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMembershipDetail("Type", widget.userData['membershipType'] ?? "N/A"),
              _buildMembershipDetail("Price", price),
              _buildMembershipDetail("Payment Type", widget.userData['paymentType'] ?? "N/A"),
              _buildMembershipDetail("Start Date", startDate),
              _buildMembershipDetail("End Date", endDate),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Close", style: TextStyle(color: Color(0xFF6A48F6))),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showAddMembershipForm() {
    if (!mounted) return;
    final emailController = TextEditingController(text: widget.userData['email'] ?? '');
    String selectedMembershipType = widget.userData['membershipType'] ?? 'Silver'; // Default to existing or Silver
    final priceController = TextEditingController(text: widget.userData['membershipPrice']?.replaceAll('\$', '') ?? (selectedMembershipType == 'Gold' ? '29.99' : '19.99'));
    String selectedPaymentType = widget.userData['paymentType'] ?? 'Cash';
    DateTime startDate = DateTime.now(); // Default start date
    DateTime endDate = DateTime.now().add(Duration(days: selectedMembershipType == 'Gold' ? 365 : 30)); // Default end date
    bool isLoading = false;
    final DateFormat displayFormat = DateFormat('dd / MM / yyyy');

    // Attempt to parse existing dates if available and in the correct format
    try {
      if(widget.userData['membershipStart'] != null && widget.userData['membershipStart'].isNotEmpty) {
        startDate = displayFormat.parse(widget.userData['membershipStart']);
      }
      if(widget.userData['membershipEnd'] != null && widget.userData['membershipEnd'].isNotEmpty) {
        endDate = displayFormat.parse(widget.userData['membershipEnd']);
      }
    } catch(e) {
      print("Error parsing existing membership dates: $e. Using defaults.");
      // Dates remain as defaults if parsing fails
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Use StatefulBuilder to update dialog state
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF232323),
              title: const Text("Add / Update Membership", style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email (Readonly)
                    _buildLabel("Email"),
                    TextField(
                        controller: emailController,
                        readOnly: true,
                        style: const TextStyle(color: Colors.white70), // Dimmed text
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF2A2A2A),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                        )
                    ),
                    const SizedBox(height: 16),
                    // Membership Type Dropdown
                    _buildLabel("Membership Type"),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: DropdownButton<String>(
                        value: selectedMembershipType,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF2A2A2A),
                        underline: Container(), // Remove underline
                        style: const TextStyle(color: Colors.white),
                        items: ['Silver', 'Gold'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setStateDialog(() { // Use setStateDialog here
                              selectedMembershipType = newValue;
                              // Update price and end date based on selection
                              if (newValue == 'Silver') {
                                priceController.text = '19.99';
                                endDate = startDate.add(const Duration(days: 30));
                              } else { // Gold
                                priceController.text = '29.99';
                                endDate = startDate.add(const Duration(days: 365));
                              }
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Price (Readonly)
                    _buildLabel("Price"),
                    TextField(
                        controller: priceController,
                        readOnly: true,
                        style: const TextStyle(color: Colors.white70), // Dimmed text
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF2A2A2A),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            prefixText: '\$ ',
                            prefixStyle: const TextStyle(color: Colors.white70)
                        )
                    ),
                    const SizedBox(height: 16),
                    // Payment Type Dropdown
                    _buildLabel("Payment Type"),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: DropdownButton<String>(
                        value: selectedPaymentType,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF2A2A2A),
                        underline: Container(), // Remove underline
                        style: const TextStyle(color: Colors.white),
                        items: ['Cash', 'Visa', 'Mastercard', 'PayPal'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            // Use setStateDialog for state changes within the dialog
                            setStateDialog(() {
                              selectedPaymentType = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Start Date Picker
                    _buildLabel("Start Date"),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow picking past dates?
                            lastDate: DateTime.now().add(const Duration(days: 365)), // Limit future dates?
                            builder: (context, child) {
                              return Theme( // Apply dark theme to date picker
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Color(0xFF6A48F6), // Purple primary color
                                    onPrimary: Colors.white, // White text on primary
                                    surface: Color(0xFF232323), // Dark background
                                    onSurface: Colors.white, // White text on surface
                                  ),
                                  dialogBackgroundColor: const Color(0xFF232323),
                                ),
                                child: child!,
                              );
                            }
                        );
                        if (picked != null && picked != startDate) {
                          setStateDialog(() { // Use setStateDialog here
                            startDate = picked;
                            // Recalculate end date based on new start date and type
                            if (selectedMembershipType == 'Silver') {
                              endDate = startDate.add(const Duration(days: 30));
                            } else { // Gold
                              endDate = startDate.add(const Duration(days: 365));
                            }
                          });
                        }
                      },
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Text(displayFormat.format(startDate), style: const TextStyle(color: Colors.white))
                      ),
                    ),
                    const SizedBox(height: 16),
                    // End Date Picker
                    _buildLabel("End Date"),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: startDate, // End date cannot be before start date
                            lastDate: startDate.add(const Duration(days: 730)), // Allow up to 2 years?
                            builder: (context, child) {
                              return Theme( // Apply dark theme to date picker
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Color(0xFF6A48F6),
                                    onPrimary: Colors.white,
                                    surface: Color(0xFF232323),
                                    onSurface: Colors.white,
                                  ),
                                  dialogBackgroundColor: const Color(0xFF232323),
                                ),
                                child: child!,
                              );
                            }
                        );
                        if (picked != null && picked != endDate) {
                          setStateDialog(() { // Use setStateDialog here
                            endDate = picked;
                          });
                        }
                      },
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Text(displayFormat.format(endDate), style: const TextStyle(color: Colors.white))
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                    onPressed: () => Navigator.of(context).pop() // Close the dialog
                ),
                // Show loading indicator or Save button
                isLoading
                    ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF6A48F6)))
                )
                    : TextButton(
                  child: const Text("Save", style: TextStyle(color: Color(0xFF6A48F6))),
                  onPressed: () async {
                    setStateDialog(() { isLoading = true; });
                    // Get userId from the passed userData map
                    final String? userId = widget.userData['userId']; // Ensure userId was added in profile.dart
                    if (userId == null || userId.isEmpty) {
                      print("Error: User ID not found in userData map.");
                      if (!mounted) return;
                      setStateDialog(() { isLoading = false; });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: User ID not found. Cannot save membership.'), backgroundColor: Colors.red));
                      return; // Exit if userId is missing
                    }

                    try {
                      // Format dates consistently for Firestore
                      String startDateFormatted = displayFormat.format(startDate);
                      String endDateFormatted = displayFormat.format(endDate);

                      Map<String, dynamic> membershipData = {
                        'membershipType': selectedMembershipType,
                        'membershipPrice': '\$${priceController.text}', // Store with currency symbol
                        'paymentType': selectedPaymentType,
                        'membershipStart': startDateFormatted,
                        'membershipEnd': endDateFormatted,
                        'membershipUpdatedAt': FieldValue.serverTimestamp(), // Track update time
                      };

                      await _firestore.collection('users').doc(userId).update(membershipData);

                      if (!mounted) return; // Check mounted status AFTER async operation
                      Navigator.of(context).pop(); // Close the dialog on success

                      // *** IMPORTANT: Update local state to reflect changes immediately ***
                      setState(() { // This updates the _DetailedProfilePageState
                        // Merge the updated data into the local userData map
                        widget.userData.addAll(membershipData);
                        // Ensure dates are stored locally in the same display format
                        widget.userData['membershipStart'] = startDateFormatted;
                        widget.userData['membershipEnd'] = endDateFormatted;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membership updated successfully!'), backgroundColor: Colors.green));
                    } catch (e) {
                      print("Error updating membership: $e");
                      if (!mounted) return; // Check mounted status
                      setStateDialog(() { isLoading = false; }); // Stop loading indicator on error
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating membership: ${e.toString()}'), backgroundColor: Colors.red));
                    } finally {
                      // Ensure loading indicator is turned off if it was on and component is still mounted
                      if(isLoading && mounted) {
                        setStateDialog(() { isLoading = false; });
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract data safely, providing defaults or 'N/A'
    String firstName = widget.userData['firstName'] ?? '';
    String lastName = widget.userData['lastName'] ?? '';
    String fullName = (firstName.isNotEmpty || lastName.isNotEmpty) ? '$firstName $lastName'.trim() : 'N/A';
    String email = widget.userData['email'] ?? 'N/A';
    String phone = widget.userData['phone'] ?? 'N/A';
    String dob = _formatDOB(); // Use the formatted DOB
    String weight = widget.userData['weight']?.toString() ?? 'N/A';
    String weightUnit = widget.userData['weightUnit'] ?? 'Kg';
    String weightDisplay = weight == 'N/A' ? 'N/A' : '$weight $weightUnit';
    String height = widget.userData['height']?.toString() ?? 'N/A';
    String heightUnit = widget.userData['heightUnit'] ?? ''; // Default to empty if null
    String heightDisplay = height == 'N/A' ? 'N/A' : '$height ${heightUnit.toUpperCase()}'.trim(); // Ensure unit is uppercase and trim space if no unit
    String gender = widget.userData['gender'] ?? 'N/A';
    // Check both potential casings for diseases if unsure, prioritizing 'Diseases'
    String diseases = widget.userData['Diseases'] ?? widget.userData['disease'] ?? 'None';
    String role = widget.userData['role'] ?? 'N/A';
    String coach = widget.userData['coachName'] ?? 'Not assigned'; // Changed 'coach' to 'coachName'

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background
      appBar: AppBar(
        title: const Text(
            "Profile Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)
        ),
        backgroundColor: const Color(0xFFB29BFF), // Purple AppBar background
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()
        ),
        centerTitle: true, // Center the title
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30.0), // Add padding at the bottom
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Full name'),
              _buildTextField(fullName),
              _buildLabel('Email'),
              _buildTextField(email),
              _buildLabel('Mobile Number'),
              _buildTextField(phone),
              _buildLabel('Date of birth'),
              _buildTextField(dob),
              _buildLabel('Weight'),
              _buildTextField(weightDisplay),
              _buildLabel('Height'),
              _buildTextField(heightDisplay),
              _buildLabel('Gender'),
              _buildTextField(gender),
              _buildLabel('Diseases'), // Label can remain 'Diseases'
              _buildTextField(diseases), // Display the disease info
              _buildLabel('Role'),
              _buildTextField(role),
              // Display Coach only if the user is a Trainee
              if (widget.userData['role'] == 'Trainee') ...[
                _buildLabel('Coach'), // Keep the UI label as 'Coach'
                _buildTextField(coach), // Display the fetched coach name
              ],
              if (_canViewMembership()) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8), // Add space before buttons
                  child: GestureDetector(
                    onTap: _showMembershipModal,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A48F6), // Purple button
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: const Text(
                        "View Membership Details",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center
                      ),
                    ),
                  ),
                ),
                // Only show Add/Update button if user can edit membership
                if (_canEditMembership())
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: _showAddMembershipForm,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFF233), // Yellow button
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add, color: Colors.black87, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Add / Update Membership",
                              style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
