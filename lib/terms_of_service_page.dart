import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Terms of Service',
          style: TextStyle(
            color: Color(0xFF222222),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF222222)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Terms of Service',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: March 2024',
              style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
            ),
            SizedBox(height: 24),
            Text(
              '1. Acceptance of Terms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'By accessing or using our service, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, you may not access the service.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '2. Use License',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Permission is granted to temporarily download one copy of the application per device for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '3. User Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account or password.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '4. Intellectual Property',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The Service and its original content, features, and functionality are and will remain the exclusive property of Hiiyo and its licensors. The Service is protected by copyright, trademark, and other laws.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '5. User Content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You retain all rights to any content you submit, post or display on or through the Service. By submitting content, you grant us a worldwide, non-exclusive, royalty-free license to use, reproduce, and distribute your content.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '6. Prohibited Uses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You may use our Service only for lawful purposes and in accordance with these Terms. You agree not to use the Service in any way that violates any applicable law or regulation.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '7. Termination',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We may terminate or suspend your account and bar access to the Service immediately, without prior notice or liability, under our sole discretion, for any reason whatsoever and without limitation.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '8. Limitation of Liability',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'In no event shall Hiiyo, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '9. Disclaimer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your use of the Service is at your sole risk. The Service is provided on an "AS IS" and "AS AVAILABLE" basis. The Service is provided without warranties of any kind.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '10. Governing Law',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'These Terms shall be governed and construed in accordance with the laws, without regard to its conflict of law provisions. Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '11. Changes to Terms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days\' notice prior to any new terms taking effect.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '12. Contact Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'If you have any questions about these Terms, please contact us at support@hiiyo.com.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
