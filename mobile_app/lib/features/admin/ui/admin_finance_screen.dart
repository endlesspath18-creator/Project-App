import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/constants.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class AdminFinanceScreen extends StatefulWidget {
  const AdminFinanceScreen({super.key});

  @override
  State<AdminFinanceScreen> createState() => _AdminFinanceScreenState();
}

class _AdminFinanceScreenState extends State<AdminFinanceScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _financeStats;

  @override
  void initState() {
    super.initState();
    _loadFinanceData();
  }

  Future<void> _loadFinanceData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.get('/admin/finance/revenue-stats');
      // stats[0] is grouping by type, stats[1] is booking aggregate
      final rawStats = response.data['data'];
      
      setState(() {
        _financeStats = {
          'activationRevenue': (rawStats['activationRevenue'] ?? 0).toDouble(),
          'bookingCommission': (rawStats['bookingCommission'] ?? 0).toDouble(),
          'totalEarnings': (rawStats['totalPlatformEarnings'] ?? 0).toDouble(),
          'bookingRevenue': (rawStats['bookingRevenue'] ?? 0).toDouble(),
        };
      });
    } catch (e) {
      debugPrint('Finance data error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.s24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("FINANCE CONTROL", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
                onPressed: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => const AdminPayoutSettingsScreen())
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadFinanceData,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildRevenueOverview(),
                    const SizedBox(height: 24),
                    const AppSectionLabel(label: "Finance Tools"),
                    const SizedBox(height: 16),
                    _buildToolCard(
                      "Transaction Logs", 
                      "View all payments and activations", 
                      Icons.list_alt_rounded, 
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen()))
                    ),
                    const SizedBox(height: 12),
                    _buildToolCard(
                      "Payout Settings", 
                      "Manage your UPI and Bank details", 
                      Icons.account_balance_rounded, 
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPayoutSettingsScreen()))
                    ),
                  ],
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildRevenueOverview() {
    return FadeInUp(
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        color: AppColors.primary.withValues(alpha: 0.05),
        child: Column(
          children: [
            const Text("Net Platform Earnings", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Text("₹${_financeStats?['totalEarnings'].toInt()}", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const Divider(height: 40),
            Row(
              children: [
                _buildMiniStat("Activation Fees", "₹${_financeStats?['activationRevenue'].toInt()}", Colors.purple),
                const SizedBox(width: 16),
                _buildMiniStat("Commissions", "₹${_financeStats?['bookingCommission'].toInt()}", Colors.teal),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Booking Volume", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Text("₹${_financeStats?['bookingRevenue'].toInt()}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildToolCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return FadeInLeft(
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(subtitle, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Payout Settings Screen ──────────────────────────────────────────────────
class AdminPayoutSettingsScreen extends StatefulWidget {
  const AdminPayoutSettingsScreen({super.key});

  @override
  State<AdminPayoutSettingsScreen> createState() => _AdminPayoutSettingsScreenState();
}

class _AdminPayoutSettingsScreenState extends State<AdminPayoutSettingsScreen> {
  final _upiController = TextEditingController();
  final _nameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    setState(() => _loading = true);
    try {
      final response = await ApiClient.get('/admin/finance/payout-settings');
      final data = response.data['data'];
      if (data != null) {
        _upiController.text = data['upiId'] ?? '';
        _nameController.text = data['accountName'] ?? '';
        _bankNameController.text = data['bankName'] ?? '';
        _accNumberController.text = data['accountNumber'] ?? '';
        _ifscController.text = data['ifscCode'] ?? '';
      }
    } catch (e) {
      debugPrint('Fetch settings error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _loading = true);
    try {
      await ApiClient.post('/admin/finance/payout-settings', {
        'upiId': _upiController.text,
        'accountName': _nameController.text,
        'bankName': _bankNameController.text,
        'accountNumber': _accNumberController.text,
        'ifscCode': _ifscController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payout Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: _loading 
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const AppSectionLabel(label: "UPI Details"),
                    const SizedBox(height: 16),
                    GlassInput(controller: _upiController, hintText: "UPI ID (e.g. name@upi)", prefixIcon: Icons.qr_code_rounded),
                    const SizedBox(height: 12),
                    GlassInput(controller: _nameController, hintText: "Account Holder Name", prefixIcon: Icons.person_outline),
                    const SizedBox(height: 32),
                    const AppSectionLabel(label: "Bank Account Details"),
                    const SizedBox(height: 16),
                    GlassInput(controller: _bankNameController, hintText: "Bank Name", prefixIcon: Icons.account_balance_rounded),
                    const SizedBox(height: 12),
                    GlassInput(
                      controller: _accNumberController, 
                      hintText: "Account Number", 
                      prefixIcon: Icons.numbers_rounded, 
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    GlassInput(controller: _ifscController, hintText: "IFSC Code", prefixIcon: Icons.code_rounded),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        children: [
                          Icon(Icons.security_rounded, size: 16, color: Colors.blue),
                          SizedBox(width: 12),
                          Expanded(child: Text("Details are encrypted at rest and masked for your security.", style: TextStyle(fontSize: 10, color: AppColors.textSecondary))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    GlassButton(onPressed: _saveSettings, text: "Save Securely"),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Transactions Screen ─────────────────────────────────────────────────────
class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  List<dynamic> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final response = await ApiClient.get('/admin/finance/transactions');
      setState(() => _transactions = response.data['data']);
    } catch (e) {
      debugPrint('Fetch transactions error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: _loading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final t = _transactions[index];
                      final isActivation = t['type'] == 'PROVIDER_ACTIVATION';
                      return FadeInUp(
                        delay: Duration(milliseconds: 50 * index),
                        child: GlassCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isActivation ? Colors.purple : Colors.teal).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isActivation ? Icons.bolt_rounded : Icons.home_repair_service_rounded, 
                                  color: isActivation ? Colors.purple : Colors.teal, 
                                  size: 20
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(isActivation ? "Provider Activation" : "Service Booking", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text(t['user']['fullName'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("₹${t['amount']}", style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
                                  if (!isActivation) Text("Comm: ₹${t['commissionAmount']}", style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
                                  Text(t['status'], style: TextStyle(fontSize: 9, color: t['status'] == 'SUCCESS' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
