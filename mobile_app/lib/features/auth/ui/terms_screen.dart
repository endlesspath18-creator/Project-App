import 'package:flutter/material.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Platform Policies", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.security_rounded, size: 60, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              "ENDLESSPATH",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const Text(
              "COMPLETE APP DETAILS & POLICIES",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            _buildTermSection(
              "1", "INTRODUCTION",
              "Endlesspath is a technology-based platform designed to connect users with independent service providers. We simplify everyday needs by providing access to multiple services through a single application.",
            ),

            _buildTermSection(
              "2", "ABOUT THE APP",
              "Endlesspath provides access to a wide range of services including Transportation, Home Services, Delivery, Repairs, Local Workers, Education Services, and more.",
              footer: "Vision: Simple, fast, and reliable all-in-one service platform.",
            ),

            _buildTermSection(
              "3", "PLATFORM ROLE & OPERATION",
              "Endlesspath is a marketplace platform only. We do not provide services directly.",
              items: [
                "All providers are independent third parties.",
                "No employer-employee relationship exists.",
                "Platform operates on a commission-based model.",
              ],
              isWarning: true,
            ),

            _buildTermSection(
              "4", "ACCOUNT & SECURITY",
              "Users are responsible for their account activity.",
              items: [
                "Do not share OTPs or login details with anyone.",
                "Unauthorized usage due to negligence is the user's responsibility.",
              ],
            ),

            _buildTermSection(
              "5", "COMMUNICATION & RESPECT",
              "Endlesspath promotes equality and respect for all. All communication must be respectful.",
              items: [
                "Strictly prohibited: Abuse, threats, or misuse.",
                "Zero Tolerance: Comments against religion, caste, region, or community.",
                "Abusive or discriminatory behavior leads to permanent ban.",
              ],
              highlight: true,
            ),

            _buildTermSection(
              "6", "SERVICE & LOCATION ACCURACY",
              "Services depend on user location and accurate data.",
              items: [
                "Users must provide correct information.",
                "Incorrect data may affect service quality or lead to cancellation.",
              ],
            ),

            _buildTermSection(
              "7", "SERVICE PROVIDER TERMS",
              "Providers are expected to maintain professional standards.",
              items: [
                "Deliver genuine services and follow applicable laws.",
                "Maintain quality, safety, and respect for users.",
              ],
            ),

            _buildTermSection(
              "8", "PAYMENTS, CANCELLATIONS & REFUNDS",
              "Standard financial policies apply to all bookings.",
              items: [
                "Service charges and platform fees may apply.",
                "Refunds depend on providers; Endlesspath assists but does not guarantee them.",
              ],
            ),

            _buildTermSection(
              "9", "PRIVACY POLICY & DATA",
              "We value your privacy and handle data with care.",
              items: [
                "We collect Name, Phone, Location, and Usage data.",
                "Data is used for service delivery and platform improvement.",
                "WE DO NOT SELL YOUR PERSONAL DATA.",
              ],
              footer: "Data may be used for analytics to improve service quality.",
            ),

            _buildTermSection(
              "10", "DISCLAIMER & LIABILITY",
              "Endlesspath is NOT responsible for:",
              items: [
                "Service quality or delays.",
                "Damages caused by third-party providers.",
                "Actions or behavior of independent providers.",
              ],
              footer: "Use services at your own discretion.",
            ),

            _buildTermSection(
              "11", "JURISDICTION & UPDATES",
              "Terms are governed by the laws of India. Disputes are subject to local jurisdiction.",
              footer: "Policies may change as the platform evolves.",
            ),

            _buildTermSection(
              "12", "BETA & STARTUP NOTICE",
              "Endlesspath is currently in its early-stage / startup phase.",
              items: [
                "Currently in Beta: Features and services may change.",
                "Registration: Compliance and registration processes are in progress.",
              ],
              highlight: true,
            ),

            const SizedBox(height: 32),
            _buildContactSection(),
            const SizedBox(height: 40),
            const Text(
              "❤️ FINAL STATEMENT\nEndlesspath aims to build a trusted, simple, and equal platform for everyone. We are committed to transparency and growth.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTermSection(String num, String title, String content, {List<String>? items, String? footer, bool isWarning = false, bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: highlight ? Colors.amber : (isWarning ? Colors.red : AppColors.primary),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: highlight ? Colors.orange[900] : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content, style: const TextStyle(fontSize: 13, height: 1.5)),
                if (items != null) ...[
                  const SizedBox(height: 8),
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        Expanded(child: Text(item, style: const TextStyle(fontSize: 13, height: 1.5))),
                      ],
                    ),
                  )),
                ],
                if (footer != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    footer,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("📩 CONTACT US", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _contactItem(Icons.camera_alt_outlined, "Instagram", "@endlesspath._"),
          const SizedBox(height: 12),
          _contactItem(Icons.email_outlined, "Email", "endlesspath18@email.com"),
        ],
      ),
    );
  }

  Widget _contactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}
