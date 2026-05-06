import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/cpu_cycle_screen.dart';
import 'screens/memory_hierarchy_screen.dart';
import 'screens/alu_demo_screen.dart';
import 'screens/io_simulation_screen.dart';
import 'screens/cache_tool_screen.dart';
import 'screens/system_flow_screen.dart';

void main() {
  runApp(const CPUCycleApp());
}

class CPUCycleApp extends StatelessWidget {
  const CPUCycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'CPU Instruction Cycle Simulation',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainScreen(),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  double animationSpeed = 1.0;

  void setSpeed(double speed) {
    animationSpeed = speed;
    notifyListeners();
  }

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  
  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CPUCycleScreen(),
    MemoryHierarchyScreen(),
    ALUDemoScreen(),
    IOSimulationScreen(),
    CacheToolScreen(),
    SystemFlowScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
              appState.setIndex(index);
            },
            backgroundColor: const Color(0xFF111827),
            indicatorColor: const Color(0xFF00F5D4).withOpacity(0.3),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.home, color: Color(0xFF00F5D4)),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.memory_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.memory, color: Color(0xFF00F5D4)),
                label: 'CPU Cycle',
              ),
              NavigationDestination(
                icon: Icon(Icons.layers_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.layers, color: Color(0xFF00F5D4)),
                label: 'Memory',
              ),
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.calculate, color: Color(0xFF00F5D4)),
                label: 'ALU',
              ),
              NavigationDestination(
                icon: Icon(Icons.input_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.input, color: Color(0xFF00F5D4)),
                label: 'I/O',
              ),
              NavigationDestination(
                icon: Icon(Icons.storage_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.storage, color: Color(0xFF00F5D4)),
                label: 'Cache',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_tree_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.account_tree, color: Color(0xFF00F5D4)),
                label: 'System',
              ),
            ],
          ),
        );
      },
    );
  }
}