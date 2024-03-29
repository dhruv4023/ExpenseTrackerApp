import 'package:flutter/material.dart';

class buildSearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return searchField();
  }

  Widget searchField() {
    return TextField(
      onChanged: (value) {
        // Handle search input here
      },
      decoration: const InputDecoration(
        hintText: 'Search...',
        contentPadding: EdgeInsetsDirectional.all(20),
        border: InputBorder.none,
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}

List<Widget> buildAppBarActions(bool isSearching, Function toggleSearch) {
  return [
    IconButton(
      icon: isSearching ? const Icon(Icons.clear) : const Icon(Icons.search),
      onPressed: () {
        toggleSearch(!isSearching);
      },
    ),
  ];
}
