import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../models/recipe.dart';
import 'categories.dart';
import 'detail.dart';
import 'favorites.dart';
import 'mealplanner.dart';
import 'community.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _ingredientController = TextEditingController();
  final AppData _appData = AppData();

  final List<String> _categoryFilterOptions = [
    'ทั้งหมด',
    'Quick Meal',
    'Breakfast',
    'Healthy',
    'Thai',
    'Soup',
    'Desserts',
    'International',
    'Vegetarian',
  ];

  @override
  void initState() {
    super.initState();
    _appData.addListener(_onAppDataChanged);
  }

  @override
  void dispose() {
    _appData.removeListener(_onAppDataChanged);
    _ingredientController.dispose();
    super.dispose();
  }

  void _onAppDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _addIngredient() {
    final text = _ingredientController.text.trim();
    if (text.isNotEmpty) {
      _appData.addIngredient(text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เพิ่มวัตถุดิบ "$text" และค้นหาสูตรอาหารที่เกี่ยวข้องแล้ว'),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF207935),
        ),
      );
      _ingredientController.clear();
    }
  }

  void _handleVoiceSearch() {
    _appData.addIngredient('ไข่');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ตรวจพบเสียง: "ไข่ไก่" - กำลังค้นหาสูตรอาหาร...'),
        backgroundColor: Color(0xFFF97906),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleCameraScan() {
    _appData.addIngredient('มะเขือเทศ');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('สแกนภาพสำเร็จ: ตรวจพบ "มะเขือเทศสด" - กำลังค้นหาสูตรอาหาร...'),
        backgroundColor: Color(0xFF039683),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const CategoriesScreen(),
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

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF207935);
    final recipesList = _appData.filteredRecipes;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'Recipe Finder',
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
              // Section Title: ใส่วัตถุดิบที่คุณมี
              const Text(
                'ใส่วัตถุดิบที่คุณมี',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 12),

              // Search Input Row
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ingredientController,
                        onSubmitted: (_) => _addIngredient(),
                        decoration: const InputDecoration(
                          hintText: 'เช่น ไข่, มะเขือเทศ, ข้าว',
                          hintStyle: TextStyle(
                            color: Color(0xFFA0A6B1),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ElevatedButton(
                        onPressed: _addIngredient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: const Text(
                          'ADD',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Active Ingredients Chips List
              if (_appData.userIngredients.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'วัตถุดิบของคุณ (${_appData.userIngredients.length}):',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryGreen),
                    ),
                    GestureDetector(
                      onTap: () => _appData.clearIngredients(),
                      child: const Text(
                        'ล้างทั้งหมด',
                        style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _appData.userIngredients.map((ing) {
                    return Chip(
                      backgroundColor: const Color(0xFFE8F5E9),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      label: Text(ing, style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                      deleteIcon: const Icon(Icons.close_rounded, size: 16, color: primaryGreen),
                      onDeleted: () => _appData.removeIngredient(ing),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Action Buttons Row: Voice Search & Scan (Redesigned with sleek style)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _handleVoiceSearch,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFF97906)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4DFF9800),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mic_rounded, size: 20, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'ค้นหาด้วยเสียง',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _handleCameraScan,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00BFA5), Color(0xFF039683)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4D00BFA5),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'สแกนวัตถุดิบ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category Quick Filter Bar
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categoryFilterOptions.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final catName = _categoryFilterOptions[index];
                    final isSelected = (catName == 'ทั้งหมด' && _appData.activeCategory == null) ||
                        (_appData.activeCategory == catName);

                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(
                        catName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : const Color(0xFF2D3142),
                        ),
                      ),
                      selectedColor: primaryGreen,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? primaryGreen : Colors.grey.shade300,
                        ),
                      ),
                      showCheckmark: false,
                      onSelected: (selected) {
                        if (catName == 'ทั้งหมด') {
                          _appData.setActiveCategory(null);
                        } else {
                          _appData.setActiveCategory(isSelected ? null : catName);
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Section Title: เมนูยอดนิยม / ผลการค้นหา
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _appData.userIngredients.isNotEmpty || _appData.activeCategory != null
                        ? 'ผลการค้นหา (${recipesList.length} เมนู)'
                        : 'เมนูยอดนิยม',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const CategoriesScreen()),
                      );
                    },
                    child: const Text(
                      'ดูหมวดหมู่ >',
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // List of Recipe Cards
              recipesList.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text(
                            'ไม่พบสูตรอาหารที่ตรงกับเงื่อนไขนี้',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'ลองเลือกหมวดหมู่อื่น หรือกดล้างการค้นหาเพื่อดูเมนูทั้งหมด',
                            style: TextStyle(fontSize: 12, color: Color(0xFF8C919E)),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              _appData.clearIngredients();
                              _appData.setActiveCategory(null);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('ดูเมนูทั้งหมด'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recipesList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final recipe = recipesList[index];
                        return _buildRecipeCard(recipe);
                      },
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
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'ชุมชน',
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Recipe Image Container
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 76,
                height: 76,
                child: Image.network(
                  recipe.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFF2F4F7),
                    alignment: Alignment.center,
                    child: Text(
                      recipe.icon,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: const Color(0xFFF2F4F7),
                      alignment: Alignment.center,
                      child: Text(recipe.icon, style: const TextStyle(fontSize: 36)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          recipe.category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF207935),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• ${recipe.difficulty}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF8C919E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Color(0xFF8C919E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.prepTime} (เตรียม) + ${recipe.cookTime} (ทำ)',
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

            // Heart / Favorite button
            IconButton(
              onPressed: () {
                _appData.toggleFavorite(recipe);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      recipe.isFavorite
                          ? 'เพิ่ม "${recipe.title}" ในรายการโปรดแล้ว'
                          : 'นำ "${recipe.title}" ออกจากรายการโปรด',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: Icon(
                recipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: recipe.isFavorite ? Colors.redAccent : const Color(0xFF8C919E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
