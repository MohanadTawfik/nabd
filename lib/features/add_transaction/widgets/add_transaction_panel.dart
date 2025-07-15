import 'package:flutter/material.dart';

class AddTransactionPanel extends StatefulWidget {
  const AddTransactionPanel({super.key});
  @override
  State<AddTransactionPanel> createState() => _AddTransactionPanelState();
}

class _AddTransactionPanelState extends State<AddTransactionPanel> {
  String _amount = '0';
  String? _selectedCategory;
  final List<String> _categories = ['طعام', 'مواصلات', 'مقاضي', 'فواتير'];

  void _onNumpadTapped(String value) {
    setState(() {
      if (value == '⌫') {
        _amount =
            _amount.length > 1 ? _amount.substring(0, _amount.length - 1) : '0';
      } else if (_amount == '0' && value != '.') {
        _amount = value;
      } else {
        if (value == '.' && _amount.contains('.')) return;
        _amount += value;
      }
    });
  }

  void _saveTransaction() {
    // حالياً، فقط نطبع البيانات ونغلق الواجهة
    print('Saving Transaction: Amount: $_amount, Category: $_selectedCategory');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12))),
          const SizedBox(height: 24),
          _buildAmountDisplay(),
          const SizedBox(height: 24),
          _buildCategoryBubbles(),
          const SizedBox(height: 24),
          _buildNumpad(),
          const SizedBox(height: 16),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildCategoryBubbles() {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      alignment: WrapAlignment.center,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category;
        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = selected ? category : null;
            });
          },
          backgroundColor: const Color(0xff0d1117),
          selectedColor: const Color(0xff8952ff),
          labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color:
                      isSelected ? const Color(0xff8952ff) : Colors.white24)),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff8952ff),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        child: const Text('حفظ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Column(children: [
      Text(_amount,
          style: const TextStyle(
              color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold)),
      const Text('ريال يمني',
          style: TextStyle(color: Colors.white54, fontSize: 18))
    ]);
  }

  Widget _buildNumpad() {
    final buttons = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '.',
      '0',
      '⌫'
    ];
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 1.5),
        itemCount: buttons.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => TextButton(
            onPressed: () => _onNumpadTapped(buttons[index]),
            style: TextButton.styleFrom(
                foregroundColor: Colors.white, shape: const CircleBorder()),
            child: Text(buttons[index],
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold))));
  }
}
