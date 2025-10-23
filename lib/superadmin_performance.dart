//superadmin_performance.dart                 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'admin_notification.dart';
import 'user_provider.dart';
import 'package:provider/provider.dart';
import 'sidebar.dart';


class SuperadminPerformancePage extends StatefulWidget {
  const SuperadminPerformancePage({super.key});

  @override
  State<SuperadminPerformancePage> createState() =>
      _SuperadminPerformancePageState();
}

class _SuperadminPerformancePageState extends State<SuperadminPerformancePage> {
  String selectedEmpId = "EMP ID";
  String selectedEmpName = "EMP NAME";

  final Map<String, String> empMap = {
    "ZeAI102": "Nivetha S",
    "ZeAI002": "Hemeswari ",
    "ZeAI115": "Srivatsini R",
    "ZeAI116": "Heme",

  };
  late final Map<String, String> nameToIdMap;

  final Map<String, Color> flagColors = {
    "Green Flag": Colors.green,
    "Yellow Flag": Colors.yellow,
    "Red Flag": Colors.red,
  };

  String selectedFlag = "Green Flag";

  TextEditingController communicationController = TextEditingController();
  TextEditingController attitudeController = TextEditingController();
  TextEditingController technicalKnowledgeController = TextEditingController();
  TextEditingController businessKnowledgeController = TextEditingController();

  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    nameToIdMap = {for (var e in empMap.entries) e.value: e.key};
  }

  String getCurrentMonth() {
    return [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ][DateTime.now().month - 1];
  }

  Future<void> submitReview() async {
    if (selectedEmpId == "EMP ID" ||
        selectedEmpName == "EMP NAME" ||
        communicationController.text.trim().isEmpty ||
        attitudeController.text.trim().isEmpty ||
        technicalKnowledgeController.text.trim().isEmpty ||
        businessKnowledgeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠ Please fill in all fields before submitting."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final url = Uri.parse('https://hrm-project-2.onrender.com/reviews');
    setState(() => _isloading = true);

    final reviewerName =
        Provider.of<UserProvider>(context, listen: false).employeeName ??
        'Admin';

    final body = {
      "empId": selectedEmpId,
      "empName": selectedEmpName,
      "communication": communicationController.text,
      "attitude": attitudeController.text,
      "technicalKnowledge": technicalKnowledgeController.text,
      "business": businessKnowledgeController.text,
      "reviewedBy": reviewerName,
      "flag": selectedFlag,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        // ✅ First time success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Review submitted successfully"),
            backgroundColor: Colors.green,
          ),
        );

        // 🔔 Add notifications (one for employee, one for admin)
        String currentMonth = getCurrentMonth();
        final notifUrl = Uri.parse("https://hrm-project-2.onrender.com/notifications");
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final adminId = userProvider.employeeId ?? 'superadmin';
        final adminName = userProvider.employeeName ?? 'Super Admin';

        // 1. Notification for the Employee
        final employeeNotifBody = {
          "month": currentMonth,
          "category": "performance",
          "message": "Performance received from ($adminName)",
          "empId": selectedEmpId,
          "senderId": adminId,
          "senderName": adminName,
          "flag": selectedFlag,
        };

        // 2. Notification for the Admin
        final adminNotifBody = {
          "month": currentMonth,
          "category": "performance",
          "message": "Performance sent to ($selectedEmpName)",
          "empId": adminId, // Sent to the admin themselves
          "senderId": adminId,
          "senderName": adminName,
          "flag": selectedFlag,
        };

        // Send both notifications
        await http.post(
          notifUrl,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(employeeNotifBody),
        );
        await http.post(
          notifUrl,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(adminNotifBody),
        );

        // ✅ Reset form
        communicationController.clear();
        attitudeController.clear();
        technicalKnowledgeController.clear();
        businessKnowledgeController.clear();
        setState(() {
          selectedEmpId = "EMP ID";
          selectedEmpName = "EMP NAME";
          selectedFlag = "Green Flag";
        });

        // ✅ Navigate to Notification screen
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminNotificationsPage(empId: "ALL"),
            ),
          );
        });
      } else if (response.statusCode == 400) {
        // ❌ Duplicate review → stay on same page
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          // ignore: prefer_interpolation_to_compose_strings
          SnackBar(
            content: Text("⚠ ${data['message']}"),
            backgroundColor: Colors.orange,
          ),
        );
        // 🔥 No navigation here → user stays on the review page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Failed to submit review"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      // Ensure loading state is reset even if an error occurs
      setState(() => _isloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: "Performance Review",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Employee selectors + Flag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Performance Review",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // 🔹 Employee Name Dropdown FIRST
                    empDropdown(
                      ["EMP NAME", ...nameToIdMap.keys],
                      selectedEmpName,
                      (val) {
                        setState(() {
                          selectedEmpName = val!;
                          selectedEmpId = val == "EMP NAME"
                              ? "EMP ID"
                              : nameToIdMap[val]!;
                        });
                      },
                      160,
                    ),
                    const SizedBox(width: 10),
                    // 🔹 Employee ID Dropdown (auto-filled, not editable)
                    empDropdown(
                      [selectedEmpId],
                      selectedEmpId,
                      (_) {},
                      120,
                      enabled: false,
                    ),
                  ],
                ),
                // Flag dropdown
                Container(
                  width: 140,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Colors.white,
                      value: selectedFlag,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      style: TextStyle(color: flagColors[selectedFlag]),
                      items: flagColors.keys.map((String val) {
                        return DropdownMenuItem(
                          value: val,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: flagColors[val],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                val,
                                style: TextStyle(color: flagColors[val]),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedFlag = val!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Flag bar
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: flagColors[selectedFlag],
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(height: 20),

            // Review fields
            reviewField("Communication", communicationController),
            reviewField("Attitude", attitudeController),
            reviewField("Technical knowledge", technicalKnowledgeController),
            reviewField("Business", businessKnowledgeController),

            const SizedBox(height: 20),

            // 🔹 Send Button
            Align(
              alignment: Alignment.centerRight,
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final reviewerName =
        Provider.of<UserProvider>(context, listen: false).employeeName ??
        'Admin';
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Reviewed by", style: TextStyle(color: Colors.white70)),
            Text(
              reviewerName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: _isloading ? null : submitReview,
          icon: const Icon(Icons.send),
          label: const Text("Send"),
        ),
      ],
    );
  }

  Widget reviewField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Text field for $label",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget empDropdown(
    List<String> items,
    String value,
    ValueChanged<String?> onChanged,
    double width, {
    bool enabled = true,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white24,
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: const TextStyle(color: Colors.white),
          items: items
              .map(
                (String val) => DropdownMenuItem(
                  value: val,
                  child: Text(val, style: const TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}