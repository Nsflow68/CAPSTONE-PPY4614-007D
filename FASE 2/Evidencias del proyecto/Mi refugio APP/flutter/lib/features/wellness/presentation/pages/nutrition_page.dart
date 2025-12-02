import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_refugio_app/features/wellness/application/nutrition_providers.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';
import 'package:mi_refugio_app/shared/constants/app_shadows.dart';
import 'package:mi_refugio_app/shared/models/nutrition_daily_summary.dart';
import 'package:mi_refugio_app/shared/models/nutrition_log.dart';
import 'package:mi_refugio_app/shared/data/food_database.dart';
import 'package:mi_refugio_app/core/services/notification_service.dart';

class NutritionPage extends ConsumerWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateUtils.dateOnly(DateTime.now());
    final summaryAsync = ref.watch(nutritionSummaryProvider(today));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Pastel Green Background
      appBar: AppBar(
        title: const Text('Alimentación'),
        backgroundColor: Colors.transparent,

      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(nutritionSummaryProvider(today));
        },
        child: summaryAsync.when(
          data: (summary) => _NutritionContent(summary: summary),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMealSheet(context, ref),
        label: const Text('Registrar Comida'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFAED581),
      ),
    );
  }
}

class _NutritionContent extends StatelessWidget {
  final NutritionDailySummary? summary;

  const _NutritionContent({required this.summary});

  @override
  Widget build(BuildContext context) {
    final totals = summary?.totals;
    final logs = summary?.logs ?? [];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Chart Section
        _NutritionChartCard(totals: totals),
        const SizedBox(height: 24),

        // Meals List
        Text(
          'Comidas de hoy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (logs.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No has registrado comidas hoy.'),
            ),
          )
        else
          ...logs.map((log) => _MealCard(log: log)),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }
}

class _NutritionChartCard extends StatelessWidget {
  final NutritionTotals? totals;

  const _NutritionChartCard({required this.totals});

  @override
  Widget build(BuildContext context) {
    final calories = totals?.calories ?? 0;
    final protein = totals?.protein ?? 0;
    final carbs = totals?.carbs ?? 0;
    final fat = totals?.fat ?? 0;

    // Calculate percentages for chart (avoid division by zero)
    final totalMacros = protein + carbs + fat;
    final pProtein = totalMacros > 0 ? (protein / totalMacros) * 100 : 33.3;
    final pCarbs = totalMacros > 0 ? (carbs / totalMacros) * 100 : 33.3;
    final pFat = totalMacros > 0 ? (fat / totalMacros) * 100 : 33.3;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resumen Diario',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEDC8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${calories.toInt()} kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF558B2F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Pie Chart & Legend
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: const Color(0xFF9ED9C5), // Green (Fats)
                        value: pFat,
                        title: '${pFat.toInt()}%',
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A6B61),
                        ),
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFFFAB91), // Pink/Red (Carbs)
                        value: pCarbs,
                        title: '${pCarbs.toInt()}%',
                        radius: 70,
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8D4D42),
                        ),
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFFFD54F), // Yellow (Protein)
                        value: pProtein,
                        title: '${pProtein.toInt()}%',
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8D7832),
                        ),
                      ),
                    ],
                  ),
                ),
                // Legend Overlay
                Positioned(
                  right: 0,
                  top: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ChartLegendItem(
                        color: const Color(0xFFFFAB91),
                        label: 'Carbohidratos',
                        value: '${carbs.toInt()} g',
                      ),
                      const SizedBox(height: 8),
                      _ChartLegendItem(
                        color: const Color(0xFFFFD54F),
                        label: 'Proteína',
                        value: '${protein.toInt()} g',
                      ),
                      const SizedBox(height: 8),
                      _ChartLegendItem(
                        color: const Color(0xFF9ED9C5),
                        label: 'Grasas',
                        value: '${fat.toInt()} g',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLegendItem extends StatelessWidget {
  const _ChartLegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final NutritionLog log;

  const _MealCard({required this.log});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (log.mealType.toLowerCase()) {
      case 'breakfast':
        icon = Icons.breakfast_dining;
        color = const Color(0xFFFFCC80);
        break;
      case 'lunch':
        icon = Icons.lunch_dining;
        color = const Color(0xFFA5D6A7);
        break;
      case 'dinner':
        icon = Icons.dinner_dining;
        color = const Color(0xFF90CAF9);
        break;
      default:
        icon = Icons.restaurant;
        color = const Color(0xFFCE93D8);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color.withOpacity(1.0), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _translateMealType(log.mealType),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${log.calories.toInt()} kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _translateMealType(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return 'Desayuno';
      case 'lunch':
        return 'Almuerzo';
      case 'dinner':
        return 'Cena';
      case 'snack':
        return 'Snack';
      default:
        return type;
    }
  }
}

Future<void> _showAddMealSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _AddMealSheet(),
  );
  // Refresh data after closing sheet
  final today = DateUtils.dateOnly(DateTime.now());
  ref.invalidate(nutritionSummaryProvider(today));
}

class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet();

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  String _selectedType = 'Breakfast';
  FoodItem? _selectedFood;
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _onFoodSelected(FoodItem? food) {
    setState(() {
      _selectedFood = food;
      if (food != null) {
        _caloriesController.text = food.calories.toString();
        _proteinController.text = food.protein.toString();
        _carbsController.text = food.carbs.toString();
        _fatController.text = food.fat.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registrar Comida',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo de comida',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Breakfast', child: Text('Desayuno')),
                DropdownMenuItem(value: 'Lunch', child: Text('Almuerzo')),
                DropdownMenuItem(value: 'Dinner', child: Text('Cena')),
                DropdownMenuItem(value: 'Snack', child: Text('Snack')),
              ],
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<FoodItem>(
              value: _selectedFood,
              decoration: const InputDecoration(
                labelText: 'Seleccionar alimento (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              items: [
                const DropdownMenuItem<FoodItem>(
                  value: null,
                  child: Text('Personalizado / Otro'),
                ),
                ...commonFoods.map((food) => DropdownMenuItem(
                      value: food,
                      child: Text('${food.name} (${food.unit})'),
                    )),
              ],
              onChanged: _onFoodSelected,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calorías (kcal)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _proteinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Proteína (g)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _carbsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Carbs (g)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _fatController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Grasas (g)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: Consumer(
                builder: (context, ref, _) {
                  return FilledButton(
                    onPressed: () async {
                      final log = NutritionLog(
                        date: DateTime.now(),
                        mealType: _selectedType,
                        calories: double.tryParse(_caloriesController.text) ?? 0,
                        protein: double.tryParse(_proteinController.text) ?? 0,
                        carbs: double.tryParse(_carbsController.text) ?? 0,
                        fat: double.tryParse(_fatController.text) ?? 0,
                        foodItems: _selectedFood != null ? [_selectedFood!.name] : [],
                      );
        
                      try {
                        await ref.read(nutritionRepositoryProvider).logMeal(log);
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Guardar Registro'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
