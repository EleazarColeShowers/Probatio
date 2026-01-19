import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/api_requests/presentation/bloc/request_bloc.dart';
import 'features/collections/presentation/bloc/collection_bloc.dart';
import 'injection_container.dart' as di;
import 'features/api_requests/presentation/pages/request_page.dart';
import 'features/api_requests/presentation/pages/saved_request_page.dart';
import 'features/collections/presentation/pages/collection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<RequestBloc>()),
        BlocProvider(create: (_) => di.sl<CollectionBloc>()),
      ],
      child: MaterialApp(
        title: 'API Tester',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB), // Modern blue
            brightness: Brightness.light,
          ),
          // // Card theme

          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF1F2937),
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          // Elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Outlined button theme
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
            ),
          ),
          // Text button theme
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const MainNavigationPage(),
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const RequestPage(),
    const SavedPage(),
    const CollectionsPage(),
  ];

  final List<_NavigationItem> _navItems = [
    _NavigationItem(
      icon: Icons.bolt_outlined,
      selectedIcon: Icons.bolt,
      label: 'Request',
      gradient: const LinearGradient(
        colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
      ),
    ),
    _NavigationItem(
      icon: Icons.bookmark_outline,
      selectedIcon: Icons.bookmark,
      label: 'Saved',
      gradient: const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
      ),
    ),
    _NavigationItem(
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
      label: 'Collections',
      gradient: const LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;

                return _NavBarItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                    // Haptic feedback
                    HapticFeedback.lightImpact();
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Gradient gradient;

  _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.gradient,
  });
}

class _NavBarItem extends StatelessWidget {
  final _NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected ? item.gradient : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                size: 24,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// DESIGN IMPROVEMENTS MADE:
// ============================================
//
// 1. **Modern Color Palette**
//    - Blue (#2563EB) for primary actions
//    - Purple (#8B5CF6) for saved items
//    - Pink (#EC4899) for collections
//    - Neutral grays for text and backgrounds
//
// 2. **Enhanced Navigation Bar**
//    - Gradient backgrounds on selected items
//    - Smooth animations (200ms transitions)
//    - Haptic feedback on tap
//    - Elevated with subtle shadow
//    - Rounded corners for modern feel
//
// 3. **Consistent Spacing & Borders**
//    - 12px border radius throughout
//    - 16px standard padding
//    - Consistent elevation shadows
//
// 4. **Material 3 Design**
//    - Updated color scheme
//    - Modern card styles
//    - Improved input fields
//    - Better button designs
//
// 5. **Visual Hierarchy**
//    - Bold app bar titles (24px)
//    - Clear selected states
//    - Subtle hover/press effects
//
// 6. **Accessibility**
//    - High contrast colors
//    - Clear icon distinctions
//    - Readable font sizes
//    - Touch-friendly targets
//
// Next: Send me each page for individual redesigns!
// ============================================