import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/app_data.dart';
import 'mealplanner.dart';
import 'community.dart';

class DetailScreen extends StatefulWidget {
  final Recipe? recipe;
  final String recipeTitle;
  final String prepTime;
  final String cookTime;
  final String difficulty;
  final String icon;

  const DetailScreen({
    super.key,
    this.recipe,
    this.recipeTitle = 'ไข่เจียวมะเขือเทศ',
    this.prepTime = '15 นาที',
    this.cookTime = '10 นาที',
    this.difficulty = 'ง่าย',
    this.icon = '🍳',
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final AppData _appData = AppData();

  late Recipe _currentRecipe;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _currentRecipe = widget.recipe!;
    } else {
      // Find or fallback to recipe
      final matches = _appData.recipes.where((r) => r.title == widget.recipeTitle);
      if (matches.isNotEmpty) {
        _currentRecipe = matches.first;
      } else {
        _currentRecipe = _appData.recipes.first;
      }
    }
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

  void _addToMealPlanner() {
    _appData.setMealForDay(15, 'กลางวัน', _currentRecipe);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เพิ่ม "${_currentRecipe.title}" ในแผนมื้ออาหารเรียบร้อยแล้ว!'),
        backgroundColor: const Color(0xFF207935),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'ดูแผน',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MealPlannerScreen()),
            );
          },
        ),
      ),
    );
  }

  void _shareToCommunity() {
    _appData.createCommunityPost(
      author: _appData.userName,
      title: _currentRecipe.title,
      description: _currentRecipe.description,
      icon: _currentRecipe.icon,
      imageUrl: _currentRecipe.imageUrl,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('แชร์ "${_currentRecipe.title}" ลงชุมชนเรียบร้อยแล้ว!'),
        backgroundColor: const Color(0xFF207935),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'ดูชุมชน',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CommunityScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF207935);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D3142)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Recipe Detail',
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF8C919E)),
            onPressed: _shareToCommunity,
          ),
          IconButton(
            icon: Icon(
              _currentRecipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _currentRecipe.isFavorite ? Colors.redAccent : const Color(0xFF8C919E),
            ),
            onPressed: () {
              _appData.toggleFavorite(_currentRecipe);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_currentRecipe.isFavorite ? 'เพิ่มในรายการโปรดแล้ว' : 'นำออกจากรายการโปรด'),
                  duration: const Duration(seconds: 1),
                ),
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
              // Food Header Banner Image / Container
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _currentRecipe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFFFF3E0),
                          child: Center(
                            child: Text(
                              _currentRecipe.icon,
                              style: const TextStyle(fontSize: 70),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Text(
                          _currentRecipe.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                _currentRecipe.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C727F),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Metadata Stat Cards (Prep Time, Cook Time, Difficulty)
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.timer_outlined,
                      value: _currentRecipe.prepTime,
                      label: 'เวลาเตรียม',
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.soup_kitchen_outlined,
                      value: _currentRecipe.cookTime,
                      label: 'เวลาทำ',
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.bar_chart_outlined,
                      value: _currentRecipe.difficulty,
                      label: 'ระดับความยาก',
                      color: const Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section 1: วัตถุดิบ (Ingredients)
              _buildSectionTile(
                title: 'วัตถุดิบ (Ingredients)',
                icon: Icons.shopping_basket_outlined,
                children: _currentRecipe.ingredients.map((ing) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: primaryGreen),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ing,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF2D3142)),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),

              // Section 2: อุปกรณ์ครัว (Cooking Tools)
              _buildSectionTile(
                title: 'อุปกรณ์ครัว (Cooking Tools)',
                icon: Icons.flatware_outlined,
                children: _currentRecipe.tools.map((tool) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Color(0xFFFF9800)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tool,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF2D3142)),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),

              // Section 3: ขั้นตอนการทำ (Steps)
              _buildSectionTile(
                title: 'ขั้นตอนการทำ (Steps)',
                icon: Icons.format_list_numbered_rounded,
                children: _currentRecipe.steps.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF2D3142), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),

              // Section 4: เทคนิคและเคล็ดลับ (Tips & Tricks)
              _buildSectionTile(
                title: 'เทคนิคและเคล็ดลับ (Tips & Tricks)',
                icon: Icons.lightbulb_outline,
                children: _currentRecipe.tips.map((tip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb, size: 18, color: Color(0xFFFFB300)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF2D3142), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),

              // Section 5: ข้อมูลโภชนาการ (Nutrition Info)
              _buildSectionTile(
                title: 'ข้อมูลโภชนาการ (Nutrition Info)',
                icon: Icons.pie_chart_outline,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: _currentRecipe.nutrition.entries.map((entry) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${entry.key}: ',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF8C919E)),
                          ),
                          Text(
                            entry.value,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Bottom Buttons Row (Add to Meal Planner & Share to Community)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _addToMealPlanner,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.calendar_month_rounded, size: 18),
                        label: const Text(
                          'เพิ่มในแผนมื้ออาหาร',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _shareToCommunity,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryGreen,
                        side: const BorderSide(color: primaryGreen, width: 1.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.people_alt_rounded, size: 18),
                      label: const Text(
                        'แชร์ลงชุมชน',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8C919E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTile({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(icon, color: const Color(0xFF207935)),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
