import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../data/models/customer_save_request.dart';
import '../bloc/register_cubit.dart';
import '../bloc/register_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _tcNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dogumTarihiController = TextEditingController();
  final TextEditingController _dogumYeriController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool _isPasswordVisible = false;
  DateTime? _selectedDate;

  // Dropdown seçimleri
  int? _selectedAddressCountryId;
  int? _selectedAddressCityId;
  int? _selectedPhoneCountryId;

  static const String _pageTitle = 'Kayıt Ol';
  static const String _subtitle = 'Yeni Hesap Oluşturun';
  static const String _registerButtonText = 'Kayıt Ol';
  static const String _hasAccountText = 'Hesabınız var mı?';
  static const String _loginText = 'Giriş Yap';
  static const double _maxFormWidth = 600.0;

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _tcNoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dogumTarihiController.dispose();
    _dogumYeriController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 yaş
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dogumTarihiController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen doğum tarihinizi seçiniz'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final request = CustomerSaveRequest(
      ad: _adController.text.trim(),
      soyad: _soyadController.text.trim(),
      tcNo: _tcNoController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      dogumTarihi: _selectedDate!,
      dogumYeri: _dogumYeriController.text.trim().isNotEmpty
          ? _dogumYeriController.text.trim()
          : null,
      addressCountryId: _selectedAddressCountryId,
      addressCityId: _selectedAddressCityId,
      openAddress: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      phoneCountryId: _selectedPhoneCountryId,
      phoneNumber: _phoneNumberController.text.trim(),
    );

    context.read<RegisterCubit>().register(request);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is RegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kayıt başarılı! Giriş yapabilirsiniz.'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      builder: (context, state) {
        final isLoading = state is RegisterLoading;

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
                              Icons.health_and_safety_outlined,
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
                          const SizedBox(height: AppSizes.sm),
                          Center(
                            child: Text(
                              _subtitle,
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: AppSizes.xl),

                          // Ad
                          TextFormField(
                            controller: _adController,
                            decoration: InputDecoration(
                              labelText: 'Ad *',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ad alanı boş bırakılamaz';
                              }
                              if (value.trim().length < 2 ||
                                  value.trim().length > 50) {
                                return 'Ad 2-50 karakter arasında olmalıdır';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Soyad
                          TextFormField(
                            controller: _soyadController,
                            decoration: InputDecoration(
                              labelText: 'Soyad *',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Soyad alanı boş bırakılamaz';
                              }
                              if (value.trim().length < 2 ||
                                  value.trim().length > 50) {
                                return 'Soyad 2-50 karakter arasında olmalıdır';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),

                          // TC No
                          TextFormField(
                            controller: _tcNoController,
                            decoration: InputDecoration(
                              labelText: 'TC Kimlik No *',
                              prefixIcon: const Icon(Icons.credit_card_outlined),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'TC Kimlik No boş bırakılamaz';
                              }
                              if (value.trim().length != 11) {
                                return 'TC Kimlik No 11 haneli olmalıdır';
                              }
                              if (!RegExp(r'^[0-9]{11}$').hasMatch(value.trim())) {
                                return 'TC Kimlik No sadece rakam içermelidir';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'E-posta *',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'E-posta alanı boş bırakılamaz';
                              }
                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Geçerli bir e-posta adresi giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Şifre
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Şifre *',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre alanı boş bırakılamaz';
                              }
                              if (value.length < 6) {
                                return 'Şifre en az 6 karakter olmalıdır';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Doğum Tarihi
                          TextFormField(
                            controller: _dogumTarihiController,
                            decoration: InputDecoration(
                              labelText: 'Doğum Tarihi *',
                              prefixIcon:
                                  const Icon(Icons.calendar_today_outlined),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Doğum tarihi boş bırakılamaz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Doğum Yeri
                          TextFormField(
                            controller: _dogumYeriController,
                            decoration: InputDecoration(
                              labelText: 'Doğum Yeri',
                              prefixIcon: const Icon(Icons.location_city_outlined),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value != null &&
                                  value.trim().isNotEmpty &&
                                  (value.trim().length < 2 ||
                                      value.trim().length > 50)) {
                                return 'Doğum yeri 2-50 karakter arasında olmalıdır';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Telefon Ülke Kodu Dropdown
                          DropdownButtonFormField<int>(
                            key: const Key('phone_country_dropdown'),
                            value: _selectedPhoneCountryId,
                            decoration: InputDecoration(
                              labelText: 'Telefon Ülke Kodu',
                              prefixIcon: const Icon(Icons.flag_outlined),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            items: state.isLoadingCountries
                                ? []
                                : state.countries
                                    .where((country) => country.id != null)
                                    .map((country) {
                                    return DropdownMenuItem<int>(
                                      value: country.id,
                                      child: Text(
                                        '${country.name} ${country.phoneCode != null ? "(${country.phoneCode})" : ""}',
                                      ),
                                    );
                                  }).toList(),
                            onChanged: state.isLoadingCountries
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedPhoneCountryId = value;
                                    });
                                  },
                            hint: state.isLoadingCountries
                                ? const Text('Yükleniyor...')
                                : const Text('Ülke seçiniz'),
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Telefon Numarası
                          TextFormField(
                            controller: _phoneNumberController,
                            decoration: InputDecoration(
                              labelText: 'Telefon Numarası *',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              prefixText: '+90 ',
                              hintText: '5xxxxxxxxx',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Telefon numarası boş bırakılamaz';
                              }
                              if (value.trim().length != 10) {
                                return 'Telefon numarası 10 haneli olmalıdır';
                              }
                              if (!value.trim().startsWith('5')) {
                                return 'Telefon numarası 5 ile başlamalıdır';
                              }
                              if (!RegExp(r'^5[0-9]{9}$').hasMatch(value.trim())) {
                                return 'Geçerli bir telefon numarası giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Adres Ülke Dropdown
                          DropdownButtonFormField<int>(
                            key: const Key('address_country_dropdown'),
                            value: _selectedAddressCountryId,
                            decoration: InputDecoration(
                              labelText: 'Adres Ülkesi',
                              prefixIcon: const Icon(Icons.public_outlined),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            items: state.isLoadingCountries
                                ? []
                                : state.countries
                                    .where((country) => country.id != null)
                                    .map((country) {
                                    return DropdownMenuItem<int>(
                                      value: country.id,
                                      child: Text(country.name),
                                    );
                                  }).toList(),
                            onChanged: state.isLoadingCountries
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedAddressCountryId = value;
                                      _selectedAddressCityId = null;
                                    });
                                    if (value != null) {
                                      context.read<RegisterCubit>().loadCities(value);
                                    } else {
                                      context.read<RegisterCubit>().clearCities();
                                    }
                                  },
                            hint: state.isLoadingCountries
                                ? const Text('Yükleniyor...')
                                : const Text('Ülke seçiniz'),
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Adres Şehir Dropdown
                          DropdownButtonFormField<int>(
                            key: const Key('address_city_dropdown'),
                            value: _selectedAddressCityId,
                            decoration: InputDecoration(
                              labelText: 'Adres Şehri',
                              prefixIcon: const Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            items: state.isLoadingCities
                                ? []
                                : state.cities
                                    .where((city) => city.id != null)
                                    .map((city) {
                                    return DropdownMenuItem<int>(
                                      value: city.id,
                                      child: Text(city.name),
                                    );
                                  }).toList(),
                            onChanged: (_selectedAddressCountryId == null ||
                                    state.isLoadingCities)
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedAddressCityId = value;
                                    });
                                  },
                            hint: _selectedAddressCountryId == null
                                ? const Text('Önce ülke seçiniz')
                                : state.isLoadingCities
                                    ? const Text('Yükleniyor...')
                                    : const Text('Şehir seçiniz'),
                          ),
                          const SizedBox(height: AppSizes.md),

                          // Adres
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Açık Adres',
                              prefixIcon: const Icon(Icons.home_outlined),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            maxLines: 3,
                            maxLength: 250,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value != null &&
                                  value.trim().isNotEmpty &&
                                  value.trim().length > 250) {
                                return 'Adres en fazla 250 karakter olabilir';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.lg),

                          // Kayıt Ol Butonu
                          SizedBox(
                            width: double.infinity,
                            height: AppSizes.buttonHeightLarge,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleRegister,
                              child: isLoading
                                  ? const SizedBox(
                                      height: AppSizes.iconMedium,
                                      width: AppSizes.iconMedium,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.textOnPrimary,
                                      ),
                                    )
                                  : const Text(_registerButtonText),
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),

                          // Giriş Yap Linki
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _hasAccountText,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  _loginText,
                                  style: textTheme.labelLarge?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.md),
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
