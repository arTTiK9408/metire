# Metire

**Metire** é um timer Pomodoro TUI (Terminal User Interface) com contador em Braille 8-dot, construído com Dart e Nocterm.

## Instalação

### Binário pré-compilado (Linux x86_64)

Baixe o binário da [página de releases](https://github.com/arTTiK9408/metire/releases):

```bash
chmod +x metire-linux-x86_64
./metire-linux-x86_64
```

### Via Dart

```bash
dart run
```

### Arch Linux (AUR)

```bash
yay -S metire
```

### Debian/Ubuntu

```bash
sudo dpkg -i metire_1.0_amd64.deb
metire
```

### Windows (Chocolatey)

```powershell
choco install metire
metire.exe
```

## Uso

```
         METIRE TUI
       󱓻 󱓼 󱓼 󱓼
     FOCUS (0) PAUSE (S)

            25:00

     Espaço Iniciar  R Reset  Q Sair
```

| Tecla | Ação |
|-------|------|
| `Espaço` | Iniciar / Pausar |
| `R` | Resetar |
| `Q` | Sair |

### Ciclo Pomodoro

- **Foco:** 25 minutos (1500s)
- **Pausa curta:** 5 minutos (300s) — até 3 ciclos
- **Pausa longa:** 15 minutos (900s) — 4º ciclo, então reinicia

## Desenvolvimento

```bash
dart test         # 25 testes
dart analyze      # análise estática
dart compile exe bin/metire.dart -o metire  # build binário
```

### Estrutura do projeto

```
bin/metire.dart              — entrypoint
lib/
├── metire.dart              — exports
└── src/
    ├── models/pomodoro.dart — Pomodoro model
    └── ui/
        ├── tui_app.dart     — TUI layout e teclado
        └── widgets/
            └── counter.dart — contador Braille
test/                        — testes unitários (25)
dist/                        — packaging (Arch, Debian, Windows)
.github/workflows/           — CI/CD
```

### Stack

- **Linguagem:** Dart 3.12+
- **Framework TUI:** Nocterm 0.4.4
- **Testes:** package:test
- **Lints:** package:lints

### Sobre o projeto

Projeto de estudo desenvolvido com assistência do **opencode** (modelo `big-pickle`), explorando conceitos de TUI com Nocterm, TDD, packaging multi-plataforma e CI/CD com GitHub Actions.
