import 'package:flutter/material.dart';
import 'home.dart';
import 'categories.dart';
import 'favorites.dart';
import 'detail.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  static const primaryGreen = Color(0xFF207935);

  int _currentIndex = 3; // "วางแผนมื้ออาหาร" tab selected
  DateTime _selectedDate = DateTime(2024, 5, 15);

  final List<String> _weekDays = ['อา.', 'จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.'];

  final Map<String, Map<String, String>> _meals = {
    'เช้า': {
      'title': 'สมูทตี้กล้วย',
      'time': '5 นาที',
      'icon': '🥤',
    },
    'กลางวัน': {
      'title': 'ข้าวผัดไข่',
      'time': '15 นาที',
      'icon': '🍚',
    },
    'เย็น': {
      'title': 'ต้มจืดไข่น้ำ',
      'time': '20 นาที',
      'icon': '🍲',
    },
  };

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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const FavoritesScreen(),
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

  void _generateShoppingList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.shopping_bag_outlined, color: primaryGreen),
            SizedBox(width: 10),
            Text('รายการซื้อของ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('รายการวัตถุดิบสำหรับมื้ออาหารวันนี้:', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 12),
            Text('• ไข่ไก่ 4 ฟอง'),
            SizedBox(height: 4),
            Text('• มะเขือเทศ 2 ลูก'),
            SizedBox(height: 4),
            Text('• กล้วยหอม 2 ลูก'),
            SizedBox(height: 4),
            Text('• ข้าวสวย 1 จาน'),
            SizedBox(height: 4),
            Text('• นมสด 200 ml'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'Meal Planner',
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar Card
              Container(
                padding: const EdgeInsets.all(16),
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
                  children: [
                    // Month Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF2D3142)),
                          onPressed: () {},
                        ),
                        const Text(
                          'พฤษภาคม 2024',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF2D3142)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Weekday headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _weekDays
                          .map((day) => SizedBox(
                                width: 36,
                                child: Text(
                                  day,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8C919E),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    // Mini Calendar Grid sample
                    _buildCalendarGrid(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Title: เมนูประจำวันที่ 15 พฤษภาคม 2024
              Text(
                'เมนูประจำวันที่ ${_selectedDate.day} พฤษภาคม ${_selectedDate.year}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 16),

              // Meals List (เช้า, กลางวัน, เย็น)
              _buildMealSection('เช้า', _meals['เช้า']!),
              const SizedBox(height: 12),
              _buildMealSection('กลางวัน', _meals['กลางวัน']!),
              const SizedBox(height: 12),
              _buildMealSection('เย็น', _meals['เย็น']!),

              const SizedBox(height: 28),

              // Action Button: สร้างรายการซื้อของ
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _generateShoppingList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: const Text(
                    'สร้างรายการซื้อของ (Generate Shopping List)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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

  Widget _buildCalendarGrid() {
    final days = [
      [28, 29, 30, 1, 2, 3, 4],
      [5, 6, 7, 8, 9, 10, 11],
      [12, 13, 14, 15, 16, 17, 18],
      [19, 20, 21, 22, 23, 24, 25],
      [26, 27, 28, 29, 30, 31, 1],
    ];

    return Column(
      children: days.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: row.map((day) {
              final isSelected = (day == _selectedDate.day);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = DateTime(2024, 5, day);
                  });
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryGreen : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : (day > 25 && row == days.first) || (day < 10 && row == days.last)
                              ? Colors.grey.shade400
                              : const Color(0xFF2D3142),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMealSection(String mealTime, Map<String, String> recipe) {
    return Container(
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
          // Meal time badge
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mealTime == 'เช้า'
                      ? '🌅'
                      : mealTime == 'กลางวัน'
                          ? '☀️'
                          : '🌙',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  mealTime,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF207935),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Food Icon / Thumbnail
          Text(
            recipe['icon'] ?? '🍽️',
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          // Meal Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
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
                      recipe['time'] ?? '',
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
          // Tap to view details / edit
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF8C919E)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    recipeTitle: recipe['title'] ?? 'เมนูอาหาร',
                    prepTime: recipe['time'] ?? '15 นาที',
                    cookTime: '10 นาที',
                    difficulty: 'ง่าย',
                    icon: recipe['icon'] ?? '🍳',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
