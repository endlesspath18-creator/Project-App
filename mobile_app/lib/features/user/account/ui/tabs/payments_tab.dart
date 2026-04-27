import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/providers/user_account_provider.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';
import 'package:animate_do/animate_do.dart';

class PaymentsTab extends StatefulWidget {
  const PaymentsTab({super.key});

  @override
  State<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserAccountProvider>(context, listen: false).fetchPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserAccountProvider>(context);
    final payments = provider.payments;
    final isLoading = provider.isLoading;

    if (isLoading && payments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_rounded, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            const Text("No transactions yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Your payment history will appear here", style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        final bool isSuccess = payment['status'] == 'SUCCESS' || payment['status'] == 'captured';
        final bool isFailed = payment['status'] == 'FAILED' || payment['status'] == 'failed';

        return FadeInUp(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (isSuccess ? Colors.green : (isFailed ? Colors.red : Colors.orange)).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess ? Icons.check_circle_outline : (isFailed ? Icons.error_outline : Icons.pending_outlined),
                      color: isSuccess ? Colors.green : (isFailed ? Colors.red : Colors.orange),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment['booking'] != null ? payment['booking']['service']['title'] : "Service Payment",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          "ID: ${payment['paymentId'] ?? 'N/A'}",
                          style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
                        ),
                        Text(
                          _formatDate(payment['createdAt']),
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "\u20B9${payment['amount']}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        payment['status'].toString().toUpperCase(),
                        style: TextStyle(
                          color: isSuccess ? Colors.green : (isFailed ? Colors.red : Colors.orange),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return "${date.day} ${_getMonth(date.month)} ${date.year}";
  }

  String _getMonth(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }
}
