import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/biometric_service.dart';
import '../services/auth_service.dart';

class BiometricLockScreen extends StatefulWidget {
  final VoidCallback onUnlockSuccess;
  final VoidCallback onReload;

  const BiometricLockScreen({
    super.key,
    required this.onUnlockSuccess,
    required this.onReload,
  });

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> with SingleTickerProviderStateMixin {
  bool _isAuthenticating = false;
  String _message = 'Ketuk sensor sidik jari untuk masuk';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto trigger biometric prompt after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBiometricAuth();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startBiometricAuth() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _message = 'Menunggu verifikasi sidik jari...';
    });

    final success = await BiometricService.instance.authenticate(
      'Verifikasi identitas Anda untuk membuka Retivy',
    );

    if (mounted) {
      setState(() {
        _isAuthenticating = false;
      });

      if (success) {
        widget.onUnlockSuccess();
      } else {
        setState(() {
          _message = 'Autentikasi gagal. Silakan ketuk tombol sidik jari untuk mencoba kembali.';
        });
      }
    }
  }

  Future<void> _handleFallbackLogout() async {
    // Custom dialog asking for confirmation before logging out
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: const Text('Masuk dengan Akun Lain?'),
          content: const Text(
            'Langkah ini akan mengeluarkan sesi offline Anda saat ini dan meminta Anda masuk kembali dengan password.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal', style: TextStyle(color: theme.colorScheme.outline)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Keluar & Login Ulang'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await AuthService.instance.logout();
      widget.onReload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Elegant animated background mesh
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF131524), const Color(0xFF0F1113)]
                    : [const Color(0xFFE8EBFC), const Color(0xFFF7F9FB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Radial decorative glowing spots
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.25),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.secondary.withValues(alpha: isDark ? 0.12 : 0.2),
                ),
              ),
            ),
          ),

          // Central Frosted Card Layout
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(32.0),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Brand Logo
                        Image.asset(
                          'assets/images/retivy_logo_padded.png',
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return CircleAvatar(
                              radius: 40,
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              child: Icon(
                                LucideIcons.sparkles,
                                size: 40,
                                color: theme.colorScheme.primary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'RETIVY',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.lock,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Aplikasi Terkunci',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32.0),

                        // Fingerprint Glowing Button
                        GestureDetector(
                          onTap: _startBiometricAuth,
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isAuthenticating
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Icon(
                                        LucideIcons.fingerprint,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            _message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              height: 1.5,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12.0),
                        if (!_isAuthenticating)
                          TextButton(
                            onPressed: _startBiometricAuth,
                            child: Text(
                              'Coba Lagi',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        const Divider(height: 40.0),

                        // Fallback option
                        TextButton.icon(
                          onPressed: _handleFallbackLogout,
                          icon: const Icon(LucideIcons.logOut, size: 16),
                          label: const Text('Masuk dengan Akun Lain / Password'),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
