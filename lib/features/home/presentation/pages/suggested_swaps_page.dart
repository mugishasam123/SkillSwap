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
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedLanguage = 'Language';
  String _selectedCountry = 'Country';
  String _selectedAvailability = 'Availability';

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

  void _showFullScreenImage(String imageUrl, String userName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageView(
          imageUrl: imageUrl,
          userName: userName,
        ),
      ),
    );
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

