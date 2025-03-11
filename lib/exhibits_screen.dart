import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExhibitsScreen extends StatefulWidget {
  const ExhibitsScreen({super.key});

  @override
  State<ExhibitsScreen> createState() => _ExhibitsScreenState();
}

class _ExhibitsScreenState extends State<ExhibitsScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;
  double _sliderValue = 1.0;

  final List<Map<String, dynamic>> _exhibits = [
    {
      'id': '1',
      'title': 'Qasr Al Hosn Fort',
      'category': 'History',
      'image': 'assets/exhibits/exhibit1.png',
      'crowd': 0.7,
      'era': '18th Century',
      'description': 'The oldest stone building in Abu Dhabi, serving as a watchtower and later a royal residence.'
    },
    {
      'id': '2',
      'title': 'Louvre Abu Dhabi’s Arab Art Collection',
      'category': 'Islamic Art',
      'image': 'assets/exhibits/exhibit2.png',
      'crowd': 0.5,
      'era': 'Modern',
      'description': 'A collection of Islamic and Arab art from different centuries, showcasing rich cultural history.'
    },
    {
      'id': '3',
      'title': 'Dubai’s Skyscraper Revolution',
      'category': 'Architecture',
      'image': 'assets/exhibits/exhibit3.png',
      'crowd': 0.9,
      'era': 'Contemporary',
      'description': 'Explore how Dubai transformed from a desert town into a global skyscraper hub.'
    },
    {
  'id': '4',
  'title': 'Sheikh Zayed & UAE Unification',
  'category': 'History',
  'image': 'assets/exhibits/exhibit4.png',
  'crowd': 0.8,
  'era': '20th Century',
  'description': 'An exhibit dedicated to Sheikh Zayed bin Sultan Al Nahyan and the unification of the UAE, showcasing artifacts, photographs, and historical documents that illustrate the nation’s formation.'
},
{
  'id': '5',
  'title': 'Bedouin Life & Culture',
  'category': 'Cultural Heritage',
  'image': 'assets/exhibits/exhibit5.png',
  'crowd': 0.6,
  'era': 'Traditional',
  'description': 'Experience the rich traditions of Bedouin life with interactive displays, artifacts, and multimedia presentations that highlight desert survival, hospitality, and artistic expressions.'
},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Exhibits', style: GoogleFonts.playfairDisplay(fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.grid_view : Icons.list, color: Colors.white),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          _buildSlider(),
          Expanded(child: _isGridView ? _buildExhibitsGrid() : _buildExhibitsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feature coming soon!'))
          );
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search exhibits...',
          prefixIcon: const Icon(Icons.search, color: Colors.purple),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', 'Islamic Art', 'History', 'Architecture'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        spacing: 10,
        children: categories.map((category) {
          return ChoiceChip(
            label: Text(category),
            selected: _selectedCategory == category,
            selectedColor: Colors.amber,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = selected ? category : 'All';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSlider() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Crowd Level: ${(_sliderValue * 10).toInt()} / 10', style: const TextStyle(color: Colors.purple)),
          Slider(
            value: _sliderValue,
            onChanged: (value) => setState(() => _sliderValue = value),
            min: 0,
            max: 1,
            divisions: 10,
            activeColor: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildExhibitsGrid() {
    final filteredExhibits = _filteredExhibits();
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filteredExhibits.length,
      itemBuilder: (context, index) {
        final exhibit = filteredExhibits[index];
        return _buildExhibitCard(exhibit);
      },
    );
  }

  Widget _buildExhibitsList() {
    final filteredExhibits = _filteredExhibits();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredExhibits.length,
      itemBuilder: (context, index) {
        final exhibit = filteredExhibits[index];
        return _buildExhibitCard(exhibit);
      },
    );
  }

  Widget _buildExhibitCard(Map<String, dynamic> exhibit) {
    return GestureDetector(
      onTap: () {
        _showExhibitDetails(exhibit);
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(exhibit['image'], height: 120, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exhibit['title'], style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Era: ${exhibit['era']}', style: const TextStyle(color: Colors.grey)),
                  LinearProgressIndicator(value: exhibit['crowd'], color: Colors.purple, backgroundColor: Colors.grey.shade300),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExhibitDetails(Map<String, dynamic> exhibit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(exhibit['title']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(exhibit['image']),
              const SizedBox(height: 10),
              Text('Era: ${exhibit['era']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(exhibit['description']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _filteredExhibits() {
    return _exhibits.where((exhibit) {
      final matchesCategory = _selectedCategory == 'All' || exhibit['category'] == _selectedCategory;
      final matchesSearch = exhibit['title'].toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }
}