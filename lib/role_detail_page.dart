import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'chat_page.dart';

class RoleDetailPage extends StatefulWidget {
  final DivinRole role;
  final Function? onFollowStateChanged;
  const RoleDetailPage({
    Key? key,
    required this.role,
    this.onFollowStateChanged,
  }) : super(key: key);

  @override
  State<RoleDetailPage> createState() => _RoleDetailPageState();
}

class _RoleDetailPageState extends State<RoleDetailPage> {
  bool _isFollowed = false;

  @override
  void initState() {
    super.initState();
    _loadFollowState();
  }

  Future<void> _loadFollowState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFollowed = prefs.getBool('follow_role_${widget.role.id}') ?? false;
    });
  }

  Future<void> _toggleFollow() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFollowed = !_isFollowed;
    });
    await prefs.setBool('follow_role_${widget.role.id}', _isFollowed);
    // 通知 home_page 关注状态已改变
    if (widget.onFollowStateChanged != null) {
      widget.onFollowStateChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
              width: size.width,
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Color(0xFF222222),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.asset(
                              widget.role.avatar,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.role.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF222222),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.role.introduction,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Gallery',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.role.avatarArrayImg.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final img = widget.role.avatarArrayImg[index];
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: GestureDetector(
                                          onTap:
                                              () => Navigator.of(context).pop(),
                                          child: InteractiveViewer(
                                            child: Image.asset(
                                              img,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  img,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _toggleFollow,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isFollowed
                                        ? const Color(0xFFEE2757)
                                        : const Color.fromARGB(
                                          255,
                                          19,
                                          127,
                                          222,
                                        ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minimumSize: const Size(double.infinity, 48),
                                elevation: 0,
                              ),
                              child: Text(
                                _isFollowed ? 'Unfollow' : 'Follow',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatPage(role: widget.role),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color:
                                    _isFollowed
                                        ? const Color(0xFFEE2757)
                                        : const Color.fromARGB(
                                          255,
                                          19,
                                          127,
                                          222,
                                        ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: const Size(48, 48),
                            ),
                            child: Icon(
                              Icons.message,
                              color:
                                  _isFollowed
                                      ? const Color(0xFFEE2757)
                                      : const Color.fromARGB(255, 19, 127, 222),
                            ),
                          ),
                        ],
                      ),
                    ],
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
