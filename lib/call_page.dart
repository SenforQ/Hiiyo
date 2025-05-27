import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class CallPage extends StatefulWidget {
  final String backgroundImg;
  final String avatarImg;
  final String nickname;
  final String ringAsset;
  final String callType; // 'voice' or 'video'
  final int durationSeconds;
  final Function(String userMsg, String aiMsg)? onMessageSent;
  final List<String>? aiReplyList;

  const CallPage({
    Key? key,
    required this.backgroundImg,
    required this.avatarImg,
    required this.nickname,
    required this.ringAsset,
    this.callType = 'voice',
    this.durationSeconds = 30,
    this.onMessageSent,
    this.aiReplyList,
  }) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isCallActive = true;
  Timer? _callTimer;
  int _remainingSeconds = 30;
  bool _isRinging = false;

  late List<String> _replyMessages;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _replyMessages =
        widget.aiReplyList ??
        [
          "Sorry, I was busy and missed your call. How are you doing now?",
          "I was in the middle of something and couldn't answer. What's up?",
          "Sorry, I was in a meeting. Are you free to talk now?",
          "I missed your call earlier. I'm available now, would you like me to call you back?",
          "Sorry I couldn't answer earlier. Are you free to chat now?",
          "I was occupied when you called. Is everything okay?",
          "Sorry about missing your call. What can I help you with?",
          "I was unavailable when you called. Would you like to talk now?",
          "Sorry I couldn't pick up. Is there something you needed?",
          "I was busy earlier. Are you free to talk now?",
        ];
    _startCall();
  }

  void _startCall() async {
    await _playCallSound();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        _endCall();
      }
    });
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }

  Future<void> _playCallSound() async {
    setState(() {
      _isRinging = true;
    });
    try {
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource(widget.ringAsset));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isRinging = false);
      });
      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {});
    } catch (e) {
      if (mounted) setState(() => _isRinging = false);
    }
  }

  void _endCall() {
    _callTimer?.cancel();
    _audioPlayer.stop();
    setState(() {
      _isCallActive = false;
      _isRinging = false;
    });
    Vibration.vibrate(duration: 200);
    // 用户消息
    String userMsg =
        widget.callType == 'video'
            ? '[Request Video Call]'
            : '[Request Voice Call]';
    String aiMsg =
        _replyMessages[DateTime.now().millisecondsSinceEpoch %
            _replyMessages.length];
    widget.onMessageSent?.call(userMsg, aiMsg);
    Timer(const Duration(milliseconds: 500), () {
      Navigator.of(context).pop(true);
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _endCall();
        return false;
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图片
            Image.asset(
              widget.backgroundImg,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            // 渐变遮罩层
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // 通话界面内容
            SafeArea(
              child: Column(
                children: [
                  // 顶部状态栏
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(widget.avatarImg),
                          radius: 24,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.nickname,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _isRinging
                                  ? 'Ringing...'
                                  : _isCallActive
                                  ? widget.callType == 'video'
                                      ? 'Video call in progress'
                                      : 'Voice call in progress'
                                  : 'Call ended',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // 状态文字（无动画）
                  Text(
                    _isRinging
                        ? 'Waiting for answer...'
                        : _isCallActive
                        ? 'Call will end in $_remainingSeconds seconds'
                        : 'Call ended',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 静态挂断按钮
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB16CEA), Color(0xFFF9CFE6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
