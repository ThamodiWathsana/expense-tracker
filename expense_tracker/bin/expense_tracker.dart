import 'dart:io';
import 'dart:convert';

class Expense {
  String description;
  double amount;
  String category;

  Expense(this.description, this.amount, this.category);

  @override
  String toString() {
    return '$description ($category): \$${amount.toStringAsFixed(2)}';
  }

  Map<String, dynamic> toJson() => {
    'description': description,
    'amount': amount,
    'category': category,
  };

  factory Expense.fromJson(Map<String, dynamic> json) =>
      Expense(json['description'], json['amount'], json['category']);
}

class ExpenseTracker {
  List<Expense> expenses = [];
  late final String filePath;

  ExpenseTracker() {
    filePath = '${Directory.current.path}/expenses.json';
    print('Saving expenses to: $filePath');
    loadFromFile();

    if (!File(filePath).existsSync()) {
      saveToFile();
    }
  }

  void saveToFile() {
    final file = File(filePath);
    try {
      final jsonList = expenses.map((e) => e.toJson()).toList();
      file.writeAsStringSync(jsonEncode(jsonList));
      print('Successfully saved to $filePath');
    } catch (e) {
      print('Error saving expenses: $e');
    }
  }

  void loadFromFile() {
    final file = File(filePath);
    if (file.existsSync()) {
      try {
        final jsonList = jsonDecode(file.readAsStringSync()) as List;
        expenses = jsonList.map((e) => Expense.fromJson(e)).toList();
      } catch (e) {
        print('Error loading expenses: $e');
        expenses = [];
      }
    }
  }

  void addExpense(String description, double amount, String category) {
    final expense = Expense(description, amount, category);
    expenses.add(expense);
    saveToFile();
    print('Added: $expense');
  }

  void updateExpense(
    int index, {
    String? description,
    double? amount,
    String? category,
  }) {
    if (index >= 1 && index <= expenses.length) {
      final expense = expenses[index - 1];
      if (description != null && description.trim().isNotEmpty) {
        expense.description = description;
      }
      if (amount != null && amount >= 0) {
        expense.amount = amount;
      }
      if (category != null && category.trim().isNotEmpty) {
        expense.category = category;
      }
      saveToFile();
      print('Updated: $expense');
    } else {
      print('Invalid index!');
    }
  }

  void viewTotal() {
    final total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    print('Total Expenses: \$${total.toStringAsFixed(2)}');
  }

  void viewExpenses() {
    if (expenses.isEmpty) {
      print('No expenses recorded yet!');
      return;
    }
    print('Expenses:');
    for (int i = 0; i < expenses.length; i++) {
      print('${i + 1}. ${expenses[i]}');
    }
  }

  void deleteExpense(int index) {
    if (index >= 1 && index <= expenses.length) {
      final removed = expenses.removeAt(index - 1);
      saveToFile();
      print('Deleted: $removed');
    } else {
      print('Invalid index!');
    }
  }

  void viewHighestExpense() {
    if (expenses.isEmpty) {
      print('No expenses recorded yet!');
      return;
    }

    final highestExpense = expenses.reduce(
      (current, next) => current.amount > next.amount ? current : next,
    );

    print(
      'Highest Expense: ${highestExpense.description} (${highestExpense.category}): \$${highestExpense.amount.toStringAsFixed(2)}',
    );
  }

  void viewTotalByCategory(String category) {
    final categoryExpenses = expenses.where(
      (expense) => expense.category.toLowerCase() == category.toLowerCase(),
    );
    final total = categoryExpenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
    print('Total Expenses for $category: \$${total.toStringAsFixed(2)}');
  }
}

void main() {
  final tracker = ExpenseTracker();

  while (true) {
    print(
      '=============================================================================================',
    );
    print(
      '                                       EXPENSE TRACKER                                      ',
    );
    print(
      '=============================================================================================\n',
    );

    print('Menu Options For you->');
    print('1. Add Expense');
    print('2. View All Expenses');
    print('3. View Total');
    print('4. Delete Expense');
    print('5. View Total by Category');
    print('6. Update Expense');
    print('7. View Highest Expense');
    print('8. Exit');
    stdout.write('Choose an option (1-8): ');

    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        stdout.write('Describe the expense: ');
        final desc = stdin.readLineSync();
        if (desc == null || desc.trim().isEmpty) {
          print('Description cannot be empty!');
          continue;
        }

        stdout.write('Enter the expense amount: ');
        final amountInput = stdin.readLineSync();
        final amount = double.tryParse(amountInput ?? '');
        if (amount == null || amount < 0) {
          print('That doesn’t look right. Try entering a positive number.');
          continue;
        }

        stdout.write('Enter the expense category: ');
        final category = stdin.readLineSync();
        if (category == null || category.trim().isEmpty) {
          print('Category cannot be empty!');
          continue;
        }

        tracker.addExpense(desc, amount, category);
        break;

      case '2':
        tracker.viewExpenses();
        break;

      case '3':
        tracker.viewTotal();
        break;

      case '4':
        tracker.viewExpenses();
        stdout.write(
          'Which expense would you like to delete? Enter its number: ',
        );
        final indexInput = stdin.readLineSync();
        final index = int.tryParse(indexInput ?? '');
        if (index == null) {
          print('Invalid input! Please enter a number.');
          continue;
        }
        tracker.deleteExpense(index);
        break;

      case '5':
        stdout.write('Enter the expense category to check the total: ');
        final category = stdin.readLineSync();
        if (category == null || category.trim().isEmpty) {
          print('Category cannot be empty!');
          continue;
        }
        tracker.viewTotalByCategory(category);
        break;

      case '6':
        tracker.viewExpenses();
        if (tracker.expenses.isEmpty) continue;
        stdout.write('Enter the expense number to update: ');
        final indexInput = stdin.readLineSync();
        final index = int.tryParse(indexInput ?? '');
        if (index == null) {
          print('Invalid input! Please enter a number.');
          continue;
        }
        final expense =
            index >= 1 && index <= tracker.expenses.length
                ? tracker.expenses[index - 1]
                : null;
        if (expense == null) {
          print('Invalid index!');
          continue;
        }

        stdout.write(
          'New description (leave blank to keep "${expense.description}"): ',
        );
        final newDesc = stdin.readLineSync();

        stdout.write('New amount (leave blank to keep ${expense.amount}): ');
        final newAmountInput = stdin.readLineSync();
        final newAmount =
            newAmountInput != null && newAmountInput.trim().isNotEmpty
                ? double.tryParse(newAmountInput)
                : null;

        stdout.write(
          'New category (leave blank to keep "${expense.category}"): ',
        );
        final newCategory = stdin.readLineSync();

        if (newAmountInput != null &&
            newAmountInput.trim().isNotEmpty &&
            newAmount == null) {
          print('That doesn’t look right. Try entering a positive number.');
          continue;
        }

        tracker.updateExpense(
          index,
          description: newDesc,
          amount: newAmount,
          category: newCategory,
        );
        break;
      case '7':
        tracker.viewHighestExpense();
        break;

      case '8':
        print('Exiting... Have a nice day!!!');
        return;

      default:
        print('Invalid choice! Try again.');
    }
  }
}
