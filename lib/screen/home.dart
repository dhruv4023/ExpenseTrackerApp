import 'package:expense_tracker/constants/colors.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: tdGrey,
        automaticallyImplyLeading: false,
        title: Text('Expense Tracker App'),
      ),
      body: Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget SearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // border: Border.all(color: Colors.amberAccent)
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // border: Border.all(color: Colors.black45)
        ),
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: const TextField(
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: tdBlack),
              prefixIconConstraints: BoxConstraints(
                maxHeight: 20,
                minWidth: 25,
              ),
              border: InputBorder.none,
              hintText: "Search",
              hintStyle: TextStyle(color: tdGrey)),
        ),
      ),
    );
  }
}
