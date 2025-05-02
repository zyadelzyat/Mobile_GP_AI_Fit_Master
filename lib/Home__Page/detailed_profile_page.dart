import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for FieldValue

class DetailedProfilePage extends StatefulWidget {
  // Receive user data from the previous page
  final Map<String, dynamic> userData;
  const DetailedProfilePage({super.key, required this.userData});

  @override
  State<DetailedProfilePage> createState() => _DetailedProfilePageState();
}

class _DetailedProfilePageState extends State<DetailedProfilePage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Formats DOB from YYYY-MM-DD to DD / MM / YYYY
  String _formatDOB() {
    final dob = widget.userData['dob'];
    if (dob == null || dob.isEmpty) return "N/A";
    try {
      List<String> parts = (dob as String).split('-');
      if (parts.length != 3) return dob;
      return "${parts[2]} / ${parts[1]} / ${parts[0]}";
    } catch (e) {
      return dob is String ? dob : "Invalid Date";
    }
  }

  // Build a read-only text field display
  Widget _buildTextField(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.transparent)),
        child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 15)),
      ),
    );
  }

  // Build a label for a text field
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(label, style: const TextStyle(color: Color(0xFF9D7BFF), fontSize: 14)),
    );
  }

  // Check if user can view membership details
  bool _canViewMembership() {
    final role = widget.userData['role']?.toString().toLowerCase() ?? '';
    return role == 'self-trainee' || role == 'trainee';
  }

  // Build a single detail row for the membership modal
  Widget _buildMembershipDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Show the membership details modal
  void _showMembershipModal() {
    if (!mounted) return;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF232323),
            title: const Text("Membership Details", style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMembershipDetail("Type", widget.userData['membershipType'] ?? "N/A"),
                _buildMembershipDetail("Price", widget.userData['membershipPrice'] ?? "N/A"),
                _buildMembershipDetail("Payment Type", widget.userData['paymentType'] ?? "N/A"),
                _buildMembershipDetail("Start Date", widget.userData['membershipStart'] ?? "N/A"),
                _buildMembershipDetail("End Date", widget.userData['membershipEnd'] ?? "N/A"),
              ],
            ),
            actions: [TextButton(child: const Text("Close", style: TextStyle(color: Color(0xFF6A48F6))), onPressed: () => Navigator.of(context).pop())],
          );
        }
    );
  }

  // Show the add membership form modal
  void _showAddMembershipForm() {
    if (!mounted) return;

    final emailController = TextEditingController(text: widget.userData['email'] ?? '');
    String selectedMembershipType = widget.userData['membershipType'] ?? 'Silver'; // Default to existing or Silver
    final priceController = TextEditingController(text: widget.userData['membershipPrice']?.replaceAll('\$', '') ?? (selectedMembershipType == 'Gold' ? '29.99' : '19.99'));
    String selectedPaymentType = widget.userData['paymentType'] ?? 'Cash';
    DateTime startDate = DateTime.now(); // Default to now, or parse existing? For simplicity, default to now.
    DateTime endDate = DateTime.now().add(Duration(days: selectedMembershipType == 'Gold' ? 365 : 30)); // Default end date
    bool isLoading = false;

    // Attempt to parse existing dates if available
    try {
      if(widget.userData['membershipStart'] != null && widget.userData['membershipStart'].isNotEmpty) {
        startDate = DateFormat('dd / MM / yyyy').parse(widget.userData['membershipStart']);
      }
      if(widget.userData['membershipEnd'] != null && widget.userData['membershipEnd'].isNotEmpty) {
        endDate = DateFormat('dd / MM / yyyy').parse(widget.userData['membershipEnd']);
      }
    } catch(e) {
      print("Error parsing existing membership dates: $e");
      // Keep default dates if parsing fails
    }


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                backgroundColor: const Color(0xFF232323),
                title: const Text("Add / Update Membership", style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Email"),
                      TextField(controller: emailController, readOnly: true, style: const TextStyle(color: Colors.white70), decoration: InputDecoration(filled: true, fillColor: const Color(0xFF2A2A2A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
                      const SizedBox(height: 16),

                      _buildLabel("Membership Type"),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8)),
                        child: DropdownButton<String>(
                          value: selectedMembershipType, isExpanded: true, dropdownColor: const Color(0xFF2A2A2A), underline: Container(), style: const TextStyle(color: Colors.white),
                          items: ['Silver', 'Gold'].map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setStateDialog(() {
                                selectedMembershipType = newValue;
                                if (newValue == 'Silver') { priceController.text = '19.99'; endDate = startDate.add(const Duration(days: 30)); }
                                else { priceController.text = '29.99'; endDate = startDate.add(const Duration(days: 365)); }
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildLabel("Price"),
                      TextField(controller: priceController, readOnly: true, style: const TextStyle(color: Colors.white70), keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(filled: true, fillColor: const Color(0xFF2A2A2A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), prefixText: '\$ ', prefixStyle: const TextStyle(color: Colors.white70))),
                      const SizedBox(height: 16),

                      _buildLabel("Payment Type"),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8)),
                        child: DropdownButton<String>(
                          value: selectedPaymentType, isExpanded: true, dropdownColor: const Color(0xFF2A2A2A), underline: Container(), style: const TextStyle(color: Colors.white),
                          items: ['Cash', 'Visa', 'Mastercard', 'PayPal'].map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                          onChanged: (String? newValue) { if (newValue != null) { setStateDialog(() { selectedPaymentType = newValue; }); } },
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildLabel("Start Date"),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(context: context, initialDate: startDate, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365)), builder: (context, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF6A48F6), onPrimary: Colors.white, surface: Color(0xFF232323), onSurface: Colors.white), dialogBackgroundColor: const Color(0xFF232323)), child: child!));
                          if (picked != null && picked != startDate) {
                            setStateDialog(() {
                              startDate = picked;
                              if (selectedMembershipType == 'Silver') { endDate = startDate.add(const Duration(days: 30)); } else { endDate = startDate.add(const Duration(days: 365)); }
                            });
                          }
                        },
                        child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8)), child: Text(DateFormat('dd / MM / yyyy').format(startDate), style: const TextStyle(color: Colors.white))),
                      ),
                      const SizedBox(height: 16),

                      _buildLabel("End Date"),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(context: context, initialDate: endDate, firstDate: startDate, lastDate: startDate.add(const Duration(days: 730)), builder: (context, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF6A48F6), onPrimary: Colors.white, surface: Color(0xFF232323), onSurface: Colors.white), dialogBackgroundColor: const Color(0xFF232323)), child: child!));
                          if (picked != null && picked != endDate) { setStateDialog(() { endDate = picked; }); }
                        },
                        child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8)), child: Text(DateFormat('dd / MM / yyyy').format(endDate), style: const TextStyle(color: Colors.white))),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(child: const Text("Cancel", style: TextStyle(color: Colors.grey)), onPressed: () => Navigator.of(context).pop()),
                  isLoading
                      ? const Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF6A48F6))))
                      : TextButton(
                    child: const Text("Save", style: TextStyle(color: Color(0xFF6A48F6))),
                    onPressed: () async {
                      setStateDialog(() { isLoading = true; });

                      // *** GET userId FROM THE PASSED userData MAP ***
                      final String? userId = widget.userData['userId'];
                      if (userId == null || userId.isEmpty) {
                        if (!mounted) return;
                        setStateDialog(() { isLoading = false; });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: User ID not found.'), backgroundColor: Colors.red));
                        return; // Cannot save without userId
                      }

                      try {
                        String startDateFormatted = DateFormat('dd / MM / yyyy').format(startDate);
                        String endDateFormatted = DateFormat('dd / MM / yyyy').format(endDate);
                        Map<String, dynamic> membershipData = {
                          'membershipType': selectedMembershipType, 'membershipPrice': '\$${priceController.text}', 'paymentType': selectedPaymentType,
                          'membershipStart': startDateFormatted, 'membershipEnd': endDateFormatted, 'membershipUpdatedAt': FieldValue.serverTimestamp(),
                        };

                        await _firestore.collection('users').doc(userId).update(membershipData);

                        if (!mounted) return;
                        Navigator.of(context).pop(); // Close the dialog

                        // *** UPDATE LOCAL STATE TO REFLECT CHANGES IMMEDIATELY ***
                        setState(() { // This updates the _DetailedProfilePageState
                          widget.userData.addAll(membershipData);
                          // Ensure dates are stored in the correct display format locally
                          widget.userData['membershipStart'] = startDateFormatted;
                          widget.userData['membershipEnd'] = endDateFormatted;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membership updated successfully!'), backgroundColor: Colors.green));

                      } catch (e) {
                        if (!mounted) return;
                        setStateDialog(() { isLoading = false; });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating membership: $e'), backgroundColor: Colors.red));
                      } finally {
                        if(isLoading && mounted) { setStateDialog(() { isLoading = false; }); }
                      }
                    },
                  ),
                ],
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String fullName = widget.userData['firstName'] != null ? '${widget.userData['firstName']} ${widget.userData['lastName'] ?? ''}' : 'N/A';
    String email = widget.userData['email'] ?? 'N/A';
    String phone = widget.userData['phone'] ?? 'N/A';
    String dob = _formatDOB();
    String weightDisplay = "${widget.userData['weight'] ?? 'N/A'} ${widget.userData['weightUnit'] ?? 'Kg'}";
    String heightDisplay = widget.userData['heightUnit'] == 'CM' ? "${widget.userData['height'] ?? 'N/A'} CM" : "${widget.userData['height'] ?? 'N/A'} ${widget.userData['heightUnit'] ?? 'M'}";
    String gender = widget.userData['gender'] ?? 'N/A';
    String diseases = widget.userData['Diseases'] ?? 'None'; // Check Firestore key casing
    String role = widget.userData['role'] ?? 'N/A';
    String coach = widget.userData['coach'] ?? 'Not assigned';

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Profile Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFFB29BFF), // Match profile page AppBar color
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Full name'), _buildTextField(fullName),
              _buildLabel('Email'), _buildTextField(email),
              _buildLabel('Mobile Number'), _buildTextField(phone),
              _buildLabel('Date of birth'), _buildTextField(dob),
              _buildLabel('Weight'), _buildTextField(weightDisplay),
              _buildLabel('Height'), _buildTextField(heightDisplay),
              _buildLabel('Gender'), _buildTextField(gender),
              _buildLabel('Diseases'), _buildTextField(diseases),
              _buildLabel('Role'), _buildTextField(role),
              _buildLabel('Coach'), _buildTextField(coach),

              if (_canViewMembership()) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: GestureDetector(
                    onTap: _showMembershipModal,
                    child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: const Color(0xFF6A48F6), borderRadius: BorderRadius.circular(8)), child: const Text("View Membership Details", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: _showAddMembershipForm,
                    child: Container(
                      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: const Color(0xFFDFF233), borderRadius: BorderRadius.circular(8)), // Yellow button
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [ Icon(Icons.add, color: Colors.black87, size: 20), SizedBox(width: 8), Text("Add / Update Membership", style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600))],
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
