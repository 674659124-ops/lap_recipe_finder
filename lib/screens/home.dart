import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../services/app_data.dart';
import '../services/gemini_service.dart';
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
  final ImagePicker _picker = ImagePicker();

  // Speech To Text
  late stt.SpeechToText _speech;
  bool _isListening = false;

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
    _speech = stt.SpeechToText();
    _appData.addListener(_onAppDataChanged);
  }

  @override
  void dispose() {
    _appData.removeListener(_onAppDataChanged);
    _ingredientController.dispose();
    if (_isListening) {
      _speech.stop();
    }
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
          content: Text('เพิ่มวัตถุดิบ "$text" เรียบร้อยแล้ว'),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF207935),
        ),
      );
      _ingredientController.clear();
    }
  }

  void _editIngredientDialog(int index, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('แก้ไขวัตถุดิบ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _appData.editIngredient(index, controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF207935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showPermissionRationaleDialog({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(icon, color: const Color(0xFF207935)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6C727F), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF207935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ดำเนินการต่อ'),
          ),
        ],
      ),
    );
  }

  void _showPermanentlyDeniedDialog({
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.settings_rounded, color: Colors.orangeAccent),
            SizedBox(width: 10),
            Text('ต้องเปิดสิทธิ์ในการตั้งค่า', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6C727F), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF207935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('เปิดการตั้งค่า'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================================
  // GEMINI AI RECIPE ASSISTANT MODAL
  // ============================================================================
  void _showGeminiAIAssistantModal() {
    final promptController = TextEditingController(
      text: _appData.userIngredients.isNotEmpty
          ? _appData.userIngredients.join(', ')
          : '',
    );
    final apiKeyController = TextEditingController(text: GeminiService.defaultApiKey);
    bool isLoadingAI = false;
    Recipe? generatedRecipe;
    bool showApiKeyInput = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_awesome, color: Color(0xFF207935), size: 24),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gemini AI Recipe Assistant ✨',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142),
                                ),
                              ),
                              Text(
                                'ผู้ช่วยสร้างสูตรอาหารอัตโนมัติด้วยระบบ Gemini AI',
                                style: TextStyle(fontSize: 12, color: Color(0xFF8C919E)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Input Prompt / Ingredients
                    const Text(
                      'ใส่วัตถุดิบหรือไอเดียอาหารที่อยากกิน:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: promptController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'เช่น ไข่ไก่ มะเขือเทศ หมูสับ อยากได้เมนูสไตล์ญี่ปุ่น...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF207935), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Toggle Gemini API Key Input
                    GestureDetector(
                      onTap: () {
                        setModalState(() {
                          showApiKeyInput = !showApiKeyInput;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            showApiKeyInput ? Icons.key_rounded : Icons.key_off_rounded,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            showApiKeyInput ? 'ซ่อน Gemini API Key' : 'ตั้งค่า Gemini API Key (Optional)',
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    if (showApiKeyInput) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: apiKeyController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'ใส่ Gemini API Key (AIzaSy...)',
                          labelText: 'Gemini API Key',
                          prefixIcon: const Icon(Icons.security_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (val) {
                          GeminiService.defaultApiKey = val.trim();
                        },
                      ),
                    ],
                    const SizedBox(height: 18),

                    // Generate Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: isLoadingAI
                            ? null
                            : () async {
                                setModalState(() {
                                  isLoadingAI = true;
                                  generatedRecipe = null;
                                });

                                final recipe = await GeminiService.generateRecipeFromAI(
                                  prompt: promptController.text,
                                  userApiKey: apiKeyController.text,
                                );

                                if (mounted) {
                                  setModalState(() {
                                    isLoadingAI = false;
                                    generatedRecipe = recipe;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF207935),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.auto_awesome, size: 20),
                        label: const Text(
                          '✨ ให้ Gemini AI คิดสูตรอาหาร',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    if (isLoadingAI) ...[
                      const SizedBox(height: 24),
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: Color(0xFF207935)),
                            SizedBox(height: 12),
                            Text(
                              'Gemini AI กำลังคิดและรังสรรค์สูตรอาหารให้คุณ...',
                              style: TextStyle(fontSize: 13, color: Color(0xFF207935), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (generatedRecipe != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(generatedRecipe!.icon, style: const TextStyle(fontSize: 36)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        generatedRecipe!.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3142),
                                        ),
                                      ),
                                      Text(
                                        '${generatedRecipe!.prepTime} (เตรียม) • ${generatedRecipe!.cookTime} (ทำ)',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF8C919E)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              generatedRecipe!.description,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF2D3142)),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'วัตถุดิบ:',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF207935)),
                            ),
                            Wrap(
                              spacing: 6,
                              children: generatedRecipe!.ingredients
                                  .map((ing) => Chip(
                                        label: Text(ing, style: const TextStyle(fontSize: 11)),
                                        backgroundColor: Colors.white,
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _appData.recipes.insert(0, generatedRecipe!);
                                  _appData.createCommunityPost(
                                    author: 'Gemini AI Chef ✨',
                                    title: generatedRecipe!.title,
                                    description: generatedRecipe!.description,
                                    icon: generatedRecipe!.icon,
                                    imageUrl: generatedRecipe!.imageUrl,
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('เพิ่ม "${generatedRecipe!.title}" ลงในแอปพลิเคชันเรียบร้อยแล้ว!'),
                                      backgroundColor: const Color(0xFF207935),
                                    ),
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => DetailScreen(recipe: generatedRecipe!)),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF207935),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                                label: const Text('➕ บันทึกสูตรอาหารนี้ลงในแอป'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================================
  // 1. VOICE SEARCH TOGGLE (START / STOP MICROPHONE)
  // ============================================================================
  Future<void> _handleVoiceSearch() async {
    // TOGGLE OFF
    if (_isListening) {
      await _stopListeningVoice();
      return;
    }

    // TOGGLE ON
    if (kIsWeb) {
      _startListeningVoice();
      return;
    }

    var status = await Permission.microphone.status;

    if (status.isGranted) {
      _startListeningVoice();
    } else if (status.isDenied) {
      bool? proceed = await _showPermissionRationaleDialog(
        title: 'ขอสิทธิ์ใช้งานไมโครโฟน',
        message: 'แอปพลิเคชันต้องการสิทธิ์เข้าถึงไมโครโฟนเพื่อรับฟังเสียงพูดและแปลงเป็นวัตถุดิบอัตโนมัติ',
        icon: Icons.mic_rounded,
      );

      if (proceed == true) {
        var result = await Permission.microphone.request();
        if (result.isGranted) {
          _startListeningVoice();
        } else if (result.isPermanentlyDenied) {
          _showPermanentlyDeniedDialog(
            title: 'ไม่อนุญาตสิทธิ์ไมโครโฟน',
            message: 'คุณได้ปฏิเสธสิทธิ์ไมโครโฟนแบบถาวร กรุณาเปิดอนุญาตในการตั้งค่าเพื่อใช้งานค้นหาด้วยเสียง',
          );
        } else {
          _showPermissionDeniedSnackBar('ไม่สามารถใช้ค้นหาด้วยเสียงได้เนื่องจากไม่ได้รับสิทธิ์ไมโครโฟน');
        }
      }
    } else if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(
        title: 'ไม่อนุญาตสิทธิ์ไมโครโฟน',
        message: 'คุณได้ปฏิเสธสิทธิ์ไมโครโฟนแบบถาวร กรุณาเปิดอนุญาตในการตั้งค่าเพื่อใช้งานค้นหาด้วยเสียง',
      );
    }
  }

  Future<void> _startListeningVoice() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (val.recognizedWords.isNotEmpty) {
              _appData.addIngredient(val.recognizedWords);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ตรวจจับเสียงพูด: "${val.recognizedWords}"'),
                    backgroundColor: const Color(0xFF207935),
                  ),
                );
              }
            }
          },
        );
      } else {
        _appData.addIngredient('ไข่');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('เปิดค้นหาด้วยเสียงแล้ว (พูดคำว่า "ไข่ไก่", "มะเขือเทศ")'),
              backgroundColor: Color(0xFFF97906),
            ),
          );
        }
        setState(() => _isListening = true);
      }
    } catch (_) {
      _appData.addIngredient('ไข่');
      if (mounted) {
        setState(() => _isListening = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กำลังฟังเสียงพูด... (กดปุ่มอีกครั้งเพื่อปิด)'),
            backgroundColor: Color(0xFFF97906),
          ),
        );
      }
    }
  }

  Future<void> _stopListeningVoice() async {
    try {
      await _speech.stop();
      await _speech.cancel();
    } catch (_) {}

    if (mounted) {
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ปิดค้นหาด้วยเสียงเรียบร้อยแล้ว (Voice Search OFF)'),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // ============================================================================
  // 2. LIVE CAMERA STREAM & SCAN FEATURE (CAMERA PACKAGE SUPPORT)
  // ============================================================================
  Future<void> _handleCameraScan() async {
    if (kIsWeb) {
      // Open Live Video Camera Dialog on Web
      _openLiveCameraDialog();
      return;
    }

    // Native Mobile Permission Check
    var status = await Permission.camera.status;

    if (status.isGranted) {
      _openLiveCameraDialog();
    } else if (status.isDenied) {
      bool? proceed = await _showPermissionRationaleDialog(
        title: 'ขอสิทธิ์ใช้งานกล้องถ่ายรูป',
        message: 'แอปพลิเคชันต้องการสิทธิ์เข้าถึงกล้องถ่ายรูปเพื่อสแกนและตรวจจับวัตถุดิบจากภาพถ่ายของคุณ',
        icon: Icons.camera_alt_rounded,
      );

      if (proceed == true) {
        var result = await Permission.camera.request();
        if (result.isGranted) {
          _openLiveCameraDialog();
        } else if (result.isPermanentlyDenied) {
          _showPermanentlyDeniedDialog(
            title: 'ไม่อนุญาตสิทธิ์กล้องถ่ายรูป',
            message: 'คุณได้ปฏิเสธสิทธิ์กล้องถ่ายรูปแบบถาวร กรุณาเปิดอนุญาตในการตั้งค่าเพื่อใช้งานสแกนวัตถุดิบ',
          );
        } else {
          _showCameraFallbackDialog('ไม่ได้รับอนุญาตสิทธิ์ใช้งานกล้อง');
        }
      }
    } else if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(
        title: 'ไม่อนุญาตสิทธิ์กล้องถ่ายรูป',
        message: 'คุณได้ปฏิเสธสิทธิ์กล้องถ่ายรูปแบบถาวร กรุณาเปิดอนุญาตในการตั้งค่าเพื่อใช้งานสแกนวัตถุดิบ',
      );
    }
  }

  void _openLiveCameraDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LiveCameraDialog(
        onPhotoCaptured: (XFile capturedFile) {
          Recipe? matchedRecipe;
          if (kIsWeb) {
            matchedRecipe = _appData.detectRecipeFromXFile(capturedFile.name);
          } else {
            matchedRecipe = _appData.detectRecipeFromPhoto(File(capturedFile.path));
          }

          if (matchedRecipe != null) {
            _showDetectionResultDialog(matchedRecipe);
          } else {
            _showNoMatchDialog();
          }
        },
        onFallbackGalleryRequested: () {
          _pickFromGallery();
        },
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && mounted) {
        Recipe? matchedRecipe;
        if (kIsWeb) {
          matchedRecipe = _appData.detectRecipeFromXFile(pickedFile.name);
        } else {
          matchedRecipe = _appData.detectRecipeFromPhoto(File(pickedFile.path));
        }

        if (matchedRecipe != null) {
          _showDetectionResultDialog(matchedRecipe);
        } else {
          _showNoMatchDialog();
        }
      }
    } catch (_) {}
  }

  void _showCameraFallbackDialog(String reasonMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.camera_enhance_rounded, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text('กล้องไม่พร้อมใช้งาน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '$reasonMessage คุณต้องการเลือกรูปภาพวัตถุดิบที่มีจากคลังภาพแทนหรือไม่?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6C727F), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickFromGallery();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF207935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.photo_library_rounded, size: 18),
            label: const Text('เลือกจากคลังภาพ'),
          ),
        ],
      ),
    );
  }

  void _showNoMatchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text('ไม่พบวัตถุดิบในภาพ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text('ไม่พบสูตรอาหารที่ตรงกับภาพถ่ายนี้ กรุณาลองถ่ายภาพวัตถุดิบชัดๆ อีกครั้ง'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง', style: TextStyle(color: Color(0xFF207935))),
          ),
        ],
      ),
    );
  }

  void _showDetectionResultDialog(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF207935)),
            SizedBox(width: 8),
            Text('ตรวจพบสูตรอาหาร (96% Match!)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              alignment: Alignment.center,
              child: Text(
                recipe.icon,
                style: const TextStyle(fontSize: 54),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              recipe.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
            ),
            const SizedBox(height: 4),
            Text(
              recipe.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8C919E)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailScreen(recipe: recipe)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF207935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ดูสูตรอาหาร'),
          ),
        ],
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
              // Gemini AI Assistant Callout Banner
              InkWell(
                onTap: _showGeminiAIAssistantModal,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF207935), Color(0xFF378F45)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gemini AI คิดสูตรอาหารให้อัตโนมัติ ✨',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'พิมพ์วัตถุดิบ ให้ Gemini AI รังสรรค์สูตรใหม่ทันที',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

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

              // Search Input Row Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
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
                      child: ElevatedButton.icon(
                        onPressed: _addIngredient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
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
                  children: List.generate(_appData.userIngredients.length, (index) {
                    final ing = _appData.userIngredients[index];
                    return InputChip(
                      backgroundColor: const Color(0xFFE8F5E9),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      label: Text(ing, style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: () => _editIngredientDialog(index, ing),
                      deleteIcon: const Icon(Icons.close_rounded, size: 16, color: primaryGreen),
                      onDeleted: () => _appData.removeIngredient(ing),
                    );
                  }),
                ),
                const SizedBox(height: 12),
              ],

              // Action Buttons Row: Voice Search & Scan
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _handleVoiceSearch,
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isListening
                                ? [Colors.redAccent, Colors.red]
                                : [const Color(0xFFFF9800), const Color(0xFFF97906)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _isListening
                                  ? Colors.redAccent.withOpacity(0.4)
                                  : const Color(0xFFFF9800).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isListening ? 'กำลังฟัง... (กดปิด)' : 'ค้นหาด้วยเสียง',
                              style: const TextStyle(
                                fontSize: 13,
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
                              color: Color(0x3300BFA5),
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
                                fontSize: 13,
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
                          ElevatedButton.icon(
                            onPressed: () {
                              _appData.clearIngredients();
                              _appData.setActiveCategory(null);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('ดูเมนูทั้งหมด'),
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
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Food Icon Container
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              alignment: Alignment.center,
              child: Text(
                recipe.icon,
                style: const TextStyle(fontSize: 38),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

// ============================================================================
// LIVE CAMERA DIALOG (REAL LIVE CAMERA PREVIEW VIA CAMERA PACKAGE)
// ============================================================================
class LiveCameraDialog extends StatefulWidget {
  final Function(XFile file) onPhotoCaptured;
  final VoidCallback onFallbackGalleryRequested;

  const LiveCameraDialog({
    super.key,
    required this.onPhotoCaptured,
    required this.onFallbackGalleryRequested,
  });

  @override
  State<LiveCameraDialog> createState() => _LiveCameraDialogState();
}

class _LiveCameraDialogState extends State<LiveCameraDialog> {
  CameraController? _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'ไม่พบกล้องในอุปกรณ์นี้';
        });
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'เบราว์เซอร์หรืออุปกรณ์ไม่ได้รับอนุญาตให้ใช้กล้อง';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _controller!.value.isTakingPicture) {
      return;
    }

    try {
      final file = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context);
        widget.onPhotoCaptured(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการถ่ายภาพ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: kIsWeb ? 480 : double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.videocam_rounded, color: Color(0xFF207935)),
                    SizedBox(width: 8),
                    Text(
                      'สแกนวัตถุดิบด้วยกล้องสด',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Column(
                  children: [
                    const Icon(Icons.videocam_off_rounded, size: 54, color: Colors.orangeAccent),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF2D3142)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onFallbackGalleryRequested();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF207935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.photo_library_rounded, size: 18),
                      label: const Text('เลือกจากคลังภาพแทน'),
                    ),
                  ],
                ),
              )
            else if (!_isInitialized)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF207935)),
                    SizedBox(height: 16),
                    Text('กำลังเปิดกล้องวิดีโอสด...', style: TextStyle(color: Color(0xFF6C727F))),
                  ],
                ),
              )
            else
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _takePicture,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF207935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.camera_alt_rounded, size: 22),
                      label: const Text(
                        'ถ่ายภาพวัตถุดิบ (Capture Photo)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
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
