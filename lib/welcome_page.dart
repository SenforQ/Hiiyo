import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'terms_of_service_page.dart';
import 'privacy_policy_page.dart';
import 'home_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _agreed = false;

  void _showAgreementDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Notice'),
            content: const Text(
              'You need to agree to the Terms of Service and Privacy Policy to enter the app.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  void _onEnterApp() {
    if (!_agreed) {
      _showAgreementDialog();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Widget _buildCheckButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _agreed = !_agreed;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _agreed ? const Color(0xFF24B6FF) : Colors.white,
          border: Border.all(
            color: _agreed ? const Color(0xFF24B6FF) : const Color(0xFFCCCCCC),
            width: 2,
          ),
        ),
        child:
            _agreed
                ? const Icon(
                  CupertinoIcons.check_mark,
                  color: Colors.white,
                  size: 12,
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: size.width,
            height: size.height,
            child: Image.asset(
              'assets/images/welcome_bg_2025_5_22.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: SizedBox(
                    width: 280,
                    height: 52,
                    child: CupertinoButton(
                      color: const Color(0xFF24B6FF),
                      borderRadius: BorderRadius.circular(26),
                      padding: EdgeInsets.zero,
                      onPressed: _onEnterApp,
                      child: const Text(
                        'Enter APP',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCheckButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF999999),
                            ),
                            children: [
                              const TextSpan(text: 'I have read and agree '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: const TextStyle(
                                  color: Color(0xFF51B1FF),
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder:
                                                (context) =>
                                                    const TermsOfServicePage(),
                                          ),
                                        );
                                      },
                              ),
                              const TextSpan(text: ' and\n'),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  color: Color(0xFF51B1FF),
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder:
                                                (context) =>
                                                    const PrivacyPolicyPage(),
                                          ),
                                        );
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
