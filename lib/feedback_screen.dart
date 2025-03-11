import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double _rating = 0;
  String _selectedEmoji = '';
  final List<File> _images = [];
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _suggestionController = TextEditingController();
  final List<String> _emojiOptions = ['😍', '😊', '😐', '😕', '😠'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tour Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRatingSection(),
            const SizedBox(height: 20),
            _buildEmojiReactions(),
            const SizedBox(height: 20),
            _buildCommentSection(),
            const SizedBox(height: 20),
            _buildPhotoUpload(),
            const SizedBox(height: 20),
            _buildSocialShare(),
            const SizedBox(height: 30),
            _buildSuggestionForm(),
            const SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // Rating Section
  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rate your experience:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        RatingBar.builder(
          initialRating: _rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4),
          itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (rating) => setState(() => _rating = rating),
        ),
      ],
    );
  }

  // Emoji Reactions
  Widget _buildEmojiReactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick reaction:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _emojiOptions
              .map((emoji) => GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedEmoji == emoji
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 32)),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // Comment Section
  Widget _buildCommentSection() {
    return TextField(
      controller: _commentController,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Share your thoughts...',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.emoji_emotions),
          onPressed: _showEmojiPicker,
        ),
      ),
    );
  }

  // Photo Upload
  Widget _buildPhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upload photos:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _images.length + 1,
          itemBuilder: (context, index) {
            if (index == _images.length) {
              return GestureDetector(
                onTap: _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_a_photo),
                ),
              );
            }
            return Stack(
              children: [
                Image.file(_images[index], fit: BoxFit.cover),
                Positioned(
                  top: 2,
                  right: 2,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => setState(() => _images.removeAt(index)),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // Social Share Section
  Widget _buildSocialShare() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Image.asset('assets/facebook.png', width: 40),
          onPressed: () => _shareToSocial('Facebook'),
        ),
        IconButton(
          icon: Image.asset('assets/twitter.png', width: 40),
          onPressed: () => _shareToSocial('Twitter'),
        ),
        IconButton(
          icon: Image.asset('assets/instagram.png', width: 40),
          onPressed: () => _shareToSocial('Instagram'),
        ),
      ],
    );
  }

  // Suggestion Form
  Widget _buildSuggestionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Suggest an exhibit:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: _suggestionController,
          decoration: const InputDecoration(
            hintText: 'What exhibit would you like to see in the future?',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  // Submit Button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.send),
        label: const Text('Submit Feedback'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _submitFeedback,
      ),
    );
  }

  // Image Picker
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _images.add(File(pickedFile.path)));
    }
  }

  // Emoji Picker
  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 200,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemCount: _emojiOptions.length,
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              setState(() => _selectedEmoji = _emojiOptions[index]);
              Navigator.pop(context);
            },
            child: Text(_emojiOptions[index], style: const TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }

  // Social Sharing
  void _shareToSocial(String platform) async {
    final text = 'My museum experience: $_rating stars! ${_commentController.text}';
    await Share.share(text, subject: 'Museum Tour Feedback');
  }

  // Submit Feedback and Send Email
  Future<void> _submitFeedback() async {
    final smtpServer = gmail('bramwela8@gmail.com', 'hftgdegtcpbfewcw');

    final message = Message()
      ..from = Address('bramwela8@gmail.com', 'Museum Feedback')
      ..recipients.add('abramwel3@gmail.com')
      ..subject = 'New Museum Feedback'
      ..text = '''
Rating: $_rating Stars
Emoji Reaction: $_selectedEmoji
Comment: ${_commentController.text}
Suggestion: ${_suggestionController.text}
''';

    try {
      await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback sent successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send feedback: $e')),
      );
    }
  }
}