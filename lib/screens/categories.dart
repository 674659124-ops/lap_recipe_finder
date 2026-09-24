import 'package:flutter/material.dart';
import 'home.dart';
import 'detail.dart';
import 'favorites.dart';
import 'mealplanner.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _currentIndex = 1; // "หมวดหมู่" tab selected

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Healthy',
      'subtitle': 'เพื่อสุขภาพ',
      'recipesCount': '24 สูตร',
      'icon': '🥗',
      'color': const Color(0xFF4CAF50),
      'bgLight': const Color(0xFFE8F5E9),
    },
    {
      'title': 'Quick Meal',
      'subtitle': 'จานด่วนทำง่าย',
      'recipesCount': '18 สูตร',
      'icon': '⏱️',
      'color': const Color(0xFFFF9800),
      'bgLight': const Color(0xFFFFF3E0),
    },
    {
      'title': 'Thai',
      'subtitle': 'อาหารไทย',
      'recipesCount': '35 สูตร',
      'icon': '🍲',
      'color': const Color(0xFFE91E63),
      'bgLight': const Color(0xFFFCE4EC),
    },
    {
      'title': 'International',
      'subtitle': 'อาหารนานาชาติ',
      'recipesCount': '20 สูตร',
      'icon': '🍕',
      'color': const Color(0xFF2196F3),
      'bgLight': const Color(0xFFE3F2FD),
    },
    {
      'title': 'Vegetarian',
      'subtitle': 'มังสวิรัติ',
      'recipesCount': '15 สูตร',
      'icon': '🥦',
      'color': const Color(0xFF8BC34A),
      'bgLight': const Color(0xFFF1F8E9),
    },
    {
      'title': 'Desserts',
      'subtitle': 'ของหวาน & เบเกอรี่',
      'recipesCount': '28 สูตร',
      'icon': '🍰',
      'color': const Color(0xFFEC407A),
      'bgLight': const Color(0xFFFCE4EC),
    },
    {
      'title': 'Breakfast',
      'subtitle': 'อาหารเช้า',
      'recipesCount': '16 สูตร',
      'icon': '🍳',
      'color': const Color(0xFFFFB300),
      'bgLight': const Color(0xFFFFF8E1),
    },
    {
      'title': 'Soup',
      'subtitle': 'ซุป & ต้ม',
      'recipesCount': '12 สูตร',
      'icon': '🥣',
      'color': const Color(0xFF00BCD4),
      'bgLight': const Color(0xFFE0F7FA),
    },
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    if (index == 0) {
      // Navigate to Home
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const HomeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (index == 2) {
      // Navigate to Favorites
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const FavoritesScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (index == 3) {
      // Navigate to Meal Planner
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const MealPlannerScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF207935);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'Categories',
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'เลือกหมวดหมู่อาหาร',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: _categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (context, index) {
                    final item = _categories[index];
                    return _buildCategoryCard(item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGreen,
        unselectedItemColor: const Color(0xFF8C919E),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'หมวดหมู่',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            label: 'รายการโปรด',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'วางแผนมื้ออาหาร',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> item) {
    final Color itemColor = item['color'] as Color;
    final Color bgLight = item['bgLight'] as Color;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              recipeTitle: 'เมนูในหมวด ${item['title']}',
              prepTime: '15 นาที',
              cookTime: '10 นาที',
              difficulty: 'ปานกลาง',
              icon: item['icon'] as String,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item['icon'] as String,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item['recipesCount'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: itemColor,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['subtitle'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8C919E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
