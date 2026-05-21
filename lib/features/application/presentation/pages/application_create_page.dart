import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../data/models/application_save_request.dart';
import '../bloc/application_cubit.dart';
import '../bloc/application_state.dart';
import '../../../product/presentation/bloc/product_cubit.dart';
import '../../../product/presentation/bloc/product_state.dart';

class ApplicationCreatePage extends StatefulWidget {
  const ApplicationCreatePage({super.key});

  @override
  State<ApplicationCreatePage> createState() => _ApplicationCreatePageState();
}

class _ApplicationCreatePageState extends State<ApplicationCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _installmentCountController = TextEditingController();

  String? _selectedGender;
  String? _selectedPaymentType;
  int? _selectedProductId;

  static const String _pageTitle = 'Yeni Başvuru Oluştur';
  static const double _maxFormWidth = 600.0;

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _installmentCountController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ürün seçiniz'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen cinsiyet seçiniz'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedPaymentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ödeme tipi seçiniz'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Taksit sayısını belirle: Peşin ise 1, Taksitli ise kullanıcının girdiği değer
    final installmentCount = _selectedPaymentType == 'P'
        ? 1
        : int.parse(_installmentCountController.text);

    final request = ApplicationSaveRequest(
      customerId: 1, // Test için sabit değer
      productId: _selectedProductId!,
      description: 'Mobil uygulama üzerinden oluşturulan başvuru',
      paymentTypeCode: _selectedPaymentType!,
      installmentCount: installmentCount,
      requestedCoverageCodes: ['COVERAGE_001', 'COVERAGE_002'], // Test için sabit değerler
      age: int.parse(_ageController.text),
      height: double.parse(_heightController.text),
      weight: double.parse(_weightController.text),
      gender: _selectedGender,
    );

    context.read<ApplicationCubit>().submitApplication(request);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<ApplicationCubit, ApplicationState>(
      listener: (context, state) {
        if (state is ApplicationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is ApplicationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Başvuru başarıyla oluşturuldu'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is ApplicationLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxFormWidth),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Icon(
                              Icons.assignment_outlined,
                              size: AppSizes.iconXLarge * 1.5,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.md),
                          Center(
                            child: Text(
                              _pageTitle,
                              style: textTheme.displayMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: AppSizes.xl),

                          // Ürün Seçimi
                          BlocBuilder<ProductCubit, ProductState>(
                            builder: (context, state) {
                              if (state is ProductLoading) {
                                return Container(
                                  padding: const EdgeInsets.all(AppSizes.md),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.textSecondary),
                                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                  ),
                                  child: const Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      SizedBox(width: AppSizes.md),
                                      Text('Ürünler yükleniyor...'),
                                    ],
                                  ),
                                );
                              }

                              if (state is ProductLoaded) {
                                return DropdownButtonFormField<int>(
                                  decoration: InputDecoration(
                                    labelText: 'Ürün Seçimi *',
                                    prefixIcon: const Icon(Icons.shopping_bag_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                    ),
                                  ),
                                  items: state.products.map((product) {
                                    return DropdownMenuItem<int>(
                                      value: product.id,
                                      child: Text(
                                        '${product.name} - ${product.amount.toStringAsFixed(2)} TL',
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedProductId = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Ürün seçimi zorunludur';
                                    }
                                    return null;
                                  },
                                );
                              }

                              if (state is ProductFailure) {
                                return Container(
                                  padding: const EdgeInsets.all(AppSizes.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    border: Border.all(color: AppColors.error),
                                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: AppColors.error),
                                      const SizedBox(width: AppSizes.md),
                                      Expanded(
                                        child: Text(
                                          state.message,
                                          style: const TextStyle(color: AppColors.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Yaş
                          TextFormField(
                            controller: _ageController,
                            decoration: InputDecoration(
                              labelText: 'Yaş *',
                              prefixIcon: const Icon(Icons.calendar_today_outlined),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Yaş alanı boş bırakılamaz';
                              }
                              final age = int.tryParse(value);
                              if (age == null || age < 1 || age > 120) {
                                return 'Geçerli bir yaş giriniz (1-120)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Boy (cm)
                          TextFormField(
                            controller: _heightController,
                            decoration: InputDecoration(
                              labelText: 'Boy (cm) *',
                              prefixIcon: const Icon(Icons.height_outlined),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Boy alanı boş bırakılamaz';
                              }
                              final height = double.tryParse(value);
                              if (height == null || height < 50 || height > 250) {
                                return 'Geçerli bir boy giriniz (50-250 cm)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Kilo (kg)
                          TextFormField(
                            controller: _weightController,
                            decoration: InputDecoration(
                              labelText: 'Kilo (kg) *',
                              prefixIcon: const Icon(Icons.monitor_weight_outlined),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Kilo alanı boş bırakılamaz';
                              }
                              final weight = double.tryParse(value);
                              if (weight == null || weight < 20 || weight > 300) {
                                return 'Geçerli bir kilo giriniz (20-300 kg)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Cinsiyet
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Cinsiyet *',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'E', child: Text('Erkek')),
                              DropdownMenuItem(value: 'K', child: Text('Kadın')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Cinsiyet seçimi zorunludur';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Ödeme Tipi
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Ödeme Tipi *',
                              prefixIcon: const Icon(Icons.payment_outlined),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'P', child: Text('Peşin')),
                              DropdownMenuItem(value: 'T', child: Text('Taksitli')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentType = value;
                                // Peşin seçilirse taksit sayısı alanını temizle
                                if (value == 'P') {
                                  _installmentCountController.clear();
                                }
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ödeme tipi seçimi zorunludur';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Taksit Sayısı (Sadece Taksitli seçilirse göster)
                          if (_selectedPaymentType == 'T') ...[
                            TextFormField(
                              controller: _installmentCountController,
                              decoration: InputDecoration(
                                labelText: 'Taksit Sayısı *',
                                prefixIcon: const Icon(Icons.credit_card_outlined),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.radiusMedium),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (_selectedPaymentType == 'T') {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Taksit sayısı boş bırakılamaz';
                                  }
                                  final installment = int.tryParse(value);
                                  if (installment == null || installment < 1 || installment > 12) {
                                    return 'Geçerli bir taksit sayısı giriniz (1-12)';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.xl),
                          ] else
                            const SizedBox(height: AppSizes.xl),

                          // Kaydet Butonu
                          SizedBox(
                            width: double.infinity,
                            height: AppSizes.buttonHeightLarge,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.radiusMedium),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: AppColors.textOnPrimary,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Kaydet',
                                      style: textTheme.titleMedium?.copyWith(
                                        color: AppColors.textOnPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
