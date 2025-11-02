import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_refugio_app/core/services/storage_service.dart';
import 'package:mi_refugio_app/core/services/theme_controller.dart';
import 'package:mi_refugio_app/shared/constants/app_shadows.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _nameKey = 'profile.name';
  static const _emailKey = 'profile.email';
  static const _phoneKey = 'profile.phone';
  static const _avatarKey = 'profile.avatar';
  static const _notificationsKey = 'profile.notifications';

  final List<String> _avatarOptions = const [
    'assets/images/mascot/pose1.png',
    'assets/images/mascot/pose2.png',
    'assets/images/mascot/pose3.png',
    'assets/images/mascot/pose4.png',
  ];

  String _name = 'Mateo Flores';
  String _email = 'mateo.flores@mirefugio.cl';
  String _phone = '+56 9 1234 5678';
  String _avatarAsset = 'assets/images/mascot/pose2.png';
  bool _notifications = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final storage = StorageService.instance;
    final storedName = storage.getString(_nameKey);
    final storedEmail = storage.getString(_emailKey);
    final storedPhone = storage.getString(_phoneKey);
    final storedAvatar = storage.getString(_avatarKey);
    final storedNotifications = storage.getString(_notificationsKey);

    setState(() {
      if (storedName != null && storedName.isNotEmpty) _name = storedName;
      if (storedEmail != null && storedEmail.isNotEmpty) _email = storedEmail;
      if (storedPhone != null && storedPhone.isNotEmpty) _phone = storedPhone;
      if (storedAvatar != null && storedAvatar.isNotEmpty) {
        _avatarAsset = storedAvatar;
      }
      if (storedNotifications != null) {
        _notifications = storedNotifications.toLowerCase() != 'false';
      }
      _loading = false;
    });
  }

  Future<void> _editProfile() async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar datos personales',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Ingresa un nombre'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final input = value?.trim() ?? '';
                    if (input.isEmpty) return 'Ingresa un correo';
                    if (!input.contains('@')) return 'Correo no válido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono de contacto',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            Navigator.of(context).pop({
                              'name': nameCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim(),
                            });
                          }
                        },
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || result == null) return;

    final storage = StorageService.instance;
    await storage.setString(_nameKey, result['name']!);
    await storage.setString(_emailKey, result['email']!);
    await storage.setString(_phoneKey, result['phone']!);

    if (!mounted) return;

    setState(() {
      _name = result['name']!;
      _email = result['email']!;
      _phone = result['phone']!;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado correctamente')),
    );
  }

  Future<void> _onNotificationsChanged(bool value) async {
    setState(() => _notifications = value);
    await StorageService.instance.setString(
      _notificationsKey,
      value.toString(),
    );
  }

  Future<void> _onAvatarSelected(String asset) async {
    setState(() => _avatarAsset = asset);
    await StorageService.instance.setString(_avatarKey, asset);
  }

  void _toggleTheme() {
    ThemeController.instance.toggle();
    setState(() {});
  }

  void _logout() {
    GoRouter.of(context).go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF0EBFF), Color(0xFFE7F5FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundImage: AssetImage(_avatarAsset),
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '23 · Masculino · Santiago',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(_email, style: theme.textTheme.bodySmall),
                            const SizedBox(height: 2),
                            Text(_phone, style: theme.textTheme.bodySmall),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                FilledButton.icon(
                                  onPressed: _editProfile,
                                  icon: const Icon(Icons.edit_rounded),
                                  label: const Text('Editar perfil'),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.verified_user_rounded),
                                  label: const Text('Credenciales'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  'Selecciona tu avatar',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    for (final asset in _avatarOptions)
                      GestureDetector(
                        onTap: () => _onAvatarSelected(asset),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _avatarAsset == asset
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: _avatarAsset == asset
                                ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.25),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : null,
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundImage: AssetImage(asset),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/government/gobierno_chile.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Programa Salud Mental MINSAL',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Recursos oficiales y lineamientos del Ministerio de Salud de Chile.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                ListTile(
                  leading: const Icon(Icons.badge_rounded),
                  title: const Text('Información personal'),
                  subtitle: const Text(
                    'Actualiza tus datos de contacto y ocupación',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _editProfile,
                ),
                SwitchListTile.adaptive(
                  value: _notifications,
                  onChanged: _onNotificationsChanged,
                  secondary: const Icon(Icons.notifications_active_rounded),
                  title: const Text('Recordatorios de bienestar'),
                  subtitle: const Text(
                    'Respiraciones, diario emocional y hábitos saludables',
                  ),
                ),
                SwitchListTile.adaptive(
                  value: ThemeController.instance.mode == ThemeMode.dark,
                  onChanged: (_) => _toggleTheme(),
                  secondary: const Icon(Icons.dark_mode_rounded),
                  title: const Text('Modo oscuro'),
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text('Cerrar sesión'),
                  onTap: _logout,
                ),
              ],
            ),
    );
  }
}
