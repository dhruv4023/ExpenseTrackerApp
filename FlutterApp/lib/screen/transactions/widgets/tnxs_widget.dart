import 'package:expense_tracker/Models/LabelMetaData.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/Models/Transactions.dart';
import 'package:expense_tracker/screen/transactions/widgets/TransactionRow.dart';

class TnxWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final List<LabelMetaData> labelsMetadata;
  TnxWidget({required this.transactions, required this.labelsMetadata});

  @override
  Widget build(BuildContext context) {
  

    return Container(
      height: 500,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey, // Border color
          width: 1.0, // Border width
        ),
        borderRadius:
            BorderRadius.circular(7.0), // Circular rectangle border radius
      ),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        bool isLargeScreen = constraints.maxWidth > 600;

        return CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: 20.0,
                maxHeight: 20.0,
                child: Container(
                  color: Theme.of(context).canvasColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Label',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Text('Amount',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      if (isLargeScreen)
                        Expanded(
                          child: Text('DateTime',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      if (isLargeScreen)
                        Expanded(
                          child: Text('Comment',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      if (!isLargeScreen)
                        Expanded(
                          child: Text('Details',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Column(
                    children: [
                      Divider(),
                      TransactionRow(
                        label_name: labelsMetadata.firstWhere((e) => e.id == transactions[index].labelId).labelName,
                        transaction: transactions[index],
                        isLargeScreen: isLargeScreen,
                      ),
                    ],
                  );
                },
                childCount: transactions.length,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
