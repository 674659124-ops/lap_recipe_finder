import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../models/recipe.dart';
import 'home.dart';
import 'categories.dart';
import 'favorites.dart';
import 'detail.dart';
import 'community.dart';
import 'profile.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  static const primaryGreen = Color(0xFF207935);
  final AppData _appData = AppData();

  int _currentIndex = 3; // "วางแผนมื้ออาหาร" tab selected
  DateTime _selectedDate = DateTime(2024, 5, 15);

  final List<String> _weekDays = ['อา.', 'จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.'];

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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const FavoritesScreen(),
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

  void _generateShoppingList() {
    final ingredientsList = _appData.generateShoppingListForDay(_selectedDate.day);
    final Map<String, bool> checkedMap = {
      for (var item in ingredientsList) item: false
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, color: primaryGreen),
                  SizedBox(width: 10),
                  Text('รายการซื้อของ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'วัตถุดิบทั้งหมดสำหรับมื้ออาหารวันที่ ${_selectedDate.day} พฤษภาคม ${_selectedDate.year}:',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    width: double.maxFinite,
                    child: checkedMap.isEmpty
                        ? const Center(child: Text('ไม่มีรายการมื้ออาหาร'))
                        : ListView(
                            shrinkWrap: true,
                            children: checkedMap.keys.map((item) {
                              final isChecked = checkedMap[item] ?? false;
                              return CheckboxListTile(
                                activeColor: primaryGreen,
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  item,
                                  style: TextStyle(
                                    decoration: isChecked ? TextDecoration.lineThrough : null,
                                    color: isChecked ? Colors.grey : const Color(0xFF2D3142),
                                  ),
                                ),
                                value: isChecked,
                                onChanged: (val) {
                                  setDialogState(() {
                                    checkedMap[item] = val ?? false;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('คัดลอกรายการซื้อของแล้ว')),
                    );
                  },
                  child: const Text('คัดลอกรายการ', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('บันทึกรายการซื้อของเรียบร้อยแล้ว'),
                        backgroundColor: primaryGreen,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('ตกลง', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editMeal(String mealTime) {
    Recipe selectedRecipe = _appData.getMealsForDay(_selectedDate.day)[mealTime] ?? _appData.recipes.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('เลือกเมนูปรับเปลี่ยนมื้อ$mealTime', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SizedBox(
                height: 250,
                width: double.maxFinite,
                child: ListView.separated(
                  itemCount: _appData.recipes.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final recipe = _appData.recipes[index];
                    final isChosen = recipe.id == selectedRecipe.id;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: Text(recipe.icon, style: const TextStyle(fontSize: 24)),
                      title: Text(recipe.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text('${recipe.prepTime} | ${recipe.difficulty}', style: const TextStyle(fontSize: 12)),
                      trailing: isChosen ? const Icon(Icons.check_circle_rounded, color: primaryGreen) : null,
                      onTap: () {
                        setDialogState(() {
                          selectedRecipe = recipe;
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    _appData.setMealForDay(_selectedDate.day, mealTime, selectedRecipe);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('เปลี่ยนมื้อ$mealTime เป็น "${selectedRecipe.title}" เรียบร้อยแล้ว'),
                        backgroundColor: primaryGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('บันทึก'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayMeals = _appData.getMealsForDay(_selectedDate.day);

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
                          onPressed: () {
                            setState(() {
                              _selectedDate = DateTime(2024, 5, _selectedDate.day > 1 ? _selectedDate.day - 1 : 1);
                            });
                          },
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
                          onPressed: () {
                            setState(() {
                              _selectedDate = DateTime(2024, 5, _selectedDate.day < 31 ? _selectedDate.day + 1 : 31);
                            });
                          },
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
                    // Mini Calendar Grid
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
              if (dayMeals.containsKey('เช้า')) _buildMealSection('เช้า', dayMeals['เช้า']!),
              const SizedBox(height: 12),
              if (dayMeals.containsKey('กลางวัน')) _buildMealSection('กลางวัน', dayMeals['กลางวัน']!),
              const SizedBox(height: 12),
              if (dayMeals.containsKey('เย็น')) _buildMealSection('เย็น', dayMeals['เย็น']!),

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
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'ชุมชน',
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
              final isCurrentMonth = !((row == days.first && day > 20) || (row == days.last && day < 10));

              return GestureDetector(
                onTap: () {
                  if (isCurrentMonth) {
                    setState(() {
                      _selectedDate = DateTime(2024, 5, day);
                    });
                  }
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
                          : !isCurrentMonth
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

  Widget _buildMealSection(String mealTime, Recipe recipe) {
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
                    color: primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Food Icon / Thumbnail
          Text(
            recipe.icon,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          // Meal Details
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(recipe: recipe),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
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
                        '${recipe.prepTime} | ${recipe.difficulty}',
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
          ),
          // Edit or View Details
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF8C919E)),
            onPressed: () => _editMeal(mealTime),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF8C919E)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(recipe: recipe),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
