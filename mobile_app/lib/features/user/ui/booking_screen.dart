import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';
import 'package:mobile_app/data/service_model.dart';
import 'package:mobile_app/providers/booking_provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeSlot = "10:00 AM";
  String _paymentMethod = "COD"; // COD or ONLINE

  late Razorpay _razorpay;
  late ServiceModel _service;

  final List<String> _timeSlots = [
    "09:00 AM", "10:00 AM", "11:00 AM", 
    "12:00 PM", "02:00 PM", "04:00 PM", "06:00 PM"
  ];

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
    _addressController.dispose();
    _notesController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  // ─── Razorpay Callbacks ──────────────────────────────────────────────────

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final provider = context.read<BookingProvider>();
    
    final bookingData = {
      'serviceId': _service.id,
      'dateTime': _selectedDate.toIso8601String(),
      'address': _addressController.text.trim(),
      'notes': _notesController.text.trim(),
    };

    final success = await provider.verifyAndConfirmBooking(
      orderId: response.orderId!,
      paymentId: response.paymentId!,
      signature: response.signature!,
      bookingData: bookingData,
    );

    if (success && mounted) {
      _showSuccessDialog("Payment Successful! Your booking is confirmed.");
    } else if (mounted) {
      _showSnackBar(provider.error ?? "Failed to verify payment", isError: true);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showSnackBar("Payment Failed: ${response.message}", isError: true);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackBar("External Wallet Selected: ${response.walletName}");
  }

  // ─── Booking Logic ───────────────────────────────────────────────────────

  void _handleBooking() async {
    if (_addressController.text.isEmpty) {
      _showSnackBar("Please enter service address", isError: true);
      return;
    }

    final bookingProvider = context.read<BookingProvider>();
    final authProvider = context.read<AuthProvider>();

    if (_paymentMethod == "COD") {
      final success = await bookingProvider.createBooking(
        serviceId: _service.id,
        address: _addressController.text.trim(),
        scheduledDate: _selectedDate,
        notes: _notesController.text.trim(),
        paymentMethod: "COD",
      );

      if (success && mounted) {
        _showSuccessDialog("Booking Request Sent! Pay after service completion.");
      } else if (mounted) {
        _showSnackBar(bookingProvider.error ?? "Booking failed", isError: true);
      }
    } else {
      // Step 1: Create Razorpay Order
      final orderData = await bookingProvider.createPaymentOrder(_service.id);
      if (orderData == null) {
        _showSnackBar(bookingProvider.error ?? "Failed to initialize payment", isError: true);
        return;
      }

      // Step 2: Open Razorpay Checkout
      var options = {
        'key': orderData['key'],
        'amount': (orderData['amount'] * 100).toInt(), // amount in paise
        'name': 'EndlessPath Services',
        'order_id': orderData['orderId'],
        'description': _service.title,
        'prefill': {
          'contact': authProvider.user?.phone ?? '',
          'email': authProvider.user?.email ?? ''
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint('Razorpay Error: $e');
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ZoomIn(
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r24)),
          title: const Text("Success! 🎉", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          content: Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back from booking screen
              },
              child: const Text("Done", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args == null || args is! ServiceModel) {
       return const Scaffold(body: Center(child: Text("Missing service data")));
    }
    _service = args;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Schedule Service", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: AppGradients.bgGlow))),
          SafeArea(
            child: SingleChildScrollView(
              padding: AppDimensions.screenPadding(context).copyWith(top: AppDimensions.s24, bottom: AppDimensions.s48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: GlassCard(
                      padding: const EdgeInsets.all(AppDimensions.s16),
                      child: Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.home_repair_service, color: AppColors.primary),
                          ),
                          const SizedBox(width: AppDimensions.s16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_service.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text("by ${_service.providerName}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                Text("₹${_service.price.toInt()}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s32),
                  const AppSectionLabel(label: "Select Date"),
                  _buildDatePicker(),
                  const SizedBox(height: AppDimensions.s32),
                  const AppSectionLabel(label: "Available Slots"),
                  _buildTimeSlots(),
                  const SizedBox(height: AppDimensions.s32),
                  const AppSectionLabel(label: "Service Address"),
                  FadeInUp(
                    child: GlassInput(
                      controller: _addressController,
                      hintText: "Enter full address with landmark",
                      prefixIcon: Icons.location_on_outlined,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s32),
                  const AppSectionLabel(label: "Payment Method"),
                  _buildPaymentMethods(),
                  const SizedBox(height: AppDimensions.s48),
                  Consumer<BookingProvider>(
                    builder: (context, prov, _) => GlassButton(
                      onPressed: prov.isLoading ? null : _handleBooking,
                      isLoading: prov.isLoading,
                      text: _paymentMethod == "COD" ? "Complete Booking" : "Pay & Book Now",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return FadeInUp(
      child: GlassCard(
        padding: const EdgeInsets.all(AppDimensions.s8),
        borderRadius: AppDimensions.r16,
        child: Row(
          children: List.generate(5, (index) {
            final date = DateTime.now().add(Duration(days: index + 1));
            final isSelected = date.day == _selectedDate.day;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][date.weekday - 1],
                        style: TextStyle(color: isSelected ? Colors.white : AppColors.textTertiary, fontSize: 10),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${date.day}",
                        style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: _timeSlots.map((slot) {
        final isSelected = _selectedTimeSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedTimeSlot = slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              slot,
              style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        _paymentOption(
          id: "COD",
          title: "Cash on Delivery",
          subtitle: "Pay after service completion",
          icon: Icons.money,
        ),
        const SizedBox(height: 12),
        _paymentOption(
          id: "ONLINE",
          title: "Online Payment",
          subtitle: "Cards, UPI, Netbanking",
          icon: Icons.account_balance_wallet,
        ),
      ],
    );
  }

  Widget _paymentOption({required String id, required String title, required String subtitle, required IconData icon}) {
    final isSelected = _paymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = id),
      child: FadeInUp(
        child: GlassCard(
          padding: const EdgeInsets.all(AppDimensions.s16),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textTertiary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    Text(subtitle, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
