# Metire

**Metire** é um timer Pomodoro TUI com contador em Braille 8-dot, construído com Dart e Nocterm. Seguindo os princípios originais criados por Francesco Cirillo:

1. Escolher a tarefa ou tarefas a serem executadas;
2. Ajustar o cronômetro para o tempo desejado (geralmente 25 minutos);
3. Trabalhar na tarefa escolhida até que o alarme toque. Se alguma distração importante surgir, anotá-la e voltar o foco à tarefa;
4. Quando o alarme tocar, fazer uma marcação em um papel para contabilizar o intervalo;
5. Se houver menos de 4 marcações, fazer uma pausa curta (3–5 minutos);
6. Após a quarta marcação, fazer uma pausa mais longa (20–30 minutos), zerar a contagem e retornar ao passo 1.

## Instalação

### Linux / macOS (recomendado)

```bash
curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/install.sh | sh
```

### Windows

Baixe o binário da [página de releases](https://github.com/arTTiK9408/metire/releases) e execute `metire-windows-x86_64.exe`.

### Via Dart (desenvolvimento)

```bash
dart run
```

## Desinstalação

```bash
curl -sS https://raw.githubusercontent.com/arTTiK9408/metire/main/uninstall.sh | sh
```

## Uso

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
install.sh                   — instalador universal
uninstall.sh                 — removedor universal
.github/workflows/           — CI/CD
```

### Stack

- **Linguagem:** Dart 3.12+
- **Framework TUI:** Nocterm 0.4.4
- **Testes:** package:test
- **Lints:** package:lints

### Sobre o projeto

Projeto de estudo desenvolvido com assistência do **opencode** (modelo `big-pickle`), explorando conceitos de TUI com Nocterm, TDD, packaging multi-plataforma e CI/CD com GitHub Actions.

## TODO

Funcionalidades planejadas para versões futuras:

- [ ] **Sessões persistentes** — salvar e restaurar o estado do timer entre execuções, com estatísticas acumuladas de ciclos concluídos e tempo total de foco
- [ ] **Arquivo de configuração** — personalizar cores, tempos dos modos e atalhos de teclado via arquivo YAML/JSON (`~/.config/metire/config.yaml`)
- [ ] **Notificações e alerta sonoro** — sinal ao final de cada modo (foco, pausa curta, pausa longa), com suporte a notificações do sistema e beep no terminal
- [ ] **Tempos personalizáveis** — permitir ajustar durações de foco, pausa curta e pausa longa na interface ou no arquivo de configuração
- [ ] **Log de histórico** — registro local das sessões concluídas com data, duração e modo, exportável em CSV/JSON
- [ ] **Múltiplos perfis** — suporte a diferentes configurações (ex.: trabalho, estudos, exercícios) alternáveis em tempo de execução
- [ ] **Modo escuro/claro** — tema alternativo claro para melhor legibilidade em ambientes bem iluminados
- [ ] **Ícones Nerd Font opcionais** — fallback textual para terminais sem Nerd Font instalada
