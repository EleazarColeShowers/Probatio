import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/api_requests/presentation/bloc/request_bloc.dart';
import 'injection_container.dart' as di;
import 'shared/widgets/customappbar.dart';
import 'shared/widgets/tabtext.dart';
import 'features/api_requests/presentation/pages/request_page.dart';
import 'features/api_requests/presentation/pages/saved_request_page.dart';
import 'features/collections/presentation/pages/collection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Probatio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider(
        create: (_) => di.sl<RequestBloc>(),
        child: const MyHomePage(title: 'Probatio'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; 

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const RequestPage();
      case 1:
        return const SavedPage();
      case 2:
        return const CollectionsPage();
      default:
        return const RequestPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TabText(
                  text: 'Request',
                  onTap: () => _onTabSelected(0),
                  isSelected: _selectedIndex == 0,
                ),
                TabText(
                  text: 'Saved',
                  onTap: () => _onTabSelected(1),
                  isSelected: _selectedIndex == 1,
                ),
                TabText(
                  text: 'Collections',
                  onTap: () => _onTabSelected(2),
                  isSelected: _selectedIndex == 2,
                ),
              ],
            ),
          ),

          // Display the selected page content
          Expanded(
            child: _getCurrentPage(),
          ),
        ],
      ),
    );
  }
}