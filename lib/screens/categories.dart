import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../models/recipe.dart';
import 'home.dart';
import 'detail.dart';
import 'favorites.dart';
import 'mealplanner.dart';
import 'community.dart';
import 'profile.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _currentIndex = 1; // "หมวดหมู่" tab selected
  final AppData _appData = AppData();

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Quick Meal',
      'subtitle': 'จานด่วนทำง่าย',
      'icon': '⏱️',
      'color': const Color(0xFFFF9800),
      'bgLight': const Color(0xFFFFF3E0),
    },
    {
      'title': 'Breakfast',
      'subtitle': 'อาหารเช้า',
      'icon': '🍳',
      'color': const Color(0xFFFFB300),
      'bgLight': const Color(0xFFFFF8E1),
    },
    {
      'title': 'Healthy',
      'subtitle': 'เพื่อสุขภาพ',
      'icon': '🥗',
      'color': const Color(0xFF4CAF50),
      'bgLight': const Color(0xFFE8F5E9),
    },
    {
      'title': 'Thai',
      'subtitle': 'อาหารไทย',
      'icon': '🍲',
      'color': const Color(0xFFE91E63),
      'bgLight': const Color(0xFFFCE4EC),
    },
    {
      'title': 'Soup',
      'subtitle': 'ซุป & ต้ม',
      'icon': '🥣',
      'color': const Color(0xFF00BCD4),
      'bgLight': const Color(0xFFE0F7FA),
    },
    {
      'title': 'Desserts',
      'subtitle': 'ของหวาน & เบเกอรี่',
      'icon': '🍰',
      'color': const Color(0xFFEC407A),
      'bgLight': const Color(0xFFFCE4EC),
    },
    {
      'title': 'International',
      'subtitle': 'อาหารนานาชาติ',
      'icon': '🍕',
      'color': const Color(0xFF2196F3),
      'bgLight': const Color(0xFFE3F2FD),
    },
    {
      'title': 'Vegetarian',
      'subtitle': 'มังสวิรัติ',
      'icon': '🥦',
      'color': const Color(0xFF8BC34A),
      'bgLight': const Color(0xFFF1F8E9),
    },
  ];

  @override
  void initState() {
    super.initState();
    _appData.addListener(_onAppDataChanged);
  }

  @override
  void dispose() {
    _appData.removeListener(_onAppDataChanged);
    super.dispose();
  }

  void _onAppDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const HomeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const FavoritesScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const MealPlannerScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const CommunityScreen(),
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

  void _selectCategory(String catTitle) {
    if (_appData.activeCategory == catTitle) {
      _appData.setActiveCategory(null);
    } else {
      _appData.setActiveCategory(catTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF207935);
    final selectedCategory = _appData.activeCategory;
    final categoryRecipes = selectedCategory != null
        ? _appData.recipes.where((r) => r.category == selectedCategory).toList()
        : [];

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
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: primaryGreen),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'เลือกหมวดหมู่อาหาร',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  if (selectedCategory != null)
                    GestureDetector(
                      onTap: () => _appData.setActiveCategory(null),
                      child: const Text(
                        'ดูทุกหมวดหมู่',
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Categories Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                ),
                itemBuilder: (context, index) {
                  final item = _categories[index];
                  final catTitle = item['title'] as String;
                  final isSelected = selectedCategory == catTitle;
                  final count = _appData.recipes.where((r) => r.category == catTitle).length;

                  return _buildMinimalCategoryCard(item, isSelected, count);
                },
              ),

              const SizedBox(height: 28),

              // Filtered Category Recipes Section Title
              if (selectedCategory != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'สูตรอาหารในหมวด $selectedCategory (${categoryRecipes.length})',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (categoryRecipes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('ยังไม่มีสูตรอาหารในหมวดหมู่นี้', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryRecipes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final recipe = categoryRecipes[index];
                      return _buildCategoryRecipeCard(recipe);
                    },
                  ),
              ],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'ชุมชน',
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalCategoryCard(Map<String, dynamic> item, bool isSelected, int count) {
    final Color itemColor = item['color'] as Color;
    final Color bgLight = item['bgLight'] as Color;
    final String catTitle = item['title'] as String;
    const primaryGreen = Color(0xFF207935);

    return InkWell(
      onTap: () => _selectCategory(catTitle),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? primaryGreen.withOpacity(0.08) : Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
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
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    catTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? primaryGreen : const Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count สูตร',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: itemColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRecipeCard(Recipe recipe) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(recipe: recipe),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 68,
                height: 68,
                child: Image.network(
                  recipe.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFF2F4F7),
                    alignment: Alignment.center,
                    child: Text(recipe.icon, style: const TextStyle(fontSize: 32)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${recipe.prepTime} | ความยาก: ${recipe.difficulty}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8C919E)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF8C919E)),
          ],
        ),
      ),
    );
  }
}
