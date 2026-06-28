import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar_view.dart';

/// Criação de perfil infantil: nome, idade opcional e avatar base.
class ProfileCreateScreen extends StatefulWidget {
  const ProfileCreateScreen({super.key});

  @override
  State<ProfileCreateScreen> createState() => _ProfileCreateScreenState();
}

class _ProfileCreateScreenState extends State<ProfileCreateScreen> {
  final TextEditingController _name = TextEditingController();
  int? _age;
  String _avatarId = kAvatarBases.first.id;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para o perfil.')),
      );
      return;
    }
    await context
        .read<AppState>()
        .createProfile(name: name, age: _age, avatarBaseId: _avatarId);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Perfil'),
        backgroundColor: AppColors.kidsBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Pré-visualização do avatar selecionado.
              Column(
                children: <Widget>[
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(colors: <Color>[
                        Color.lerp(
                            avatarBaseById(_avatarId).color, Colors.white, 0.6)!,
                        Color.lerp(avatarBaseById(_avatarId).color,
                            Colors.white, 0.2)!,
                      ]),
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Image.asset(avatarBaseById(_avatarId).asset,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.face_rounded,
                              size: 90,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_name.text.isEmpty ? 'Novo Explorador' : _name.text,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Nome',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _name,
                        onChanged: (_) => setState(() {}),
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Ex.: Lucas',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Idade (opcional)',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: <Widget>[
                          for (int age = 4; age <= 8; age++)
                            ChoiceChip(
                              label: Text('$age anos'),
                              selected: _age == age,
                              onSelected: (_) => setState(() => _age = age),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Escolha o avatar',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: kAvatarBases.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (BuildContext context, int i) {
                            final AvatarBase a = kAvatarBases[i];
                            final bool sel = a.id == _avatarId;
                            return GestureDetector(
                              onTap: () => setState(() => _avatarId = a.id),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Color.lerp(
                                      a.color, Colors.white, 0.55),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: sel
                                        ? AppColors.kidsBlue
                                        : Colors.transparent,
                                    width: 4,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Image.asset(a.asset,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.face_rounded,
                                          size: 40,
                                          color: Colors.white)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Criar Perfil'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kidsGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
