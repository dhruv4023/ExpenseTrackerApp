// lib/screen/label/widgets/label_list.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/Models/Label.dart';

class LabelList extends StatelessWidget {
  final List<Label> labels;
  final int? expandedIndex;
  final Function(int) onExpansionChanged;
  final Function(String) onEditLabelName;
  final Function(String) onSetDefaultLabel;

  LabelList({
    required this.labels,
    required this.expandedIndex,
    required this.onExpansionChanged,
    required this.onEditLabelName,
    required this.onSetDefaultLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        onExpansionChanged(index);
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: monthNameMap.entries.map((entry) {
                final monthKey = entry.key;
                final monthName = entry.value;
                return _buildTotalMonthCard(monthName, monthKey);
              }).toList(),
            ),
          ),
          isExpanded: expandedIndex == 0,
        ),
        ...labels.map<ExpansionPanel>((label) {
          final index = labels.indexOf(label) + 1;
          final totals = label.calculateTotalDrCr();
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Wrap(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        label.labelName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        "CR: +${totals['total_cr']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(
                              255, 165, 250, 168), // Set color for CR
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        "DR: -${totals['total_dr']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(
                              255, 228, 130, 123), // Set color for DR
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        "OVERALL: ${(totals['total_cr']! - totals['total_dr']!).toStringAsFixed(2)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                (totals['total_cr']! - totals['total_dr']!) < 0
                                    ? Colors.red
                                    : Colors.green),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        onEditLabelName(label.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.star),
                      disabledColor: Colors.blue,
                      onPressed: label.isDefault
                          ? null
                          : () {
                              onSetDefaultLabel(
                                  label.id);
                            },
                    ),
                  ],
                ),
              );
            },
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                children: label.monthlyData.keys.map((month) {
                  return _buildMonthCard(
                    monthNameMap[month]!,
                    label.monthlyData[month]!,
                  );
                }).toList(),
              ),
            ),
            isExpanded: expandedIndex == index,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMonthCard(String month, Map<String, double> data) {
    final totalDr = data['dr'] ?? 0;
    final totalCr = data['cr'] ?? 0;

    return _buildCard(month, totalDr, totalCr);
  }

  Widget _buildTotalMonthCard(String month, String monthKey) {
    double totalDr = 0;
    double totalCr = 0;

    for (var label in labels) {
      totalDr += label.monthlyData[monthKey]?['dr'] ?? 0;
      totalCr += label.monthlyData[monthKey]?['cr'] ?? 0;
    }

    totalDr = double.parse(totalDr.toStringAsFixed(2));
    totalCr = double.parse(totalCr.toStringAsFixed(2));

    return _buildCard(month, totalDr, totalCr);
  }

  Widget _buildCard(String month, double totalDr, double totalCr) {
    return Container(
      width: 120.0,
      height: 200.0,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 8.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 16.0),
              SizedBox(width: 4.0),
              Text(
                month,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            'DR: $totalDr',
            style: TextStyle(fontSize: 12.0),
          ),
          Text(
            'CR: $totalCr',
            style: TextStyle(fontSize: 12.0),
          ),
          Text(
            'OVERALL: ${totalCr - totalDr}',
            style: TextStyle(
                fontSize: 12.0,
                color: totalCr < totalDr ? Colors.red : Colors.green),
          ),
          SizedBox(height: 8.0),
          if (totalDr != 0 || totalCr != 0)
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    if (totalDr != 0)
                      PieChartSectionData(
                        color: Colors.red,
                        value: totalDr.toDouble(),
                        title: 'DR',
                        radius: 30,
                        titleStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (totalCr != 0)
                      PieChartSectionData(
                        color: Colors.green,
                        value: totalCr.toDouble(),
                        title: 'CR',
                        radius: 30,
                        titleStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                  sectionsSpace: 0,
                  centerSpaceRadius: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

const Map<String, String> monthNameMap = {
  'jan': 'January',
  'feb': 'February',
  'mar': 'March',
  'apr': 'April',
  'may': 'May',
  'jun': 'June',
  'jul': 'July',
  'aug': 'August',
  'sep': 'September',
  'oct': 'October',
  'nov': 'November',
  'dec': 'December',
};
