import 'package:flutter/material.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Header Profile Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.secondary,
                            child: Icon(Icons.person, color: AppTheme.background, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Text('Good Morning', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: AppTheme.onSurface),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Hero Text
                Text(
                  'Where to?',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48),
                ),
                const SizedBox(height: 32),
                
                // Destination Input (Navigates to Map)
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/map'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 28, color: AppTheme.secondary),
                        const SizedBox(width: 16),
                        Text('Search destination', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.primary)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.schedule, size: 18, color: AppTheme.onSurface),
                              SizedBox(width: 8),
                              Text('Now', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Saved Places
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Saved Places', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24)),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primary),
                  ],
                ),
                const SizedBox(height: 24),
                
                // List of saved places
                _buildSavedPlace('Home', '123 Fluid Way, Glass City', Icons.home_rounded),
                const SizedBox(height: 20),
                _buildSavedPlace('Office', 'Tech Park, District 9', Icons.work_rounded),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: AppTheme.surfaceContainerLow,
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.secondary,
          unselectedItemColor: AppTheme.primary.withOpacity(0.5),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            // If Account tab clicked, add logic
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.explore_rounded, size: 28), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded, size: 28), label: 'Activity'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded, size: 28), label: 'Account'),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPlace(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.onSurface, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary)),
            ],
          ),
        ],
      ),
    );
  }
}
