import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../models/recipe.dart';
import 'home.dart';
import 'categories.dart';
import 'detail.dart';
import 'mealplanner.dart';
import 'community.dart';
import 'profile.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _currentIndex = 2; // "รายการโปรด" tab selected
  final AppData _appData = AppData();

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
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const CategoriesScreen(),
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

  void _removeFavorite(Recipe recipe) {
    _appData.toggleFavorite(recipe);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('นำ "${recipe.title}" ออกจากรายการโปรดแล้ว'),
        action: SnackBarAction(
          label: 'เลิกทำ',
          textColor: Colors.yellowAccent,
          onPressed: () {
            _appData.toggleFavorite(recipe);
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF207935);
    final favList = _appData.favoriteRecipes;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'Favorites',
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'รายการโปรดของคุณ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  Text(
                    '${favList.length} เมนู',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8C919E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              favList.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border_rounded,
                              size: 70,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'ยังไม่มีรายการโปรด',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF8C919E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'กดไอคอนหัวใจเพื่อบันทึกเมนูที่คุณชอบ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFA0A6B1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.separated(
                        itemCount: favList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final recipe = favList[index];
                          return _buildFavoriteCard(recipe);
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
            icon: Icon(Icons.favorite_rounded),
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

  Widget _buildFavoriteCard(Recipe recipe) {
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
            // Recipe Image / Icon Container
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
                    child: Text(
                      recipe.icon,
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: Color(0xFF8C919E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.prepTime} | ${recipe.difficulty}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8C919E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Red Heart / Remove favorite button
            IconButton(
              onPressed: () => _removeFavorite(recipe),
              icon: const Icon(
                Icons.favorite_rounded,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
