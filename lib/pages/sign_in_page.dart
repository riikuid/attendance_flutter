import 'package:flutter/material.dart';
import 'package:presence_app/theme.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_page.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.isLoading;

    if (auth.user != null) {
      Future.microtask(() {
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          await context.read<AuthProvider>().signInWithGoogle();
                        },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: whiteColor,
                  foregroundColor: subtitle1TextColor,
                  minimumSize: const Size(280, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  side: const BorderSide(
                    color: Color(0xFFDADCE0),
                  ), // border abu tipis
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Image.asset('assets/images/logo_g.png'),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Login With Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: semibold,
                        color: isLoading ? blackColor : const Color(0xFF3C4043),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isLoading) ...[
            ModalBarrier(
              color: blackColor.withOpacity(0.3),
              dismissible: false,
            ),
            const Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(strokeWidth: 5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
