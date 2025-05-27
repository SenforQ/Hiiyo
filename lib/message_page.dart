import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'chat_page.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  List<_ChatSession> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _loading = true;
    });
    // 1. 加载所有角色
    final String jsonStr = await rootBundle.loadString(
      'assets/images/ChatResource/divin_role.json',
    );
    final List<dynamic> jsonList = json.decode(jsonStr);
    final List<DivinRole> allRoles =
        jsonList.map((e) => DivinRole.fromJson(e)).toList();
    // 2. 遍历角色，查找有聊天历史的
    final prefs = await SharedPreferences.getInstance();
    List<_ChatSession> sessions = [];
    for (final role in allRoles) {
      final key = 'chat_history_${role.id}';
      final historyJson = prefs.getString(key);
      if (historyJson != null) {
        final List<dynamic> list = jsonDecode(historyJson);
        if (list.isNotEmpty) {
          final lastMsg = ChatMessage.fromJson(list.last);
          sessions.add(_ChatSession(role: role, lastMessage: lastMsg));
        }
      }
    }
    // 3. 按最后消息时间降序排序
    sessions.sort(
      (a, b) => b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp),
    );
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      // 今天
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else if (now.difference(time).inDays == 1) {
      return "Yesterday";
    } else {
      return "${time.month}/${time.day}";
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 12,
                      bottom: 12,
                    ),
                    child: const Text(
                      'Messages',
                      style: TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _sessions.isEmpty
                            ? FutureBuilder<List<DivinRole>>(
                              future: _loadAllRoles(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final allRoles = snapshot.data!;
                                if (allRoles.isEmpty) {
                                  return const Center(
                                    child: Text('No roles available.'),
                                  );
                                }
                                final random =
                                    allRoles[DateTime.now()
                                            .millisecondsSinceEpoch %
                                        allRoles.length];
                                final recommend =
                                    80 +
                                    (DateTime.now().millisecondsSinceEpoch %
                                        20);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 40,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 24,
                                        ),
                                        child: Text(
                                          "Hi, welcome to the Dive Community! New here? Don't worry—we've picked a friendly diver for you to connect with. Say hello and start your underwater adventure together!",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF666666),
                                            height: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Image.asset(
                                          random.avatar,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        random.name,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF222222),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        random.introduction,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF666666),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 18),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEDF6FF),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Text(
                                          'Recommended: $recommend%',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF1976D2),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF1976D2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                          ),
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        ChatPage(role: random),
                                              ),
                                            );
                                            if (result == true) {
                                              _loadSessions();
                                            }
                                          },
                                          child: const Text(
                                            'Try to chat',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                            : ListView.separated(
                              itemCount: _sessions.length,
                              separatorBuilder:
                                  (_, __) =>
                                      const Divider(height: 1, indent: 72),
                              itemBuilder: (context, index) {
                                final session = _sessions[index];
                                return ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      session.role.avatar,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    session.role.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF222222),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    session.lastMessage.type == 'image'
                                        ? '[ image ]'
                                        : session.lastMessage.type == 'video'
                                        ? '[ video ]'
                                        : session.lastMessage.text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF888888),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Text(
                                    _formatTime(session.lastMessage.timestamp),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFBBBBBB),
                                    ),
                                  ),
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                ChatPage(role: session.role),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadSessions();
                                    }
                                  },
                                );
                              },
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

  Future<List<DivinRole>> _loadAllRoles() async {
    final String jsonStr = await rootBundle.loadString(
      'assets/images/ChatResource/divin_role.json',
    );
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((e) => DivinRole.fromJson(e)).toList();
  }
}

class _ChatSession {
  final DivinRole role;
  final ChatMessage lastMessage;
  _ChatSession({required this.role, required this.lastMessage});
}
