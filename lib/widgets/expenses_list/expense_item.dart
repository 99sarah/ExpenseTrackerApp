import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';

class ExpenseItem extends StatelessWidget {
  ///constructor
  const ExpenseItem(this.expense, {super.key});

  final Expense expense;

  ///build method
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // opens ModalBottomSheet for the user to edit this specific expense
        showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (ctx) =>
              NewExpense.edit(onAddExpense: (expense) {}, expense: expense),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                  ), //max 2 numbers behind the comma
                  const Spacer(),
                  Row(
                    children: [
                      Icon(categoryIcons[expense.category]),
                      const SizedBox(width: 8),
                      Text(expense.formattedDate)
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
