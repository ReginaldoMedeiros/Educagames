# Educa Games

> Aprender brincando, no tempo certo.

Aplicativo educativo infantil (4–8 anos) em **Flutter**, em **modo paisagem** e
**100% em Português do Brasil**, com minijogos, personalização de avatar,
progressão por estrelas, álbum de colecionáveis e um forte diferencial de
**controle parental de tempo de tela**.

Este repositório contém o **MVP navegável e funcional** descrito no Documento
Mestre do Produto (Fases 1–4): fluxo completo da criança e área dos pais, com
os 4 minijogos funcionais.

## O que já está implementado

- **Orientação**: todo o app é travado em landscape (`main.dart`).
- **Onboarding dos pais**: criação de PIN numérico (4 dígitos) com confirmação.
- **Perfis infantis**: criação, seleção e exclusão (1 no plano gratuito, até 5 no Premium).
- **Biblioteca Central (hub)**: 5 portais de mundos + menu (Avatar, Álbum, Conquistas, Perfil) e acesso à Área dos Pais.
- **Mundos**: Animais, Dinossauros, Espaço, Oceano e Biblioteca, com bloqueio por estrelas (lógica pronta).
- **Minijogos funcionais**:
  - **Memória** (grade 4×3, tema do mundo)
  - **Colorir** (pintura por células, paleta de 8 cores, desfazer/limpar/concluir)
  - **Quebra-Cabeça** (3×3 deslizante com dica)
  - **Letras e Números** (quiz PT-BR com ilustrações)
- **Recompensas**: estrelas (progresso) e moedas (cosméticos), adesivos temáticos, conquistas e tela de recompensa com o Mestre Corujão.
- **Avatar**: compra (moedas) e equipa cosméticos em camadas, por raridade.
- **Álbum do Explorador**: colecionáveis por categoria (coletados x silhuetas) com % de conclusão.
- **Conquistas**: 15 conquistas iniciais com progresso.
- **Controle Parental** (visual profissional, estilo Family Link):
  - Jogando Agora, Uso de Hoje, Relatório Semanal
  - Limite Diário (15/30/60/90/120 min)
  - Horário Permitido (faixa horária)
  - Tempo Extra (+15/+30/+60, exige PIN)
  - Proteção por PIN e troca de PIN
  - Plano Gratuito/Premium (feature flag local)
- **Controle de tempo**: contagem de tempo ativo em foreground, bloqueio dos jogos
  ao atingir o limite ou fora do horário, tela de tempo encerrado (mantém avatar,
  álbum e conquistas acessíveis).

O **Mestre Corujão** é o mascote oficial, desenhado em `CustomPaint` (sem assets externos).

## Arquitetura

- **Estado**: `provider` + `ChangeNotifier` (`lib/state/app_state.dart`) como fonte única de verdade.
- **Persistência**: local via `shared_preferences` (`lib/services/storage_service.dart`).
  A estrutura de dados espelha as coleções Firestore sugeridas (users, childProfiles,
  parentalSettings, etc.) e está **preparada para migração para Firebase** (Auth/Firestore).
- **Tema**: dois temas — infantil (vibrante) e dos pais (sóbrio) — em `lib/theme/`.

```
lib/
  data/        # catálogos: mundos, conquistas, adesivos, cosméticos, recompensas, conteúdo dos jogos
  models/      # ChildProfile, ParentalSettings, World
  services/    # StorageService (SharedPreferences)
  state/       # AppState (ChangeNotifier)
  screens/     # telas (onboarding, hub, mundos, jogos, avatar, álbum, conquistas, perfil, pais)
  widgets/     # Mestre Corujão, avatar, PIN pad, botões grandes
  theme/       # cores e temas
```

## Como executar

Este repositório contém apenas o código Dart (`lib/`) e o `pubspec.yaml`. As pastas
de plataforma (`android/`, `ios/`, `web/`) são geradas pelo Flutter:

```bash
# 1. Gerar o scaffolding de plataforma (mantém o lib/ existente)
flutter create . --platforms=android,ios,web

# 2. Baixar dependências
flutter pub get

# 3. Rodar (emulador/dispositivo em landscape)
flutter run

# Análise estática e testes
flutter analyze
flutter test
```

Requer **Flutter 3.27+** (uso de `Color.withValues` e `CardThemeData`).

## Próximos passos (fora do MVP atual)

- Integração real com Firebase (Auth, Firestore, Storage, Analytics, Crashlytics, Remote Config).
- Assinatura real via loja (atualmente feature flag local).
- Assets de arte 2D (mascote, mundos, desenhos, cosméticos).
- Recompensa diária (estrutura prevista, ver documento mestre §28).

Itens **fora do MVP** (chat IA, voz do mascote, multiplayer, ranking, loot boxes,
compra de estrelas, etc.) **não** são implementados, conforme as regras éticas do produto.
