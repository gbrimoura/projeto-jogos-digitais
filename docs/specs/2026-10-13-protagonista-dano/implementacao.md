# Implementação — reação de dano v1

## Resultado

O contact comparativo foi aprovado pelo principal antes da integração. A arte reproduzida contém três quadros 64×64, nativos à esquerda, em 80/80/100 ms. O clip runtime `hurt` é não-looping, dura 260 ms e tem prioridade visual sobre dash, ar, aterrissagem e caminhada. Ao terminar, o estado atual do personagem é reaplicado. Hit durante invulnerabilidade não reinicia o clip; dano letal vai direto para morte.

`PlayerHealth` atualiza HP e ativa 0,5 s de invulnerabilidade antes de emitir sinais; `Player` inicia hurt somente por dano aceito com sobrevivência. O flash mantém alpha 1 durante o clip e volta ao pulso mais forte no restante da janela. Inputs, velocidade, dash físico e estado aéreo continuam ativos. O override de `scenes/player.tscn` também foi reduzido para 0,5 s.

## Integração e preservação

O integrador Lua reabriu o snapshot imutável e a arte aprovada, comparou pixels e durações dos 25 frames originais e restaurou/validou o início, fim, direção e repetições de todas as tags após anexar frames, antes de gravar a nova tag `hurt_v1`. Resultado: 28 frames, atlas PNG 1792×64, animação Godot `hurt` com `loop=false` e speed 1. O atlas mantém a área 0–1599 e a fonte runtime mantém os 25 cels baseline sem alteração pixel a pixel.

Godot 4.7.2 importou o projeto via editor em recovery mode com exit 0:

```powershell
Godot_v4.7.2-stable_win64_console.exe --headless --editor --recovery-mode --path <repo> --import --quit
```

O editor registrou `Player`, `PlayerHealth` e `PlayerVisual`, reimportou `player-animations.png` e concluiu o scan. Uma tentativa anterior sem recovery não concluiu: a extensão preexistente `addons/godot-git-plugin/git_plugin.gdextension` não abriu a DLL nativa indicada pelo plugin e Godot encerrou com signal 11 durante `first_scan_filesystem`. O addon e os arquivos temporários existentes não foram alterados. Recovery mode foi usado com autorização do principal e desativa ferramentas/plugins/GDExtensions que causam o crash.

## Arquivos runtime congelados e hashes

SHA-256 após integração/importação:

| Arquivo | SHA-256 |
|---|---|
| `assets/player/player-animations.png` | `FF8EDE966AB19A3395CAD1EA7B28E3B5920D7042736ED0D4EB965EF3FFF69FDA` |
| `assets/player/source/player-animations.aseprite` | `FAAD4270FC0A8B8CA08D2662BF1EB64FE84195BAF5483E3F5E9B11212A5DEBB3` |
| `resources/player_sprite_frames.tres` | `38C1DE56C724DFD0526BEF8D3CC49859EEC4A4C195D2045F293F4A353D947164` |
| `scenes/player.tscn` | `A98540A71C4309C32136E39D3179F21A52E5463D88254B19BCBEA1BA8700B45E` |
| `scripts/player/player_health.gd` | `1127F2E826C2DCFB04C6D9AD121B3802FA9504428FD4D3E6F6D727B299B8EE8E` |
| `scripts/player/player.gd` | `5C0EB27CA07F933DB71A3AA5A4B0368AA6C293C5B0810F488D715CFA6D344951` |
| `scripts/player/player_visual.gd` | `278B897A0CA12CAE987725B0FC25C609536E8D31B0CE747EC5F785FC6745153F` |
| Art integrator `integrar-protagonista-hurt-v1.lua` | `A3FFFC51752213F96FFAFC96F627086520DAB20641AE9F60BE17EA7323908B45` |

Hashes dos artefatos reproduzidos, prompt/resumo e extração constam em `GDD_Dieselpunk_Noir/pitch-assets/protagonista-hurt-v1/README.md` e `protagonista-hurt-v1-metadata.json`.

## Escopo de validação e revisão

- Aseprite real: execução do gerador e integrador; assertions de 25/25 frames/timings/tag invariants passaram; atlas final 1792×64.
- Godot 4.7.2 editor: import autorizado em recovery mode, exit 0.
- Não foram adicionados nem executados testes, gameplay ou quality audit.
- Gemini, Muse e Grok concluíram a revisão estática final sem correções obrigatórias; stdout e avaliação do principal em [pareceres/README.md](pareceres/README.md). Claude Opus 5.5 High `claude-opus-5-5-high` não foi disponível no preflight por quota; nenhum substituto foi usado.
- Avaliação estética final pelo usuário em runtime continua pendente.
