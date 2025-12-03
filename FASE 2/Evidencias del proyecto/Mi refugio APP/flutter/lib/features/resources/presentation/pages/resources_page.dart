// ignore_for_file: prefer_single_quotes
import "package:flutter/material.dart";
import "package:mi_refugio_app/shared/constants/app_colors.dart";
import "package:mi_refugio_app/shared/constants/app_gradients.dart";
import "package:mi_refugio_app/shared/constants/app_shadows.dart";
import "package:mi_refugio_app/shared/data/mental_health_resources.dart";
import "package:mi_refugio_app/shared/models/resource_item.dart";

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = "Todos";

  final _categories = const [
    "Todos",
    "Urgencia",
    "Juventud",
    "Profesionales",
    "Comunidad",
    "Mindfulness",
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _applyFilters(mentalHealthResources);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.softBackground,
        color: theme.scaffoldBackgroundColor,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(title: const Text("Recursos profesionales")),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppShadows.soft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Encuentra apoyo a tu medida",
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Directorios avalados, líneas de contención 24/7 y programas de bienestar emocional.",
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: "Buscar por entidad o palabra clave",
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () =>
                                    setState(() => _searchCtrl.clear()),
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories
                    .map(
                      (category) => ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = category),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              if (filtered.isEmpty)
                _EmptyState(
                  onClear: () {
                    setState(() {
                      _selectedCategory = "Todos";
                      _searchCtrl.clear();
                    });
                  },
                )
              else
                ...filtered.map((item) => _ResourceCard(item: item)),
            ],
          ),
        ),
      ),
    );
  }

  List<ResourceItem> _applyFilters(List<ResourceItem> items) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return items.where((resource) {
      final matchesCategory = _selectedCategory == "Todos" ||
          resource.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesQuery = query.isEmpty ||
          resource.title.toLowerCase().contains(query) ||
          resource.description.toLowerCase().contains(query) ||
          resource.subtitle.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.item});

  final ResourceItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  item.asset,
                  height: 48,
                  width: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(item.subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F0FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(item.category, style: theme.textTheme.labelLarge),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.description, style: theme.textTheme.bodyMedium),
          if (item.contact != null) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _launchUrl(context, 'tel:${item.contact!.replaceAll(' ', '')}'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.phone_in_talk_rounded, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      item.contact!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (item.website != null) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _launchUrl(context, item.website!),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.public_rounded, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item.website!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          const Icon(Icons.psychology_alt_outlined, size: 56),
          const SizedBox(height: 12),
          Text(
            "No encontramos coincidencias",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            "Ajusta tu búsqueda o explora otra categoría para descubrir alternativas.",
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Restablecer filtros"),
          ),
        ],
      ),
    );
  }
}

