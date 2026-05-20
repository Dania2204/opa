import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app/theme.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/user_model.dart';

// ── Producto alimenticio (no plato) ──────────────────────────────────────────

class FoodProduct {
  const FoodProduct({
    required this.name,
    required this.category,
    required this.unit,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.icon = Icons.set_meal_rounded,
  });

  final String name;
  final String category;
  final String unit; // 'g' o 'ml'
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final IconData icon;
}

// ── Base de productos PAE Colombia ───────────────────────────────────────────

const List<FoodProduct> kFoodProducts = [
  // Cereales y tubérculos
  FoodProduct(name: 'Arroz blanco', category: 'Cereales', unit: 'g', caloriesPer100g: 130, proteinPer100g: 2.7, carbsPer100g: 28.2, fatPer100g: 0.3, icon: Icons.grain_rounded),
  FoodProduct(name: 'Arroz integral', category: 'Cereales', unit: 'g', caloriesPer100g: 123, proteinPer100g: 2.7, carbsPer100g: 25.6, fatPer100g: 1.0, icon: Icons.grain_rounded),
  FoodProduct(name: 'Papa pastusa', category: 'Tubérculos', unit: 'g', caloriesPer100g: 77, proteinPer100g: 2.0, carbsPer100g: 17.0, fatPer100g: 0.1, icon: Icons.set_meal_rounded),
  FoodProduct(name: 'Papa criolla', category: 'Tubérculos', unit: 'g', caloriesPer100g: 70, proteinPer100g: 1.9, carbsPer100g: 15.4, fatPer100g: 0.1, icon: Icons.set_meal_rounded),
  FoodProduct(name: 'Yuca', category: 'Tubérculos', unit: 'g', caloriesPer100g: 160, proteinPer100g: 1.4, carbsPer100g: 38.1, fatPer100g: 0.3, icon: Icons.set_meal_rounded),
  FoodProduct(name: 'Plátano maduro', category: 'Tubérculos', unit: 'g', caloriesPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 22.8, fatPer100g: 0.3, icon: Icons.set_meal_rounded),
  FoodProduct(name: 'Plátano verde', category: 'Tubérculos', unit: 'g', caloriesPer100g: 122, proteinPer100g: 1.3, carbsPer100g: 31.9, fatPer100g: 0.4, icon: Icons.set_meal_rounded),
  FoodProduct(name: 'Maíz', category: 'Cereales', unit: 'g', caloriesPer100g: 365, proteinPer100g: 9.4, carbsPer100g: 74.3, fatPer100g: 4.7, icon: Icons.grain_rounded),
  FoodProduct(name: 'Avena', category: 'Cereales', unit: 'g', caloriesPer100g: 389, proteinPer100g: 17.0, carbsPer100g: 66.3, fatPer100g: 6.9, icon: Icons.grain_rounded),
  FoodProduct(name: 'Pan blanco', category: 'Cereales', unit: 'g', caloriesPer100g: 265, proteinPer100g: 9.0, carbsPer100g: 49.0, fatPer100g: 3.2, icon: Icons.bakery_dining_rounded),
  FoodProduct(name: 'Arepa de maíz', category: 'Cereales', unit: 'g', caloriesPer100g: 200, proteinPer100g: 4.5, carbsPer100g: 40.0, fatPer100g: 2.5, icon: Icons.grain_rounded),
  FoodProduct(name: 'Pasta', category: 'Cereales', unit: 'g', caloriesPer100g: 131, proteinPer100g: 5.0, carbsPer100g: 25.0, fatPer100g: 1.1, icon: Icons.ramen_dining_rounded),

  // Leguminosas
  FoodProduct(name: 'Fríjol negro', category: 'Leguminosas', unit: 'g', caloriesPer100g: 132, proteinPer100g: 8.9, carbsPer100g: 23.7, fatPer100g: 0.5, icon: Icons.spa_rounded),
  FoodProduct(name: 'Fríjol rojo', category: 'Leguminosas', unit: 'g', caloriesPer100g: 127, proteinPer100g: 8.7, carbsPer100g: 22.8, fatPer100g: 0.5, icon: Icons.spa_rounded),
  FoodProduct(name: 'Lenteja', category: 'Leguminosas', unit: 'g', caloriesPer100g: 116, proteinPer100g: 9.0, carbsPer100g: 20.1, fatPer100g: 0.4, icon: Icons.spa_rounded),
  FoodProduct(name: 'Garbanzo', category: 'Leguminosas', unit: 'g', caloriesPer100g: 164, proteinPer100g: 8.9, carbsPer100g: 27.4, fatPer100g: 2.6, icon: Icons.spa_rounded),
  FoodProduct(name: 'Arveja', category: 'Leguminosas', unit: 'g', caloriesPer100g: 81, proteinPer100g: 5.4, carbsPer100g: 14.5, fatPer100g: 0.4, icon: Icons.spa_rounded),

  // Proteína animal
  FoodProduct(name: 'Pollo (pechuga)', category: 'Carnes', unit: 'g', caloriesPer100g: 165, proteinPer100g: 31.0, carbsPer100g: 0.0, fatPer100g: 3.6, icon: Icons.set_meal_rounded),
  FoodProduct(name: 'Pollo (muslo)', category: 'Carnes', unit: 'g', caloriesPer100g: 209, proteinPer100g: 26.0, carbsPer100g: 0.0, fatPer100g: 10.9, icon: Icons.set_meal_rounded),
  FoodProduct(name: 'Carne de res', category: 'Carnes', unit: 'g', caloriesPer100g: 250, proteinPer100g: 26.0, carbsPer100g: 0.0, fatPer100g: 15.0, icon: Icons.set_meal_rounded),
  FoodProduct(name: 'Cerdo', category: 'Carnes', unit: 'g', caloriesPer100g: 242, proteinPer100g: 27.0, carbsPer100g: 0.0, fatPer100g: 14.0, icon: Icons.set_meal_rounded),
  FoodProduct(name: 'Tilapia', category: 'Pescados', unit: 'g', caloriesPer100g: 96, proteinPer100g: 20.1, carbsPer100g: 0.0, fatPer100g: 1.7, icon: Icons.set_meal_rounded),
  FoodProduct(name: 'Atún en agua', category: 'Pescados', unit: 'g', caloriesPer100g: 116, proteinPer100g: 25.5, carbsPer100g: 0.0, fatPer100g: 1.0, icon: Icons.set_meal_rounded),
  FoodProduct(name: 'Huevo entero', category: 'Huevos', unit: 'g', caloriesPer100g: 155, proteinPer100g: 13.0, carbsPer100g: 1.1, fatPer100g: 11.0, icon: Icons.egg_rounded),
  FoodProduct(name: 'Sardina en lata', category: 'Pescados', unit: 'g', caloriesPer100g: 208, proteinPer100g: 24.6, carbsPer100g: 0.0, fatPer100g: 11.5, icon: Icons.set_meal_rounded),

  // Lácteos
  FoodProduct(name: 'Leche entera', category: 'Lácteos', unit: 'ml', caloriesPer100g: 61, proteinPer100g: 3.2, carbsPer100g: 4.8, fatPer100g: 3.3, icon: Icons.local_drink_rounded),
  FoodProduct(name: 'Leche descremada', category: 'Lácteos', unit: 'ml', caloriesPer100g: 35, proteinPer100g: 3.4, carbsPer100g: 5.0, fatPer100g: 0.2, icon: Icons.local_drink_rounded),
  FoodProduct(name: 'Yogur natural', category: 'Lácteos', unit: 'g', caloriesPer100g: 61, proteinPer100g: 3.5, carbsPer100g: 4.7, fatPer100g: 3.3, icon: Icons.local_drink_rounded),
  FoodProduct(name: 'Queso blanco', category: 'Lácteos', unit: 'g', caloriesPer100g: 264, proteinPer100g: 18.0, carbsPer100g: 3.4, fatPer100g: 20.0, icon: Icons.set_meal_rounded),
  FoodProduct(name: 'Queso doble crema', category: 'Lácteos', unit: 'g', caloriesPer100g: 350, proteinPer100g: 22.0, carbsPer100g: 2.0, fatPer100g: 28.0, icon: Icons.set_meal_rounded),

  // Verduras
  FoodProduct(name: 'Zanahoria', category: 'Verduras', unit: 'g', caloriesPer100g: 41, proteinPer100g: 0.9, carbsPer100g: 9.6, fatPer100g: 0.2, icon: Icons.eco_rounded),
  FoodProduct(name: 'Ahuyama (calabaza)', category: 'Verduras', unit: 'g', caloriesPer100g: 26, proteinPer100g: 1.0, carbsPer100g: 6.5, fatPer100g: 0.1, icon: Icons.eco_rounded),
  FoodProduct(name: 'Tomate', category: 'Verduras', unit: 'g', caloriesPer100g: 18, proteinPer100g: 0.9, carbsPer100g: 3.9, fatPer100g: 0.2, icon: Icons.eco_rounded),
  FoodProduct(name: 'Cebolla cabezona', category: 'Verduras', unit: 'g', caloriesPer100g: 40, proteinPer100g: 1.1, carbsPer100g: 9.3, fatPer100g: 0.1, icon: Icons.eco_rounded),
  FoodProduct(name: 'Espinaca', category: 'Verduras', unit: 'g', caloriesPer100g: 23, proteinPer100g: 2.9, carbsPer100g: 3.6, fatPer100g: 0.4, icon: Icons.eco_rounded),
  FoodProduct(name: 'Brócoli', category: 'Verduras', unit: 'g', caloriesPer100g: 34, proteinPer100g: 2.8, carbsPer100g: 6.6, fatPer100g: 0.4, icon: Icons.eco_rounded),
  FoodProduct(name: 'Habichuela (vainita)', category: 'Verduras', unit: 'g', caloriesPer100g: 31, proteinPer100g: 1.8, carbsPer100g: 7.1, fatPer100g: 0.1, icon: Icons.eco_rounded),
  FoodProduct(name: 'Remolacha', category: 'Verduras', unit: 'g', caloriesPer100g: 43, proteinPer100g: 1.6, carbsPer100g: 9.6, fatPer100g: 0.2, icon: Icons.eco_rounded),
  FoodProduct(name: 'Pepino', category: 'Verduras', unit: 'g', caloriesPer100g: 15, proteinPer100g: 0.7, carbsPer100g: 3.6, fatPer100g: 0.1, icon: Icons.eco_rounded),

  // Frutas
  FoodProduct(name: 'Banano', category: 'Frutas', unit: 'g', caloriesPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 23.0, fatPer100g: 0.3, icon: Icons.local_florist_rounded),
  FoodProduct(name: 'Mango', category: 'Frutas', unit: 'g', caloriesPer100g: 60, proteinPer100g: 0.8, carbsPer100g: 15.0, fatPer100g: 0.4, icon: Icons.local_florist_rounded),
  FoodProduct(name: 'Naranja', category: 'Frutas', unit: 'g', caloriesPer100g: 47, proteinPer100g: 0.9, carbsPer100g: 11.8, fatPer100g: 0.1, icon: Icons.local_florist_rounded),
  FoodProduct(name: 'Papaya', category: 'Frutas', unit: 'g', caloriesPer100g: 43, proteinPer100g: 0.5, carbsPer100g: 10.8, fatPer100g: 0.3, icon: Icons.local_florist_rounded),
  FoodProduct(name: 'Guayaba', category: 'Frutas', unit: 'g', caloriesPer100g: 68, proteinPer100g: 2.6, carbsPer100g: 14.3, fatPer100g: 1.0, icon: Icons.local_florist_rounded),
  FoodProduct(name: 'Lulo', category: 'Frutas', unit: 'g', caloriesPer100g: 31, proteinPer100g: 0.6, carbsPer100g: 7.6, fatPer100g: 0.1, icon: Icons.local_florist_rounded),
  FoodProduct(name: 'Maracuyá', category: 'Frutas', unit: 'g', caloriesPer100g: 97, proteinPer100g: 2.2, carbsPer100g: 23.4, fatPer100g: 0.7, icon: Icons.local_florist_rounded),
  FoodProduct(name: 'Piña', category: 'Frutas', unit: 'g', caloriesPer100g: 50, proteinPer100g: 0.5, carbsPer100g: 13.1, fatPer100g: 0.1, icon: Icons.local_florist_rounded),
  FoodProduct(name: 'Mandarina', category: 'Frutas', unit: 'g', caloriesPer100g: 53, proteinPer100g: 0.8, carbsPer100g: 13.3, fatPer100g: 0.3, icon: Icons.local_florist_rounded),

  // Aceites y grasas
  FoodProduct(name: 'Aceite vegetal', category: 'Aceites', unit: 'ml', caloriesPer100g: 884, proteinPer100g: 0.0, carbsPer100g: 0.0, fatPer100g: 100.0, icon: Icons.opacity_rounded),
  FoodProduct(name: 'Mantequilla', category: 'Aceites', unit: 'g', caloriesPer100g: 717, proteinPer100g: 0.9, carbsPer100g: 0.1, fatPer100g: 81.0, icon: Icons.opacity_rounded),

  // Azúcares
  FoodProduct(name: 'Azúcar', category: 'Azúcares', unit: 'g', caloriesPer100g: 387, proteinPer100g: 0.0, carbsPer100g: 100.0, fatPer100g: 0.0, icon: Icons.cookie_rounded),
  FoodProduct(name: 'Panela', category: 'Azúcares', unit: 'g', caloriesPer100g: 380, proteinPer100g: 0.3, carbsPer100g: 98.0, fatPer100g: 0.1, icon: Icons.cookie_rounded),
];

// ── Categorías únicas ────────────────────────────────────────────────────────

List<String> get kCategories {
  final cats = kFoodProducts.map((p) => p.category).toSet().toList();
  cats.sort();
  return ['Todos', ...cats];
}

// ── Model ────────────────────────────────────────────────────────────────────

class FoodEntry {
  FoodEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.portion,
    required this.mealType,
    required this.registeredAt,
  });

  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String portion;
  final MealType mealType;
  final DateTime registeredAt;
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get label {
    switch (this) {
      case MealType.breakfast: return 'Desayuno';
      case MealType.lunch:     return 'Almuerzo';
      case MealType.dinner:    return 'Cena';
      case MealType.snack:     return 'Merienda';
    }
  }

  IconData get icon {
    switch (this) {
      case MealType.breakfast: return Icons.wb_sunny_rounded;
      case MealType.lunch:     return Icons.restaurant_rounded;
      case MealType.dinner:    return Icons.nightlight_round;
      case MealType.snack:     return Icons.cookie_rounded;
    }
  }

  Color get color {
    switch (this) {
      case MealType.breakfast: return const Color(0xFFFF9800);
      case MealType.lunch:     return const Color(0xFF4CAF50);
      case MealType.dinner:    return const Color(0xFF673AB7);
      case MealType.snack:     return const Color(0xFFE91E63);
    }
  }
}

// ── Main Screen ──────────────────────────────────────────────────────────────

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key, required this.user});
  final AppUser user;

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final List<FoodEntry> _entries = [];
  List<_AiMessage> _aiMessages = [];
  bool _aiLoading = false;
  final _aiChatCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _aiMessages = [
      _AiMessage(
        role: 'assistant',
        text: '¡Hola! Soy tu asistente de nutrición del PAEGo. '
            'Puedo darte recetas saludables y consejos de nutrición '
            'basados en los productos que hayas registrado. '
            '¿En qué te puedo ayudar hoy?',
      ),
    ];
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _aiChatCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Totals ────────────────────────────────────────────────────────────────

  double get _totalCalories =>
      _entries.fold(0, (s, e) => s + e.calories);
  double get _totalProtein =>
      _entries.fold(0, (s, e) => s + e.protein);
  double get _totalCarbs =>
      _entries.fold(0, (s, e) => s + e.carbs);
  double get _totalFat =>
      _entries.fold(0, (s, e) => s + e.fat);

  // ── AI ────────────────────────────────────────────────────────────────────

  Future<void> _sendAiMessage(String userText) async {
    if (userText.trim().isEmpty) return;

    setState(() {
      _aiMessages.add(_AiMessage(role: 'user', text: userText));
      _aiLoading = true;
    });
    _aiChatCtrl.clear();
    _scrollToBottom();

    final foodContext = _entries.isEmpty
        ? 'No hay productos registrados hoy.'
        : 'Productos registrados hoy:\n' +
            _entries
                .map((e) =>
                    '- ${e.name} (${e.portion}) — ${e.calories.toStringAsFixed(0)} kcal, '
                    '${e.protein.toStringAsFixed(1)}g proteína, '
                    '${e.carbs.toStringAsFixed(1)}g carbohidratos, '
                    '${e.fat.toStringAsFixed(1)}g grasa [${e.mealType.label}]')
                .join('\n') +
            '\n\nTotales del día: ${_totalCalories.toStringAsFixed(0)} kcal | '
                '${_totalProtein.toStringAsFixed(1)}g proteína | '
                '${_totalCarbs.toStringAsFixed(1)}g carbohidratos | '
                '${_totalFat.toStringAsFixed(1)}g grasa';

    final systemPrompt = '''
Eres un nutricionista experto del Programa de Alimentación Escolar (PAE) en Colombia.
Tu rol es ayudar al usuario ${widget.user.fullName} a llevar una dieta saludable y equilibrada.
El usuario registra productos alimenticios individuales (ingredientes), no platos preparados.
Puedes dar recetas combinando los productos registrados, consejos de nutrición, análisis de la dieta y sugerencias.
Responde siempre en español, de forma amigable, clara y práctica.
Considera las tradiciones alimentarias colombianas cuando sea relevante.

Contexto nutricional actual del usuario:
$foodContext
''';

    const geminiApiKey = 'AIzaSyBN5q-ndv00o91fGS0f_2VG_WfV0_1dHVE';

    final geminiContents = <Map<String, dynamic>>[];
    for (int i = 1; i < _aiMessages.length; i++) {
      final msg = _aiMessages[i];
      geminiContents.add({
        'role': msg.role == 'user' ? 'user' : 'model',
        'parts': [{'text': msg.text}],
      });
    }
    geminiContents.add({
      'role': 'user',
      'parts': [{'text': userText}],
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/'
          'gemini-2.0-flash:generateContent?key=$geminiApiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [{'text': systemPrompt}],
          },
          'contents': geminiContents,
          'generationConfig': {
            'maxOutputTokens': 1024,
            'temperature': 0.7,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>;
        final text = candidates
            .map((c) => c['content']['parts'] as List<dynamic>)
            .expand((parts) => parts)
            .map((p) => p['text'] as String)
            .join('');
        setState(() {
          _aiMessages.add(_AiMessage(role: 'assistant', text: text));
        });
      } else if (response.statusCode == 400) {
        setState(() {
          _aiMessages.add(_AiMessage(
            role: 'assistant',
            text: '⚠️ API key no configurada. En nutrition_screen.dart reemplaza AQUI_TU_GEMINI_API_KEY con tu key de aistudio.google.com',
            isError: true,
          ));
        });
      } else {
        setState(() {
          _aiMessages.add(_AiMessage(
            role: 'assistant',
            text: 'Error ${response.statusCode}. Verifica tu conexión e intenta de nuevo.',
            isError: true,
          ));
        });
      }
    } catch (_) {
      setState(() {
        _aiMessages.add(_AiMessage(
          role: 'assistant',
          text: 'Sin conexión. Verifica tu internet e intenta de nuevo.',
          isError: true,
        ));
      });
    } finally {
      setState(() => _aiLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Add food dialog ───────────────────────────────────────────────────────

  void _showAddFoodDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddProductSheet(
        onAdd: (entry) {
          setState(() => _entries.add(entry));
        },
      ),
    );
  }

  // ── Delete food ───────────────────────────────────────────────────────────

  void _deleteEntry(FoodEntry entry) {
    setState(() => _entries.removeWhere((e) => e.id == entry.id));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          GradientHeader(
            title: 'Nutrición',
            subtitle: 'Registro de productos y asesoría IA',
            height: 110,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                onPressed: _showAddFoodDialog,
                tooltip: 'Registrar producto',
              ),
            ],
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabCtrl,
              labelColor: PaeColors.primary,
              unselectedLabelColor: PaeColors.textSecondary,
              indicatorColor: PaeColors.primary,
              tabs: const [
                Tab(icon: Icon(Icons.inventory_2_rounded), text: 'Productos'),
                Tab(icon: Icon(Icons.smart_toy_rounded), text: 'Asistente IA'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildRegistroTab(),
                _buildAiTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Registro Tab ──────────────────────────────────────────────────────────

  Widget _buildRegistroTab() {
    return RefreshIndicator(
      onRefresh: () async {},
      color: PaeColors.primary,
      child: CustomScrollView(
        slivers: [
          // Summary card
          SliverToBoxAdapter(
            child: _SummaryCard(
              calories: _totalCalories,
              protein: _totalProtein,
              carbs: _totalCarbs,
              fat: _totalFat,
            ),
          ),

          // Quick suggestion chips
          if (_entries.isEmpty)
            SliverToBoxAdapter(
              child: _QuickSuggestions(
                onSuggestionTap: (text) {
                  _tabCtrl.animateTo(1);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _sendAiMessage(text);
                  });
                },
              ),
            ),

          if (_entries.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: PaeColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        size: 56,
                        color: PaeColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sin productos registrados',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: PaeColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toca + para añadir un producto\nalimenticio del día',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PaeColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Group by meal type
            for (final meal in MealType.values)
              ..._buildMealGroup(meal),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  List<Widget> _buildMealGroup(MealType meal) {
    final group = _entries.where((e) => e.mealType == meal).toList();
    if (group.isEmpty) return [];

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: meal.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(meal.icon, color: meal.color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                meal.label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: meal.color,
                  fontFamily: PaeTypography.fontDisplay,
                ),
              ),
              const Spacer(),
              Text(
                '${group.fold(0.0, (s, e) => s + e.calories).toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  fontSize: 12,
                  color: PaeColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _FoodEntryTile(
            entry: group[i],
            onDelete: () => _deleteEntry(group[i]),
          ),
          childCount: group.length,
        ),
      ),
    ];
  }

  // ── AI Tab ────────────────────────────────────────────────────────────────

  Widget _buildAiTab() {
    return Column(
      children: [
        // Quick prompts
        if (_entries.isNotEmpty)
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _QuickChip(
                  label: '¿Cómo está mi dieta hoy?',
                  onTap: () => _sendAiMessage('¿Cómo está mi dieta hoy según los productos que he consumido?'),
                ),
                _QuickChip(
                  label: '¿Qué receta puedo hacer?',
                  onTap: () => _sendAiMessage(
                      'Con los productos que he registrado hoy, ¿qué receta saludable me recomiendas preparar?'),
                ),
                _QuickChip(
                  label: 'Consejo nutricional',
                  onTap: () => _sendAiMessage(
                      'Basándote en los productos que he consumido hoy, dame un consejo de nutrición personalizado.'),
                ),
              ],
            ),
          ),

        // Chat messages
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _aiMessages.length + (_aiLoading ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == _aiMessages.length) {
                return const _TypingIndicator();
              }
              return _ChatBubble(message: _aiMessages[i]);
            },
          ),
        ),

        // Input
        _AiInput(
          controller: _aiChatCtrl,
          loading: _aiLoading,
          onSend: () => _sendAiMessage(_aiChatCtrl.text),
        ),
      ],
    );
  }
}

// ── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  @override
  Widget build(BuildContext context) {
    const goal = 2000.0;
    final progress = (calories / goal).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PaeColors.gradStart, PaeColors.gradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PaeColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resumen del día',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  fontFamily: PaeTypography.fontDisplay,
                ),
              ),
              Text(
                '${calories.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} kcal',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroChip(label: 'Proteína', value: protein, unit: 'g', color: const Color(0xFF4FC3F7)),
              _MacroChip(label: 'Carbos', value: carbs, unit: 'g', color: const Color(0xFFFFD54F)),
              _MacroChip(label: 'Grasas', value: fat, unit: 'g', color: const Color(0xFFFF8A65)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label;
  final double value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            fontFamily: PaeTypography.fontDisplay,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ── Food Entry Tile ───────────────────────────────────────────────────────────

class _FoodEntryTile extends StatelessWidget {
  const _FoodEntryTile({required this.entry, required this.onDelete});

  final FoodEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: PaeColors.error,
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: entry.mealType.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(entry.mealType.icon, color: entry.mealType.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: PaeColors.textPrimary,
                    ),
                  ),
                  Text(
                    entry.portion,
                    style: const TextStyle(
                      fontSize: 12,
                      color: PaeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.calories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: PaeColors.primary,
                  ),
                ),
                Text(
                  'P:${entry.protein.toStringAsFixed(0)}g C:${entry.carbs.toStringAsFixed(0)}g G:${entry.fat.toStringAsFixed(0)}g',
                  style: const TextStyle(
                    fontSize: 10,
                    color: PaeColors.textSecondary,
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

// ── Add Product Sheet ─────────────────────────────────────────────────────────
// Flujo: 1) Buscar/seleccionar producto  2) Indicar cantidad y comida

class _AddProductSheet extends StatefulWidget {
  const _AddProductSheet({required this.onAdd});
  final void Function(FoodEntry) onAdd;

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  // Paso 1: selección de producto
  FoodProduct? _selected;
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  final _searchCtrl = TextEditingController();

  // Paso 2: cantidad y comida
  final _amountCtrl = TextEditingController(text: '100');
  MealType _selectedMeal = MealType.lunch;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  List<FoodProduct> get _filtered {
    return kFoodProducts.where((p) {
      final matchCat = _selectedCategory == 'Todos' || p.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  // Valores calculados según cantidad ingresada
  double get _parsedAmount => double.tryParse(_amountCtrl.text) ?? 100;
  double get _calcCalories => (_selected!.caloriesPer100g * _parsedAmount) / 100;
  double get _calcProtein  => (_selected!.proteinPer100g  * _parsedAmount) / 100;
  double get _calcCarbs    => (_selected!.carbsPer100g    * _parsedAmount) / 100;
  double get _calcFat      => (_selected!.fatPer100g      * _parsedAmount) / 100;

  void _confirm() {
    if (_selected == null) return;
    final amount = _parsedAmount;
    final unit = _selected!.unit;

    final entry = FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _selected!.name,
      calories: _calcCalories,
      protein: _calcProtein,
      carbs: _calcCarbs,
      fat: _calcFat,
      portion: '${amount.toStringAsFixed(0)} $unit',
      mealType: _selectedMeal,
      registeredAt: DateTime.now(),
    );

    widget.onAdd(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _selected == null ? _buildStep1() : _buildStep2(),
      ),
    );
  }

  // ── Paso 1: Buscar y seleccionar producto ─────────────────────────────────

  Widget _buildStep1() {
    final filtered = _filtered;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PaeColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search_rounded, color: PaeColors.primary),
            ),
            const SizedBox(width: 12),
            const Text(
              'Seleccionar producto',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                fontFamily: PaeTypography.fontDisplay,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Buscador
        TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Buscar producto (ej: arroz, pollo…)',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: PaeColors.bgLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: 10),

        // Filtro de categorías
        SizedBox(
          height: 34,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: kCategories.length,
            itemBuilder: (_, i) {
              final cat = kCategories[i];
              final selected = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? PaeColors.primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : PaeColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Lista de productos
        Flexible(
          child: filtered.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No se encontraron productos',
                      style: TextStyle(color: PaeColors.textSecondary),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final p = filtered[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: PaeColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(p.icon, color: PaeColors.primary, size: 20),
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        p.category,
                        style: const TextStyle(fontSize: 11, color: PaeColors.textSecondary),
                      ),
                      trailing: Text(
                        '${p.caloriesPer100g.toStringAsFixed(0)} kcal/100${p.unit}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: PaeColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => setState(() => _selected = p),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Paso 2: Cantidad y tipo de comida ─────────────────────────────────────

  Widget _buildStep2() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con botón volver
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selected = null),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 20, color: PaeColors.textSecondary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selected!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        fontFamily: PaeTypography.fontDisplay,
                      ),
                    ),
                    Text(
                      _selected!.category,
                      style: const TextStyle(fontSize: 12, color: PaeColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Cantidad
          const Text(
            'Cantidad consumida',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: PaeColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Botón −
              _AmountButton(
                icon: Icons.remove_rounded,
                onTap: () {
                  final v = (double.tryParse(_amountCtrl.text) ?? 100) - 10;
                  if (v >= 10) {
                    _amountCtrl.text = v.toStringAsFixed(0);
                    setState(() {});
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    suffixText: _selected!.unit,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: PaeColors.bgLight,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              // Botón +
              _AmountButton(
                icon: Icons.add_rounded,
                onTap: () {
                  final v = (double.tryParse(_amountCtrl.text) ?? 100) + 10;
                  _amountCtrl.text = v.toStringAsFixed(0);
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preview nutricional calculado
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PaeColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: PaeColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NutrientPreview(label: 'Calorías', value: _calcCalories, unit: 'kcal', color: PaeColors.primary),
                _NutrientPreview(label: 'Proteína', value: _calcProtein, unit: 'g', color: const Color(0xFF4FC3F7)),
                _NutrientPreview(label: 'Carbos', value: _calcCarbs, unit: 'g', color: const Color(0xFFFFB300)),
                _NutrientPreview(label: 'Grasas', value: _calcFat, unit: 'g', color: const Color(0xFFFF7043)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tipo de comida
          const Text(
            'Momento del día',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: PaeColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: MealType.values.map((m) {
              final sel = m == _selectedMeal;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMeal = m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? m.color.withOpacity(0.15) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? m.color : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(m.icon, color: m.color, size: 18),
                        const SizedBox(height: 2),
                        Text(
                          m.label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: sel ? m.color : PaeColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          GradientButton(
            label: 'Agregar producto',
            icon: Icons.check_rounded,
            onPressed: _confirm,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares del sheet ──────────────────────────────────────────────

class _AmountButton extends StatelessWidget {
  const _AmountButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: PaeColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: PaeColors.primary, size: 22),
      ),
    );
  }
}

class _NutrientPreview extends StatelessWidget {
  const _NutrientPreview({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
  final String label;
  final double value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)}',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color),
        ),
        Text(unit, style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: PaeColors.textSecondary)),
      ],
    );
  }
}

// ── Quick Suggestions ─────────────────────────────────────────────────────────

class _QuickSuggestions extends StatelessWidget {
  const _QuickSuggestions({required this.onSuggestionTap});
  final void Function(String) onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pregúntale a la IA',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: PaeColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickChip(
                label: 'Productos PAE recomendados',
                onTap: () => onSuggestionTap(
                    'Dame una lista de productos alimenticios saludables recomendados para el PAE colombiano.'),
              ),
              _QuickChip(
                label: '¿Qué debo consumir hoy?',
                onTap: () => onSuggestionTap(
                    'No he consumido nada aún. ¿Qué productos alimenticios balanceados me recomiendas para hoy?'),
              ),
              _QuickChip(
                label: 'Nutrición para niños',
                onTap: () => onSuggestionTap(
                    'Dame consejos sobre qué productos alimenticios son esenciales para niños en edad escolar en el PAE.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: PaeColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PaeColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_rounded, size: 14, color: PaeColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: PaeColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chat Widgets ──────────────────────────────────────────────────────────────

class _AiMessage {
  const _AiMessage({required this.role, required this.text, this.isError = false});
  final String role;
  final String text;
  final bool isError;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final _AiMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? PaeColors.primary
              : message.isError
                  ? PaeColors.error.withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Icon(
                Icons.smart_toy_rounded,
                size: 16,
                color: message.isError ? PaeColors.error : PaeColors.primary,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : PaeColors.textPrimary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_rounded, size: 16, color: PaeColors.primary),
            const SizedBox(width: 8),
            const SizedBox(
              width: 40,
              child: LinearProgressIndicator(
                color: PaeColors.primary,
                backgroundColor: PaeColors.bgLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiInput extends StatelessWidget {
  const _AiInput({
    required this.controller,
    required this.loading,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !loading,
              decoration: InputDecoration(
                hintText: 'Pregunta sobre nutrición…',
                hintStyle: const TextStyle(color: PaeColors.textSecondary, fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: PaeColors.bgLight,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              maxLines: null,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: loading
                ? Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: PaeColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PaeColors.primary,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: onSend,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [PaeColors.gradStart, PaeColors.gradEnd],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
