import 'package:flutter/material.dart';
import 'package:expense_tracker/Models/Transactions.dart';

class TransactionRow extends StatefulWidget {
  final Transaction transaction;
  final bool isLargeScreen;

  TransactionRow({required this.transaction, required this.isLargeScreen});

  @override
  _TransactionRowState createState() => _TransactionRowState();
}

class _TransactionRowState extends State<TransactionRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(widget.transaction.labelId)),
            Expanded(child: Text(widget.transaction.amt.toString())),
            if (widget.isLargeScreen)
              Expanded(child: Text(widget.transaction.dateTime)),
            if (widget.isLargeScreen)
              Expanded(child: Text(widget.transaction.comment)),
            if (!widget.isLargeScreen)
              IconButton(
                icon: Icon(
                  _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
          ],
        ),
        if (_isExpanded && !widget.isLargeScreen)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Column(
              children: [
                ListTile(
                  title: Text('ID: ${widget.transaction.id}'),
                ),
                ListTile(
                  title: Text('DateTime: ${widget.transaction.dateTime}'),
                ),
                ListTile(
                  title: Text('Comment: ${widget.transaction.comment}'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
