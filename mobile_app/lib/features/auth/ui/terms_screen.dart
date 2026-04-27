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
        title: const Text("Terms & Conditions", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.gavel_rounded, size: 60, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              "ENDLESSPATH",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const Text(
              "TERMS OF USE & PLATFORM POLICY",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "LEGAL DRAFT",
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            
            _buildTermSection(
              "1", "PLATFORM ROLE (VERY IMPORTANT)",
              "Endlesspath is ONLY a technology marketplace platform that connects Users with independent Service Providers.",
              items: [
                "The Company DOES NOT provide any services directly.",
                "All services are provided SOLELY by third-party Service Providers.",
              ],
              isWarning: true,
            ),
            
            _buildTermSection(
              "2", "INDEPENDENT CONTRACTORS",
              "All Service Providers are INDEPENDENT CONTRACTORS.",
              items: [
                "No employer-employee, partnership, or agency relationship exists with the Company.",
              ],
            ),
            
            _buildTermSection(
              "3", "ZERO LIABILITY FOR SERVICES",
              "The Company shall NOT be responsible for:",
              items: [
                "Service quality issues",
                "Delays or cancellations",
                "Accidents, damages, or losses",
                "Misconduct by Service Providers",
              ],
              footer: "All responsibility lies with the Service Provider and User directly.",
            ),

            _buildTermSection(
              "4", "USER RESPONSIBILITY",
              "Users agree to:",
              items: [
                "Verify service provider details",
                "Use services at their OWN RISK",
              ],
            ),

            _buildTermSection(
              "5", "PAYMENTS & COMMISSION",
              "Payment handling details:",
              items: [
                "Platform may collect payments on behalf of providers",
                "Company charges a COMMISSION / SERVICE FEE",
                "All taxes (including GST) apply as per law",
              ],
            ),

            _buildTermSection(
              "6", "LIMITATION OF LIABILITY",
              "To the maximum extent permitted by law, Endlesspath shall NOT be liable for indirect, incidental, or consequential damages including loss of money, data, or reputation.",
            ),

            _buildTermSection(
              "7", "INDEMNIFICATION",
              "Users & Service Providers agree to PROTECT and COMPENSATE the Company against:",
              items: [
                "Legal claims",
                "Losses due to misuse, negligence, or violations",
              ],
            ),

            _buildTermSection(
              "8", "STRICT NEUTRALITY POLICY",
              "The Platform maintains STRICT NEUTRALITY and EQUALITY.",
              items: [
                "No promotion or propagation of any: Religion, Political ideology, Caste or community-based discrimination.",
                "Endlesspath believes ALL RELIGIONS AND INDIVIDUALS ARE EQUAL.",
              ],
              footer: "Any violation may result in IMMEDIATE ACCOUNT SUSPENSION OR REMOVAL.",
              highlight: true,
            ),

            _buildTermSection(
              "9", "PROHIBITED ACTIVITIES",
              "Users & Providers must NOT:",
              items: [
                "Perform illegal activities",
                "Share false information",
                "Engage in fraud or harmful conduct",
              ],
            ),

            _buildTermSection(
              "10", "ACCOUNT SUSPENSION",
              "The Company reserves the right to:",
              items: [
                "Suspend or terminate accounts",
                "Without prior notice",
              ],
              footer: "If any misuse, fraud, or policy violation occurs.",
            ),

            _buildTermSection(
              "11", "COMPLIANCE WITH LAW",
              "All users must follow APPLICABLE INDIAN LAWS AND REGULATIONS.",
            ),

            _buildTermSection(
              "12", "GOVERNING LAW",
              "This Agreement is governed by the LAWS OF INDIA, and disputes fall under jurisdiction of courts in our registered location.",
            ),

            const SizedBox(height: 40),
            const Text(
              "Final Note: This is a startup-level legal draft. Clauses may change based on service operations.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: AppColors.textTertiary, fontStyle: FontStyle.italic),
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
}
