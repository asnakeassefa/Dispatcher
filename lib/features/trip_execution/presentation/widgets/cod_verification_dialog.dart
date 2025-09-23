import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../order/domain/entity/order.dart';

class CODVerificationDialog extends StatefulWidget {
  final List<Order> orders;

  const CODVerificationDialog({
    super.key,
    required this.orders,
  });

  @override
  State<CODVerificationDialog> createState() => _CODVerificationDialogState();
}

class _CODVerificationDialogState extends State<CODVerificationDialog> {
  final Map<String, TextEditingController> _amountControllers = {};
  final Map<String, TextEditingController> _notesControllers = {};
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each order
    for (final order in widget.orders) {
      _amountControllers[order.id] = TextEditingController(
        text: order.codAmount.toStringAsFixed(2),
      );
      _notesControllers[order.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    for (final controller in _notesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalExpected = widget.orders.fold<double>(
      0, (sum, order) => sum + order.codAmount,
    );
    final totalCollected = _getTotalCollected();

    return AlertDialog(
      title: const Text('COD Verification'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Expected Total:'),
                        Text(
                          '\$${totalExpected.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Collected Total:'),
                        Text(
                          '\$${totalCollected.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getTotalColor(totalCollected, totalExpected),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Difference:'),
                        Text(
                          '\$${(totalCollected - totalExpected).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getDifferenceColor(totalCollected, totalExpected),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Individual orders
              ...widget.orders.map((order) => _buildOrderVerification(order)),
              
              // Validation message
              if (_hasValidationErrors()) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getValidationMessage(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isVerifying || _hasValidationErrors() ? null : _verifyCOD,
          child: _isVerifying
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify & Complete'),
        ),
      ],
    );
  }

  Widget _buildOrderVerification(Order order) {
    final collectedAmount = _getCollectedAmount(order.id);
    final difference = collectedAmount - order.codAmount;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Expected: \$${order.codAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountControllers[order.id],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: 'Collected Amount',
              prefixText: '\$',
              border: const OutlineInputBorder(),
              errorText: _getOrderValidationError(order),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesControllers[order.id],
            decoration: const InputDecoration(
              labelText: 'Collection Notes (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          if (difference != 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  difference > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: _getOrderDifferenceColor(difference),
                ),
                const SizedBox(width: 4),
                Text(
                  'Difference: \$${difference.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    color: _getOrderDifferenceColor(difference),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  double _getCollectedAmount(String orderId) {
    final controller = _amountControllers[orderId];
    if (controller == null) return 0;
    return double.tryParse(controller.text) ?? 0;
  }

  double _getTotalCollected() {
    return widget.orders.fold<double>(
      0, (sum, order) => sum + _getCollectedAmount(order.id),
    );
  }

  Color _getTotalColor(double collected, double expected) {
    final difference = collected - expected;
    if (difference < 0) return Colors.red;
    if (difference > 1.0) return Colors.orange;
    return Colors.green;
  }

  Color _getDifferenceColor(double collected, double expected) {
    final difference = collected - expected;
    if (difference < 0) return Colors.red;
    if (difference > 1.0) return Colors.orange;
    return Colors.green;
  }

  Color _getOrderDifferenceColor(double difference) {
    if (difference < 0) return Colors.red;
    if (difference > 1.0) return Colors.orange;
    return Colors.green;
  }

  bool _hasValidationErrors() {
    for (final order in widget.orders) {
      final collected = _getCollectedAmount(order.id);
      final difference = collected - order.codAmount;
      
      // Shortfall not allowed
      if (difference < 0) return true;
      
      // Over-collection tolerance exceeded
      if (difference > 1.0) return true;
    }
    return false;
  }

  String _getValidationMessage() {
    for (final order in widget.orders) {
      final collected = _getCollectedAmount(order.id);
      final difference = collected - order.codAmount;
      
      if (difference < 0) {
        return 'Shortfall not allowed. Order #${order.id} is \$${difference.abs().toStringAsFixed(2)} short.';
      }
      
      if (difference > 1.0) {
        return 'Over-collection tolerance exceeded. Order #${order.id} is \$${difference.toStringAsFixed(2)} over (max \$1.00).';
      }
    }
    return '';
  }

  String? _getOrderValidationError(Order order) {
    final collected = _getCollectedAmount(order.id);
    final difference = collected - order.codAmount;
    
    if (difference < 0) {
      return 'Shortfall not allowed';
    }
    
    if (difference > 1.0) {
      return 'Over-collection exceeds \$1.00 tolerance';
    }
    
    return null;
  }

  Future<void> _verifyCOD() async {
    setState(() {
      _isVerifying = true;
    });

    try {
      // Collect the COD data
      final Map<String, Map<String, dynamic>> codData = {};
      
      for (final order in widget.orders) {
        final collectedAmount = _getCollectedAmount(order.id);
        final notes = _notesControllers[order.id]?.text.trim();
        
        codData[order.id] = {
          'collectedAmount': collectedAmount,
          'collectionDate': DateTime.now(),
          'collectionNotes': notes?.isEmpty == true ? null : notes,
        };
      }
      
      // Return the COD data and close dialog
      Navigator.of(context).pop(codData);
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('COD verification completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying COD: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }
}
