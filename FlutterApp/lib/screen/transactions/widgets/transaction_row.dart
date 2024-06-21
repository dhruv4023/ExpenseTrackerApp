import 'package:flutter/material.dart';
import 'package:expense_tracker/Models/Transactions.dart';

class TransactionRow extends StatefulWidget {
  final String accountName;
  final String? labelName;
  final Transaction transaction;
  final bool isLargeScreen;
  final Function(String) onEditTransactionComment;
  final Function(String) onEditTransactionLabel;
  final Function(String) onDeleteTransaction;

  TransactionRow({
    required this.labelName,
    required this.accountName,
    required this.transaction,
    required this.isLargeScreen,
    required this.onEditTransactionComment,
    required this.onEditTransactionLabel,
    required this.onDeleteTransaction,
  });

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
            Expanded(child: Text(widget.accountName)),
            Expanded(child: Text(widget.transaction.amt.toString())),
            if (widget.isLargeScreen)
              Expanded(
                  child: Text(widget.labelName == null
                      ? "No label"
                      : widget.labelName!)),
            if (widget.isLargeScreen)
              Expanded(child: Text(widget.transaction.dateTime)),
            if (widget.isLargeScreen)
              Expanded(child: Text(widget.transaction.comment)),
            if (!widget.isLargeScreen)
              Expanded(
                child: IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  ),
                  onPressed: () {
                    setState(
                      () {
                        _isExpanded = !_isExpanded;
                      },
                    );
                  },
                ),
              ),
            if (widget.isLargeScreen)
              Expanded(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () {
                        widget.onEditTransactionComment(widget.transaction.id);
                      },
                    ),
                    IconButton(
                      color: Colors.amber,
                      icon: Icon(Icons.label),
                      onPressed: () {
                        widget.onEditTransactionLabel(widget.transaction.id);
                      },
                    ),
                    IconButton(
                      color: Colors.red,
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        widget.onDeleteTransaction(widget.transaction.id);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (_isExpanded && !widget.isLargeScreen)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Column(
              children: [
                ListTile(
                  title: Text('Label: ${widget.labelName}'),
                ),
                ListTile(
                  title: Text('DateTime: ${widget.transaction.dateTime}'),
                ),
                ListTile(
                  title: Text('Comment: ${widget.transaction.comment}'),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        widget.onEditTransactionComment(widget.transaction.id);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.label),
                      onPressed: () {
                        widget.onEditTransactionLabel(widget.transaction.id);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        widget.onDeleteTransaction(widget.transaction.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
