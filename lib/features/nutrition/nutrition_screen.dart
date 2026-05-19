import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app/theme.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/user_model.dart';

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
            'basados en los alimentos que hayas registrado. '
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

    // Build context summary of today's food
    final foodContext = _entries.isEmpty
        ? 'No hay alimentos registrados hoy.'
        : 'Alimentos registrados hoy:\n' +
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
Puedes dar recetas, consejos de nutrición, análisis de la dieta del día y sugerencias.
Responde siempre en español, de forma amigable, clara y práctica.
Considera las tradiciones alimentarias colombianas cuando sea relevante.

Contexto nutricional actual del usuario:
$foodContext
''';

    // Build messages history for API
    final apiMessages = <Map<String, String>>[];
    for (final msg in _aiMessages) {
      apiMessages.add({'role': msg.role, 'content': msg.text});
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
          'anthropic-dangerous-direct-browser-access': 'true',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1024,
          'system': systemPrompt,
          'messages': apiMessages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['content'] as List<dynamic>;
        final text = content
            .where((c) => c['type'] == 'text')
            .map((c) => c['text'] as String)
            .join('');
        setState(() {
          _aiMessages.add(_AiMessage(role: 'assistant', text: text));
        });
      } else {
        setState(() {
          _aiMessages.add(_AiMessage(
            role: 'assistant',
            text: 'Lo siento, tuve un problema al procesar tu consulta. '
                'Por favor intenta de nuevo.',
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
      builder: (_) => _AddFoodSheet(
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
            subtitle: 'Registro de alimentos y asesoría IA',
            height: 110,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                onPressed: _showAddFoodDialog,
                tooltip: 'Registrar alimento',
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
                Tab(icon: Icon(Icons.restaurant_menu_rounded), text: 'Registro'),
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
                        Icons.fastfood_rounded,
                        size: 56,
                        color: PaeColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sin alimentos registrados',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: PaeColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toca + para añadir tu primer alimento\ndel día',
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
                  onTap: () => _sendAiMessage('¿Cómo está mi dieta hoy según lo que he comido?'),
                ),
                _QuickChip(
                  label: 'Dame una receta con lo que tengo',
                  onTap: () => _sendAiMessage(
                      'Con los alimentos que he registrado hoy, ¿qué receta saludable me recomiendas para completar el día?'),
                ),
                _QuickChip(
                  label: 'Consejo nutricional',
                  onTap: () => _sendAiMessage(
                      'Basándote en lo que he comido hoy, dame un consejo de nutrición personalizado.'),
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

// ── Add Food Sheet ────────────────────────────────────────────────────────────

class _AddFoodSheet extends StatefulWidget {
  const _AddFoodSheet({required this.onAdd});

  final void Function(FoodEntry) onAdd;

  @override
  State<_AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<_AddFoodSheet> {
  final _nameCtrl = TextEditingController();
  final _portionCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  MealType _selectedMeal = MealType.lunch;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _portionCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) return;

    final entry = FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      calories: double.tryParse(_caloriesCtrl.text) ?? 0,
      protein: double.tryParse(_proteinCtrl.text) ?? 0,
      carbs: double.tryParse(_carbsCtrl.text) ?? 0,
      fat: double.tryParse(_fatCtrl.text) ?? 0,
      portion: _portionCtrl.text.trim().isEmpty ? '1 porción' : _portionCtrl.text.trim(),
      mealType: _selectedMeal,
      registeredAt: DateTime.now(),
    );

    widget.onAdd(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PaeColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_circle_outline_rounded,
                      color: PaeColors.primary),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Registrar alimento',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    fontFamily: PaeTypography.fontDisplay,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Meal type selector
            const Text(
              'Tipo de comida',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: PaeColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: MealType.values.map((m) {
                final selected = m == _selectedMeal;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMeal = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? m.color.withOpacity(0.15)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? m.color : Colors.transparent,
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
                              color: selected ? m.color : PaeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Fields
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del alimento *',
                prefixIcon: Icon(Icons.restaurant_rounded),
                hintText: 'Ej: Arroz con pollo',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _portionCtrl,
              decoration: const InputDecoration(
                labelText: 'Porción',
                prefixIcon: Icon(Icons.scale_rounded),
                hintText: 'Ej: 1 plato mediano, 200g',
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _caloriesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Calorías',
                      suffixText: 'kcal',
                      prefixIcon: Icon(Icons.local_fire_department_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _proteinCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Proteína',
                      suffixText: 'g',
                      prefixIcon: Icon(Icons.fitness_center_rounded),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _carbsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Carbohidratos',
                      suffixText: 'g',
                      prefixIcon: Icon(Icons.grain_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _fatCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Grasas',
                      suffixText: 'g',
                      prefixIcon: Icon(Icons.opacity_rounded),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Guardar alimento',
              icon: Icons.check_rounded,
              onPressed: _submit,
            ),
          ],
        ),
      ),
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
                label: 'Recetas saludables PAE',
                onTap: () => onSuggestionTap(
                    'Dame 3 recetas saludables típicas del PAE colombiano, fáciles de preparar.'),
              ),
              _QuickChip(
                label: '¿Qué debo comer hoy?',
                onTap: () => onSuggestionTap(
                    'No he comido nada aún. ¿Qué menú balanceado me recomiendas para hoy?'),
              ),
              _QuickChip(
                label: 'Nutrición para niños',
                onTap: () => onSuggestionTap(
                    'Dame consejos de nutrición para niños en edad escolar en el contexto del PAE.'),
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
