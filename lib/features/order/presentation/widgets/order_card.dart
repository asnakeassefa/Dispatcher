import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/model/order_with_customer.dart';

class OrderCard extends StatelessWidget {
  final OrderWithCustomer orderWithCustomer;
  final VoidCallback? onTap;
  
  const OrderCard({
    super.key,
    required this.orderWithCustomer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final order = orderWithCustomer.order;
    final customer = orderWithCustomer.customer;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getOrderTypeColor().withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getOrderTypeColor().withOpacity(0.05),
                _getOrderTypeColor().withOpacity(0.02),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Order ID and Type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.id}',
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            customer?.name ?? 'Unknown Customer',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildOrderTypeChip(context),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Order Details Grid
                _buildDetailsGrid(context),
                
                const SizedBox(height: 16),
                
                // Items Summary
                _buildItemsSummary(context),
                
                const SizedBox(height: 16),
                
                // Action Footer
                _buildActionFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context) {
    final order = orderWithCustomer.order;
    
    return Row(
      children: [
        // Weight Info
        Expanded(
          child: _buildDetailItem(
            icon: Ionicons.scale_outline,
            label: 'Weight',
            value: '${order.totalWeight.toStringAsFixed(1)} kg',
            color: _getOrderTypeColor(),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Volume Info
        Expanded(
          child: _buildDetailItem(
            icon: Ionicons.cube_outline,
            label: 'Volume',
            value: '${order.totalVolume.toStringAsFixed(2)} m³',
            color: _getOrderTypeColor(),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Items Count
        Expanded(
          child: _buildDetailItem(
            icon: Ionicons.bag_outline,
            label: 'Items',
            value: '${order.items.length}',
            color: _getOrderTypeColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildItemsSummary(BuildContext context) {
    final order = orderWithCustomer.order;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Ionicons.list_outline,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Order Items',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...order.items.take(3).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _getOrderTypeColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${item.name} (${item.quantity}x)',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${item.weight.toStringAsFixed(1)}kg',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),
          if (order.items.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+${order.items.length - 3} more items',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context) {
    final order = orderWithCustomer.order;
    
    return Row(
      children: [
        // Location Info
        Expanded(
          child: Row(
            children: [
              Icon(
                Ionicons.location_outline,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatLocation(),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // COD Amount
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.successColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Ionicons.cash_outline,
                size: 14,
                color: AppTheme.successColor,
              ),
              const SizedBox(width: 4),
              Text(
                '\$${order.codAmount.toStringAsFixed(0)}',
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // View Details Button
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: _getOrderTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getOrderTypeColor().withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Ionicons.eye_outline,
                  size: 14,
                  color: _getOrderTypeColor(),
                ),
                const SizedBox(width: 4),
                Text(
                  'View',
                  style: AppTheme.labelSmall.copyWith(
                    color: _getOrderTypeColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTypeChip(BuildContext context) {
    final order = orderWithCustomer.order;
    final isDiscounted = order.isDiscounted;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getOrderTypeColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getOrderTypeColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDiscounted ? Ionicons.pricetag_outline : Ionicons.receipt_outline,
            size: 14,
            color: _getOrderTypeColor(),
          ),
          const SizedBox(width: 6),
          Text(
            isDiscounted ? 'Discounted' : 'Regular',
            style: AppTheme.labelSmall.copyWith(
              color: _getOrderTypeColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getOrderTypeColor() {
    return orderWithCustomer.order.isDiscounted 
        ? AppTheme.successColor 
        : AppTheme.warningColor;
  }

  String _formatLocation() {
    final customer = orderWithCustomer.customer;
    if (customer?.location != null) {
      return '${customer!.location.lat.toStringAsFixed(4)}, ${customer.location.lon.toStringAsFixed(4)}';
    }
    return 'Location not available';
  }
}
