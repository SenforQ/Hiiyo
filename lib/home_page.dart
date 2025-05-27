import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'report_page.dart'; // 引入举报页面
import 'package:flutter/cupertino.dart';
import 'discover_page.dart';
import 'role_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'message_page.dart';
import 'setting_page.dart';

class DivinRole {
  final int id;
  final String name;
  final String avatarHomeShowImg;
  final String avatar;
  final String introduction;
  final List<String> avatarArrayImg;
  final String avatarSayHi;
  final String avatarDiscoverShowVideo;
  DivinRole({
    required this.id,
    required this.name,
    required this.avatarHomeShowImg,
    required this.avatar,
    required this.introduction,
    required this.avatarArrayImg,
    required this.avatarSayHi,
    required this.avatarDiscoverShowVideo,
  });
  factory DivinRole.fromJson(Map<String, dynamic> json) => DivinRole(
    id: json['divinroleId'],
    name: json['divinroleName'],
    avatarHomeShowImg: json['divinroleAvatarHomeShowImg'],
    avatar: json['divinroleAvatar'],
    introduction: _getIntroduction(json['divinroleName']),
    avatarArrayImg:
        (json['divinroleAvatarArrayImg'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
    avatarSayHi:
        json['divinroleAvatarSayHi'] ?? "Hi! How can I help you today?",
    avatarDiscoverShowVideo: json['divinroleAvatarDiscoverShowVideo'] ?? '',
  );
}

String _getIntroduction(String name) {
  // 这里可根据角色名自定义介绍，示例如下
  switch (name) {
    case 'Emma (INFP)':
      return '35yo, explored 50+ cave systems...';
    case 'Lucas (ENTJ)':
      return 'Ex-navy instructor. Expert in tactical diving.';
    case 'Mia (ESFP)':
      return 'Marine biologist, loves coral reefs.';
    case 'Sophia (INFJ)':
      return 'Underwater photographer, ocean dreamer.';
    case 'Olivia (ENFP)':
      return 'Travel vlogger, passionate about sea life.';
    case 'Ava (ISFJ)':
      return 'Safety diver, always ready to help.';
    case 'Lily (ISTP)':
      return 'Wreck diver, tech gear enthusiast.';
    case 'Grace (ENFJ)':
      return 'Dive group leader, community builder.';
    case 'Chloe (INTP)':
      return 'Oceanographer, loves marine science.';
    case 'Zoe (ESFJ)':
      return 'Event organizer, makes every dive fun.';
    case 'Ella (ISFP)':
      return 'Artist, inspired by underwater beauty.';
    case 'Harper (ESTJ)':
      return 'Trip planner, keeps dives on schedule.';
    case 'Scarlett (ENTP)':
      return 'Gadget tester, always trying new gear.';
    case 'Victoria (ISTJ)':
      return 'Safety first, detail-oriented diver.';
    case 'Madison (INFJ)':
      return 'Finds peace and meaning in the sea.';
    default:
      return 'Passionate diver and ocean lover.';
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<DivinRole> _roles = [];
  Map<int, bool> _followStates = {};

  final List<String> _tabIconsNormal = [
    'assets/images/home_2025_5_23_n.png',
    'assets/images/discover_2025_5_23_n.png',
    'assets/images/message_2025_5_23_n.png',
    'assets/images/me_2025_5_23_n.png',
  ];
  final List<String> _tabIconsSelected = [
    'assets/images/home_2025_5_23_s.png',
    'assets/images/discover_2025_5_23_s.png',
    'assets/images/message_2025_5_23_s.png',
    'assets/images/me_2025_5_23_s.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadRoles();
    _loadFollowStates();
  }

  Future<void> _loadRoles() async {
    final String jsonStr = await rootBundle.loadString(
      'assets/images/ChatResource/divin_role.json',
    );
    final List<dynamic> jsonList = json.decode(jsonStr);
    final List<DivinRole> allRoles =
        jsonList.map((e) => DivinRole.fromJson(e)).toList();
    allRoles.shuffle(Random());
    setState(() {
      _roles = allRoles.take(8).toList();
    });
  }

  Future<void> _loadFollowStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var role in _roles) {
        _followStates[role.id] =
            prefs.getBool('follow_role_${role.id}') ?? false;
      }
    });
  }

  Future<void> _refreshFollowStates() async {
    await _loadFollowStates();
  }

  void _showReportDialog(BuildContext context, DivinRole role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Report'),
          content: Text('Are you sure you want to report ${role.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportPage(role: role),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showBlockDialog(BuildContext context, DivinRole role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Block'),
          content: Text('Are you sure you want to block ${role.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _roles.removeWhere((r) => r.id == role.id);
                });
                showCupertinoDialog(
                  context: context,
                  builder:
                      (context) => CupertinoAlertDialog(
                        content: const Text(
                          'User blocked, content will no longer be displayed',
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('OK'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showNotInterestedDialog(BuildContext context, DivinRole role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Not Interested'),
          content: Text('Are you sure you are not interested in ${role.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _roles.removeWhere((r) => r.id == role.id);
                });
                showCupertinoDialog(
                  context: context,
                  builder:
                      (context) => CupertinoAlertDialog(
                        content: const Text(
                          'You will no longer see this user',
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('OK'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double cardWidth = (size.width - 40 - 15) / 2.0;
    final List<Widget> _pages = [
      // 首页内容
      _buildHomeContent(size, cardWidth),
      // Discover页面
      const DiscoverPage(),
      // 其余Tab页可继续添加
      const MessagePage(),
      const SettingPage(),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFD5F1FF),
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _pages),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(29),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (index) {
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: SizedBox(
                      width: 48,
                      height: 58,
                      child: Center(
                        child: Image.asset(
                          isSelected
                              ? _tabIconsSelected[index]
                              : _tabIconsNormal[index],
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(Size size, double cardWidth) {
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              width: size.width,
              child: Image.asset(
                'assets/images/home_top_bg_2025_5_23.png',
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 0,
                ),
                child:
                    _roles.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : MasonryGridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          padding: const EdgeInsets.only(top: 16, bottom: 90),
                          itemCount: _roles.length,
                          itemBuilder: (context, index) {
                            final double height = index == 0 ? 242 : 288;
                            final double imageHeight = index == 0 ? 154 : 200;
                            final role = _roles[index];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => RoleDetailPage(
                                          role: role,
                                          onFollowStateChanged:
                                              _refreshFollowStates,
                                        ),
                                  ),
                                );
                                // 返回时刷新关注状态
                                _refreshFollowStates();
                              },
                              child: Container(
                                width: cardWidth,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment(0.5, 0),
                                    end: Alignment(0.5, 1),
                                    colors: [
                                      Color(0xFF9AFFFF),
                                      Color(0xFF94B6FF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      color: Colors.white,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                height: imageHeight,
                                                child: Image.asset(
                                                  role.avatarHomeShowImg,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.more_vert,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    showCupertinoModalPopup(
                                                      context: context,
                                                      builder:
                                                          (
                                                            context,
                                                          ) => CupertinoActionSheet(
                                                            actions: [
                                                              CupertinoActionSheetAction(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (
                                                                            context,
                                                                          ) => ReportPage(
                                                                            role:
                                                                                role,
                                                                          ),
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    const Text(
                                                                      'Report',
                                                                    ),
                                                              ),
                                                              CupertinoActionSheetAction(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                  _showBlockDialog(
                                                                    context,
                                                                    role,
                                                                  );
                                                                },
                                                                child:
                                                                    const Text(
                                                                      'Block',
                                                                    ),
                                                                isDestructiveAction:
                                                                    true,
                                                              ),
                                                              CupertinoActionSheetAction(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                  _showNotInterestedDialog(
                                                                    context,
                                                                    role,
                                                                  );
                                                                },
                                                                child: const Text(
                                                                  'Not Interested',
                                                                ),
                                                              ),
                                                            ],
                                                            cancelButton: CupertinoActionSheetAction(
                                                              onPressed:
                                                                  () =>
                                                                      Navigator.of(
                                                                        context,
                                                                      ).pop(),
                                                              child: const Text(
                                                                'Cancel',
                                                              ),
                                                            ),
                                                          ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 13),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(width: 8),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.asset(
                                                  role.avatar,
                                                  width: 20,
                                                  height: 20,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  role.name.split(' ').first,
                                                  style: const TextStyle(
                                                    color: Color(0xFF333333),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'SF Pro',
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 6,
                                                ),
                                                child: Image.asset(
                                                  _followStates[role.id] == true
                                                      ? 'assets/images/home_cancel_2025_5_23.png'
                                                      : 'assets/images/home_add_2025_5_23.png',
                                                  width: 34,
                                                  height: 34,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              role.introduction,
                                              style: const TextStyle(
                                                color: Color(0xFF999999),
                                                fontSize: 14,
                                                height: 1.2,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
