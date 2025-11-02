import "package:flutter/material.dart";

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alimentación")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _MacroTile(
            title: "Carbohidratos",
            detail: "150 g recomendados",
            color: Color(0xFFFFA79D),
          ),
          SizedBox(height: 12),
          _MacroTile(
            title: "Proteínas",
            detail: "70 g recomendados",
            color: Color(0xFFFFD97C),
          ),
          SizedBox(height: 12),
          _MacroTile(
            title: "Grasas saludables",
            detail: "50 g recomendados",
            color: Color(0xFF9ED9C5),
          ),
          SizedBox(height: 24),
          Text("Consejos rápidos"),
          SizedBox(height: 12),
          _TipCard(
            text:
                "Planifica tus comidas con antelación para evitar saltarte tiempos importantes.",
          ),
          SizedBox(height: 12),
          _TipCard(
            text:
                "Hidrátate con al menos 6 vasos de agua al día, y prioriza frutas y verduras frescas.",
          ),
        ],
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.title,
    required this.detail,
    required this.color,
  });

  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14352F44),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(detail, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14352F44),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(text),
    );
  }
}
