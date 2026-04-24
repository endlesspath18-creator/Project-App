import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';
import 'package:mobile_app/data/service_model.dart';
import 'package:mobile_app/providers/booking_provider.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _addressController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeSlot = "10:00 AM";

  final List<String> _timeSlots = [
    "09:00 AM", "10:00 AM", "11:00 AM", 
    "12:00 PM", "02:00 PM", "04:00 PM", "06:00 PM"
  ];

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _handleBooking(ServiceModel service) async {
    if (_addressController.text.isEmpty) {
      _showSnackBar("Please enter service address", isError: true);
      return;
    }

    final provider = context.read<BookingProvider>();
    final success = await provider.createBooking(
      serviceId: service.id,
      address: _addressController.text.trim(),
      scheduledDate: _selectedDate,
    );

    if (success && mounted) {
      _showSuccessDialog();
    } else if (mounted) {
      _showSnackBar(provider.error ?? "Booking failed", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r12)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ZoomIn(
        child: BackdropFilter(
          filter: ColorFilter.mode(Colors.black.withValues(alpha: 0.1), BlendMode.darken),
          child: AlertDialog(
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r24)),
            title: const Text("Booking Success! 🎉", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            content: const Text(
              "Your service has been scheduled. The provider will contact you shortly.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back from booking screen
                },
                child: const Text("Awesome", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // In a real app, you'd get this from arguments
    final dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args == null || args is! ServiceModel) {
       return const Scaffold(body: Center(child: Text("Missing service data")));
    }
    final ServiceModel service = args;

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
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.home_repair_service, color: AppColors.primary),
                          ),
                          const SizedBox(width: AppDimensions.s16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(service.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text("by ${service.providerName}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text("₹${service.price.toInt()}", style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
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
                  const SizedBox(height: AppDimensions.s48),
                  Consumer<BookingProvider>(
                    builder: (context, prov, _) => GlassButton(
                      onPressed: prov.isLoading ? null : () => _handleBooking(service),
                      isLoading: prov.isLoading,
                      text: "Confirm Booking",
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
                    boxShadow: isSelected ? [
                       BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                    ] : null,
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
      spacing: 12,
      runSpacing: 12,
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
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              boxShadow: isSelected ? [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
              ] : [AppShadows.soft],
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
}
