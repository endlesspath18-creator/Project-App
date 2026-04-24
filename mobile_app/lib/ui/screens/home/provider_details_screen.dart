import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../widgets/glass_widgets.dart';

class ProviderDetailsScreen extends StatelessWidget {
  const ProviderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: GlacierGradients.bgGlow))),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, GlacierColors.background],
                      ),
                    ),
                    child: const Center(child: Icon(Icons.engineering, size: 80, color: GlacierColors.primary)),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Apex AC Solutions", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const Text(" 4.9 (120+ reviews)", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Text("AVAILABLE", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 12),
                      Text(
                        "We provide high-end AC maintenance and repair services. Our team is certified and follows all safety protocols. We guarantee satisfaction with every job.",
                        style: TextStyle(color: Colors.white.withOpacity(0.6), height: 1.6),
                      ),
                      const SizedBox(height: 32),
                      const Text("Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 16),
                      _ServiceItem("General Servicing", "₹499"),
                      _ServiceItem("Gas Refilling", "₹899"),
                      _ServiceItem("PCB Repair", "₹1,499"),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: GlassButton(onPressed: () {}, text: "Book Appointment"),
          ),
        ],
      ),
    );
  }

  Widget _ServiceItem(String title, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(price, style: const TextStyle(color: GlacierColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
