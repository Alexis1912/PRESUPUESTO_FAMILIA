import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final amount = TextEditingController();
  final desc = TextEditingController();
  String category = "Alimentos";

  final fs = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agregar Gasto")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Monto"),
            ),

            TextField(
              controller: desc,
              decoration: InputDecoration(labelText: "Descripción"),
            ),

            SizedBox(height: 10),
            DropdownButton<String>(
              value: category,
              items: ["Alimentos", "Transporte", "Servicios", "Otros"]
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              child: Text("Guardar"),
              onPressed: () async {
                final exp = Expense(
                  id: "",
                  amount: double.tryParse(amount.text) ?? 0,
                  description: desc.text,
                  category: category,
                  createdAt: Timestamp.now(),
                );

                await fs.addExpense(exp);

                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
