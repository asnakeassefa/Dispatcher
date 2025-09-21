
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../widgets/filter_button.dart';
import '../widgets/order_card.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int _selectedIndex = 0;
  final List<String> _filterOptions = [
    'All Orders',
    'Discounted',
    'Not Discounted',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // search box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomTextField(
                controller: TextEditingController(),
                isObscure: false,
                headerText: '',
                hintText: 'Search by order ID, customer name, etc.',
                prefixIcon: Ionicons.search,
                keyboardType: TextInputType.text,
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            // line break
            const Divider(height: 1, color: Colors.grey),
        
            // filter by is discounted
            const SizedBox(height: 8),
            // create horizontal list of filter chips which has only all, is discounted, is not discounted
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  FillterButton(
                    isSelected: _selectedIndex == 0,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    text: 'All Orders',
                  ),
                  const SizedBox(width: 8),
                  FillterButton(
                    isSelected: _selectedIndex == 1,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    text: 'Discounted',
                  ),
                  const SizedBox(width: 8),
                  FillterButton(
                    isSelected: _selectedIndex == 2,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                    text: 'Not Discounted',
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // orders list
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * .67,
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    return const OrderCard();
                  },
                  itemCount: 8,
                  shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
