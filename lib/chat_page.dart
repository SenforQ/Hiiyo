import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'report_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'voice_call_page.dart';

class ChatPage extends StatefulWidget {
  final DivinRole role;
  const ChatPage({Key? key, required this.role}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isBlocked = false;
  bool _hasSentMessage = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadBlockState();
    _loadChatHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadBlockState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBlocked = prefs.getBool('block_role_${widget.role.id}') ?? false;
    });
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_history_${widget.role.id}';
    final historyJson = prefs.getString(key);
    if (historyJson != null) {
      final List<dynamic> list = jsonDecode(historyJson);
      setState(() {
        _messages.clear();
        _messages.addAll(list.map((e) => ChatMessage.fromJson(e)).toList());
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } else {
      setState(() {
        _messages.clear();
        _messages.add(
          ChatMessage(text: widget.role.avatarSayHi, isUser: false),
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_history_${widget.role.id}';
    final list = _messages.map((e) => e.toJson()).toList();
    await prefs.setString(key, jsonEncode(list));
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Block'),
          content: Text('Are you sure you want to block ${widget.role.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('block_role_${widget.role.id}', true);
                setState(() {
                  _isBlocked = true;
                });
                showCupertinoDialog(
                  context: context,
                  builder:
                      (context) => CupertinoAlertDialog(
                        content: const Text(
                          'User blocked, chat will be disabled',
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

  void _showNotInterestedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Not Interested'),
          content: Text(
            'Are you sure you are not interested in ${widget.role.name}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('block_role_${widget.role.id}', true);
                setState(() {
                  _isBlocked = true;
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isBlocked) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
      _hasSentMessage = true;
    });
    await _saveChatHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      final response = await http.post(
        Uri.parse('https://open.bigmodel.cn/api/paas/v4/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer 388048cf1fa643228919b30347fee1be.os4hzisCirReUzWf',
        },
        body: jsonEncode({
          'model': 'glm-4-flash',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are ${widget.role.name}, a friendly and helpful AI assistant. Please respond in English.',
            },
            {'role': 'user', 'content': userMessage},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];

        setState(() {
          _messages.add(ChatMessage(text: aiResponse, isUser: false));
        });
        await _saveChatHistory();
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else {
        throw Exception('Failed to get response');
      }
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                "Sorry, I'm having trouble connecting right now. Please try again later.",
            isUser: false,
          ),
        );
      });
      await _saveChatHistory();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF222222)),
          onPressed: () => Navigator.pop(context, _hasSentMessage),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                widget.role.avatar,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.role.name.split(' ').first,
              style: const TextStyle(
                color: Color(0xFF222222),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF222222)),
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder:
                    (context) => CupertinoActionSheet(
                      actions: [
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ReportPage(role: widget.role),
                              ),
                            );
                          },
                          child: const Text('Report'),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            if (_isBlocked) {
                              // Unblock
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool(
                                'block_role_${widget.role.id}',
                                false,
                              );
                              setState(() {
                                _isBlocked = false;
                              });
                              showCupertinoDialog(
                                context: context,
                                builder:
                                    (context) => CupertinoAlertDialog(
                                      content: const Text(
                                        'User unblocked, you can chat now',
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text('OK'),
                                          onPressed:
                                              () => Navigator.of(context).pop(),
                                        ),
                                      ],
                                    ),
                              );
                            } else {
                              // Block
                              _showBlockDialog();
                            }
                          },
                          child: Text(_isBlocked ? 'Unblock' : 'Block'),
                          isDestructiveAction: !_isBlocked,
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              controller: _scrollController,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment:
                      message.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildMessageBubble(message),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: SizedBox(
              height: 44,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _RequestCapsuleButton(
                      icon: Icons.call,
                      label: 'Audio Call',
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => CupertinoAlertDialog(
                                title: const Text('Audio Call Request'),
                                content: const Text(
                                  "This request requires the other party's consent before sending.",
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text('Cancel'),
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                  ),
                                  CupertinoDialogAction(
                                    child: const Text('OK'),
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                  ),
                                ],
                              ),
                        );
                        if (confirmed == true) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => VoiceCallPage(
                                    role: widget.role,
                                    onMessageSent: (userMsg, aiMsg) async {
                                      setState(() {
                                        _messages.add(
                                          ChatMessage(
                                            text: userMsg,
                                            isUser: true,
                                          ),
                                        );
                                        _messages.add(
                                          ChatMessage(
                                            text: aiMsg,
                                            isUser: false,
                                          ),
                                        );
                                      });
                                      await _saveChatHistory();
                                      WidgetsBinding.instance
                                          .addPostFrameCallback(
                                            (_) => _scrollToBottom(),
                                          );
                                    },
                                  ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    _RequestCapsuleButton(
                      icon: Icons.image,
                      label: 'Request Photo',
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => CupertinoAlertDialog(
                                title: const Text('Photo Request'),
                                content: const Text(
                                  "This request requires the other party's consent before sending.",
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text('Cancel'),
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                  ),
                                  CupertinoDialogAction(
                                    child: const Text('OK'),
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                  ),
                                ],
                              ),
                        );
                        if (confirmed == true) {
                          setState(() {
                            _messages.add(
                              ChatMessage(
                                text: 'Can you share a photo with me?',
                                isUser: true,
                              ),
                            );
                            final imgs = widget.role.avatarArrayImg;
                            if (imgs.isNotEmpty) {
                              final img = (imgs..shuffle()).first;
                              _messages.add(
                                ChatMessage(
                                  text: '',
                                  isUser: false,
                                  type: 'image',
                                  resource: img,
                                ),
                              );
                            }
                          });
                          await _saveChatHistory();
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _scrollToBottom(),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    _RequestCapsuleButton(
                      icon: Icons.videocam,
                      label: 'Request Video',
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => CupertinoAlertDialog(
                                title: const Text('Video Request'),
                                content: const Text(
                                  "This request requires the other party's consent before sending.",
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text('Cancel'),
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                  ),
                                  CupertinoDialogAction(
                                    child: const Text('OK'),
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                  ),
                                ],
                              ),
                        );
                        if (confirmed == true) {
                          setState(() {
                            _messages.add(
                              ChatMessage(
                                text: 'Can you share a video with me?',
                                isUser: true,
                              ),
                            );
                            final video = widget.role.avatarDiscoverShowVideo;
                            if (video.isNotEmpty) {
                              _messages.add(
                                ChatMessage(
                                  text: '',
                                  isUser: false,
                                  type: 'video',
                                  resource: video,
                                ),
                              );
                            }
                          });
                          await _saveChatHistory();
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _scrollToBottom(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_isBlocked,
                    decoration: InputDecoration(
                      hintText:
                          _isBlocked ? 'Chat disabled' : 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor:
                          _isBlocked
                              ? const Color(0xFFF5F5F5)
                              : const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isBlocked ? null : _sendMessage,
                  icon: Icon(
                    Icons.send,
                    color: _isBlocked ? Colors.grey : const Color(0xFF7F7FFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final bgColor = isUser ? const Color(0xFF7F7FFF) : const Color(0xFFF5F5F5);
    final textColor = isUser ? Colors.white : const Color(0xFF222222);
    switch (message.type) {
      case 'image':
        return GestureDetector(
          onTap: () => _showFullImage(message.resource),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                message.resource ?? '',
                width: 160,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      case 'video':
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(6),
          child: _VideoBubblePreview(
            videoPath: message.resource ?? '',
            onTap: () => _showFullVideo(message.resource),
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.text,
            style: TextStyle(color: textColor, fontSize: 16),
          ),
        );
    }
  }

  void _showFullImage(String? imgPath) {
    if (imgPath == null) return;
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.black.withOpacity(0.85),
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: Image.asset(imgPath, fit: BoxFit.contain),
                  ),
                ),
                Positioned(
                  top: 32,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showFullVideo(String? videoPath) {
    if (videoPath == null) return;
    showDialog(
      context: context,
      builder: (_) => _FullScreenVideoPlayer(videoPath: videoPath),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String type;
  final String? resource;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.type = 'text',
    this.resource,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'type': type,
    'resource': resource,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'] ?? '',
    isUser: json['isUser'] ?? false,
    timestamp:
        json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
    type: json['type'] ?? 'text',
    resource: json['resource'],
  );
}

class _VideoBubblePreview extends StatefulWidget {
  final String videoPath;
  final VoidCallback onTap;
  const _VideoBubblePreview({required this.videoPath, required this.onTap});

  @override
  State<_VideoBubblePreview> createState() => _VideoBubblePreviewState();
}

class _VideoBubblePreviewState extends State<_VideoBubblePreview> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.pause();
        _controller.seekTo(Duration.zero);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child:
                _initialized
                    ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                    : Container(width: 160, height: 120, color: Colors.black12),
          ),
          Container(
            width: 160,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.black.withOpacity(0.18),
            ),
          ),
          const Icon(
            Icons.play_circle_fill,
            color: Color(0xFF1976D2),
            size: 48,
          ),
        ],
      ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final String videoPath;
  const _FullScreenVideoPlayer({required this.videoPath});

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
          _duration = _controller.value.duration;
        });
        _controller.play();
        _controller.addListener(_onVideoUpdate);
      });
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    setState(() {
      _position = _controller.value.position;
      _duration = _controller.value.duration;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoUpdate);
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child:
                _initialized
                    ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                    : const CircularProgressIndicator(),
          ),
          Positioned(
            top: 32,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (_initialized)
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: Column(
                children: [
                  Slider(
                    value: _position.inSeconds.toDouble().clamp(
                      0,
                      _duration.inSeconds.toDouble(),
                    ),
                    min: 0,
                    max:
                        _duration.inSeconds.toDouble() > 0
                            ? _duration.inSeconds.toDouble()
                            : 1,
                    onChanged: (v) {
                      _controller.seekTo(Duration(seconds: v.toInt()));
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RequestCapsuleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _RequestCapsuleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 19, 127, 222),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
