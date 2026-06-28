# 📝 Progresso & Memória — Educa Games

Última atualização: 2026-06-28. Branch: `claude/educa-games-product-bible-ncu58l`.

## 🔗 Como testar (link ao vivo)
- Repo é **público** + GitHub Pages via **GitHub Actions** (Settings → Pages → Source: GitHub Actions).
- A cada push na branch, o workflow `.github/workflows/deploy-web.yml` compila web + APK e publica.
- **Link:** https://reginaldomedeiros.github.io/Educagames/
- Abrir **em aba anônima** (ou hard refresh) pra evitar cache; **modo paisagem**.
- APK (Android) também sai como artifact em Actions → run → Artifacts → `educa-games-apk` (usuário usa **iPhone**, então o foco é o link web).

## ✅ Pronto (funcionando)
- Fluxo completo: splash → PIN dos pais → perfis → Biblioteca Central → mundos → jogos → recompensa.
- 4 jogos: **Memória, Quebra-Cabeça, Letras e Números** funcionais; **Colorir** com line-art real (pinta tocando/arrastando).
- **Mascote real** (Mestre Corujão) integrado.
- **24 avatares reais** (12+12) fatiados; seleção/perfil usam a arte real.
- **Loja de avatar** com 36 chapéus + 25 óculos reais (cosméticos = coleção, sem vestir no corpo — decisão "versão A" do escopo).
- Controle parental (limite diário, horário, tempo extra com PIN, relatório), estrelas/moedas, conquistas, álbum (com fallback de ícone).
- **Cenários de fundo** nos mundos **Oceano, Dinossauros, Biblioteca** com 3 botões sobre os medalhões + Letras e Números no topo.

## ⏳ Pendências (continuar amanhã)
1. **Ajustar posição dos botões** dos cenários (usuário vai testar e dizer "sobe/desce/lados"). Editar `lib/data/world_scenes.dart` → `kDefaultSlots` (ou `slots` por mundo). São frações 0..1 da tela.
2. **Identificar cenários de Animais, Espaço e Hub** entre os mockups não-abertos (ver tabela abaixo) e ligar em `kWorldScenes`. Enviar candidatos por `SendUserFile` pro usuário rotular (meu preview falha pelo limite de 32 MB).
3. **Arte premium de Colorir + Adesivos** (gerada no ChatGPT pelo usuário): está no Drive, mas **não dá pra puxar pelo conector** (base64 gigante). Plano: usuário sobe via **git push de um computador** para `incoming/colorir/` e `incoming/adesivos/` → eu `git pull`, fatio/limpo fundo, troco os provisórios e ligo no Álbum (`StickerDef.asset` + registrar `assets/stickers/` no pubspec).
4. **Mapear folhas de cosméticos** (mochilas/sapatos/acessórios/chapéus extras) e fatiar na loja. Hashes candidatos abaixo.
5. (Opcional) cenário de fundo no **Hub** e telas de jogo.

## 🧠 Aprendizados/gotchas importantes (não repetir investigação)
- **Limite de 32 MB por requisição**: o chat já está cheio de imagens; **não tentar visualizar/enviar imagens novas** — dispara "Request too large". Para erros, usar **logs de CI** (GitHub MCP) ou pedir **texto**.
- **Rede de saída bloqueada** (só registries de pacote + Anthropic). Não dá `curl` em drive.google.com nem github.io. `git` (via proxy) funciona.
- **Google Drive MCP**: lista arquivos ok (após aprovação do usuário), mas `download_file_content` retorna base64 enorme (centenas de milhares de tokens/imagem) → **inviável** para baixar arte. Pasta: `1aCyZ6nRCvl_h7q4QNJGjHLU_5vNJJjKD`.
- **Higgsfield (geração de imagem)**: usuário **sem créditos** → não usar.
- **GitHub Pages**: exige repo público (usuário já tornou público).
- Ferramenta de fatiar sprites: `tool/slice_sheets.py` (segmenta por gaps, remove fundo branco por flood-fill das bordas). `tool/make_coloring.py` gera line-art.

## 🗂️ Mapa das imagens de referência (assets/references/approved_screens/)
Identificadas: `39684cea`=style guide/hub · `31ac2837`=mascote · `3f34678e`=avatares meninos · `419ab2cc`=avatares meninas · `760348f9`=óculos · `41e19631`=chapéus · `0bd0b184`=mundo Biblioteca · `46bfae18`=mundo Oceano · `836da5bd`=mundo Dinossauros · `353c5650`=tela Perfil · `39a6799d`=tela Avatar · `3fa53116`=tela Conquistas · `718e03af`/`25323434`=mockup de jogo.

A identificar (full-screen): `53fd7fa9`, `7e985abe`, `ace1680a`, `b7fb46c3`, `bbcbda06`, `e69cbc60`, `f5f8a200` → prováveis Animais/Espaço/Hub/telas de jogo/parental/recompensa/tempo/splash.

Folhas de cosméticos a mapear (usuário disse: mochilas/sapatos/acessórios/chapéus + mascote + guia): `30a57792`(guia?), `454eebdf`, `da060fda`, `d064dfc4`, `ec7f5d61`, `b2793897`, `325511a9`.

## 📁 Arquivos-chave
- `lib/data/world_scenes.dart` — cenários e posição dos botões.
- `lib/screens/world_screen.dart` — layout com cenário (`_SceneLayout`) e fallback (`_GradientLayout`).
- `lib/widgets/avatar_view.dart` — avatar (personagem inteiro, sem overlay).
- `lib/data/cosmetics.dart` — catálogo gerado das folhas reais.
- `lib/screens/games/coloring_game_screen.dart` — Colorir com line-art.
- `tool/` — slicers Python.
- `incoming/` — pasta para o usuário subir arte nova (colorir/adesivos/cosméticos).
