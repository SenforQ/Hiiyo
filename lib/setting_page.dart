import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'edit_profile_page.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'about_us_page.dart';
import 'privacy_policy_page.dart';
import 'terms_of_service_page.dart';
import 'vip_page.dart';
import 'wallet_page.dart';
import 'package:flutter/cupertino.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String avatar = 'assets/images/applogo_5_26.png';
  String nickname = '';
  String signature = '';
  bool _isVip = false;
  int _vipExpireTime = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadVipStatus();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAvatar = prefs.getString('user_avatar');
    final savedNickname = prefs.getString('user_nickname');
    final savedSignature = prefs.getString('user_signature');
    String defaultNickname = '';
    if (savedNickname == null || savedNickname.isEmpty) {
      // 生成随机ID
      final rand = Random();
      final id = 'ID13284' + List.generate(6, (_) => rand.nextInt(10)).join();
      defaultNickname = id;
      await prefs.setString('user_nickname', id);
    }
    setState(() {
      avatar = savedAvatar ?? 'assets/images/applogo_5_26.png';
      nickname = savedNickname == null || savedNickname.isEmpty
          ? defaultNickname
          : savedNickname;
      signature = (savedSignature == null || savedSignature.isEmpty)
          ? 'No personal signature yet.'
          : savedSignature;
    });
  }

  Future<void> _loadVipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isVip = prefs.getBool('is_vip') ?? false;
      _vipExpireTime = prefs.getInt('vip_expire_time') ?? 0;
    });
  }

  Future<void> _goToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          avatar: avatar,
          nickname: nickname,
          signature: signature,
        ),
      ),
    );
    if (result == true) {
      _loadUserInfo();
    }
  }

  ImageProvider _getAvatarProvider() {
    if (avatar.startsWith('avatar_images/')) {
      // 本地沙盒图片
      return FileImage(
        File(path.join((Directory.systemTemp.parent).path, avatar)),
      );
    } else if (avatar.startsWith('/')) {
      // 兼容老的绝对路径
      return FileImage(File(avatar));
    } else {
      // asset
      return AssetImage(avatar);
    }
  }

  Future<ImageProvider> _getAvatarProviderAsync() async {
    if (avatar.startsWith('avatar_images/')) {
      final dir = await getApplicationDocumentsDirectory();
      return FileImage(File(path.join(dir.path, avatar)));
    } else if (avatar.startsWith('/')) {
      return FileImage(File(avatar));
    } else {
      return AssetImage(avatar);
    }
  }

  void _goToVipPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VipPage(),
      ),
    );
  }

  void _goToWalletPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WalletPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 顶部渐变背景
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 125,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.5, 0),
                  end: Alignment(0.5, 1),
                  colors: [Color(0xFFB7EFFF), Color(0xFFFFFFFF)],
                ),
              ),
            ),
          ),
          // 内容
          Positioned.fill(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 12, bottom: 12),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // 用户信息卡片
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Stack(
                      children: [
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _goToEditProfile,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: FutureBuilder<ImageProvider>(
                                      future: _getAvatarProviderAsync(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircleAvatar(
                                            radius: 24,
                                            backgroundColor: Colors.grey,
                                          );
                                        }
                                        return CircleAvatar(
                                          radius: 24,
                                          backgroundImage: snapshot.data,
                                          backgroundColor: Colors.grey[200],
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                  maxWidth: 100),
                                              child: Text(
                                                nickname,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF222222),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          signature,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF888888),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Edit Profile',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF888888),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Color(0xFFBBBBBB),
                                        size: 28,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Stack右下角添加VIP状态标识
                        if (true)
                          Positioned(
                            right: 18,
                            bottom: 10,
                            child: Text(
                              (_isVip &&
                                      _vipExpireTime >
                                          DateTime.now().millisecondsSinceEpoch)
                                  ? 'VIP Activated (ON)'
                                  : 'VIP Activated (OFF)',
                              style: TextStyle(
                                color: (_isVip &&
                                        _vipExpireTime >
                                            DateTime.now()
                                                .millisecondsSinceEpoch)
                                    ? Color(0xFFFFC107)
                                    : Color(0xFF888888),
                                fontWeight: (_isVip &&
                                        _vipExpireTime >
                                            DateTime.now()
                                                .millisecondsSinceEpoch)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 7,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 新增VIP和Wallet入口
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: GestureDetector(
                              onTap: _goToVipPage,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFF6E0),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Icon(Icons.workspace_premium,
                                          color: Color(0xFFFFB300), size: 32),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'VIP',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF222222),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: GestureDetector(
                              onTap: _goToWalletPage,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFE6F7FF),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Icon(Icons.account_balance_wallet,
                                          color: Color(0xFF24B6FF), size: 32),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Wallet',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF222222),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 功能区域
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildFunctionItem(
                            'About Us',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutUsPage(),
                              ),
                            ),
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          _buildFunctionItem(
                            'Privacy Policy',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PrivacyPolicyPage(),
                              ),
                            ),
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          _buildFunctionItem(
                            'Terms of Service',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TermsOfServicePage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF222222),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFFBBBBBB), size: 28),
          ],
        ),
      ),
    );
  }
}
