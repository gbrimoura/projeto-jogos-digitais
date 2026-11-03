# Lobby pixel-art kit — V1

## Estado

A arte R3 foi gerada no Aseprite 1.3.18.6 após revisão visual do principal; `Sprite:setPalette()` aplica diretamente a paleta editável de 20 cores nas fontes `.aseprite`. A integração foi feita somente em `scripts/world/lobby_visual.gd`; revisão estática final permanece com o principal. As imagens de contexto são estudos, não captura/runtime.

## Conteúdo

- `source/generate_lobby.lua` — gerador Aseprite Lua reproduzível e única fonte raster procedural/autoral.
- `source/lobby-backdrop.aseprite` — canvas 576×324, seis layers editáveis.
- `source/elevator-doors.aseprite` — canvas 32×56, folhas esquerda/direita em layers separados.
- `export/lobby-backdrop-576x324.png` — background nativo 576×324; transparente em todas as linhas y=280–323.
- `export/elevator-door-left-32x56.png` e `export/elevator-door-right-32x56.png` — portas nativas 32×56.
- `manifest.json` — paleta, regiões, dimensões, correspondência para o mundo lógico, previews e hashes.
- `preview/` — contextos estáticos com o Hero original e versões ampliadas.

## Escala e montagem prevista

Desenhar cada asset PNG em destino lógico 2× nearest: backdrop em Rect2(0,0,1152,648); cada porta em Rect2(0,0,64,112). O backdrop deixa o piso inteiro transparente a partir de y=280 nativo (y=560 no mundo), para que o código/atlas atual continue sendo a única arte do piso. As folhas usam posições atuais, sem alterar interpolação: esquerda x=848→912 e direita x=1040→976, ambas y=448.

Os PNGs de produção não contêm o Player, piso, placa âmbar, texto bitmap ou estado das luzes. Placa/letreiro/indicadores permanecem sobre o backdrop, e a cena preserva o Player e o atlas existentes. Não há geometria, colisão ou plataforma nestes assets.

## Paleta e técnica

Os três PNGs de produção novos usam apenas a paleta da fábrica de 17 cores mais até três acentos já existentes (`#E8D8B5`, `#879198`, `#52BAC7`), com teto20 cores; essa trava vale só para estes exports. A placa/luzes existentes, piso original e pixels do Hero não são remapeados. Os estudos contextuais preservam as cores próprias dessas referências. Transparência dos PNGs novos é binária (0/255). O acento ciano aparece somente como um ponto pequeno num módulo distante. Não há antialiasing, dither aleatório ou textura gerada por ruído; chapas, bevels, rebites e desgaste são pixels colocados em clusters deliberados.

O estudo contextual reutiliza o frame0 original do Player (crop64×64), atlas de piso e atlas tipográfico em leitura, sem modificar/remapear essas fontes. O crop foi desenhado em 64×64 nativo na posição (88,223): bounds visíveis (21,7)–(43,56), borda inferior em y=280 nativo = y=560 lógico. Contextos não são screenshots, execução Godot ou prévia de colisões.

## Reprodução

Executar a partir da raiz do repositório no Aseprite real, passando parâmetros antes de `--script`:

```powershell
& 'C:/Program Files (x86)/Steam/steamapps/common/Aseprite/Aseprite.exe' -b --script-param 'root=C:/Users/danie/Documents/ChatGPT/TEC - Jogos/projeto-jogos-digitais' --script 'assets/environment/factory_v1/lobby_v1/source/generate_lobby.lua'
```

A produção R3 terminou com exit code 0; stdout/stderr/exit estão em `source/aseprite-production-r3.*`. `makePalette` chama `sprite:setPalette(pal)` sem `pcall`, para falhas interromperem a produção. R1 e R3 pré-correção estão preservados em `history/r1-before-opaque-base/` e `history/r3-before-setPalette/`. Os três PNGs de produção mantiveram os mesmos SHA-256 antes/depois desta correção de metadados/paleta do arquivo Aseprite. O gerador recria as duas fontes Aseprite, os exports e os estudos estáticos da pasta `preview/`.

## Previews

- `preview/lobby-context-player-study-576x324.png` — composição na grade nativa; texto bitmap de runtime é omitido nessa escala menor que a grade lógica.
- `preview/lobby-context-player-study-1152x648.png` — contexto estático 2× com Player, portas abertas, piso de fábrica, placa, focos âmbar e texto original do letreiro em escala lógica.
- `preview/lobby-context-player-study-1728x972.png` — ampliação nearest 3:2 do contexto lógico para leitura a 3× da grade nativa.
- `preview/lobby-backdrop-2x.png` e `preview/lobby-backdrop-3x.png` — apenas arte de fundo em ampliações nearest.

## Limites desta V1

O principal aprovou a prévia visual após a correção do fundo noturno opaco. `scripts/world/lobby_visual.gd` integra os PNGs como dependências `preload` normais, desenhadas em nearest 2×; o pipeline usual do editor gerencia imports ao abrir o projeto. `scenes/lobby.tscn` e demais fontes de produto permanecem congelados. O contexto de 1152×648 é limitado ao viewport de referência; o trecho de piso que ultrapassa y=648 no desenho antigo continua sendo cortado pelo viewport e não foi alterado. Não foram executados Godot, import, parser, lint, testes, simulação, `quality_audit` ou validação de runtime.



