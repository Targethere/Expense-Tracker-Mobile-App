// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   final Color accentPurple = const Color(0xFF8A5BFF);
//   final Color accentBlue = const Color(0xFF00A9FF);
//   final Color accentGreen = const Color(0xFF00C48C);
//   final Color lightBg = const Color(0xFFF9F9F9);

//   final TextEditingController nameController = TextEditingController(
//     text: "Sheikh Rafi",
//   );
//   final TextEditingController budgetController = TextEditingController(
//     text: "1500",
//   );

//   bool darkMode = false;
//   bool pushNotifications = true;
//   bool budgetAlert = true;

//   final List<Map<String, dynamic>> categories = [
//     {"name": "Coffee & Drinks", "color": 0xFF8A5BFF, "count": 5},
//     {"name": "Gym & Fitness", "color": 0xFF00C48C, "count": 3},
//     {"name": "Pet Expenses", "color": 0xFF00A9FF, "count": 12},
//   ];

//   BoxDecoration commonCardDecoration() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 8,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _profileCard(),
//             const SizedBox(height: 12),
//             _exportDataCard(),
//             const SizedBox(height: 12),
//             _syncBackupCard(),
//             const SizedBox(height: 12),
//             _customCategoriesCard(),
//             const SizedBox(height: 12),
//             _preferencesCard(),
//             const SizedBox(height: 12),
//             _securityCard(),
//             const SizedBox(height: 16),
//             _footer(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//       ),
//     );
//   }

//   Widget _profileCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: commonCardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle("Profile"),
//           Row(
//             children: [
//               Container(
//                 width: 56,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF3E8FF),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Center(
//                   child: Text(
//                     "SR",
//                     style: TextStyle(
//                       color: accentPurple,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   children: [
//                     TextField(
//                       controller: nameController,
//                       decoration: InputDecoration(
//                         hintText: "Full Name",
//                         filled: true,
//                         fillColor: lightBg,
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical: 12,
//                           horizontal: 14,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(
//                             color: Color(0xFFE0E0E0),
//                           ),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(
//                             color: Color(0xFFE0E0E0),
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: accentPurple,
//                             width: 1.5,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: budgetController,
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       decoration: InputDecoration(
//                         hintText: "Monthly Budget",
//                         prefixIcon: const Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 12.0),
//                           child: Text(
//                             "৳",
//                             style: TextStyle(fontSize: 16, color: Colors.grey),
//                           ),
//                         ),
//                         prefixIconConstraints: const BoxConstraints(
//                           minWidth: 0,
//                           minHeight: 0,
//                         ),
//                         filled: true,
//                         fillColor: lightBg,
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical: 12,
//                           horizontal: 14,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(
//                             color: Color(0xFFE0E0E0),
//                           ),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(
//                             color: Color(0xFFE0E0E0),
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: accentPurple,
//                             width: 1.5,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _exportDataCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: commonCardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle("Export Data"),
//           Row(
//             children: [
//               Expanded(
//                 child: _squareAction(
//                   icon: CupertinoIcons.square_arrow_down,
//                   label: "Export CSV",
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _squareAction(
//                   icon: CupertinoIcons.doc_on_doc,
//                   label: "Export PDF",
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             "Export your expense data for backup or analysis in other tools.",
//             style: TextStyle(fontSize: 12, color: Colors.black54),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _squareAction({required IconData icon, required String label}) {
//     return Container(
//       height: 80,
//       decoration: BoxDecoration(
//         color: lightBg,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFE0E0E0)),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: accentPurple),
//           const SizedBox(height: 6),
//           Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _syncBackupCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: commonCardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle("Sync & Backup"),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: const Color(0xFFE8F5FE),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: const Color(0xFFB3E5FC)),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 34,
//                   height: 34,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(CupertinoIcons.cloud_upload, color: accentBlue),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: const [
//                       Text(
//                         "Google Drive Backup",
//                         style: TextStyle(fontWeight: FontWeight.w700),
//                       ),
//                       SizedBox(height: 2),
//                       Text(
//                         "Last backup: 2 hours ago",
//                         style: TextStyle(fontSize: 12, color: Colors.black54),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE8F5E9),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     "Connected",
//                     style: TextStyle(
//                       color: Color(0xFF2E7D32),
//                       fontWeight: FontWeight.w700,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () {},
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     side: BorderSide(color: accentBlue),
//                   ),
//                   child: const Text("Backup Now"),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: accentPurple,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Sync Data",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _customCategoriesCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: commonCardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               _sectionTitle("Custom Categories"),
//               const Spacer(),
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   color: lightBg,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: const Color(0xFFE0E0E0)),
//                 ),
//                 child: Icon(CupertinoIcons.plus, color: accentPurple, size: 18),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           ...categories.map((c) => _categoryRow(c)),
//         ],
//       ),
//     );
//   }

//   Widget _categoryRow(Map<String, dynamic> c) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: lightBg,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: const Color(0xFFE0E0E0)),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 34,
//               height: 34,
//               decoration: BoxDecoration(
//                 color: Color(c["color"]).withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(CupertinoIcons.tag, color: Color(c["color"])),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     c["name"],
//                     style: const TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                   Text(
//                     "${c["count"]} transactions",
//                     style: const TextStyle(fontSize: 12, color: Colors.black54),
//                   ),
//                 ],
//               ),
//             ),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _iconCircle(
//                   CupertinoIcons.pencil,
//                   const Color(0xFFE8F5FE),
//                   accentBlue,
//                 ),
//                 const SizedBox(width: 8),
//                 _iconCircle(
//                   CupertinoIcons.delete,
//                   const Color(0xFFFFEBEE),
//                   const Color(0xFFD32F2F),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _iconCircle(IconData icon, Color bg, Color color) {
//     return Container(
//       width: 34,
//       height: 34,
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Icon(icon, color: color, size: 18),
//     );
//   }

//   Widget _prefRow(
//     String title,
//     String? subtitle,
//     bool value,
//     ValueChanged<bool> onChanged,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(fontWeight: FontWeight.w700),
//                 ),
//                 if (subtitle != null)
//                   Text(
//                     subtitle,
//                     style: const TextStyle(fontSize: 12, color: Colors.black54),
//                   ),
//               ],
//             ),
//           ),
//           Switch(value: value, onChanged: onChanged, activeThumbColor: accentPurple),
//         ],
//       ),
//     );
//   }

//   Widget _preferencesCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: commonCardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle("Preferences"),
//           _prefRow(
//             "Dark Mode",
//             "Switch the theme",
//             darkMode,
//             (v) => setState(() => darkMode = v),
//           ),
//           _prefRow(
//             "Push Notifications",
//             "Get notified about expenses",
//             pushNotifications,
//             (v) => setState(() => pushNotifications = v),
//           ),
//           _prefRow(
//             "Budget Alert",
//             "Alert when overspending",
//             budgetAlert,
//             (v) => setState(() => budgetAlert = v),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _securityCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: commonCardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle("Security & Privacy"),
//           _navRow(
//             icon: CupertinoIcons.creditcard,
//             title: "Manage Payment Methods",
//           ),
//           const SizedBox(height: 8),
//           _navRow(icon: CupertinoIcons.lock, title: "Change Password"),
//           const SizedBox(height: 8),
//           _navRow(icon: CupertinoIcons.time, title: "History settings"),
//         ],
//       ),
//     );
//   }

//   Widget _navRow({required IconData icon, required String title}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//       decoration: BoxDecoration(
//         color: lightBg,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE0E0E0)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: accentPurple),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               title,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//           const Icon(
//             CupertinoIcons.chevron_right,
//             size: 18,
//             color: Colors.black38,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _footer() {
//     return Column(
//       children: const [
//         Text("ExpenseTracker v1.0", style: TextStyle(color: Colors.black54)),
//         SizedBox(height: 4),
//         Text(
//           "Terms • Privacy • Help",
//           style: TextStyle(color: Colors.black45, fontSize: 12),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Color palette based on the screenshot/theme
  final Color accentPurple = const Color(0xFF8A5BFF);
  final Color accentBlue = const Color(0xFF00A9FF);
  final Color accentGreen = const Color(0xFF00C48C);
  final Color lightBg = const Color(0xFFF9F9F9);
  final Color greyBorder = const Color(0xFFE0E0E0);
  final Color primaryTextColor = Colors.black87;

  // Dynamic: Controllers initialized with data from the screenshot
  final TextEditingController nameController = TextEditingController(
    text: "Sarah Anderson",
  );
  final TextEditingController budgetController = TextEditingController(
    text: "7,500", // Dynamic: Used comma separator as seen in the image
  );

  // Dynamic: State for switches initialized to match the screenshot
  bool darkMode = false;
  bool pushNotifications = true;
  bool budgetAlert = true;

  // Custom Category data updated to match screenshot icons/colors
  final List<Map<String, dynamic>> categories = [
    {
      "name": "Coffee & Drinks",
      "color": 0xFFEF6C00, // Orange
      "count": 13,
      "icon": CupertinoIcons.cart_fill, // Adjusted icon
    },
    {
      "name": "Gym & Fitness",
      "color": 0xFF00C48C, // Green
      "count": 8,
      "icon": CupertinoIcons.sportscourt_fill, // Adjusted icon
    },
    {
      "name": "Pet Expenses",
      "color": 0xFF00A9FF, // Blue
      "count": 12,
      "icon": CupertinoIcons.paw_solid, // Adjusted icon
    },
  ];

  // Common card decoration (white card with shadow)
  BoxDecoration commonCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic: Wrap with Scaffold for a complete screen and consistent look
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // Using a leading icon with opacity 0 to simply align the title
        leading: const Opacity(opacity: 0, child: Icon(CupertinoIcons.back)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileCard(),
              const SizedBox(height: 12),
              _exportDataCard(),
              const SizedBox(height: 12),
              _syncBackupCard(),
              const SizedBox(height: 12),
              _customCategoriesCard(),
              const SizedBox(height: 12),
              _preferencesCard(),
              const SizedBox(height: 12),
              _securityCard(),
              const SizedBox(height: 30),
              Center(child: _footer()),
            ],
          ),
        ),
      ),
      // If you need the bottom nav bar back, you can uncomment this:
      // bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget _sectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(icon, color: Colors.black87, size: 20),
            ),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Profile"),
          Row(
            children: [
              // Dynamic: Avatar matching screenshot (SA, light purple background)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accentPurple.withOpacity(0.1), // Light accent purple
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "SA", // Dynamic: Initials from "Sarah Anderson"
                    style: TextStyle(
                      color: accentPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Full Name",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    TextField(
                      controller: nameController,
                      onChanged: (v) =>
                          setState(() {}), // Dynamic: Update state on change
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 0,
                        ),
                        border: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: accentPurple,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Monthly Budget",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    TextField(
                      controller: budgetController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (v) =>
                          setState(() {}), // Dynamic: Update state on change
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 0,
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Text(
                            "\$",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ), // Dynamic: Currency symbol from screenshot
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        border: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: accentPurple,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _exportDataCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Export Data", icon: CupertinoIcons.arrow_down_doc),
          Row(
            children: [
              Expanded(
                child: _squareAction(
                  icon: CupertinoIcons
                      .doc_text_fill, // Updated icon to fit CSV theme
                  label: "Export CSV",
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _squareAction(
                  icon:
                      CupertinoIcons.doc_text, // Updated icon to fit PDF theme
                  label: "Export PDF",
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Export your expense data for backup or analysis in other tools.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Dynamic: Made Square Action clickable
  Widget _squareAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: lightBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: greyBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accentPurple),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _syncBackupCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Sync & Backup", icon: CupertinoIcons.cloud_upload),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // Dynamic: Matching color gradient/shading from screenshot
              color: const Color(0xFFE8F5FE), // Light blue background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFB3E5FC),
              ), // Slightly darker border
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(CupertinoIcons.cloud_upload, color: accentBlue),
                ),
                const SizedBox(width: 10),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Google Drive Backup",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Last backup: 2 hours ago",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                // Dynamic: "Connected" badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9), // Light green background
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Connected",
                    style: TextStyle(
                      color: Color(0xFF2E7D32), // Dark green text
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Implement backup logic
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: accentBlue),
                    foregroundColor: accentBlue,
                  ),
                  child: const Text(
                    "Backup Now",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement sync logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Sync Data",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _customCategoriesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionTitle("Custom Categories", icon: CupertinoIcons.tag),
              const Spacer(),
              // Dynamic: Add Category Button
              InkWell(
                onTap: () {
                  // TODO: Show Add Category Modal
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accentPurple),
                  ),
                  child: Icon(
                    CupertinoIcons.plus,
                    color: accentPurple,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Dynamic: Map category data to rows
          ...categories.map((c) => _categoryRow(c)).toList(),
        ],
      ),
    );
  }

  Widget _categoryRow(Map<String, dynamic> c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: lightBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: greyBorder),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Color(c["color"]).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                c["icon"] as IconData,
                color: Color(c["color"]),
                size: 20,
              ), // Dynamic icon
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c["name"],
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "${c["count"]} transactions",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            // Edit and Delete Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _iconCircle(
                  CupertinoIcons.pencil,
                  const Color(0xFFE8F5FE), // Light Blue BG
                  accentBlue,
                  onTap: () {
                    // TODO: Implement Edit Category
                  },
                ),
                const SizedBox(width: 8),
                _iconCircle(
                  CupertinoIcons.delete,
                  const Color(0xFFFFEBEE), // Light Red BG
                  const Color(0xFFD32F2F), // Dark Red Icon
                  onTap: () {
                    // TODO: Implement Delete Category
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dynamic: Made icon circle clickable
  Widget _iconCircle(
    IconData icon,
    Color bg,
    Color color, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _prefRow(
    String title,
    String? subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
              ],
            ),
          ),
          // Dynamic: Switch logic
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: accentPurple,
            activeTrackColor: accentPurple.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _preferencesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Preferences", icon: CupertinoIcons.gear),
          _prefRow(
            "Dark Mode",
            "Switch to dark theme",
            darkMode,
            (v) =>
                setState(() => darkMode = v), // Dynamic: Update Dark Mode state
          ),
          _prefRow(
            "Push Notifications",
            "Get notified about expenses",
            pushNotifications,
            (v) => setState(
              () => pushNotifications = v,
            ), // Dynamic: Update Notifications state
          ),
          _prefRow(
            "Budget Alert",
            "Alert when overspending",
            budgetAlert,
            (v) => setState(
              () => budgetAlert = v,
            ), // Dynamic: Update Budget Alert state
          ),
        ],
      ),
    );
  }

  Widget _securityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Security & Privacy", icon: CupertinoIcons.lock_shield),
          _navRow(
            icon: CupertinoIcons.creditcard,
            title: "Manage Payment Methods",
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _navRow(
            icon: CupertinoIcons.lock,
            title: "Change Password",
            onTap: () {},
          ),
          const SizedBox(height: 8),
          // Dynamic: Corrected text to match screenshot
          _navRow(
            icon: CupertinoIcons.lock_shield,
            title: "Privacy Settings",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Dynamic: Nav row made clickable
  Widget _navRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: lightBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: greyBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: accentPurple),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Column(
      children: [
        const Text(
          "ExpenseTracker v1.0",
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Terms",
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),
            Text(" • ", style: TextStyle(color: Colors.black45, fontSize: 12)),
            Text(
              "Privacy",
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),
            Text(" • ", style: TextStyle(color: Colors.black45, fontSize: 12)),
            Text("Help", style: TextStyle(color: Colors.black45, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
