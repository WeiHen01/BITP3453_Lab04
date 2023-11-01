import 'package:flutter/material.dart';

class Expense{
  final String description;
  final String amount;

  Expense(this.description, this.amount);
}

class DailyExpensesApp extends StatelessWidget {

  // Constructor parameter to accept the Username value
  final String username;
  const DailyExpensesApp({required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      // username will be passed to ExpenseList()
      home: ExpenseList(username: username),
    );
  }
}

class ExpenseList extends StatefulWidget {

  // Constructor parameter to accept the Username value
  final String username;
  ExpenseList({required this.username});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {

  /**
   * By accepting the username parameter in both
   * the DailyExpensesApp and ExpenseList constructors,
   * you enable the passing of the username value from the
   * parent screen (in this case, DailyExpensesApp) to the
   * child screen (in this case, ExpenseList).
   * This allows you to use the username value on the
   * ExpenseList screen.
   */
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // Show SnackBar with a welcome message and the username
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${widget.username}!'),
        ),
      );
    });
  }

  final List<Expense> expenses = [];
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController totalController = TextEditingController();

  double total = 0.0;

  void _addExpense(){
    String description = descriptionController.text.trim();
    String amount = amountController.text.trim();

    if(description.isNotEmpty && amount.isNotEmpty){
      setState(() {

        // sum up the total cost spend
        total = double.parse(amount) + total;

        // adding the new items into the List
        expenses.add(Expense(description, amount));

        // display the output in text field
        totalController.text = total.toStringAsFixed(1);

        // clear the text fields
        descriptionController.clear();
        amountController.clear();



      });
    }
  }

  void _removeExpense(int index){
    setState(() {

      // variable to convert input from text field to double datatype
      double cost = double.parse(expenses[index].amount);

      // calculation
      total = total - cost;

      totalController.text = total.toString();
      expenses.removeAt(index);

      // if there's no items in the List, set default total spend is 0
      if(expenses.length == 0){
        totalController.text = '0.0';
      }

    });
  }

  void _editExpense(int index)
  {
    Navigator.push(
      context,
        MaterialPageRoute(
        builder: (context)=> EditExpenseScreen(
            expense: expenses[index],
            onSave: (editedExpense){
              setState(() {
                total += double.parse(editedExpense.amount) - double.parse(expenses[index].amount);
                expenses[index] = editedExpense;
                totalController.text = totalController.toString();
              });
            }
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Daily Expenses'),

        ),
        body: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount (RM)',
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: totalController,
                // enabled: false, //disable from editing text in text field
                decoration: InputDecoration(
                  labelText: 'Total Spend(RM)',
                ),
              ),
            ),

            ElevatedButton(
                onPressed: _addExpense,
                child: Text('Add Expense')
            ),

            Container(
              child: _buildListView(),
            ),
          ],
        )
    );
  }


  Widget _buildListView() {
    return Expanded(
      child: ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: Key(expenses[index].amount),
              background: Container(
                color: Colors.red,
                  child: Center(
                      child: Text("Delete", style: TextStyle(
                        color: Colors.white
                      ))
                  )
              ),
              onDismissed: (direction){
                _removeExpense(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item dismissed'))
                );
              },
              child: Card(
                child: ListTile(
                  title: Text(expenses[index].description),
                  subtitle: Text('Amount: ${expenses[index].amount}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeExpense(index),
                  ),
                  onLongPress: (){
                    _editExpense(index);
                  },
                ),
              ),
            );
          }
      ),
    );
  }
}

class EditExpenseScreen extends StatelessWidget {
  //const EditExpenseScreen({super.key});
  final Expense expense;
  final Function(Expense) onSave;

  EditExpenseScreen({required this.expense, required this.onSave});

  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    descController.text = expense.description;
    amountController.text = expense.amount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
      ),
      body:
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                )
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount (RM)',
                  )
              ),
            ),

            ElevatedButton(
                onPressed:(){
                  // Save the edited expense details
                  onSave(Expense(amountController.text, descController.text));

                  // Navigate back to ExpenseList screen
                  Navigator.pop(context);
                },
                child: Text("Save")
            ),
          ],
        )
    );
  }
}
