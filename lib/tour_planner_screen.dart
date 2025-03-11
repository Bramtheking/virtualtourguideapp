
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class TourPlannerScreen extends StatefulWidget {
  const TourPlannerScreen({super.key});

  @override
  State<TourPlannerScreen> createState() => _TourPlannerScreenState();
}

class _TourPlannerScreenState extends State<TourPlannerScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<Map<String, dynamic>> _selectedExhibits = [];
  final List<Map<String, dynamic>> _availableExhibits = [
    {
      'id': '1',
      'name': 'Islamic Calligraphy',
      'location': 'Gallery A1',
      'duration': '20 mins'
    },
    {
      'id': '2',
      'name': 'Bedouin Lifestyle',
      'location': 'Outdoor Area',
      'duration': '30 mins'
    },
    {
      'id': '3',
      'name': 'Space Exploration',
      'location': 'Modern Wing',
      'duration': '45 mins'
    },
    // You can add more available exhibits here as needed.
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tour Planner',
          style: GoogleFonts.playfairDisplay(fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveTour,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'cancel') {
                _cancelTour();
              } else if (value == 'reschedule') {
                _rescheduleTour();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'cancel',
                  child: Text('Cancel Tour'),
                ),
                const PopupMenuItem(
                  value: 'reschedule',
                  child: Text('Reschedule Tour'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(),
            const SizedBox(height: 20),
            _buildTimeSelector(),
            const SizedBox(height: 20),
            _buildCrowdPrediction(),
            const SizedBox(height: 20),
            _buildSelectedExhibits(),
            const SizedBox(height: 20),
            _buildAddExhibitButton(),
          ],
        ),
      ),
    );
  }

  // Date Selector
  Widget _buildDateSelector() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date',
                style: GoogleFonts.roboto(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickDate,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined),
                  const SizedBox(width: 10),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Time Selector
  Widget _buildTimeSelector() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Time Slot',
                style: GoogleFonts.roboto(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _buildTimeChip('09:00 AM'),
                _buildTimeChip('10:00 AM'),
                _buildTimeChip('11:00 AM'),
                _buildTimeChip('02:00 PM'),
                _buildTimeChip('03:00 PM'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(String time) {
    return ChoiceChip(
      label: Text(time),
      selected: _selectedTime.format(context) == time,
      onSelected: (selected) {
        setState(() {
          // This simplistic conversion assumes hour only, adjust if needed.
          _selectedTime = TimeOfDay(hour: int.parse(time.split(':')[0]), minute: 0);
        });
      },
      selectedColor: const Color(0xFF2E3192).withOpacity(0.2),
      labelStyle: TextStyle(
        color: _selectedTime.format(context) == time ? const Color(0xFF2E3192) : Colors.black,
      ),
    );
  }

  // Crowd Prediction Widget (for demonstration purposes)
  Widget _buildCrowdPrediction() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expected Crowd',
                    style: GoogleFonts.roboto(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Icon(Icons.people_outline),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildCrowdIndicator('09 AM', 0.3)),
                Expanded(child: _buildCrowdIndicator('10 AM', 0.6)),
                Expanded(child: _buildCrowdIndicator('11 AM', 0.8)),
                Expanded(child: _buildCrowdIndicator('02 PM', 0.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrowdIndicator(String time, double percentage) {
    Color getColor() {
      if (percentage > 0.7) return Colors.red;
      if (percentage > 0.4) return Colors.orange;
      return Colors.green;
    }
    return Column(
      children: [
        Text(time, style: GoogleFonts.roboto(fontSize: 12)),
        const SizedBox(height: 5),
        Container(
          height: 40,
          width: double.infinity,
          decoration: BoxDecoration(
            color: getColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text('${(percentage * 100).toInt()}%',
                style: GoogleFonts.roboto(
                    color: getColor(), fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // Selected Exhibits List
  Widget _buildSelectedExhibits() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Selected Exhibits (${_selectedExhibits.length})',
                    style: GoogleFonts.roboto(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                if (_selectedExhibits.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _selectedExhibits.clear()),
                    child: const Text('Clear All'),
                  ),
              ],
            ),
            ..._selectedExhibits.map((exhibit) => Dismissible(
                  key: Key(exhibit['id']),
                  direction: DismissDirection.endToStart,
                  background: Container(color: Colors.red),
                  onDismissed: (direction) => setState(
                      () => _selectedExhibits.removeWhere((e) => e['id'] == exhibit['id'])),
                  child: ListTile(
                    leading: const Icon(Icons.museum_outlined),
                    title: Text(exhibit['name']),
                    subtitle: Text(exhibit['location']),
                    trailing: Text(exhibit['duration']),
                  ),
                )),
            if (_selectedExhibits.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No exhibits selected yet'),
              ),
          ],
        ),
      ),
    );
  }

  // Add Exhibit Button (opens bottom sheet to select exhibits)
  Widget _buildAddExhibitButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add_circle_outline),
      label: const Text('Add Exhibits'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E3192),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: _showExhibitSelector,
    );
  }

  Future<void> _showExhibitSelector() async {
    final selected = await showModalBottomSheet<List<Map<String, dynamic>>>(
      context: context,
      builder: (context) => ExhibitSelectionDialog(
        availableExhibits: _availableExhibits,
        selectedExhibits: _selectedExhibits,
      ),
    );
    if (selected != null && selected.isNotEmpty) {
      setState(() {
        _selectedExhibits.addAll(selected);
      });
    }
  }

  // Date Picker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // Save the tour in Hive.
  void _saveTour() async {
    if (_selectedExhibits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one exhibit')));
      return;
    }
    final tour = {
      'date': _selectedDate.toIso8601String(),
      'time': _selectedTime.format(context),
      'exhibits': _selectedExhibits,
    };
    final toursBox = Hive.box('tours');
    // Use current timestamp as a unique key.
    String key = DateTime.now().millisecondsSinceEpoch.toString();
    await toursBox.put(key, tour);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tour saved successfully!')));
    Navigator.pop(context);
  }

  // Cancel the tour by clearing selections.
  void _cancelTour() {
    setState(() {
      _selectedExhibits.clear();
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Tour canceled')));
  }

  // Reschedule the tour by clearing current selections and prompting for new inputs.
  void _rescheduleTour() {
    _cancelTour();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tour reschedule: please select new date/time and exhibits')));
  }
}

class ExhibitSelectionDialog extends StatelessWidget {
  final List<Map<String, dynamic>> availableExhibits;
  final List<Map<String, dynamic>> selectedExhibits;

  const ExhibitSelectionDialog({
    super.key,
    required this.availableExhibits,
    required this.selectedExhibits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Select Exhibits', style: GoogleFonts.playfairDisplay(fontSize: 22)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: availableExhibits.length,
              itemBuilder: (context, index) {
                final exhibit = availableExhibits[index];
                final isSelected = selectedExhibits.any((e) => e['id'] == exhibit['id']);
                return CheckboxListTile(
                  title: Text(exhibit['name']),
                  subtitle: Text(exhibit['location']),
                  value: isSelected,
                  onChanged: (value) {
                    // Toggle exhibit selection.
                    Navigator.pop(context, [exhibit]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
