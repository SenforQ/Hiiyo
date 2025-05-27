import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class EditProfilePage extends StatefulWidget {
  final String avatar;
  final String nickname;
  final String signature;
  const EditProfilePage({
    Key? key,
    required this.avatar,
    required this.nickname,
    required this.signature,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late String _avatar;
  late TextEditingController _nicknameController;
  late TextEditingController _signatureController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _avatar = widget.avatar;
    _nicknameController = TextEditingController(text: widget.nickname);
    _signatureController = TextEditingController(
      text:
          widget.signature == 'No personal signature yet.'
              ? ''
              : widget.signature,
    );
  }

  Future<String> _saveImageToLocalDir(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final avatarDir = Directory(path.join(directory.path, 'avatar_images'));
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }
    final ext = path.extension(imagePath);
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}$ext';
    final newPath = path.join(avatarDir.path, fileName);
    final newFile = await File(imagePath).copy(newPath);
    // 返回相对路径
    return path.join('avatar_images', fileName);
  }

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      final relativePath = await _saveImageToLocalDir(image.path);
      setState(() {
        _avatar = relativePath;
      });
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar', _avatar);
    await prefs.setString('user_nickname', _nicknameController.text.trim());
    await prefs.setString('user_signature', _signatureController.text.trim());
    Navigator.of(context).pop(true);
  }

  Future<ImageProvider> _getAvatarProviderAsync() async {
    if (_avatar.startsWith('avatar_images/')) {
      final dir = await getApplicationDocumentsDirectory();
      return FileImage(File(path.join(dir.path, _avatar)));
    } else if (_avatar.startsWith('/')) {
      return FileImage(File(_avatar));
    } else {
      return AssetImage(_avatar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF222222),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF222222)),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    FutureBuilder<ImageProvider>(
                      future: _getAvatarProviderAsync(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.grey,
                          );
                        }
                        return CircleAvatar(
                          radius: 44,
                          backgroundImage: snapshot.data,
                          backgroundColor: Colors.grey[200],
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Nickname',
              style: TextStyle(fontSize: 15, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: 'Enter your nickname',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLength: 20,
            ),
            const SizedBox(height: 18),
            const Text(
              'Signature',
              style: TextStyle(fontSize: 15, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _signatureController,
              decoration: InputDecoration(
                hintText: 'No personal signature yet.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLength: 40,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _saveProfile,
                child: const Text(
                  'Save',
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
      ),
    );
  }
}
