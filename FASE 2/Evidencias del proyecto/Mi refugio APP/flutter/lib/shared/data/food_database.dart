class FoodItem {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String unit;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.unit = 'porción',
  });
}

const commonFoods = [
  FoodItem(name: 'Manzana', calories: 52, protein: 0.3, carbs: 14, fat: 0.2, unit: 'unidad'),
  FoodItem(name: 'Plátano', calories: 89, protein: 1.1, carbs: 23, fat: 0.3, unit: 'unidad'),
  FoodItem(name: 'Huevo duro', calories: 155, protein: 13, carbs: 1.1, fat: 11, unit: 'unidad'),
  FoodItem(name: 'Pan integral', calories: 265, protein: 9, carbs: 49, fat: 3, unit: 'rebanada'),
  FoodItem(name: 'Pollo (pechuga)', calories: 165, protein: 31, carbs: 0, fat: 3.6, unit: '100g'),
  FoodItem(name: 'Arroz blanco', calories: 130, protein: 2.7, carbs: 28, fat: 0.3, unit: '100g'),
  FoodItem(name: 'Lentejas', calories: 116, protein: 9, carbs: 20, fat: 0.4, unit: '100g'),
  FoodItem(name: 'Yogurt natural', calories: 59, protein: 10, carbs: 3.6, fat: 0.4, unit: '100g'),
  FoodItem(name: 'Almendras', calories: 579, protein: 21, carbs: 22, fat: 50, unit: '100g'),
  FoodItem(name: 'Palta (Aguacate)', calories: 160, protein: 2, carbs: 9, fat: 15, unit: '100g'),
  FoodItem(name: 'Avena', calories: 389, protein: 16.9, carbs: 66, fat: 6.9, unit: '100g'),
  FoodItem(name: 'Leche descremada', calories: 34, protein: 3.4, carbs: 5, fat: 0.1, unit: '100ml'),
];
