class Recipe {
  final String id;
  final String title;
  final String description;
  final String prepTime;
  final String cookTime;
  final String difficulty;
  final String icon;
  final String imageUrl;
  final String category;
  final List<String> ingredients;
  final List<String> tools;
  final List<String> steps;
  final List<String> tips;
  final Map<String, String> nutrition;
  bool isFavorite;
  final String author;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.prepTime,
    required this.cookTime,
    required this.difficulty,
    required this.icon,
    required this.imageUrl,
    required this.category,
    required this.ingredients,
    required this.tools,
    required this.steps,
    required this.tips,
    required this.nutrition,
    this.isFavorite = false,
    this.author = 'Chef Recipe Finder',
  });
}

class CommunityPost {
  final String id;
  final String author;
  final String timeAgo;
  final String title;
  final String description;
  final String icon;
  final String imageUrl;
  int likes;
  int commentsCount;
  List<String> comments;
  bool isLiked;
  final Recipe? linkedRecipe;

  CommunityPost({
    required this.id,
    required this.author,
    required this.timeAgo,
    required this.title,
    required this.description,
    required this.icon,
    required this.imageUrl,
    this.likes = 0,
    this.commentsCount = 0,
    required this.comments,
    this.isLiked = false,
    this.linkedRecipe,
  });
}
