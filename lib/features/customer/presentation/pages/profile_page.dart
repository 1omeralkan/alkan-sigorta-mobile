import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/quickalert.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/customer_update_request.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storageService = StorageService();

  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tcNoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEditMode = false;
  int? _customerId;

  @override
  void initState() {
    super.initState();
    _loadCustomerId();
  }

  Future<void> _loadCustomerId() async {
    final id = await _storageService.getCustomerId();
    if (mounted && id != null) {
      setState(() => _customerId = id);
      context.read<ProfileCubit>().loadProfile(id);
    }
  }

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _emailController.dispose();
    _tcNoController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _populateFields(ProfileState state) {
    if (state is ProfileLoaded || state is ProfileUpdating) {
      final customer = state is ProfileLoaded
          ? state.customer
          : (state as ProfileUpdating).customer;

      _adController.text = customer.ad;
      _soyadController.text = customer.soyad;
      _emailController.text = customer.email;
      _tcNoController.text = customer.tcNo;
      _phoneController.text = customer.phoneNumber ?? '';
      _addressController.text = customer.openAddress ?? '';
    }
  }

  void _handleUpdate() {
    if (!_formKey.currentState!.validate()) return;

    if (_customerId == null) return;

    final request = CustomerUpdateRequest(
      ad: _adController.text.trim(),
      soyad: _soyadController.text.trim(),
      email: _emailController.text.trim(),
      tcNo: _tcNoController.text.trim(),
      password: _passwordController.text,
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      openAddress: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
    );

    context.read<ProfileCubit>().updateProfile(_customerId!, request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditMode = true),
            )
          else
            TextButton(
              onPressed: () {
                setState(() => _isEditMode = false);
                _passwordController.clear();
              },
              child: const Text(
                'İptal',
                style: TextStyle(color: AppColors.textOnPrimary),
              ),
            ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Hata',
              text: state.message,
            );
          } else if (state is ProfileUpdateSuccess) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: 'Başarılı',
              text: 'Profil bilgileriniz güncellendi',
              autoCloseDuration: const Duration(seconds: 2),
              showConfirmBtn: false,
            );
            setState(() => _isEditMode = false);
            _passwordController.clear();
          }

          if (state is ProfileLoaded || state is ProfileUpdating) {
            _populateFields(state);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ProfileError && state is! ProfileUpdateSuccess) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: AppSizes.md),
                  Text(state.message),
                  const SizedBox(height: AppSizes.lg),
                  ElevatedButton(
                    onPressed: () {
                      if (_customerId != null) {
                        context.read<ProfileCubit>().loadProfile(_customerId!);
                      }
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final isLoading = state is ProfileUpdating;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        if (state is ProfileLoaded || state is ProfileUpdating)
                          Text(
                            (state is ProfileLoaded ? state.customer : (state as ProfileUpdating).customer).fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Personal Info Section
                  _buildSectionTitle('Kişisel Bilgiler'),
                  const SizedBox(height: AppSizes.md),
                  _buildTextField(
                    controller: _adController,
                    label: 'Ad',
                    icon: Icons.person_outline,
                    enabled: _isEditMode,
                    validator: (value) =>
                        value?.trim().isEmpty ?? true ? 'Ad boş olamaz' : null,
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildTextField(
                    controller: _soyadController,
                    label: 'Soyad',
                    icon: Icons.person_outline,
                    enabled: _isEditMode,
                    validator: (value) =>
                        value?.trim().isEmpty ?? true ? 'Soyad boş olamaz' : null,
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildTextField(
                    controller: _tcNoController,
                    label: 'TC Kimlik No',
                    icon: Icons.badge_outlined,
                    enabled: false,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Contact Info Section
                  _buildSectionTitle('İletişim Bilgileri'),
                  const SizedBox(height: AppSizes.md),
                  _buildTextField(
                    controller: _emailController,
                    label: 'E-posta',
                    icon: Icons.email_outlined,
                    enabled: _isEditMode,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'E-posta boş olamaz';
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (!emailRegex.hasMatch(value!)) {
                        return 'Geçerli bir e-posta giriniz';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Telefon',
                    icon: Icons.phone_outlined,
                    enabled: _isEditMode,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Adres',
                    icon: Icons.location_on_outlined,
                    enabled: _isEditMode,
                    maxLines: 3,
                  ),

                  if (_isEditMode) ...[
                    const SizedBox(height: AppSizes.xl),
                    _buildSectionTitle('Şifre Doğrulama'),
                    const SizedBox(height: AppSizes.md),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mevcut Şifre',
                      icon: Icons.lock_outline,
                      enabled: true,
                      obscureText: true,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Şifre gerekli' : null,
                    ),
                    const SizedBox(height: AppSizes.xl),
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeightLarge,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _handleUpdate,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(isLoading ? 'Kaydediliyor...' : 'Kaydet'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSizes.xl),
                  _buildLogoutButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: !enabled,
        fillColor: enabled ? null : AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeightLarge,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(),
        icon: const Icon(Icons.logout),
        label: const Text('Çıkış Yap'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final rootNavigator = Navigator.of(context, rootNavigator: true);
              await _storageService.deleteToken();
              await _storageService.deleteCustomerId();
              await _storageService.deleteCustomerName();
              if (mounted) {
                Navigator.pop(dialogContext);
                rootNavigator.pushReplacementNamed('/');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
