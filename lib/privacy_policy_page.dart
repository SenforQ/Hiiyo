import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Privacy Policy',
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
              'Privacy Policy',
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
              '1. Information We Collect',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We collect information that you provide directly to us, including when you create an account, use our services, or communicate with us. This may include your name, email address, and any other information you choose to provide.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '2. How We Use Your Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We use the information we collect to provide, maintain, and improve our services, to develop new ones, and to protect our company and our users. We also use this information to offer you tailored content and to communicate with you about our services.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '3. Information Sharing and Disclosure',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We do not share your personal information with companies, organizations, or individuals outside of our company except in the following cases:\n\n• With your consent\n• For legal reasons\n• With our service providers',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '4. Data Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We implement appropriate technical and organizational measures to protect your personal information against unauthorized or unlawful processing, accidental loss, destruction, or damage.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '5. Your Rights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You have the right to access, correct, or delete your personal information. You can also object to our processing of your data, request data portability, and withdraw your consent at any time.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '6. Cookies and Tracking',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We use cookies and similar tracking technologies to track activity on our service and hold certain information. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '7. Children\'s Privacy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Our service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '8. International Data Transfers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your information may be transferred to and processed in countries other than your country of residence. These countries may have different data protection laws.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '9. Changes to This Policy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Text(
              '10. Contact Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'If you have any questions about this Privacy Policy, please contact us at support@hiiyo.com.',
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
