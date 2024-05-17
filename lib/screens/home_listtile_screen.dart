import 'package:flutter/material.dart';

import '../services/database/date_time_generator.dart';
import '../services/models/expense_model.dart';


class HomeListTileScreen extends StatelessWidget {
  final void Function() onLongPress;

  /// (){}
  final Expense item;

  const HomeListTileScreen({
    super.key,
    required this.onLongPress,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: onLongPress,
      leading: Icon(
        Icons.attach_money,
        color: item.cost.isNegative ? Colors.red : Colors.green,
      ),
      title: Text(item.title),
      trailing: Text("${item.cost} so'm"),
      subtitle: Text(
        dateTime(item.createdTime),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }
}
