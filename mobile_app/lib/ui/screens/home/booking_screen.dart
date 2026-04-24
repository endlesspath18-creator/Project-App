import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../widgets/glass_widgets.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: GlacierGradients.bgGlow))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                      const Text("Booking Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Service Selected", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text("Premium AC Deep Cleaning", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        const Text("Select Date & Time", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _DateTimePickerBox(Icons.calendar_month, "28 Oct 2024")),
                            const SizedBox(width: 12),
                            Expanded(child: _DateTimePickerBox(Icons.access_time, "10:30 AM")),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text("Payment Method", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _PaymentMethodBox("Razorpay / UPI", true),
                        _PaymentMethodBox("Cash after service", false),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("TOTAL AMOUNT", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                            const Text("₹1,299", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(
                          width: 150,
                          child: GlassButton(onPressed: () {}, text: "Confirm"),
                        ),
                      ],
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

  Widget _DateTimePickerBox(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: GlacierColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _PaymentMethodBox(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? GlacierColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? GlacierColors.primary : Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? GlacierColors.primary : Colors.white24),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
