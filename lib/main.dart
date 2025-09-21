import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    _saveTheme(isDark);
  }

  void _resetTheme() {
    setState(() {
      _themeMode = ThemeMode.light;
    });
    _saveTheme(false);
  }

  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDarkMode", isDark);
  }

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool("isDarkMode") ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Assignment",
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: HomePage(
        isDarkMode: _themeMode == ThemeMode.dark,
        setTheme: _setTheme,
        resetTheme: _resetTheme,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) setTheme;
  final VoidCallback resetTheme;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.setTheme,
    required this.resetTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  bool _isFirstImage = false; // start with image2.jpg

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Setup fade animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Load saved state
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt("counter") ?? 0;
      _isFirstImage = prefs.getBool("isFirstImage") ?? false;
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("counter", _counter);
    await prefs.setBool("isFirstImage", _isFirstImage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _saveState();
  }

  void _toggleImage() {
    setState(() {
      _isFirstImage = !_isFirstImage;
    });
    _controller.forward(from: 0); // restart fade animation
    _saveState();
  }

  Future<void> _reset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Reset"),
        content: const Text(
          "Are you sure you want to reset? This will clear all saved data.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Reset"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      setState(() {
        _counter = 0;
        _isFirstImage = false; // reset to image2.jpg
      });
      widget.resetTheme();
      _controller.forward(from: 0); // restart animation
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter CW01"),
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Counter card
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'You have pressed the button this many times:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$_counter',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: _incrementCounter,
                        icon: const Icon(Icons.add),
                        label: const Text("Increment"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Image with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FadeTransition(
                  opacity: _animation,
                  child: Image.asset(
                    _isFirstImage ? "assets/image1.jpg" : "assets/image2.jpg",
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: _toggleImage,
                icon: const Icon(Icons.swap_horiz),
                label: const Text("Toggle Image"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Theme toggle row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wb_sunny, color: Colors.orange),
                  Switch(value: widget.isDarkMode, onChanged: widget.setTheme),
                  const Icon(Icons.nightlight_round, color: Colors.blueGrey),
                ],
              ),
              const SizedBox(height: 30),

              // Reset button (danger style)
              ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text("Reset App"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
