import 'package:expense_tracker/functions/auth_shared_preference.dart';
import 'package:expense_tracker/widgets/pagination.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:expense_tracker/Models/Transactions.dart';
import 'package:expense_tracker/Models/LabelMetaData.dart';
import 'package:expense_tracker/widgets/custom_app_bar.dart';
import 'package:expense_tracker/widgets/bottom_nav_bar.dart';
import 'package:expense_tracker/functions/switches.dart';
import 'package:expense_tracker/screen/transactions/widgets/tnxs_widget.dart';
import 'package:expense_tracker/config/ENV_VARS.dart'; // Import config.dart

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  int _selectedIndex = 2;
  List<Transaction> transactions = [];
  List<LabelMetaData> labelsMetadata = [];
  bool isLoading = false;
  int currentPage = 1;
  int totalPages = 1;
  Map<String, dynamic>? metadata;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions({int page = 1}) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
        '$API_URL/transaction/get/wallet/dhruv40123_2024?page=$page&limit=10');
    final headers = {'Authorization': await retriveToken()};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> transactionsJson =
            data["data"]['transactions']["page_data"];

        final List<dynamic>? labelsJson =
            data["data"]["transactions"]['labels'];

        setState(() {
          if (labelsJson != null) {
            labelsMetadata =
                labelsJson.map((json) => LabelMetaData.fromJson(json)).toList();
          }
          transactions = transactionsJson
              .map((json) => Transaction.fromJson(json))
              .toList();
          currentPage =
              data["data"]['transactions']["page_information"]["current_page"];
          totalPages =
              data["data"]['transactions']["page_information"]["last_page"];
          metadata = data["data"]['transactions']["page_information"];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switches(index, context);
  }

  void setPage(page) {
    currentPage = page;
    fetchTransactions(page: currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(isAuthenticated: true),
      body: Column(
        children: [
          if (metadata != null)
            Pagination(
                metadata: metadata as Map<String, dynamic>,
                setPage: setPage,
                page: currentPage),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: TnxWidget(
                      transactions: transactions,
                      labelsMetadata: labelsMetadata)),
          // Container(
          //   height: 50,
          //   child: ListView.builder(
          //     scrollDirection: Axis.horizontal,
          //     itemCount: totalPages,
          //     itemBuilder: (context, index) {
          //       final pageNumber = index + 1;
          //       return Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //         child: ElevatedButton(
          //           onPressed: () => _goToPage(pageNumber),
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor:
          //                 pageNumber == currentPage ? Colors.blue : null,
          //           ),
          //           child: Text(pageNumber.toString()),
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
