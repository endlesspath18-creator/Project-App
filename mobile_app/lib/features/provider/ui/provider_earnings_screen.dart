import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class ProviderEarningsScreen extends StatelessWidget {
  const ProviderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Earnings", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: SingleChildScrollView(
              padding: AppDimensions.screenPadding(context).copyWith(top: AppDimensions.s24),
              child: Column(
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 32),
                  const AppSectionLabel(label: "Earnings History"),
                  const SizedBox(height: 16),
                  _buildTransactionsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return FadeInDown(
      child: GlassCard(
        padding: const EdgeInsets.all(AppDimensions.s32),
        borderRadius: AppDimensions.r32,
        child: Column(
          children: [
            const Text("Total Balance", style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 12),
            const Text(
              "₹48,250",
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -1),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    onPressed: () {},
                    text: "Withdraw",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassButton(
                    onPressed: () {},
                    text: "History",
                    isPrimary: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        final txs = [
          {'title': 'AC Repair #9021', 'date': '24 Apr, 10:30 AM', 'amount': '+ ₹1,200', 'status': 'Completed'},
          {'title': 'Full Cleaning #8912', 'date': '23 Apr, 02:15 PM', 'amount': '+ ₹2,450', 'status': 'Completed'},
          {'title': 'Withdrawal to Bank', 'date': '22 Apr, 09:00 AM', 'amount': '- ₹15,000', 'status': 'Paid'},
          {'title': 'Plumbing #8801', 'date': '21 Apr, 11:45 AM', 'amount': '+ ₹850', 'status': 'Completed'},
          {'title': 'Painting #8754', 'date': '20 Apr, 04:30 PM', 'amount': '+ ₹8,200', 'status': 'Completed'},
        ];
        final tx = txs[index];
        final isCredit = tx['amount']!.startsWith('+');
        
        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isCredit ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      color: isCredit ? Colors.green : Colors.orange,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(tx['date']!, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(
                    tx['amount']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isCredit ? Colors.green : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
