import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/swap_repository.dart';
import '../../models/swap.dart';

class SuggestedSwapsPage extends StatefulWidget {
  const SuggestedSwapsPage({Key? key}) : super(key: key);

  @override
  State<SuggestedSwapsPage> createState() => _SuggestedSwapsPageState();
}

class _SuggestedSwapsPageState extends State<SuggestedSwapsPage> {
  final SwapRepository _repository = SwapRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _viewSwap(Swap swap) {
    // Increment view count
    _repository.incrementViews(swap.id);
    
    // Show swap details dialog
    showDialog(
      context: context,
      builder: (context) => _SwapDetailsDialog(swap: swap),
    );
  }

  void _requestSwap(Swap swap) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to request swaps')),
      );
      return;
    }

    if (currentUser.uid == swap.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot request your own swap')),
      );
      return;
    }

    try {
      await _repository.requestSwap(swap.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Swap request sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatSkill(String skill) {
    // Convert skill names to proper format
    switch (skill.toLowerCase()) {
      case 'cook':
        return 'cooking';
      case 'dance':
        return 'dancing';
      case 'code':
      case 'coding':
        return 'coding';
      case 'photography':
        return 'photography';
      case 'designing flyers':
        return 'designing flyers';
      case 'video editing':
        return 'video editing';
      case 'web design':
        return 'web design';
      default:
        return skill.toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'Suggested for You',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              color: Color(0xFF121717),
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Expanded(
          child: _buildSuggestedSwapsList(),
        ),
      ],
    );
  }

  Widget _buildSuggestedSwapsList() {
    return StreamBuilder<List<Swap>>(
      stream: _repository.getSuggestedSwaps(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'Error loading suggestions',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final swaps = snapshot.data!;
        if (swaps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No suggestions yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Complete your profile to get personalized suggestions',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            return _buildSwapCard(swaps[index]);
          },
        );
      },
    );
  }

  Widget _buildSwapCard(Swap swap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(swap.userAvatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      swap.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _repository.getTimeAgo(swap.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF225B4B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Recommended',
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFF225B4B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${swap.userName} is good at ${_formatSkill(swap.skillOffered)}, and ${swap.userName} wants to learn ${_formatSkill(swap.skillWanted)}.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _viewSwap(swap),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DA1F2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _requestSwap(swap),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Request Swap',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwapDetailsDialog extends StatelessWidget {
  final Swap swap;

  const _SwapDetailsDialog({required this.swap});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage(swap.userAvatar),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        swap.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        swap.location.isNotEmpty ? swap.location : 'Location not specified',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF225B4B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Recommended',
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFF225B4B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DetailRow(
              icon: Icons.school,
              title: 'Skill Offered',
              value: swap.skillOffered,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.psychology,
              title: 'Skill Wanted',
              value: swap.skillWanted,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            if (swap.description.isNotEmpty) ...[
              Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                swap.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (swap.tags.isNotEmpty) ...[
              Text(
                'Tags',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: swap.tags.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(fontSize: 12),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Icon(Icons.remove_red_eye, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${swap.views} views',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.handshake, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${swap.requests} requests',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Here you could navigate to a detailed swap page or start a chat
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Request Swap',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 