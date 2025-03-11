import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'exhibits_screen.dart';
import 'navigation_screen.dart';
import 'profile_screen.dart';
import 'feedback_screen.dart'; // For the feedback screen
 // For continue planning screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // Navigator keys for each tab to preserve state
  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
  };
  
  /// Intercepts the back button press:
  /// - If current tab's navigator can pop, it pops;
  /// - Otherwise, if not on Home (index 0), it switches to Home;
  /// - Otherwise, the system handles the back (exiting the app).
  Future<bool> _onWillPop() async {
    final currentNavigator = _navigatorKeys[_selectedIndex]?.currentState;
    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
      return false;
    } else if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }
    return true;
  }
  
  /// When a bottom nav item is tapped:
  /// - If it’s the current tab, pop to the first route.
  /// - Otherwise, switch to that tab.
  void _onNavigationItemSelected(int index) {
    if (index == _selectedIndex) {
      _navigatorKeys[index]?.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  
  /// Builds a nested navigator for each tab.
  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (index) {
            case 0:
              builder = (context) => const HomeContent();
              break;
            case 1:
              builder = (context) => const ExhibitsScreen();
              break;
            case 2:
              builder = (context) => const NavigationScreen();
              break;
            case 3:
              builder = (context) => const ProfileScreen();
              break;
            default:
              throw Exception('Invalid tab index');
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Museum Guide',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFF2E3192),
          elevation: 4,
          actions: [
            // Feedback icon in the app bar: pushes FeedbackScreen on the root navigator.
            IconButton(
              icon: const Icon(Icons.feedback_outlined),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                );
              },
            ),
            // Notifications icon (placeholder).
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Add your notification action here.
              },
            ),
            // Profile icon that switches to Profile tab.
            IconButton(
              icon: const CircleAvatar(
                backgroundImage: AssetImage('assets/profile_placeholder.png'),
              ),
              onPressed: () {
                setState(() {
                  _selectedIndex = 3;
                });
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
            _buildOffstageNavigator(3),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavigationItemSelected,
          selectedItemColor: const Color(0xFF2E3192),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Exhibits'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: '3D Map'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF2E3192),
          onPressed: () {
            // Navigate to the AI Chat screen using the root navigator.
            Navigator.of(context, rootNavigator: true).pushNamed('/ai_chat');
          },
          child: const Icon(Icons.assistant_outlined, color: Colors.white),
        ),
      ),
    );
  }
}

/// This widget displays the main content on the Home tab.
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});
  
  final List<Map<String, dynamic>> featuredExhibits = const [
    {
      'title': 'Qasr Al Hosn Fort',
      'image': 'assets/exhibits/exhibit1.png',
      'era': '18th Century'
    },
    {
      'title': 'Louvre Abu Dhabi’s Arab Art Collection',
      'image': 'assets/exhibits/exhibit2.png',
      'era': 'Modern'
    },
    {
      'title': 'Dubai’s Skyscraper Revolution',
      'image': 'assets/exhibits/exhibit3.png',
      'era': 'Contemporary'
    },
    {
      'title': 'Sheikh Zayed & UAE Unification',
      'image': 'assets/exhibits/exhibit4.png',
      'era': '20th Century'
    },
    {
      'title': 'Bedouin Life & Culture',
      'image': 'assets/exhibits/exhibit5.png',
      'era': 'Traditional'
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFF2E3192)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUpcomingTourCard(context),
            _buildQuickActions(context),
            _buildSectionHeader(context, 'Featured Exhibits'),
            _buildExhibitsCarousel(context),
            _buildSectionHeader(context, 'Live Crowd Status'),
            _buildCrowdIndicator(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUpcomingTourCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E3192).withOpacity(0.8),
            const Color(0xFFFFD700).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row( 
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Tour',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Chip(
                  backgroundColor: Colors.white.withOpacity(0.7),
                  label: Text(
                    'Tomorrow 10:00 AM',
                    style: GoogleFonts.roboto(
                      color: const Color(0xFF2E3192),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Selected Exhibits: 5',
              style: GoogleFonts.roboto(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              '60% of optimal route planned',
              style: GoogleFonts.roboto(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E3192),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Color(0xFF2E3192)),
                ),
              ),
              // Start New Tour navigates to ExhibitsScreen (booking a tour)
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pushNamed('/explore');
              },
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Start New Tour'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E3192),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Color(0xFF2E3192)),
                ),
              ),
              // Continue Planning navigates to TourPlannerScreen
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pushNamed('/tours');
              },
              icon: const Icon(Icons.edit_calendar_outlined),
              label: const Text('Continue Planning'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
  
  Widget _buildExhibitsCarousel(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featuredExhibits.length,
        itemBuilder: (context, index) {
          final exhibit = featuredExhibits[index];
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: GestureDetector(
              onTap: () {
                _showExhibitDetails(context, exhibit);
              },
              child: Container(
                width: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                  image: DecorationImage(
                    image: AssetImage(exhibit['image']),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.1)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exhibit['title'],
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        exhibit['era'],
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildCrowdIndicator(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Current crowd status: Moderate',
              style: GoogleFonts.roboto(fontSize: 18, color: Colors.white70),
            ),
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pushNamed('/crowd_status');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E3192),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('View Detailed Crowd Status'),
          ),
        ),
      ],
    );
  }
  
  void _showExhibitDetails(BuildContext context, Map<String, dynamic> exhibit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exhibit['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(exhibit['image']),
            const SizedBox(height: 10),
            Text('Era: ${exhibit['era']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(
              exhibit['title'] == 'Qasr Al Hosn Fort'
                  ? 'A historic fort that served as a watchtower and residence, located in Abu Dhabi.'
                  : exhibit['title'] == 'Louvre Abu Dhabi’s Arab Art Collection'
                      ? 'A world-class collection showcasing Islamic and Arab art.'
                      : exhibit['title'] == 'Dubai’s Skyscraper Revolution'
                          ? 'Discover the transformation of Dubai from a desert town to a global metropolis.'
                          : exhibit['title'] == 'Sheikh Zayed & UAE Unification'
                              ? 'Learn about the leader behind the unification of the UAE.'
                              : 'Experience traditional Bedouin culture and lifestyle.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
