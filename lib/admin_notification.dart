//admin_notifcation.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'reports.dart';
import 'sidebar.dart';


class AdminNotificationsPage extends StatefulWidget {
  final String empId;
  const AdminNotificationsPage({required this.empId, super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final Color darkBlue = const Color(0xFF0F1020);

  late String selectedMonth;
  bool isLoading = false;
  String? error;
  //int? expandedIndex;
  String? expandedKey;

  final List<String> months = [
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
  ];

  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> performance = [];
  //List<Map<String, dynamic>> meetings = [];
  //List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> holidays = [];

  @override
  void initState() {
    super.initState();
    selectedMonth = months[DateTime.now().month - 1];
    fetchNotifs();
  }

  Future<void> fetchNotifs() async {
    setState(() {
      isLoading = true;
      error = null;
      messages.clear();
      performance.clear();
      // meetings.clear();
      // events.clear();
      holidays.clear();
      //expandedIndex = null;
      expandedKey = null;
    });
    /*
    final uri = Uri.parse("http://localhost:5000/notifications/$selectedMonth");
    if (widget.empId != "ALL") {
      uri.replace(
        path: "http://localhost:5000/notifications/$selectedMonth/${widget.empId}",
      );
    }
    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        if (decoded is List) {
          setState(() {
            message = decoded
                .where((n) => (n['category'] as String).toLowerCase() == 'sms')
                .cast<Map<String, dynamic>>()
                .toList();

            performance = decoded
                .where(
                  (n) =>
                      (n['category'] as String).toLowerCase() == 'performance',
                )
                .cast<Map<String, dynamic>>()
                .toList();
            /*    meetings = decoded
                .where((n) =>
                    (n['category'] as String).toLowerCase() == 'meeting')
                .cast<Map<String, dynamic>>()
                .toList();
            events = decoded
                .where((n) =>
                    (n['category'] as String).toLowerCase() == 'event')
                .cast<Map<String, dynamic>>()
                .toList(); 
       */
            holidays = decoded
                .where(
                  (n) => (n['category'] as String).toLowerCase() == 'holiday',
                )
                .cast<Map<String, dynamic>>()
                .toList();
          });
        } else {
          setState(() => error = "Invalid data from server");
        }
      } else {
        setState(() => error = "Failed: ${resp.statusCode}");
      }
    } catch (e) {
      setState(() => error = "Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
*/

    try {
      // 🔹 Call both APIs parallel
      await Future.wait([
        fetchSmsNotifications(),
        fetchPerformanceNotifications(),
        fetchHolidayNotifications(),
        // Future-la meetings/events/holiday/s ku separate API add panna easy
      ]);
    } catch (e) {
      setState(() => error = "Server/network error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 🔹 Fetch SMS Notifications
  Future<void> fetchSmsNotifications() async {
    final uri = Uri.parse(
      "https://hrm-project-2.onrender.com/notifications/employee/${widget.empId}?month=$selectedMonth&category=messages",
    );
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      if (decoded is List) {
        setState(() {
          messages = decoded.cast<Map<String, dynamic>>();
        });
      }
    } else if (resp.statusCode == 404) {
      // 🔹 No SMS → empty list
      setState(() => messages = []);
    } else {
      throw Exception(
        "Failed to load SMS notifications. Code: ${resp.statusCode}",
      );
    }
  }

  /// 🔹 Fetch Performance Notifications
  Future<void> fetchPerformanceNotifications() async {
    final uri = Uri.parse(
      "https://hrm-project-2.onrender.com/notifications/performance/employee/$selectedMonth/${widget.empId}",
    );

    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      if (decoded is List) {
        setState(() {
          //performance = decoded.cast<Map<String, dynamic>>();
          performance =
              decoded
                  .where(
                    (n) =>
                        (n['category'] as String).toLowerCase() ==
                        'performance',
                  )
                  .cast<Map<String, dynamic>>()
                  .toList();
          //     holidays =
          // decoded
          //     .where(
          //       (n) =>
          //           (n['category'] as String).toLowerCase() == 'holiday',
          //     )
          //     .cast<Map<String, dynamic>>()
          //     .toList();
        });
      }
    } else if (resp.statusCode == 404) {
      // 🔹 No Performance → empty list
      setState(() => performance = []);
    } else {
      throw Exception(
        "Failed to load Performance notifications. Code: ${resp.statusCode}",
      );
    }
  }

  Future<void> fetchHolidayNotifications() async {
    final uri = Uri.parse(
      "https://hrm-project-2.onrender.com/notifications/holiday/admin/$selectedMonth",
    );

    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);

      if (decoded is List) {
        setState(() {
          holidays = decoded.cast<Map<String, dynamic>>();
        });
      }
    } else if (resp.statusCode == 404) {
      // 🔹 No Holiday → empty list

      setState(() => holidays = []);
    } else {
      throw Exception(
        "Failed to load Holiday notifications. Code: ${resp.statusCode}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: "Admin Notifications",
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Notifications",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _dropdownMonth(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (error != null)
                    Center(
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    )
                  else ...[
                    notificationCategory("Performance", performance),
                    notificationCategory("messages", messages),
                    //  notificationCategory("Meetings", meetings),
                    // notificationCategory("Company Events", events),
                    notificationCategory("Holidays", holidays),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownMonth() {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMonth,
          isExpanded: true,
          items:
              months
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => selectedMonth = val);
              fetchNotifs();
            }
          },
        ),
      ),
    );
  }

  Widget notificationCategory(String title, List<Map<String, dynamic>> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              "No $title found",
              style: const TextStyle(color: Colors.white70),
            ),
          )
        else
          ...list.asMap().entries.map((entry) {
            //final idx = entry.key;
            final index = entry.key;
            //final msg = entry.value['message'] as String;
            //return notificationCard(msg, idx, title);
            final notif = entry.value; // full notification map
            return notificationCard(notif, index, title.toLowerCase());
          }),
      ],
    );
  }

  //Widget notificationCard(String message, int index, String category) {
  Widget notificationCard(
    Map<String, dynamic> notif,
    int index,
    String categoryParam,
  ) {
    //final isExpanded = expandedIndex == index;
    final cardKey = "$categoryParam-$index"; // 🔴 unique key per notification
    final isExpanded = expandedKey == cardKey;
    final message = notif['message'] as String;
    final category = (notif['category'] as String).toLowerCase();
    final senderName =
        notif['senderName'] ?? 'Unknown'; // 🔴 red: added senderName
    final senderId = notif['senderId'] ?? ''; // 🔴 red: added senderId
    if (category.toLowerCase() == "messages") {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.white,
          elevation: 2,
          child: InkWell(
            onTap:
                () => setState(() => expandedKey = isExpanded ? null : cardKey),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "From: $senderName ($senderId)",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 4),
                          // 🔹 Second line -> Message
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Click again to collapse",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ] else ...[
                          const SizedBox(height: 4),
                          const Text(
                            "Click to view message...",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // if (category.toLowerCase() == "sms")
                  //   TextButton(
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (c) => ReportsAnalyticsPage(),
                  //         ),
                  //       );
                  //     },
                  //     style: TextButton.styleFrom(
                  //       backgroundColor: Colors.black,
                  //       foregroundColor: Colors.white,
                  //     ),
                  //     child: const Text("View"),
                  //   ),
                  /*
                  if (category.toLowerCase() == "performance")
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => ReportsAnalyticsPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("View"),
                  ),
                  */
                ],
              ),
            ),
          ),
        ),
      );
    }

    //Performance
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap:
              () => setState(() => expandedKey = isExpanded ? null : cardKey),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: const TextStyle(fontSize: 14),
                        maxLines: isExpanded ? null : 1,
                        overflow:
                            isExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                      ),
                      if (isExpanded) const SizedBox(height: 8),
                      if (isExpanded)
                        const Text(
                          "Click again to collapse",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                if (category.toLowerCase() == "performance")
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => ReportsAnalyticsPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("View"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      color: darkBlue,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Text(
        "",
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
