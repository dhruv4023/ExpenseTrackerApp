import 'package:flutter/material.dart';
import 'package:expense_tracker/Models/Label.dart';
import 'package:expense_tracker/constants/colors.dart';
import 'package:expense_tracker/Models/Account.dart';

class LabelList extends StatelessWidget {
  final List<Label> labels;
  final List<Account> accounts;
  final Function(String, bool) onEditLabelName;
  final Function(String, bool) onSetDefaultLabel;
  final Function(String, bool) onDeleteLabel; // Add delete callback

  LabelList({
    required this.labels,
    required this.accounts,
    required this.onEditLabelName,
    required this.onSetDefaultLabel,
    required this.onDeleteLabel, // Initialize delete callback
  });

  @override
  Widget build(BuildContext context) {
    double overallTotal =
        accounts.fold(0, (sum, account) => sum + account.balance);
    
    bool ACCOUNT = true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            'Total Balance: ${overallTotal.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            'Accounts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: tdBlue,
            ),
          ),
        ),
        ...accountWidgets(ACCOUNT),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            'Labels',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: tdBlue,
            ),
          ),
        ),
        ...labelWidgets(!ACCOUNT),
      ],
    );
  }

  List<Widget> labelWidgets(bool isAccount) {
    return labels
        .map(
          (label) => ListTile(
            title: Text(label.labelName),
            subtitle: Text('Total: ${label.balance.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.amber,
                  onPressed: () {
                    onEditLabelName(label.id, isAccount);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.star),
                  disabledColor: label.isDefault ? tdBlue : null,
                  onPressed: label.isDefault
                      ? null
                      : () {
                          onSetDefaultLabel(label.id, isAccount);
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: tdRed,
                  onPressed: () {
                    onDeleteLabel(label.id, isAccount);
                  },
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  List<Widget> accountWidgets(bool isAccount) {
    return accounts
        .map(
          (account) => ListTile(
            title: Text(account.accountName),
            subtitle: Text('Balance: ${account.balance.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.amber,
                  onPressed: () {
                    onEditLabelName(account.id, isAccount);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.star),
                  disabledColor: account.isDefault ? tdBlue : null,
                  onPressed: account.isDefault
                      ? null
                      : () {
                          onSetDefaultLabel(account.id, isAccount);
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: tdRed,
                  onPressed: () {
                    onDeleteLabel(account.id, isAccount);
                  },
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
