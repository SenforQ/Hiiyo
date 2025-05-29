import 'package:flutter/material.dart';
import 'dart:math';
import 'home_page.dart';
import 'report_page.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wallet_page.dart';

// 朋友圈动态数据结构
class FriendMoment {
  final int id;
  final int userId;
  final String userName;
  final String userAvatar;
  final DateTime time;
  final String? text;
  final List<String> images;
  final String? videoCover;
  final String? videoUrl;
  int likeCount;
  bool isLiked;
  bool isFollowed;
  List<Comment> comments;

  FriendMoment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.time,
    this.text,
    this.images = const [],
    this.videoCover,
    this.videoUrl,
    this.likeCount = 0,
    this.isLiked = false,
    this.isFollowed = false,
    List<Comment>? comments,
  }) : comments = comments ?? [];
}

class Comment {
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime time;
  int likeCount;
  bool isLiked;
  Comment({
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.time,
    this.likeCount = 0,
    this.isLiked = false,
  });
}

// 全局拉黑用户ID列表
class BlockedUsers {
  static final Set<int> blockedUserIds = {};
}

// 与弹幕区头像一一对应的昵称
const List<String> userNames = [
  'Alice',
  'Bob',
  'Cathy',
  'David',
  'Eva',
  'Frank',
  'Grace',
  'Helen',
  'Ivan',
  'Judy',
  'Kevin',
  'Lily',
  'Mike',
  'Nina',
  'Oscar',
];

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String? _fullScreenImage;
  _FullScreenVideoData? _fullScreenVideo;

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
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 12, bottom: 12),
                    child: Text(
                      'Discover',
                      style: TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // 渐变卡片区域
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cardWidth = constraints.maxWidth;
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/discover_card_2025_5_26.png',
                                    width: cardWidth,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                                Positioned(
                                  left: 5,
                                  right: 5,
                                  top: 5,
                                  bottom: 5,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const DanmakuList(),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        Positioned(
                          right: -4,
                          bottom: -20,
                          child: Image.asset(
                            'assets/images/qie_5_26.png',
                            width: 104,
                            height: 84,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Picture Notes 区域
                  Expanded(
                    child: PictureNotesSection(
                      onImageTap: (img) =>
                          setState(() => _fullScreenImage = img),
                      onVideoTap: (url, cover) => setState(
                        () => _fullScreenVideo = _FullScreenVideoData(url),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 全屏图片弹窗
          if (_fullScreenImage != null)
            GestureDetector(
              onTap: () => setState(() => _fullScreenImage = null),
              child: Container(
                color: Colors.black.withOpacity(0.95),
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: InteractiveViewer(
                        child: Image.asset(
                          _fullScreenImage!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 20,
                      child: GestureDetector(
                        onTap: () => setState(() => _fullScreenImage = null),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 全屏视频弹窗（结构和图片类似，实际可用 video_player 替换）
          if (_fullScreenVideo != null)
            FullScreenVideoPlayer(
              videoUrl: _fullScreenVideo!.videoUrl,
              onClose: () => setState(() => _fullScreenVideo = null),
            ),
        ],
      ),
    );
  }
}

class DanmakuList extends StatefulWidget {
  const DanmakuList({Key? key}) : super(key: key);

  @override
  State<DanmakuList> createState() => _DanmakuListState();
}

class _DanmakuListState extends State<DanmakuList> {
  final List<String> avatars = const [
    'assets/images/ChatResource/1/p/1_p_2025_05_23_1.png',
    'assets/images/ChatResource/2/p/2_p_2025_05_23_1.png',
    'assets/images/ChatResource/3/p/3_p_2025_05_23_1.png',
    'assets/images/ChatResource/4/p/4_p_2025_05_23_1.png',
    'assets/images/ChatResource/5/p/5_p_2025_05_23_1.png',
    'assets/images/ChatResource/6/p/6_p_2025_05_23_1.png',
    'assets/images/ChatResource/7/p/7_p_2025_05_23_1.png',
    'assets/images/ChatResource/8/p/8_p_2025_05_23_1.png',
    'assets/images/ChatResource/9/p/9_p_2025_05_23_1.png',
    'assets/images/ChatResource/10/p/10_p_2025_05_23_1.png',
    'assets/images/ChatResource/11/p/11_p_2025_05_23_1.png',
    'assets/images/ChatResource/12/p/12_p_2025_05_23_1.png',
    'assets/images/ChatResource/13/p/13_p_2025_05_23_1.png',
    'assets/images/ChatResource/14/p/14_p_2025_05_23_1.png',
    'assets/images/ChatResource/15/p/15_p_2025_05_23_1.png',
  ];

  final List<String> greetings = const [
    "Hello everyone! 👋",
    "Ready for a dive? 🤿",
    "The ocean is amazing! 🌊",
    "Let's explore together! 🐠",
    "What a beautiful day! ☀️",
    "Saw a sea turtle! 🐢",
    "Enjoying the blue! 💙",
    "Making new friends! 🤗",
    "Underwater adventure! 🏊‍♂️",
    "Love the sea life! 🐟",
    "Waves are perfect today! 🌊",
    "Let's go deeper! ⬇️",
    "Found a coral reef! 🪸",
    "So peaceful down here! 🧘‍♂️",
    "Look at all the fish! 🐠",
    "Sunshine and sea! ☀️🌊",
    "Learning new skills! 📚",
    "First time diving! 😃",
    "The water is so clear! 💎",
    "Let's take a photo! 📸",
    "Saw a dolphin! 🐬",
    "Feeling free! 🕊️",
    "Ocean breeze is the best! 🌬️",
    "Let's protect the ocean! 🌏",
    "So many colors underwater! 🌈",
    "Can't wait for the next dive! 🔄",
    "Adventure time! 🗺️",
    "Met awesome people! 🤝",
    "The sea is calling! 📞",
    "Let's swim together! 🏊‍♀️",
    "Found a starfish! ⭐️",
    "Diving is my passion! ❤️",
    "Feeling relaxed! 😌",
    "Saw a school of fish! 🐟",
    "Ocean vibes only! 🌊",
    "Let's go snorkeling! 🤿",
    "The view is breathtaking! 😍",
    "So much to discover! 🔍",
    "Let's make memories! 📝",
    "Underwater selfie! 🤳",
    "Saw a crab! 🦀",
    "The sea is endless! 🌊",
    "Let's have fun! 🎉",
    "Feeling adventurous! 🧭",
    "The water is perfect! 💦",
    "Saw a jellyfish! 🪼",
    "Let's dive again! 🔁",
    "Ocean friends forever! 🐬",
    "Learning from the best! 👨‍🏫",
    "Safety first! 🛟",
    "Let's go for a swim! 🏊",
    "Saw a manta ray! 🥽",
    "The sea is magical! ✨",
    "Let's enjoy the moment! ⏳",
    "Feeling grateful! 🙏",
    "Saw a seahorse! 🦄",
    "Let's keep exploring! 🧭",
    "The ocean is home! 🏠",
    "Let's dive deeper! ⬇️",
    "Saw a pufferfish! 🐡",
    "The water is warm! 🔥",
    "Let's go on an adventure! 🚤",
    "Saw a shark! 🦈",
    "The sea is full of life! 🐠",
    "Let's make a splash! 💦",
    "Saw a stingray! 🐟",
    "The ocean is peaceful! 🧘‍♀️",
    "Let's enjoy the waves! 🌊",
    "Saw a lobster! 🦞",
    "The sea is beautiful! 😍",
    "Let's go treasure hunting! 🪙",
    "Saw a clownfish! 🐠",
    "The ocean is mysterious! 🕵️‍♂️",
    "Let's go for a night dive! 🌙",
    "Saw a moray eel! 🐍",
    "The sea is sparkling! ✨",
    "Let's go for a boat ride! 🚤",
    "Saw a sea urchin! 🦔",
    "The ocean is alive! 🌊",
    "Let's go for a drift dive! 🏄‍♂️",
    "Saw a barracuda! 🐟",
    "The sea is calm! 😌",
    "Let's go for a wreck dive! 🚢",
    "Saw a parrotfish! 🐠",
    "The ocean is full of surprises! 🎁",
    "Let's go for a cave dive! 🕳️",
    "Saw a lionfish! 🦁",
    "The sea is refreshing! 🧊",
    "Let's go for a shore dive! 🏖️",
    "Saw a octopus! 🐙",
    "The ocean is inspiring! 🌟",
    "Let's go for a deep dive! ⬇️",
    "Saw a sea cucumber! 🥒",
    "The sea is inviting! 🤗",
    "Let's go for a sunrise dive! 🌅",
    "Saw a pipefish! 🐟",
    "The ocean is fascinating! 🤩",
    "Let's go for a sunset dive! 🌇",
    "Saw a cuttlefish! 🦑",
    "The sea is energizing! ⚡️",
    "Let's go for a fun dive! 🎉",
    "Saw a blue tang! 🐟",
    "The ocean is relaxing! 🧘‍♂️",
    "Let's go for a buddy dive! 👯‍♂️",
    "Saw a triggerfish! 🐟",
    "The sea is full of wonders! 🌊",
    "Let's go for a group dive! 👨‍👩‍👧‍👦",
    "Saw a butterflyfish! 🦋",
    "The ocean is so clear! 💎",
    "Let's go for a photo dive! 📸",
    "Saw a surgeonfish! 🐟",
    "The sea is so blue! 💙",
    "Let's go for a video dive! 🎥",
    "Saw a wrasse! 🐟",
    "The ocean is so big! 🌏",
    "Let's go for a macro dive! 🔬",
    "Saw a goby! 🐟",
    "The sea is so deep! ⬇️",
    "Let's go for a night snorkel! 🌙",
    "Saw a blenny! 🐟",
    "The ocean is so cool! 😎",
    "Let's go for a shallow dive! 🏖️",
    "Saw a damselfish! 🐟",
    "The sea is so lively! 🎉",
    "Let's go for a current dive! 🌊",
    "Saw a cardinalfish! 🐟",
    "The ocean is so mysterious! 🕵️‍♂️",
    "Let's go for a reef dive! 🪸",
    "Saw a anthias! 🐟",
    "The sea is so colorful! 🌈",
    "Let's go for a lagoon dive! 🏝️",
    "Saw a snapper! 🐟",
    "The ocean is so inviting! 🤗",
    "Let's go for a wall dive! 🧱",
    "Saw a grouper! 🐟",
    "The sea is so magical! ✨",
    "Let's go for a drift snorkel! 🏄‍♂️",
    "Saw a sweetlips! 😗",
    "The ocean is so peaceful! 🧘‍♀️",
    "Let's go for a blue water dive! 🌊",
    "Saw a batfish! 🦇",
    "The sea is so amazing! 🤩",
    "Let's go for a muck dive! 🪱",
    "Saw a frogfish! 🐸",
    "The ocean is so full of life! 🐠",
    "Let's go for a rescue dive! 🛟",
    "Saw a scorpionfish! 🦂",
    "The sea is so full of friends! 🤗",
    "Let's go for a navigation dive! 🧭",
    "Saw a filefish! 🗂️",
    "The ocean is so full of stories! 📖",
    "Let's go for a skills dive! 🏅",
    "Saw a boxfish! 📦",
    "The sea is so full of dreams! 💭",
    "Let's go for a practice dive! 🏊‍♂️",
    "Saw a cowfish! 🐄",
    "The ocean is so full of hope! 🌟",
    "Let's go for a fun swim! 🏊‍♀️",
    "Saw a trumpetfish! 🎺",
    "The sea is so full of joy! 😃",
    "Let's go for a chill dive! 😎",
    "Saw a unicornfish! 🦄",
    "The ocean is so full of beauty! 😍",
    "Let's go for a learning dive! 📚",
    "Saw a squirrelfish! 🐿️",
    "The sea is so full of adventure! 🗺️",
    "Let's go for a relaxing dive! 🧘‍♂️",
    "Saw a sandperch! 🏖️",
    "The ocean is so full of fun! 🎉",
    "Let's go for a discovery dive! 🔍",
    "Saw a hawkfish! 🦅",
    "The sea is so full of excitement! 🤩",
    "Let's go for a buddy swim! 👯‍♂️",
    "Saw a dragonet! 🐉",
    "The ocean is so full of color! 🌈",
    "Let's go for a group swim! 👨‍👩‍👧‍👦",
    "Saw a sand diver! 🏖️",
    "The sea is so full of light! 💡",
    "Let's go for a sunrise swim! 🌅",
    "Saw a goby fish! 🐟",
    "The ocean is so full of energy! ⚡️",
    "Let's go for a sunset swim! 🌇",
    "Saw a clingfish! 🐟",
    "The sea is so full of laughter! 😂",
    "Let's go for a happy dive! 😃",
    "Saw a combtooth blenny! 🦷",
    "The ocean is so full of music! 🎶",
    "Let's go for a peaceful dive! 🧘‍♀️",
    "Saw a jawfish! 👄",
    "The sea is so full of movement! 🏊‍♂️",
    "Let's go for a playful dive! 🤹‍♂️",
    "Saw a sand eel! 🐍",
    "The ocean is so full of surprises! 🎁",
    "Let's go for a cool dive! 😎",
    "Saw a snake eel! 🐍",
    "The sea is so full of magic! ✨",
    "Let's go for a bright dive! 💡",
    "Saw a ribbon eel! 🎀",
    "The ocean is so full of sparkle! ✨",
    "Let's go for a shining dive! 🌟",
    "Saw a garden eel! 🌱",
    "The sea is so full of wonder! 🤩",
    "Let's go for a glowing dive! 💡",
    "Saw a spotted eel! ⚫️",
    "The ocean is so full of light! 💡",
    "Let's go for a starry dive! ⭐️",
    "Saw a zebra eel! 🦓",
    "The sea is so full of stars! ⭐️",
    "Let's go for a dreamy dive! 💭",
    "Saw a leopard eel! 🐆",
    "The ocean is so full of dreams! 💭",
    "Let's go for a fantasy dive! 🦄",
    "Saw a tiger eel! 🐯",
    "The sea is so full of fantasy! 🦄",
    "Let's go for a wild dive! 🐾",
    "Saw a wolf eel! 🐺",
    "The ocean is so full of wildness! 🐾",
    "Let's go for a free dive! 🕊️",
    "Saw a ghost pipefish! 👻",
    "The sea is so full of mystery! 🕵️‍♂️",
    "Let's go for a mysterious dive! 🕵️‍♂️",
    "Saw a harlequin tuskfish! 🤡",
    "The ocean is so full of fun! 🎉",
    "Let's go for a party dive! 🎉",
    "Saw a clown triggerfish! 🤡",
    "The sea is so full of clowns! 🤡",
    "Let's go for a silly dive! 😜",
    "Saw a mimic octopus! 🐙",
    "The ocean is so full of mimics! 🐙",
    "Let's go for a creative dive! 🎨",
    "Saw a coconut octopus! 🥥",
    "The sea is so full of coconuts! 🥥",
    "Let's go for a tasty dive! 😋",
    "Saw a blue-ringed octopus! 🔵",
    "The ocean is so full of rings! 💍",
    "Let's go for a lucky dive! 🍀",
    "Saw a blanket octopus! 🦑",
    "The sea is so full of blankets! 🛏️",
    "Let's go for a cozy dive! 🛏️",
    "Saw a wonderpus! 🤩",
    "The ocean is so full of wonders! 🤩",
    "Let's go for a magical dive! ✨",
    "Saw a flamboyant cuttlefish! 💃",
    "The sea is so full of flamboyance! 💃",
    "Let's go for a stylish dive! 👗",
    "Saw a bobtail squid! 🦑",
    "The ocean is so full of bobtails! 🦑",
    "Let's go for a cute dive! 🥰",
    "Saw a glass squid! 🦑",
    "The sea is so full of glass! 🥃",
    "Let's go for a clear dive! 💎",
    "Saw a vampire squid! 🧛‍♂️",
    "The ocean is so full of vampires! 🧛‍♂️",
    "Let's go for a spooky dive! 👻",
    "Saw a firefly squid! 🦑",
    "The sea is so full of fireflies! 🦟",
    "Let's go for a glowing dive! 💡",
    "Saw a Humboldt squid! 🦑",
    "The ocean is so full of giants! 🦑",
    "Let's go for a giant dive! 🦑",
    "Saw a giant squid! 🦑",
    "The sea is so full of legends! 🧜‍♂️",
    "Let's go for a legendary dive! 🧜‍♂️",
    "Saw a colossal squid! 🦑",
    "The ocean is so full of colossals! 🦑",
    "Let's go for an epic dive! 🦑",
    "Saw a nautilus! 🐚",
    "The sea is so full of shells! 🐚",
    "Let's go for a shell dive! 🐚",
    "Saw a paper nautilus! 🐚",
    "The ocean is so full of paper! 📄",
    "Let's go for a light dive! 💡",
    "Saw a argonaut! 🐚",
    "The sea is so full of argonauts! 🐚",
    "Let's go for a heroic dive! 🦸‍♂️",
    "Saw a cuttlefish! 🦑",
    "The ocean is so full of cuttlefish! 🦑",
    "Let's go for a smart dive! 🧠",
    "Saw a squid! 🦑",
    "The sea is so full of squids! 🦑",
    "Let's go for a speedy dive! 🏃‍♂️",
    "Saw a octopus! 🐙",
    "The ocean is so full of octopuses! 🐙",
    "Let's go for a flexible dive! 🤸‍♂️",
    "Saw a jellyfish! 🪼",
    "The sea is so full of jelly! 🍮",
    "Let's go for a bouncy dive! 🏀",
  ];

  // 两行弹幕的数据和控制器
  late List<DanmakuBubble> _danmakuList1;
  late List<DanmakuBubble> _danmakuList2;
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  bool _isLoadingMore1 = false;
  bool _isLoadingMore2 = false;

  @override
  void initState() {
    super.initState();
    _danmakuList1 = _generateDanmaku(20);
    _danmakuList2 = _generateDanmaku(20);
    _scrollController1.addListener(() => _scrollListener(1));
    _scrollController2.addListener(() => _scrollListener(2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling(_scrollController1);
      _startScrolling(_scrollController2, delay: 2000); // 第二行延迟启动，避免完全同步
    });
  }

  List<DanmakuBubble> _generateDanmaku(int count) {
    final random = Random();
    return List.generate(count, (index) {
      final avatar = avatars[random.nextInt(avatars.length)];
      final greeting = greetings[random.nextInt(greetings.length)];
      final isBlue = random.nextBool();
      return DanmakuBubble(avatar: avatar, message: greeting, isBlue: isBlue);
    });
  }

  void _scrollListener(int row) {
    final controller = row == 1 ? _scrollController1 : _scrollController2;
    final list = row == 1 ? _danmakuList1 : _danmakuList2;
    final isLoading = row == 1 ? _isLoadingMore1 : _isLoadingMore2;
    final percent = controller.position.pixels /
        (controller.position.maxScrollExtent == 0
            ? 1
            : controller.position.maxScrollExtent);
    if (percent >= 0.5 && percent <= 0.7 && !isLoading) {
      if (row == 1) _isLoadingMore1 = true;
      if (row == 2) _isLoadingMore2 = true;
      setState(() {
        if (row == 1) {
          _danmakuList1.addAll(_generateDanmaku(20));
        } else {
          _danmakuList2.addAll(_generateDanmaku(20));
        }
      });
      if (row == 1) _isLoadingMore1 = false;
      if (row == 2) _isLoadingMore2 = false;
    }
  }

  void _startScrolling(ScrollController controller, {int delay = 0}) {
    Future.delayed(Duration(milliseconds: 50 + delay), () {
      if (controller.hasClients) {
        final double maxScrollExtent = controller.position.maxScrollExtent;
        controller
            .animateTo(
          maxScrollExtent,
          duration: Duration(seconds: (maxScrollExtent ~/ 45)),
          curve: Curves.linear,
        )
            .then((_) {
          if (mounted) {
            controller.jumpTo(0);
            _startScrolling(controller);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController1.removeListener(() => _scrollListener(1));
    _scrollController2.removeListener(() => _scrollListener(2));
    _scrollController1.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              controller: _scrollController1,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _danmakuList1.map((bubble) => bubble).toList(),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              controller: _scrollController2,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _danmakuList2.map((bubble) => bubble).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DanmakuBubble extends StatelessWidget {
  final String avatar;
  final String message;
  final bool isBlue;

  const DanmakuBubble({
    Key? key,
    required this.avatar,
    required this.message,
    required this.isBlue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.only(left: 2, top: 4, bottom: 4, right: 4),
        decoration: BoxDecoration(
          color: isBlue
              ? const Color(0xFFB6E0FF).withOpacity(0.85)
              : const Color(0xFFD1C6FF).withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: ClipOval(
                child: Image.asset(
                  avatar,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF222222),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 朋友圈区域组件
class PictureNotesSection extends StatefulWidget {
  final void Function(String imagePath)? onImageTap;
  final void Function(String videoUrl, String cover)? onVideoTap;
  const PictureNotesSection({Key? key, this.onImageTap, this.onVideoTap})
      : super(key: key);

  @override
  State<PictureNotesSection> createState() => _PictureNotesSectionState();
}

class _PictureNotesSectionState extends State<PictureNotesSection> {
  List<FriendMoment> _moments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMomentsFromRoles();
  }

  Future<void> _loadMomentsFromRoles() async {
    setState(() {
      _loading = true;
    });
    final String jsonStr = await rootBundle.loadString(
      'assets/images/ChatResource/divin_role.json',
    );
    final List<dynamic> jsonList = json.decode(jsonStr);
    final List<DivinRole> allRoles =
        jsonList.map((e) => DivinRole.fromJson(e)).toList();
    allRoles.shuffle(Random());
    final List<DivinRole> selectedRoles = allRoles.take(8).toList();
    final List<FriendMoment> moments = [];
    int id = 1;
    final now = DateTime.now();
    for (final role in selectedRoles) {
      final int count = 2 + Random().nextInt(3); // 2~4条
      for (int i = 0; i < count; i++) {
        final type = Random().nextInt(4);
        DateTime time = now.subtract(Duration(hours: id * 2 + i));
        // 随机生成1~3条评论
        int commentCount = Random().nextInt(3) + 1;
        List<String> avatarsList = _DanmakuListState().avatars;
        List<String> greetingsList = _DanmakuListState().greetings;
        List<Comment> comments = List.generate(commentCount, (ci) {
          final userIdx = Random().nextInt(avatarsList.length);
          final userName = userNames[userIdx % userNames.length];
          final userAvatar = avatarsList[userIdx];
          final content = greetingsList[Random().nextInt(greetingsList.length)];
          final commentTime = time.subtract(Duration(minutes: (ci + 1) * 5));
          return Comment(
            userName: userName,
            userAvatar: userAvatar,
            content: content,
            time: commentTime,
          );
        });
        if (type == 0 && role.avatarArrayImg.isNotEmpty) {
          // 纯图片
          moments.add(
            FriendMoment(
              id: id++,
              userId: role.id,
              userName: role.name,
              userAvatar: role.avatar,
              time: time,
              images: [
                role.avatarArrayImg[Random().nextInt(
                  role.avatarArrayImg.length,
                )],
              ],
              likeCount: Random().nextInt(100),
              comments: comments,
            ),
          );
        } else if (type == 1 && role.avatarDiscoverShowVideo.isNotEmpty) {
          // 纯视频
          moments.add(
            FriendMoment(
              id: id++,
              userId: role.id,
              userName: role.name,
              userAvatar: role.avatar,
              time: time,
              videoCover:
                  role.avatarArrayImg.isNotEmpty ? role.avatarArrayImg[0] : '',
              videoUrl: role.avatarDiscoverShowVideo,
              likeCount: Random().nextInt(100),
              comments: comments,
            ),
          );
        } else if (type == 2) {
          // 纯文字
          moments.add(
            FriendMoment(
              id: id++,
              userId: role.id,
              userName: role.name,
              userAvatar: role.avatar,
              time: time,
              text: role.introduction,
              likeCount: Random().nextInt(100),
              comments: comments,
            ),
          );
        } else if (role.avatarArrayImg.isNotEmpty) {
          // 图文
          moments.add(
            FriendMoment(
              id: id++,
              userId: role.id,
              userName: role.name,
              userAvatar: role.avatar,
              time: time,
              text: role.avatarSayHi,
              images: [
                role.avatarArrayImg[Random().nextInt(
                  role.avatarArrayImg.length,
                )],
              ],
              likeCount: Random().nextInt(100),
              comments: comments,
            ),
          );
        }
      }
    }
    moments.sort((a, b) => b.time.compareTo(a.time));
    // 先打乱顺序，避免同角色连在一起
    moments.shuffle(Random());
    // 再调整，确保没有相邻的同角色
    for (int i = 1; i < moments.length; i++) {
      if (moments[i].userId == moments[i - 1].userId) {
        // 向后找第一个不同角色的动态并交换
        int swapIdx = i + 1;
        while (swapIdx < moments.length &&
            moments[swapIdx].userId == moments[i].userId) {
          swapIdx++;
        }
        if (swapIdx < moments.length) {
          final tmp = moments[i];
          moments[i] = moments[swapIdx];
          moments[swapIdx] = tmp;
        }
      }
    }
    setState(() {
      _moments = moments;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    // 过滤拉黑用户
    final visibleMoments = _moments
        .where((m) => !BlockedUsers.blockedUserIds.contains(m.userId))
        .toList();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 0, bottom: 0),
          child: Text(
            'Picture Notes',
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 22,
              color: Color(0xFF222222),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...visibleMoments.map(
          (moment) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(moment.userAvatar),
                            radius: 24,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                moment.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatTime(moment.time),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (moment.text != null && moment.text!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          moment.text!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF222222),
                          ),
                        ),
                      ],
                      if (moment.images.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (widget.onImageTap != null) {
                                  widget.onImageTap!(moment.images.first);
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  moment.images.first,
                                  width: 320,
                                  height: 240,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (moment.videoCover != null &&
                          moment.videoUrl != null) ...[
                        const SizedBox(height: 12),
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (widget.onVideoTap != null) {
                                  widget.onVideoTap!(
                                    moment.videoUrl!,
                                    moment.videoCover!,
                                  );
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      moment.videoCover!,
                                      width: 320,
                                      height: 240,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      // 操作区：点赞和举报
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // 评论按钮
                          GestureDetector(
                            onTap: () async {
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (context) => CommentSheet(
                                  moment: moment,
                                  onAddComment: (comment) {
                                    setState(() {
                                      moment.comments.insert(0, comment);
                                    });
                                  },
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.mode_comment_outlined,
                                  color: Color(0xFF888888),
                                  size: 22,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  moment.comments.length.toString(),
                                  style: const TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // 点赞按钮
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (moment.isLiked) {
                                  moment.isLiked = false;
                                  moment.likeCount =
                                      (moment.likeCount - 1).clamp(0, 99999);
                                } else {
                                  moment.isLiked = true;
                                  moment.likeCount++;
                                }
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: moment.isLiked
                                      ? Color(0xFFFF4B7B)
                                      : Color(0xFFCCCCCC),
                                  size: 24,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  moment.likeCount.toString(),
                                  style: TextStyle(
                                    color: moment.isLiked
                                        ? Color(0xFFFF4B7B)
                                        : Color(0xFF888888),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // 更多按钮
                          GestureDetector(
                            onTap: () async {
                              await _showReportBlockSheet(context, moment);
                            },
                            child: Icon(
                              Icons.more_horiz,
                              color: Color(0xFFCCCCCC),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 关注按钮
                Positioned(
                  top: 20,
                  right: 20,
                  child: _FollowButton(
                    isFollowed: moment.isFollowed,
                    onTap: () {
                      setState(() {
                        moment.isFollowed = !moment.isFollowed;
                      });
                      // TODO: 同步到全局/首页
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} minutes ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hours ago";
    } else {
      return "${diff.inDays} days ago";
    }
  }

  // 举报/拉黑ActionSheet逻辑
  Future<void> _showReportBlockSheet(
    BuildContext context,
    FriendMoment moment,
  ) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportPage(
                        role: DivinRole(
                          id: moment.userId,
                          name: moment.userName,
                          avatarHomeShowImg: moment.userAvatar,
                          avatar: moment.userAvatar,
                          introduction: moment.text ?? '',
                          avatarArrayImg: moment.images,
                          avatarSayHi: '',
                          avatarDiscoverShowVideo: moment.videoUrl ?? '',
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  alignment: Alignment.center,
                  child: const Text(
                    'Report',
                    style: TextStyle(
                      color: Color(0xFFFF3337),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    BlockedUsers.blockedUserIds.add(moment.userId);
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  alignment: Alignment.center,
                  child: const Text(
                    'Block',
                    style: TextStyle(
                      color: Color(0xFFFF3337),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _moments.removeWhere((m) => m.id == moment.id);
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  alignment: Alignment.center,
                  child: const Text(
                    'Not Interested',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  alignment: Alignment.center,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF6066F3),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 关注按钮组件
class _FollowButton extends StatelessWidget {
  final bool isFollowed;
  final VoidCallback onTap;
  const _FollowButton({required this.isFollowed, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 87,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isFollowed
                ? [Color(0xFFFF7E80), Color(0xFFFF3337)]
                : [Color(0xFF6066F3), Color(0xFF9A49E2)],
            begin: Alignment(-1, 0.5),
            end: Alignment(1, 0.5),
          ),
        ),
        child: Text(
          isFollowed ? 'Unfollow' : 'Follow',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// 全屏视频播放页
class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onClose;
  const FullScreenVideoPlayer({
    required this.videoUrl,
    required this.onClose,
    Key? key,
  }) : super(key: key);

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl.startsWith('http')) {
      _controller = VideoPlayerController.network(widget.videoUrl);
    } else {
      _controller = VideoPlayerController.asset(widget.videoUrl);
    }
    _controller.initialize().then((_) {
      setState(() {
        _isInitialized = true;
      });
    });
    _controller.addListener(() {
      if (_controller.value.isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black.withOpacity(0.95),
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            if (_isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_controller),
                      if (!_isPlaying)
                        GestureDetector(
                          onTap: _play,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            if (!_isInitialized)
              const Center(child: CircularProgressIndicator()),
            Positioned(
              top: 40,
              left: 20,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ),
            if (_isInitialized)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Colors.blueAccent,
                    backgroundColor: Colors.white24,
                    bufferedColor: Colors.white38,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenVideoData {
  final String videoUrl;
  _FullScreenVideoData(this.videoUrl);
}

class CommentSheet extends StatefulWidget {
  final FriendMoment moment;
  final void Function(Comment) onAddComment;
  const CommentSheet({
    required this.moment,
    required this.onAddComment,
    Key? key,
  }) : super(key: key);

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final comments = widget.moment.comments;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Container(
              height: 6,
              width: 48,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Text(
              'Comments (${comments?.length ?? 0})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 1),
            Expanded(
              child: comments?.isEmpty == true
                  ? const Center(
                      child: Text(
                        'No comments yet.',
                        style: TextStyle(color: Color(0xFF888888)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: comments!.length,
                      itemBuilder: (context, idx) {
                        final c = comments![idx];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(c.userAvatar),
                            radius: 18,
                          ),
                          title: Text(
                            c.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 点赞按钮
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (c.isLiked) {
                                      c.isLiked = false;
                                      c.likeCount = (c.likeCount - 1).clamp(
                                        0,
                                        99999,
                                      );
                                    } else {
                                      c.isLiked = true;
                                      c.likeCount++;
                                    }
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      color: c.isLiked
                                          ? Color(0xFFFF4B7B)
                                          : Color(0xFFCCCCCC),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      c.likeCount.toString(),
                                      style: TextStyle(
                                        color: c.isLiked
                                            ? Color(0xFFFF4B7B)
                                            : Color(0xFF888888),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // 更多按钮
                              GestureDetector(
                                onTap: () async {
                                  await _showCommentActionSheet(
                                    context,
                                    c,
                                    idx,
                                  );
                                },
                                child: const Icon(
                                  Icons.more_horiz,
                                  color: Color(0xFFCCCCCC),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 2,
                          ),
                          // 时间显示在副标题下方
                          isThreeLine: true,
                          dense: true,
                          // 在副标题下方加时间
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.content,
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatCommentTime(c.time),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFAAAAAA),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sending
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon:
                              const Icon(Icons.send, color: Color(0xFF6066F3)),
                          onPressed: () async {
                            final text = _controller.text.trim();
                            if (text.isEmpty) return;

                            // 1. 检查金币余额
                            final prefs = await SharedPreferences.getInstance();
                            int coins = prefs.getInt('gold_coins_balance') ?? 0;
                            if (coins < 8) {
                              // 2. 弹窗提示
                              final goRecharge = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Insufficient Coins'),
                                  content: const Text(
                                      'You need at least 8 coins to comment. Would you like to recharge now?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Recharge'),
                                    ),
                                  ],
                                ),
                              );
                              if (goRecharge == true) {
                                Navigator.of(context).pop(); // 关闭评论弹窗
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => const WalletPage()));
                              }
                              return;
                            }

                            // 3. 扣除金币并允许评论
                            await prefs.setInt('gold_coins_balance', coins - 8);

                            setState(() => _sending = true);
                            await Future.delayed(
                                const Duration(milliseconds: 300));
                            widget.onAddComment(
                              Comment(
                                userName: 'You',
                                userAvatar:
                                    'assets/images/ChatResource/1/p/1_p_2025_05_23_1.png',
                                content: text,
                                time: DateTime.now(),
                              ),
                            );
                            _controller.clear();
                            setState(() => _sending = false);
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCommentTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h ago";
    } else {
      return "${diff.inDays}d ago";
    }
  }

  // 评论ActionSheet
  Future<void> _showCommentActionSheet(
    BuildContext context,
    Comment comment,
    int commentIdx,
  ) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  // 可跳转举报页或弹窗
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Report'),
                      content: const Text('Report this comment?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  alignment: Alignment.center,
                  child: const Text(
                    'Report',
                    style: TextStyle(
                      color: Color(0xFFFF3337),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  // Block: 可扩展为拉黑该用户
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Block'),
                      content: Text('Block user ${comment.userName}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  alignment: Alignment.center,
                  child: const Text(
                    'Block',
                    style: TextStyle(
                      color: Color(0xFFFF3337),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  // 点赞/取消点赞
                  setState(() {
                    if (comment.isLiked) {
                      comment.isLiked = false;
                      comment.likeCount = (comment.likeCount - 1).clamp(
                        0,
                        99999,
                      );
                    } else {
                      comment.isLiked = true;
                      comment.likeCount++;
                    }
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  alignment: Alignment.center,
                  child: Text(
                    comment.isLiked ? 'Unlike' : 'Like',
                    style: const TextStyle(
                      color: Color(0xFF6066F3),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    final comments = widget.moment.comments;
                    if (commentIdx >= 0 && commentIdx < comments.length) {
                      comments.removeAt(commentIdx);
                    }
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  alignment: Alignment.center,
                  child: const Text(
                    'Not Interested',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  alignment: Alignment.center,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF6066F3),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
