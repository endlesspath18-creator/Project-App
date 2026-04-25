import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/core/api_client.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class ProviderActivationScreen extends StatefulWidget {
  const ProviderActivationScreen({super.key});

  @override
  State<ProviderActivationScreen> createState() => _ProviderActivationScreenState();
}

class _ProviderActivationScreenState extends State<ProviderActivationScreen> {
  late Razorpay _razorpay;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _startPayment() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.post('/payments/activation/create-order', {});
      final data = response.data['data'];

      final options = {
        'key': data['key'],
        'amount': data['amount'] * 100, // in paise
        'name': 'EndlessPath Services',
        'order_id': data['orderId'],
        'description': 'Provider Activation Fee',
        'prefill': {
          'contact': context.read<AuthProvider>().user?.phone ?? '',
          'email': context.read<AuthProvider>().user?.email ?? '',
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error creating order: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isLoading = true);
    try {
      final verifyResponse = await ApiClient.post('/payments/activation/verify', {
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
      });

      if (verifyResponse.statusCode == 200) {
        // Refresh local user data
        await context.read<AuthProvider>().refreshUser();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Activated Successfully! 🎉"), backgroundColor: Colors.green));
          Navigator.pop(context, true); // Return success
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verification failed: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment failed: ${response.message}")));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("External wallet selected: ${response.walletName}")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildContent()),
                _buildFooter(),
              ],
            ),
          ),
          if (_isLoading) Container(color: Colors.black.withValues(alpha: 0.3), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 20),
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.bolt_rounded, size: 64, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            child: const Text(
              "Activate Your Professional Account",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Text(
              "Join our network of top-tier service providers and start growing your business today.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 40),
          _buildBenefitItem(Icons.check_circle_rounded, "Publish unlimited services"),
          _buildBenefitItem(Icons.check_circle_rounded, "Get featured in search results"),
          _buildBenefitItem(Icons.check_circle_rounded, "Direct booking management"),
          _buildBenefitItem(Icons.check_circle_rounded, "Secure online payments"),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              color: AppColors.primary.withValues(alpha: 0.05),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("One-time Activation Fee: ", style: TextStyle(fontWeight: FontWeight.w500)),
                  Text("₹300", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return FadeInLeft(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.green, size: 20),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          GlassButton(
            onPressed: _startPayment, 
            text: "Unlock Full Access",
          ),
          const SizedBox(height: 16),
          const Text(
            "Secure payment via Razorpay",
            style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
