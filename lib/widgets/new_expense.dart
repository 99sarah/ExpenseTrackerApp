import 'dart:io';

import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewExpense extends StatefulWidget {
  ///constructor to create a new expense
  NewExpense({super.key, required this.onAddExpense})
      : expense = Expense.empty(); //creates an empty Expense

  ///constructor to edit an existing expense
  const NewExpense.edit(
      {super.key, required this.onAddExpense, required this.expense});

  final void Function(Expense expense) onAddExpense;
  final Expense expense;

  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.food;
  File? _selectedImage;

  ///initializes the State
  @override
  void initState() {
    super.initState();
    if (widget.expense.title.isNotEmpty) {
      //sets values if it is an existing expense
      _titleController.text = widget.expense.title;
      _amountController.text = widget.expense.amount.toString();
      _selectedDate = widget.expense.date;
      _selectedCategory = widget.expense.category;
      _selectedImage = widget.expense.image;
    }
  }

  ///opens date picker
  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  ///enables the user to pick an image from gallery
  void _pickImage() async {
    ImagePicker().pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _selectedImage = image != null ? File(image.path) : null;
      });
    });
  }

  ///shows the dialog that some input is invalid
  void _showDialog() {
    if (Platform.isIOS) {
      //to show IOS specific dialog
      showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
                title: const Text('Invalid input'),
                content: const Text(
                    'Please make sure a valid title, amount, date and category was entered.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: const Text('Okay'))
                ],
              ));
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
              'Please make sure a valid title, amount, date and category was entered.'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('Okay'))
          ],
        ),
      );
    }
  }

  ///saves the data of the edited/new expense
  void _submitExpenseData() {
    final enteredAmount = double.tryParse(
        _amountController.text); //returns null if not a valid number
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;
    final titleIsInvalid = _titleController.text
        .trim() //removes leading and trailing whitespace
        .isEmpty; //true if title is empty or consists of whitespace
    final dateIsInvalid = _selectedDate == null;

    if (amountIsInvalid || titleIsInvalid || dateIsInvalid) {
      //shows Invalid Input Dialog if any input is invalid
      _showDialog();
      return;
    }

    //saves the final input in the expense attribtue
    widget.expense.title = _titleController.text;
    widget.expense.amount = enteredAmount;
    widget.expense.date = _selectedDate!;
    widget.expense.category = _selectedCategory;
    widget.expense.image = (_selectedImage) ?? widget.expense.image;
    widget.onAddExpense(widget.expense);

    //closes the creating/editing sheet
    Navigator.pop(context);
  }

  ///disposes controllers
  @override
  void dispose() {
    _titleController.dispose(); //controller would otherwise stay in memory
    _amountController.dispose();
    super.dispose();
  }

  ///build method
  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return LayoutBuilder(builder: (ctx, constraints) {
      final width = constraints.maxWidth;

      return SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
            child: Column(
              children: [
                if (width >= 600)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          maxLength: 50,
                          decoration: const InputDecoration(
                            label: Text('Title'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixText: '\$ ',
                            label: Text('Amount'),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  TextField(
                    controller: _titleController,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      label: Text('Title'),
                    ),
                  ),
                if (width >= 600)
                  Row(
                    children: [
                      DropdownButton(
                        value: _selectedCategory,
                        items: Category.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category.name.toUpperCase(),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'No date selected'
                                  : formatter.format(_selectedDate!),
                            ),
                            IconButton(
                              onPressed: _presentDatePicker,
                              icon: const Icon(
                                Icons.calendar_month,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixText: '\$ ',
                            label: Text('Amount'),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'No date selected'
                                  : formatter.format(_selectedDate!),
                            ),
                            IconButton(
                              onPressed: _presentDatePicker,
                              icon: const Icon(
                                Icons.calendar_month,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                const SizedBox(
                  height: 16,
                ),
                if (width >= 600)
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: _submitExpenseData,
                        child: const Text('Save Expense'),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      DropdownButton(
                        value: _selectedCategory,
                        items: Category.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category.name.toUpperCase(),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: _submitExpenseData,
                        child: const Text('Save Expense'),
                      ),
                    ],
                  ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Text('Pick image'),
                        IconButton(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _selectedImage != null
                        ? Image.file(_selectedImage!)
                        : const Text('No image selected')
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
