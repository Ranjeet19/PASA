import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

// ================== MODEL ==================
class TransactionModel extends HiveObject {
  String title;
  String subtitle;
  double amount;
  bool isIncome;
  DateTime date;
  String category;

  TransactionModel({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.date,
    required this.category,
  });
}

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 50; // change if it collides with an existing adapter

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      title: fields[0] as String,
      subtitle: fields[1] as String,
      amount: fields[2] as double,
      isIncome: fields[3] as bool,
      date: fields[4] as DateTime,
      category: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.subtitle)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.isIncome)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.category);
  }
}

// ================== SERVICE ==================
class FinanceService {
  static const String boxName = 'transactions';

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(50)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<TransactionModel>(boxName);
    }
  }

  static Box<TransactionModel> get box => Hive.box<TransactionModel>(boxName);

  static Future<void> addTransaction(TransactionModel tx) async {
    await box.add(tx);
  }

  static Future<void> deleteTransaction(TransactionModel tx) async {
    await tx.delete();
  }

  static List<TransactionModel> getAll() {
    final list = box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  static double getBalance() {
    double balance = 0;
    for (var tx in box.values) {
      balance += tx.isIncome ? tx.amount : -tx.amount;
    }
    return balance;
  }

  static double getIncome() {
    double total = 0;
    for (var tx in box.values) {
      if (tx.isIncome) total += tx.amount;
    }
    return total;
  }

  static double getExpense() {
    double total = 0;
    for (var tx in box.values) {
      if (!tx.isIncome) total += tx.amount;
    }
    return total;
  }

  static Future<void> seedIfEmpty() async {
    if (box.isNotEmpty) return;
    final now = DateTime.now();
    await addTransaction(TransactionModel(
      title: 'Grocery',
      subtitle: 'Eataly downtown',
      amount: 50.68,
      isIncome: false,
      date: now,
      category: 'grocery',
    ));
    await addTransaction(TransactionModel(
      title: 'Transport',
      subtitle: 'UBER Pool',
      amount: 6.00,
      isIncome: false,
      date: now,
      category: 'transport',
    ));
    await addTransaction(TransactionModel(
      title: 'Payment',
      subtitle: 'Payment from Andre',
      amount: 650.00,
      isIncome: true,
      date: now.subtract(const Duration(days: 1)),
      category: 'payment',
    ));
  }
}

// ================== ENTRY WIDGET ==================
class FinanceHomeScreen extends StatefulWidget {
  const FinanceHomeScreen({super.key});

  @override
  State<FinanceHomeScreen> createState() => _FinanceHomeScreenState();
}

class _FinanceHomeScreenState extends State<FinanceHomeScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final all = FinanceService.getAll();
    final filtered = _filter == 'All'
        ? all
        : all.where((t) => _filter == 'Income' ? t.isIncome : !t.isIncome).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopCard(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                  const Padding(
                      padding:  EdgeInsets.fromLTRB(20, 22, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Transactions',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          Text('See all',
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _filterChip('All'),
                          const SizedBox(width: 8),
                          _filterChip('Income'),
                          const SizedBox(width: 8),
                          _filterChip('Expense'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text('No transactions',
                                  style: TextStyle(color: Colors.black38)))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) => _transactionTile(filtered[i]),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _showAddTransactionSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ============ REDESIGNED TOP CARD ============
  Widget _buildTopCard() {
    final balance = FinanceService.getBalance();
    final income = FinanceService.getIncome();
    final expense = FinanceService.getExpense();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Text('Finance',
                  style: TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('AVAILABLE BALANCE',
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('•••• 2864',
                          style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 18),
                Container(height: 1, color: Colors.white12),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _statBlock(
                        icon: Icons.arrow_downward,
                        label: 'Income',
                        value: income,
                      ),
                    ),
                    Container(width: 1, height: 34, color: Colors.white12),
                    Expanded(
                      child: _statBlock(
                        icon: Icons.arrow_upward,
                        label: 'Expense',
                        value: expense,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _quickAction(Icons.arrow_upward, 'Send'),
              _quickAction(Icons.arrow_downward, 'Request'),
              _quickAction(Icons.attach_money, 'Loan'),
              _quickAction(Icons.account_balance_wallet_outlined, 'Topup'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBlock({required IconData icon, required String label, required double value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white30),
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            Text('\$${value.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _quickAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _filterChip(String label) {
    final selected = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.black : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.black : Colors.transparent),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _transactionTile(TransactionModel tx) {
    final icon = switch (tx.category) {
      'grocery' => Icons.shopping_bag_outlined,
      'transport' => Icons.directions_car_outlined,
      'payment' => Icons.account_balance_wallet_outlined,
      _ => Icons.receipt_outlined,
    };
    return Dismissible(
      key: ValueKey(tx.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        FinanceService.deleteTransaction(tx);
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  Text(tx.subtitle, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${tx.isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: tx.isIncome ? Colors.black : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(DateFormat('MMM d').format(tx.date),
                    style: const TextStyle(color: Colors.black38, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool isIncome = false;
    String category = 'grocery';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Transaction',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: subtitleCtrl,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(labelText: 'Subtitle / Note'),
                  ),
                  TextField(
                    controller: amountCtrl,
                    style: const TextStyle(color: Colors.black),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Expense'),
                        selected: !isIncome,
                        selectedColor: Colors.black,
                        labelStyle: TextStyle(color: !isIncome ? Colors.white : Colors.black),
                        onSelected: (_) => setSheetState(() => isIncome = false),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Income'),
                        selected: isIncome,
                        selectedColor: Colors.black,
                        labelStyle: TextStyle(color: isIncome ? Colors.white : Colors.black),
                        onSelected: (_) => setSheetState(() => isIncome = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(value: 'grocery', child: Text('Grocery')),
                      DropdownMenuItem(value: 'transport', child: Text('Transport')),
                      DropdownMenuItem(value: 'payment', child: Text('Payment')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) => setSheetState(() => category = v ?? 'other'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final amount = double.tryParse(amountCtrl.text) ?? 0;
                        if (titleCtrl.text.trim().isEmpty || amount <= 0) return;
                        await FinanceService.addTransaction(TransactionModel(
                          title: titleCtrl.text.trim(),
                          subtitle: subtitleCtrl.text.trim(),
                          amount: amount,
                          isIncome: isIncome,
                          date: DateTime.now(),
                          category: category,
                        ));
                        if (ctx.mounted) Navigator.pop(ctx);
                        setState(() {});
                      },
                      child: const Text('Add', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}