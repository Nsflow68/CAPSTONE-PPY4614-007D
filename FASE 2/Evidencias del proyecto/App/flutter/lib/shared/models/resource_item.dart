class ResourceItem {
  const ResourceItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.asset,
    this.contact,
    this.website,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final String asset;
  final String? contact;
  final String? website;

  factory ResourceItem.fromJson(Map<String, dynamic> json) {
    return ResourceItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      asset: json['asset']?.toString() ?? '',
      contact: json['contact']?.toString(),
      website: json['website']?.toString(),
    );
  }
}
