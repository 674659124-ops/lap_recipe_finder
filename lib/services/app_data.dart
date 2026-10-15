import 'package:flutter/material.dart';
import '../models/recipe.dart';

class AppData extends ChangeNotifier {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal() {
    _initInitialData();
  }

  // User State
  String userName = 'Natcha Cook';
  String userEmail = 'natcha.cook@email.com';
  bool isLoggedIn = true;

  // Added ingredients in Home Screen
  final List<String> userIngredients = [];

  // Active Category Filter for Categories Screen (null means All)
  String? activeCategory;

  // All Recipes in App
  final List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

  // Community Posts
  final List<CommunityPost> _communityPosts = [];
  List<CommunityPost> get communityPosts => _communityPosts;

  // Meal Plan Map: "day" -> { "เช้า": Recipe, "กลางวัน": Recipe, "เย็น": Recipe }
  final Map<String, Map<String, Recipe>> _mealPlan = {};

  void _initInitialData() {
    // 1. ข้าวผัดไข่ (Quick Meal, Thai, Breakfast)
    final eggFriedRice = Recipe(
      id: 'r1',
      title: 'ข้าวผัดไข่',
      description: 'ข้าวผัดไข่หอมกลิ่นกระทะ ข้าวเป็นเม็ดสวย นุ่มอร่อยทำง่ายภายใน 15 นาที',
      prepTime: '5 นาที',
      cookTime: '10 นาที',
      difficulty: 'ง่าย',
      icon: '🍚',
      imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=800',
      category: 'Quick Meal',
      ingredients: [
        'ข้าวสวยเย็น 1 จาน',
        'ไข่ไก่ 2 ฟอง',
        'กระเทียมสับ 1 ช้อนโต๊ะ',
        'ซอสปรุงรส 1 ช้อนโต๊ะ',
        'ซีอิ๊วขาว 1 ช้อนชา',
        'น้ำตาลทราย 1/2 ช้อนชา',
        'ต้นหอมซอย 1 ต้น',
        'น้ำมันพืช 2 ช้อนโต๊ะ',
      ],
      tools: ['กระทะผัด', 'ตะหลิว', 'จานเสิร์ฟ'],
      steps: [
        'ตั้งกระทะใส่น้ำมันพืช ใช้ไฟปานกลาง ใส่กระเทียมสับลงไปเจียวจนหอมเหลือง',
        'ตอกไข่ไก่ลงในกระทะ ยีพอแตก ยีให้ไข่เริ่มเซ็ตตัวแล้วใส่ข้าวสวยลงไป',
        'เร่งไฟแรงขึ้น ผัดข้าวกับไข่ให้เข้ากันจนเมล็ดข้าวแห้งและหอมกลิ่นกระทะ',
        'ปรุงรสด้วยซอสปรุงรส ซีอิ๊วขาว และน้ำตาลทราย ผัดให้เข้ากันดี',
        'ใส่ต้นหอมซอยลงไป ผัดเร็วๆ อีกครั้งแล้วตักใส่จาน พร้อมเสิร์ฟ',
      ],
      tips: ['ใช้ข้าวสวยที่แช่เย็นข้ามคืน จะช่วยให้ข้าวผัดเรียงเม็ดสวย ไม่แฉะ'],
      nutrition: {
        'พลังงาน': '380 kcal',
        'โปรตีน': '12 g',
        'ไขมัน': '14 g',
        'คาร์โบไฮเดรต': '52 g',
      },
      isFavorite: true,
    );

    // 2. ไข่เจียวมะเขือเทศ (Breakfast, Quick Meal)
    final tomatoOmelette = Recipe(
      id: 'r2',
      title: 'ไข่เจียวมะเขือเทศ',
      description: 'ไข่เจียวนุ่มฟู แทรกความชุ่มฉ่ำของมะเขือเทศสด อร่อยกลมกล่อมทำง่ายมาก',
      prepTime: '5 นาที',
      cookTime: '10 นาที',
      difficulty: 'ง่าย',
      icon: '🍳',
      imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=800',
      category: 'Breakfast',
      ingredients: [
        'ไข่ไก่ 2 ฟอง',
        'มะเขือเทศ 1 ลูก (หั่นเต๋าเล็ก)',
        'หอมใหญ่หั่นเต๋า 2 ช้อนโต๊ะ',
        'น้ำปลา 1 ช้อนชา',
        'ซอยหอยนางรม 1 ช้อนชา',
        'น้ำมันพืชสำหรับทอด',
      ],
      tools: ['ชามผสม', 'ส้อม', 'กระทะทอด', 'ตะหลิว'],
      steps: [
        'ตอกไข่ใส่ชาม ปรุงรสด้วยน้ำปลาและซอยหอยนางรม ตีไข่ให้เข้ากันฟู',
        'ใส่มะเขือเทศหั่นเต๋าและหอมใหญ่ลงในชามไข่ คนให้เข้ากัน',
        'ตั้งกระทะใส่น้ำมัน รอจนน้ำมันร้อนปานกลาง',
        'เทไข่ลงไปในกระทะ ทอดจนด้านล่างสุกเหลืองกรอบ แล้วกลับด้าน',
        'ทอดต่อจนสุกทั้งสองด้าน ตักขึ้นพักสะเด็ดน้ำมัน พร้อมเสิร์ฟ',
      ],
      tips: ['บีบน้ำมะนาว 2-3 หยดลงในไข่ขณะตี ช่วยให้ไข่เจียวนุ่มฟูยิ่งขึ้น'],
      nutrition: {
        'พลังงาน': '220 kcal',
        'โปรตีน': '11 g',
        'ไขมัน': '17 g',
        'คาร์โบไฮเดรต': '5 g',
      },
      isFavorite: true,
    );

    // 3. สมูทตี้กล้วย (Healthy, Breakfast, Desserts)
    final bananaSmoothie = Recipe(
      id: 'r3',
      title: 'สมูทตี้กล้วย',
      description: 'เครื่องดื่มสุขภาพหอมหวานนุ่มลิ้นจากกล้วยหอมและนมสด เพิ่มพลังงานยามเช้า',
      prepTime: '3 นาที',
      cookTime: '2 นาที',
      difficulty: 'ง่าย',
      icon: '🥤',
      imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=800',
      category: 'Healthy',
      ingredients: [
        'กล้วยหอมแช่เย็น 2 ลูก',
        'นมสดรสจืด 200 ml',
        'โยเกิร์ตรสธรรมชาติ 1/2 ถ้วย',
        'น้ำผึ้ง 1 ช้อนโต๊ะ',
        'น้ำแข็ง 1 ถ้วย',
      ],
      tools: ['เครื่องปั่นน้ำผลไม้', 'แก้วทรงสูง'],
      steps: [
        'หั่นกล้วยหอมเป็นชิ้นเล็กๆ เพื่อให้ปั่นง่าย',
        'ใส่กล้วย นมสด โยเกิร์ต น้ำผึ้ง และน้ำแข็งลงในเครื่องปั่น',
        'ปั่นด้วยความเร็วสูงจนเนื้อเนียนละเอียดเป็นเนื้อเดียวกัน',
        'เทใส่แก้ว พร้อมดื่มสดชื่นทันที',
      ],
      tips: ['หากใช้กล้วยหอมสุกงอม จะได้ความหวานตามธรรมชาติโดยไม่ต้องเติมน้ำตาลเพิ่ม'],
      nutrition: {
        'พลังงาน': '190 kcal',
        'โปรตีน': '6 g',
        'ไขมัน': '3 g',
        'คาร์โบไฮเดรต': '38 g',
      },
      isFavorite: true,
    );

    // 4. ต้มจืดไข่น้ำ (Soup, Thai)
    final eggSoup = Recipe(
      id: 'r4',
      title: 'ต้มจืดไข่น้ำ',
      description: 'ซุปร้อนๆ รสชาติกลมกล่อม ซดคล่องคอ มีทั้งไข่นุ่มๆ และหมูสับหมักรสเด็ด',
      prepTime: '8 นาที',
      cookTime: '12 นาที',
      difficulty: 'ง่าย',
      icon: '🥣',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=800',
      category: 'Soup',
      ingredients: [
        'ไข่ไก่ 2 ฟอง',
        'หมูสับ 100 กรัม',
        'ผักกาดขาว 150 กรัม',
        'ซุปก้อน 1 ก้อน',
        'ซีอิ๊วขาว 1.5 ช้อนโต๊ะ',
        'น้ำสะอาด 3 ถ้วย',
        'กระเทียมเจียว & ต้นหอมขึ้นฉ่าย',
      ],
      tools: ['หม้อต้ม', 'กระทะทอดไข่', 'ทัพพี'],
      steps: [
        'เจียวไข่ไก่ในกระทะจนสุก หั่นเป็นชิ้นพอดีคำ พักไว้',
        'ตั้งหม้อใส่น้ำสะอาดและซุปก้อน รอจนน้ำเดือด',
        'ปั้นหมูสับเป็นก้อนลงไปต้มจนหมูสุก',
        'ใส่ผักกาดขาวและปรุงรสด้วยซีอิ๊วขาว ต้มจนผักนุ่ม',
        'ใส่ไข่เจียวที่หั่นไว้ลงไป โรยต้นหอมขึ้นฉ่ายและกระเทียมเจียว ปิดไฟเสิร์ฟ',
      ],
      tips: ['ทอดไข่เจียวให้กรอบนิดๆ ก่อนนำลงต้มจืด จะทำให้น้ำซุปหอมหวานยิ่งขึ้น'],
      nutrition: {
        'พลังงาน': '240 kcal',
        'โปรตีน': '18 g',
        'ไขมัน': '15 g',
        'คาร์โบไฮเดรต': '8 g',
      },
      isFavorite: true,
    );

    // 5. ผัดกะเพราหมูสับ (Thai, Quick Meal)
    final padKrapow = Recipe(
      id: 'r5',
      title: 'ผัดกะเพราหมูสับ',
      description: 'เมนูยอดฮิตตลอดกาล รสจัดจ้าน หอมกลิ่นใบกะเพราแท้ รสชาติเข้มข้นอร่อยเด็ด',
      prepTime: '5 นาที',
      cookTime: '8 นาที',
      difficulty: 'ง่าย',
      icon: '🍲',
      imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800',
      category: 'Thai',
      ingredients: [
        'หมูสับ 200 กรัม',
        'ใบกะเพราสด 1 กำ',
        'พริกขี้หนู & กระเทียมตำละเอียด 2 ช้อนโต๊ะ',
        'น้ำมันหอย 1 ช้อนโต๊ะ',
        'น้ำปลา 1 ช้อนโต๊ะ',
        'ซีอิ๊วดำหวาน 1/2 ช้อนชา',
        'น้ำตาลทราย 1/2 ช้อนชา',
      ],
      tools: ['กระทะ', 'ตะหลิว'],
      steps: [
        'ตั้งกระทะใส่น้ำมัน นำพริกและกระเทียมตำลงไปผัดจนหอมฉุน',
        'ใส่หมูสับลงไปผัด ยีให้หมูสับกระจายตัวจนเริ่มสุก',
        'ปรุงรสด้วยน้ำมันหอย น้ำปลา ซีอิ๊วดำ และน้ำตาลทราย ผัดเร่งไฟแรง',
        'ใส่ใบกะเพราลงไป ผัดเร็วๆ 2-3 ทีแล้วปิดไฟ ตักราดข้าวสวยร้อนๆ',
      ],
      tips: ['ใช้ไฟแรงในขั้นตอนสุดท้าย จะทำให้ใบกะเพราหอมและสีสวยไม่ดำ'],
      nutrition: {
        'พลังงาน': '350 kcal',
        'โปรตีน': '24 g',
        'ไขมัน': '22 g',
        'คาร์โบไฮเดรต': '6 g',
      },
      isFavorite: false,
    );

    // 6. สลัดอกไก่ย่าง (Healthy, Quick Meal)
    final chickenSalad = Recipe(
      id: 'r6',
      title: 'สลัดอกไก่ย่าง',
      description: 'สลัดเพื่อสุขภาพ อกไก่นุ่มๆ ย่างหอมๆ พร้อมผักสดกรอบ ได้โปรตีนสูง คลีนอร่อย',
      prepTime: '10 นาที',
      cookTime: '10 นาที',
      difficulty: 'ปานกลาง',
      icon: '🥗',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
      category: 'Healthy',
      ingredients: [
        'อกไก่ 1 ชิ้น (150 กรัม)',
        'ผักสลัดคอส & ร็อกเก็ต 100 กรัม',
        'มะเขือเทศราชินี 6 ลูก',
        'แตงกวาญี่ปุ่นหั่นแว่น 1/2 ลูก',
        'น้ำสลัดงาญี่ปุ่น 2 ช้อนโต๊ะ',
        'เกลือ & พริกไทยดำบด',
      ],
      tools: ['กระทะย่างไร้น้ำมัน', 'จานสลัด'],
      steps: [
        'หมักอกไก่ด้วยเกลือและพริกไทยดำ พักไว้ 5 นาที',
        'นำอกไก่ลงย่างบนกระทะไฟปานกลางจนสุกทั่วทั้งสองด้าน (ประมาณ 8-10 นาที)',
        'นำอกไก่ขึ้นมาพักไว้ 2 นาทีแล้วหั่นเป็นชิ้นพอดีคำ',
        'จัดผักสลัด มะเขือเทศ แตงกวา ใส่จาน วางอกไก่ย่างไว้ด้านบน',
        'ราดด้วยน้ำสลัดงาญี่ปุ่น พร้อมทาน',
      ],
      tips: ['พักอกไก่หลังย่างเสร็จก่อนหั่น จะช่วยให้น้ำในเนื้อไก่ไม่ไหลออก ไก่จะนุ่มฉ่ำ'],
      nutrition: {
        'พลังงาน': '280 kcal',
        'โปรตีน': '32 g',
        'ไขมัน': '10 g',
        'คาร์โบไฮเดรต': '12 g',
      },
      isFavorite: false,
    );

    // 7. เค้กช็อกโกแลตหน้านุ่ม (Desserts)
    final chocolateCake = Recipe(
      id: 'r7',
      title: 'เค้กช็อกโกแลตหน้านุ่ม',
      description: 'เค้กช็อกโกแลตเนื้อนุ่มชุ่มฉ่ำ เคลือบด้วยหน้านุ่มรสช็อกโกแลตเข้มข้น หวานกำลังดี',
      prepTime: '20 นาที',
      cookTime: '30 นาที',
      difficulty: 'ปานกลาง',
      icon: '🎂',
      imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800',
      category: 'Desserts',
      ingredients: [
        'แป้งเค้ก 100 กรัม',
        'ผงโกโก้ 30 กรัม',
        'ไข่ไก่ 2 ฟอง',
        'น้ำตาลทราย 90 กรัม',
        'นมสด 60 ml',
        'เนยละลาย 40 กรัม',
        'ผงฟู 1 ช้อนชา',
      ],
      tools: ['เตาอบ', 'พิมพ์เค้ก', 'ตะกร้อมือ'],
      steps: [
        'ร่อนแป้งเค้ก ผงโกโก้ และผงฟูเข้าด้วยกัน',
        'ตีไข่ไก่กับน้ำตาลทรายจนฟูเป็นสีเหลืองนวล',
        'ใส่นมสด เนยละลาย และส่วนผสมแป้งที่ร่อนไว้ คนเบาๆ ให้เข้ากัน',
        'เทใส่พิมพ์ นำเข้าเตาอบที่อุณหภูมิ 175°C เป็นเวลา 25-30 นาที',
        'พักเค้กให้เย็น ราดด้วยซอสช็อกโกแลตหน้านุ่ม พร้อมตัดเสิร์ฟ',
      ],
      tips: ['ใช้นมสดอุ่นและผงโกโก้คุณภาพดี จะช่วยให้สีเค้กสวยและรสชาติเข้มข้นขึ้น'],
      nutrition: {
        'พลังงาน': '310 kcal',
        'โปรตีน': '6 g',
        'ไขมัน': '14 g',
        'คาร์โบไฮเดรต': '42 g',
      },
      isFavorite: false,
    );

    // 8. วาฟเฟิลผลไม้รวม (Desserts, Breakfast)
    final waffle = Recipe(
      id: 'r8',
      title: 'วาฟเฟิลผลไม้รวม',
      description: 'วาฟเฟิลกรอบนอกนุ่มใน หอมเนยนม ทานคู่กับสตรอว์เบอร์รี กล้วยหอม และน้ำผึ้ง',
      prepTime: '10 นาที',
      cookTime: '10 นาที',
      difficulty: 'ง่าย',
      icon: '🧇',
      imageUrl: 'https://images.unsplash.com/photo-1562376552-0d160a2f238d?w=800',
      category: 'Desserts',
      ingredients: [
        'แป้งวาฟเฟิลสำเร็จรูป 150 กรัม',
        'ไข่ไก่ 1 ฟอง',
        'นมสด 120 ml',
        'เนยสดละลาย 30 กรัม',
        'สตรอว์เบอร์รี & กล้วยหอมหั่นแว่น',
        'น้ำผึ้ง หรือ ไซรัป',
      ],
      tools: ['เครื่องทำวาฟเฟิล', 'ตะกร้อมือ'],
      steps: [
        'ผสมแป้งวาฟเฟิล ไข่ไก่ นมสด และเนยละลาย คนให้เนียนเข้ากัน',
        'วอร์มเครื่องทำวาฟเฟิล ทาเนยบางๆ บนเตา',
        'เทแป้งลงในเตา ปิดฝาอบประมาณ 4-5 นาทีจนกรอบเหลืองสวย',
        'ตักวาฟเฟิลใส่จาน ตกแต่งด้วยสตรอว์เบอร์รี กล้วยหอม และราดน้ำผึ้ง',
      ],
      tips: ['ทาเนยบนเตาวาฟเฟิลก่อนเทแป้ง จะทำให้ผิววาฟเฟิลกรอบหอมยิ่งขึ้น'],
      nutrition: {
        'พลังงาน': '290 kcal',
        'โปรตีน': '7 g',
        'ไขมัน': '11 g',
        'คาร์โบไฮเดรต': '40 g',
      },
      isFavorite: false,
    );

    // 9. สปาเก็ตตี้คาโบนารา (International)
    final carbonara = Recipe(
      id: 'r9',
      title: 'สปาเก็ตตี้คาโบนารา',
      description: 'สปาเก็ตตี้คาโบนาราสูตรดั้งเดิม ครีมมี่หอมมันจากไข่แดงและพาร์เมซานชีสแท้',
      prepTime: '10 นาที',
      cookTime: '15 นาที',
      difficulty: 'ปานกลาง',
      icon: '🍝',
      imageUrl: 'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=800',
      category: 'International',
      ingredients: [
        'เส้นสปาเก็ตตี้ 100 กรัม',
        'เบคอน หรือ คอนแชลเล่ 60 กรัม',
        'ไข่ไก่ (เฉพาะไข่แดง) 2 ฟอง',
        'พาร์เมซานชีสขูด 40 กรัม',
        'พริกไทยดำบดใหม่ 1 ช้อนชา',
        'เกลือสำหรับต้มเส้น',
      ],
      tools: ['หม้อต้มเส้น', 'กระทะทอดเบคอน', 'ชามผสมซอส'],
      steps: [
        'ต้มเส้นสปาเก็ตตี้ในน้ำเดือดใส่เกลือ นานประมาณ 8-9 นาทีจนได้ระดับ Al Dente',
        'ผสมไข่แดงกับพาร์เมซานชีสขูดและพริกไทยดำบด คนให้เข้ากัน',
        'ทอดเบคอนในกระทะจนกรอบและมีน้ำมันเบคอนออกมา',
        'ใส่เส้นสปาเก็ตตี้ร้อนๆ ลงในกระทะเบคอน ปิดไฟ แล้วเทส่วนผสมไข่ชีสลงไปคลุกเร็วๆ',
        'ใส่น้ำต้มเส้นเล็กน้อยเพื่อให้ซอสเนียนนุ่ม ตักใส่จานโรยพริกไทยเสิร์ฟ',
      ],
      tips: ['อย่าคลุกซอสขณะกระทะร้อนจัด เพราะไข่จะสุกเป็นก้อน ให้ปิดไฟก่อนคลุกซอส'],
      nutrition: {
        'พลังงาน': '450 kcal',
        'โปรตีน': '18 g',
        'ไขมัน': '24 g',
        'คาร์โบไฮเดรต': '42 g',
      },
      isFavorite: true,
    );

    // 10. ต้มยำกุ้งน้ำข้น (Thai, Soup)
    final tomYum = Recipe(
      id: 'r10',
      title: 'ต้มยำกุ้งน้ำข้น',
      description: 'ต้มยำกุ้งน้ำข้นรสจัดจ้าน เปรี้ยว เผ็ด หอมกลิ่นสมุนไพร ข่า ตะไคร้ ใบมะกรูด',
      prepTime: '12 นาที',
      cookTime: '10 นาที',
      difficulty: 'ปานกลาง',
      icon: '🍲',
      imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800',
      category: 'Thai',
      ingredients: [
        'กุ้งแม่น้ำสด 4 ตัว',
        'เห็ดฟาง 100 กรัม',
        'ข่าหั่นแว่น ตะไคร้ทุบ ใบมะกรูด',
        'พริกขี้หนูสวนทุบ 10 เม็ด',
        'น้ำพริกเผา 1.5 ช้อนโต๊ะ',
        'นมข้นจืด 3 ช้อนโต๊ะ',
        'น้ำปลา 2 ช้อนโต๊ะ',
        'น้ำมะนาวสด 2.5 ช้อนโต๊ะ',
      ],
      tools: ['หม้อต้ม', 'ทัพพี'],
      steps: [
        'ตั้งหม้อใส่น้ำต้มจนเดือด ใส่ข่า ตะไคร้ ใบมะกรูด ลงไปต้มจนหอมสมุนไพร',
        'ใส่เห็ดฟางและกุ้งแม่น้ำสดลงไป ต้มจนกุ้งเริ่มสุกเปลี่ยนเป็นสีส้ม',
        'ใส่น้ำพริกเผา นมข้นจืด และน้ำปลา คนให้เข้ากันจนน้ำซุปกลายเป็นสีส้มสวยงาม',
        'ปิดไฟ จากนั้นใส่น้ำมะนาวสดและพริกขี้หนูทุบ คนให้เข้ากัน ตักใส่ชามเสิร์ฟ',
      ],
      tips: ['ใส่น้ำมะนาวหลังจากปิดไฟแล้ว เพื่อไม่ให้น้ำมะนาวขม'],
      nutrition: {
        'พลังงาน': '260 kcal',
        'โปรตีน': '22 g',
        'ไขมัน': '12 g',
        'คาร์โบไฮเดรต': '16 g',
      },
      isFavorite: false,
    );

    // 11. ผัดผักรวมมิตร (Vegetarian, Healthy, Quick Meal)
    final stirVeggie = Recipe(
      id: 'r11',
      title: 'ผัดผักรวมมิตร',
      description: 'ผัดผักสดกรอบเพื่อสุขภาพ อุดมด้วยวิตามิน ทำง่ายภายใน 8 นาที',
      prepTime: '5 นาที',
      cookTime: '5 นาที',
      difficulty: 'ง่าย',
      icon: '🥦',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800',
      category: 'Vegetarian',
      ingredients: [
        'บล็อกโคลี & บร็อกโคลี่ 100 กรัม',
        'แครอทหั่นแว่น 50 กรัม',
        'เห็ดหอมสด 4 ดอก',
        'กระเทียมสับ 1 ช้อนชา',
        'ซอสเทอริยากิ / ซีอิ๊วขาวมังสวิรัติ 1.5 ช้อนโต๊ะ',
        'น้ำมันพืช 1 ช้อนโต๊ะ',
      ],
      tools: ['กระทะผัด', 'ตะหลิว'],
      steps: [
        'ลวกบล็อกโคลีและแครอทในน้ำเดือด 1 นาทีแล้วตักน็อคน้ำเย็น เพื่อให้ผักกรอบสีสวย',
        'ตั้งกระทะใส่น้ำมัน เจียวกระเทียมสับจนหอม',
        'ใส่เห็ดหอมและผักลวกลงไปผัดด้วยไฟแรง',
        'ปรุงรสด้วยซีอิ๊วขาว ผัดเร็วๆ 1 นาทีแล้วปิดไฟ ตักใส่จาน',
      ],
      tips: ['น็อคผักในน้ำเย็นจัดหลังลวก จะช่วยรักษาความสดกรอบและสีเขียวสดของผัก'],
      nutrition: {
        'พลังงาน': '140 kcal',
        'โปรตีน': '4 g',
        'ไขมัน': '6 g',
        'คาร์โบไฮเดรต': '18 g',
      },
      isFavorite: false,
    );

    _recipes.addAll([
      eggFriedRice,
      tomatoOmelette,
      bananaSmoothie,
      eggSoup,
      padKrapow,
      chickenSalad,
      chocolateCake,
      waffle,
      carbonara,
      tomYum,
      stirVeggie,
    ]);

    // Initial Meal Plan for 15 May 2024
    _mealPlan['15'] = {
      'เช้า': bananaSmoothie,
      'กลางวัน': eggFriedRice,
      'เย็น': eggSoup,
    };

    // Initial Community Posts
    _communityPosts.addAll([
      CommunityPost(
        id: 'p1',
        author: 'Baking Lover',
        timeAgo: '2 ชั่วโมงที่แล้ว',
        title: 'เค้กช็อกโกแลตหน้านุ่ม',
        description: 'เค้กช็อกโกแลตสูตรนุ่มละมุน ทำง่าย อร่อยมาก!',
        icon: '🎂',
        imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800',
        likes: 128,
        commentsCount: 24,
        comments: ['น่ากินมากๆ ครับ', 'ทำตามแล้วอร่อยเลยครับ!'],
        isLiked: false,
        linkedRecipe: chocolateCake,
      ),
      CommunityPost(
        id: 'p2',
        author: 'Healthy Foodie',
        timeAgo: '5 ชั่วโมงที่แล้ว',
        title: 'สลัดอกไก่ย่าง',
        description: 'สลัดเพื่อสุขภาพ ทำง่าย ได้โปรตีนสูง',
        icon: '🥗',
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
        likes: 96,
        commentsCount: 18,
        comments: ['สายคลีนถูกใจสิ่งนี้เลย'],
        isLiked: false,
        linkedRecipe: chickenSalad,
      ),
      CommunityPost(
        id: 'p3',
        author: 'Easy Cooking',
        timeAgo: '1 วันที่แล้ว',
        title: 'ผัดกะเพราหมูสับ',
        description: 'เมนูสิ้นคิด แต่อร่อยเด็ดแน่นอน',
        icon: '🍲',
        imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800',
        likes: 152,
        commentsCount: 32,
        comments: ['ไข่ดาวต้องขอบกรอบๆ ด้วยครับ'],
        isLiked: false,
        linkedRecipe: padKrapow,
      ),
      CommunityPost(
        id: 'p4',
        author: 'Sweet Tooth',
        timeAgo: '2 วันที่แล้ว',
        title: 'วาฟเฟิลผลไม้รวม',
        description: 'วาฟเฟิลกรอบนอก นุ่มใน กับผลไม้สด',
        icon: '🧇',
        imageUrl: 'https://images.unsplash.com/photo-1562376552-0d160a2f238d?w=800',
        likes: 87,
        commentsCount: 15,
        comments: ['ทานคู่กาแฟยามเช้าฟินมาก'],
        isLiked: false,
        linkedRecipe: waffle,
      ),
    ]);
  }

  // User Authentication Methods
  void login(String email, String password) {
    userEmail = email.isNotEmpty ? email : 'natcha.cook@email.com';
    userName = email.contains('@') ? email.split('@').first : 'Natcha Cook';
    isLoggedIn = true;
    notifyListeners();
  }

  void register(String name, String email, String password) {
    userName = name.isNotEmpty ? name : 'Natcha Cook';
    userEmail = email.isNotEmpty ? email : 'natcha.cook@email.com';
    isLoggedIn = true;
    notifyListeners();
  }

  void googleSignIn() {
    userName = 'Natcha Cook';
    userEmail = 'natcha.cook@gmail.com';
    isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }

  void updateProfile(String name, String email) {
    userName = name;
    userEmail = email;
    notifyListeners();
  }

  // Ingredients Matching & Category Search Methods
  void addIngredient(String name) {
    final cleaned = name.trim();
    if (cleaned.isNotEmpty && !userIngredients.contains(cleaned)) {
      userIngredients.add(cleaned);
      notifyListeners();
    }
  }

  void removeIngredient(String name) {
    userIngredients.remove(name);
    notifyListeners();
  }

  void clearIngredients() {
    userIngredients.clear();
    notifyListeners();
  }

  void setActiveCategory(String? category) {
    activeCategory = category;
    notifyListeners();
  }

  List<Recipe> get filteredRecipes {
    List<Recipe> list = _recipes;

    // Filter by Category if selected
    if (activeCategory != null && activeCategory!.isNotEmpty) {
      list = list.where((r) => r.category == activeCategory).toList();
    }

    // Filter by User Ingredients if any added
    if (userIngredients.isNotEmpty) {
      list = list.where((recipe) {
        final recipeIngredientsStr = recipe.ingredients.join(' ').toLowerCase();
        final recipeTitle = recipe.title.toLowerCase();
        return userIngredients.any((ing) {
          final query = ing.toLowerCase();
          return recipeIngredientsStr.contains(query) || recipeTitle.contains(query);
        });
      }).toList();
    }

    return list;
  }

  // Favorite Recipes Methods
  void toggleFavorite(Recipe recipe) {
    recipe.isFavorite = !recipe.isFavorite;
    notifyListeners();
  }

  List<Recipe> get favoriteRecipes {
    return _recipes.where((r) => r.isFavorite).toList();
  }

  // Meal Planner Methods
  Map<String, Recipe> getMealsForDay(int day) {
    final dayKey = day.toString();
    if (_mealPlan.containsKey(dayKey)) {
      return _mealPlan[dayKey]!;
    }
    // Default fallback meals for any unconfigured day
    return {
      'เช้า': _recipes[2], // Smoothies
      'กลางวัน': _recipes[0], // Fried Rice
      'เย็น': _recipes[3], // Egg Soup
    };
  }

  void setMealForDay(int day, String mealSlot, Recipe recipe) {
    final dayKey = day.toString();
    if (!_mealPlan.containsKey(dayKey)) {
      _mealPlan[dayKey] = Map.from(getMealsForDay(day));
    }
    _mealPlan[dayKey]![mealSlot] = recipe;
    notifyListeners();
  }

  List<String> generateShoppingListForDay(int day) {
    final meals = getMealsForDay(day);
    final Set<String> items = {};
    for (var recipe in meals.values) {
      items.addAll(recipe.ingredients);
    }
    return items.toList();
  }

  // Community Methods
  void toggleLikePost(CommunityPost post) {
    post.isLiked = !post.isLiked;
    if (post.isLiked) {
      post.likes += 1;
    } else {
      post.likes -= 1;
    }
    notifyListeners();
  }

  void addCommentToPost(CommunityPost post, String comment) {
    if (comment.trim().isNotEmpty) {
      post.comments.add(comment.trim());
      post.commentsCount += 1;
      notifyListeners();
    }
  }

  void createCommunityPost({
    required String author,
    required String title,
    required String description,
    required String icon,
    required String imageUrl,
  }) {
    final newRecipe = Recipe(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      prepTime: '15 นาที',
      cookTime: '15 นาที',
      difficulty: 'ง่าย',
      icon: icon,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
      category: 'Thai',
      ingredients: ['วัตถุดิบหลักตามสูตร 1', 'วัตถุดิบหลักตามสูตร 2', 'เครื่องปรุงรสปรุงตามชอบ'],
      tools: ['กระทะ', 'ตะหลิว'],
      steps: ['เตรียมวัตถุดิบให้พร้อม', 'ตั้งกระทะปรุงตามขั้นตอนจนสุกพร้อมเสิร์ฟ'],
      tips: ['ทานขณะร้อนๆ อร่อยที่สุด'],
      nutrition: {'พลังงาน': '300 kcal', 'โปรตีน': '15 g', 'ไขมัน': '12 g', 'คาร์โบไฮเดรต': '30 g'},
      author: author,
    );

    _recipes.insert(0, newRecipe);

    final newPost = CommunityPost(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      author: author,
      timeAgo: 'เมื่อสักครู่',
      title: title,
      description: description,
      icon: icon,
      imageUrl: newRecipe.imageUrl,
      likes: 0,
      commentsCount: 0,
      comments: [],
      isLiked: false,
      linkedRecipe: newRecipe,
    );

    _communityPosts.insert(0, newPost);
    notifyListeners();
  }
}
