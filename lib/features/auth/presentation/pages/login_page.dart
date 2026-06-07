import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/quickalert.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  static const String _appTitle = 'Alkan Sigorta';
  static const String _subtitle = 'Sisteme Giriş Yapın';
  static const String _emailLabel = 'E-posta veya TCKN';
  static const String _passwordLabel = 'Şifre';
  static const String _loginButtonText = 'Giriş Yap';
  static const String _noAccountText = 'Hesabınız yok mu?';
  static const String _registerText = 'Hemen Kayıt Ol';
  static const double _maxFormWidth = 500.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().login(
          _emailController.text,
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Giriş Başarısız',
            text: state.message,
            confirmBtnText: 'Tamam',
            confirmBtnColor: AppColors.error,
            barrierDismissible: true,
          );
        } else if (state is AuthSuccess) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Başarılı!',
            text: 'Giriş başarılı. Yönlendiriliyorsunuz...',
            autoCloseDuration: const Duration(seconds: 1),
            showConfirmBtn: false,
          );

          Future.delayed(const Duration(milliseconds: 1100), () {
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                const SizedBox(height: AppSizes.xxl),
                Icon(
                  Icons.health_and_safety_outlined,
                  size: AppSizes.iconXLarge * 2,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  _appTitle,
                  style: textTheme.displayMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  _subtitle,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.lg),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: _emailLabel,
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Bu alan boş bırakılamaz';
                              }
                              final trimmed = value.trim();
                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );
                              final tcknRegex = RegExp(r'^\d{11}$');

                              if (!emailRegex.hasMatch(trimmed) && !tcknRegex.hasMatch(trimmed)) {
                                return 'Geçerli bir e-posta veya 11 haneli TCKN giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: _passwordLabel,
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
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            textInputAction: TextInputAction.done,
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
                          const SizedBox(height: AppSizes.lg),
                          SizedBox(
                            width: double.infinity,
                            height: AppSizes.buttonHeightLarge,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              child: isLoading
                                  ? const SizedBox(
                                      height: AppSizes.iconMedium,
                                      width: AppSizes.iconMedium,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.textOnPrimary,
                                      ),
                                    )
                                  : const Text(_loginButtonText),
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _noAccountText,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text(
                                  _registerText,
                                  style: textTheme.labelLarge?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.xxl),
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
