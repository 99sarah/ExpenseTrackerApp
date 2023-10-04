import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

const uuid = Uuid();

enum Category { food, travel, leisure, work }

const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.travel: Icons.flight_takeoff,
  Category.leisure: Icons.movie,
  Category.work: Icons.work,
};

class Expense {
  ///constructor for a new expense with data
  Expense(
      {required this.title,
      required this.amount,
      required this.date,
      required this.category})
      : id = uuid.v4();

  ///constructor for an empty expense
  Expense.empty()
      : id = uuid.v4(),
        title = '',
        amount = 0,
        date = DateTime.now(),
        category = Category.food;

  final String id;
  String title;
  double amount;
  DateTime date;
  Category category;
  File? image;

  ///returns the formatted date
  String get formattedDate {
    return formatter.format(date);
  }
}

class ExpenseBucket {
  ///constructor for an ExpenseBucket with category and the belonging expenses
  const ExpenseBucket({
    required this.category,
    required this.expenses,
  });

  ///constructor for an ExpenseBucket for a category with all expenses
  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
      : expenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();

  final Category category;
  final List<Expense> expenses;

  ///returns total expenses for that bucket(for a certain category)
  double get totalExpenses {
    double sum = 0;

    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}
