import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/providers/service_provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/data/service_model.dart';
import 'package:mobile_app/core/design_system.dart';
import 'package:mobile_app/core/app_dimensions.dart';
import 'package:mobile_app/widgets/glass_widgets.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  
  String _selectedCategory = 'AC Repair';
  final List<String> _categories = [
    'AC Repair', 'Plumbing', 'Electrical', 'Cleaning', 'Appliance Repair', 'Mechanical Works'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = context.read<AuthProvider>();
    final serviceProvider = context.read<ServiceProvider>();

    final newService = ServiceModel(
      id: '',
      title: _titleController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      durationMinutes: int.parse(_durationController.text.trim()),
      providerId: authProvider.user?.id ?? '',
      providerName: authProvider.user?.fullName ?? '',
    );

    final success = await serviceProvider.addService(newService);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service added successfully! 🎉'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(serviceProvider.error ?? 'Failed to add service'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Service', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              padding: AppDimensions.screenPadding(context).copyWith(top: AppDimensions.s24, bottom: AppDimensions.s40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInDown(
                        child: GlassCard(
                          padding: const EdgeInsets.all(AppDimensions.s24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("General Details", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: AppDimensions.s24),
                              
                              _buildLabel("Service Title"),
                              GlassInput(
                                controller: _titleController,
                                hintText: "e.g. Split AC Maintenance",
                                validator: (v) => v!.length < 3 ? 'Title must be at least 3 characters' : null,
                              ),
                              
                              const SizedBox(height: AppDimensions.s20),
                              
                              _buildLabel("Category"),
                              _buildCategoryDropdown(),
                              
                              const SizedBox(height: AppDimensions.s20),
                              
                              _buildLabel("Description"),
                              GlassInput(
                                controller: _descriptionController,
                                hintText: "Describe what's included...",
                                keyboardType: TextInputType.multiline,
                                validator: (v) => v!.length < 10 ? 'Description must be at least 10 characters' : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.s24),

                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: GlassCard(
                          padding: const EdgeInsets.all(AppDimensions.s24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Pricing & Time", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: AppDimensions.s24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Price (₹)"),
                                        GlassInput(
                                          controller: _priceController,
                                          hintText: "999",
                                          keyboardType: TextInputType.number,
                                          validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.s16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Duration (m)"),
                                        GlassInput(
                                          controller: _durationController,
                                          hintText: "60",
                                          keyboardType: TextInputType.number,
                                          validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.s48),

                      Consumer<ServiceProvider>(
                        builder: (context, provider, _) => GlassButton(
                          onPressed: provider.isLoading ? null : _submitForm,
                          isLoading: provider.isLoading,
                          text: "List Service Now",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppShadows.soft],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.expand_more_rounded, color: AppColors.primary),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
        ),
      ),
    );
  }
}
