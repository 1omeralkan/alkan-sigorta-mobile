import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  static const String _appTitle = 'Alkan Sigorta';
  static const String _subtitle = 'Sisteme Giriş Yapın';
  static const String _emailLabel = 'E-posta veya TCKN';
  static const String _passwordLabel = 'Şifre';
  static const String _forgotPasswordText = 'Şifremi Unuttum';
  static const String _loginButtonText = 'Giriş Yap';
  static const String _noAccountText = 'Hesabınız yok mu?';
  static const String _registerText = 'Hemen Kayıt Ol';
  static const double _maxFormWidth = 500.0;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxFormWidth),
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
                  decoration: InputDecoration(
                    labelText: _emailLabel,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
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
                ),
                const SizedBox(height: AppSizes.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      _forgotPasswordText,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeightLarge,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
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
                      onPressed: () {},
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
    );
  }
}
