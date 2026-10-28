# Plano — Porta horizontal embutida na parede

**Data:** 18/10/2026  
**Estado:** arte e integração visual congeladas para revisão estática do principal; execução de runtime permanece fora do escopo.  
**Branch/base:** `corrigir-sprites-salas-plataformas`, HEAD `90b2e592bd70e1b2ff3e5828af8a9029031e1c66`, com o working tree local preservado.

## Objetivo confirmado

Substituir o prop vetorial solto no chão por um asset pixel art de porta integrado a um painel de parede ao fundo junto às extremidades laterais. O usuário confirmou a orientação landscape: “Desenho deitado, mais largo que alto” e “tem que ser na parede”. Não é somente uma folha que se move para o lado.

A versão anterior em retrato 32×64 está preservada como proposta descartada, em `historico/proposta-orientacao-anterior/`. O prompt vertical em `imagegen-prompt.txt` também fica imutável como histórico. A referência horizontal V2 recebida foi copiada para a pasta do asset; o prompt exato está salvo separadamente em `imagegen-prompt-horizontal-v2.txt`.

## Arte e geometria

- Usar Aseprite real com Lua editável para desenhar a arte final; `assets/environment/factory_v1/door/referencia-porta-horizontal-v2.png` e `imagegen-prompt-horizontal-v2.txt` são guia visual, não asset final. A referência anterior em retrato não participa da arte.
- Usar exclusivamente a paleta existente de 20 cores em `../GDD_Dieselpunk_Noir/pitch-assets/tileset-fabrica-v1/palette-fabrica-v1.json` e a linguagem do atlas da fábrica. Alpha somente 0 ou 255; módulo opaco para formar um painel de parede é esperado. `Sprite2D.texture_filter=1` (nearest); não alterar `.import` nem executar import.
- Cada estado mede 160×80 px nativos e é um painel texturizado de parede. A porta integrada ocupa o retângulo nativo `(16,8,128,64)`. Folha horizontal única de dois frames, 320×80 px, `hframes=2`; escala runtime 2×, logo cada módulo ocupa 320×160 px de mundo.
- `Closed` cobre o vão. `Open` recolhe a folha para o lado conforme a referência horizontal, preserva o caixilho e mostra abertura escura com ao menos 48 px nativos de altura (96 px em jogo), maior que o corpo de 88 px do protagonista. A moldura mantém canvas e registro iguais nos dois estados.
- Entregáveis: `.aseprite`, `.lua`, PNG runtime 320×80, preview em 4× e montagem estática do painel no ambiente com parede/atlas, piso e personagem atual. Preservar a nova referência horizontal recebida do principal e documentar seu prompt v2 separado.

## Encaixe e estados

- `ExitDoor` conserva Area2D em (1040,522), alcance/interação E, sinais, guards, unlock, destino e terminal. Sensor continua com 96×108 px em x=992..1088 no mundo. O texto `[E] ENTRAR` e o indicador âmbar ficam localizados perto desse sensor; não representam interação ao longo de toda a porta. `EntranceDoor` conserva Area2D em (112,522), bloqueada e sem sensor ativo.
- Saída: Sprite2D central local `(-80,-26)` em relação à raiz, centro global `(960,496)`, escala 2, módulo em x=800..1120/y=416..576, abertura da porta em x=832..1088/y=432..560.
- Entrada: Sprite2D central local `(+80,-26)`, centro global `(192,496)`, mesma escala, módulo em x=32..352/y=416..576, abertura em x=64..320/y=432..560.
- Camadas confirmadas nas cenas: `SandboxVisual` no z=-10; parede visual no z=-1 (faixas x=0..64 e x=1088..1152); piso no z=0; atores no z=1. O Sprite2D do painel usa z=-2 dentro da raiz de porta em z=0, portanto fica atrás de parede, piso e protagonista. A placa opaca deve compartilhar emendas/placas e tons do atlas existente para ler como rebaixo integrado ao fundo, não como caixa sobreposta. A parede física, o sensor, piso, spawns, plataformas e câmera ficam intactos; a porta aberta comunica a transição E sem formar uma passagem física nova.
- A região visual pode ficar parcialmente coberta pelas paredes laterais e piso, mas o retângulo completo da porta integrada termina exatamente na face x=64 (esquerda) ou x=1088 (direita) e na soleira y=560, sem clipping da porta. No estado Open, lâminas telescópicas recolhem em bolso próprio junto ao batente lateral; nenhuma folha de 128 px fica estacionada na margem externa de 16 px. Na entrada, `flip_h=true` orienta o bolso assimétrico para a parede lateral.
- Entrada sempre mostra Closed. Saída mostra Closed enquanto bloqueada/ocupada e Open depois de liberada; terminal pode mostrar Open após concluir. O label permanece separado do PNG e compacto no lado jogável.

## Sequência

1. Preservar baseline local e as propostas retrato anteriores.
2. Inspecionar a referência horizontal ImageGen e usar o prompt v2 guardado pelo principal.
3. Reproduzir dois estados em Aseprite, inspecionar PNG e dimensões/paleta/alpha de forma estática e preparar preview 4× e montagem estática.
4. Atualizar somente a apresentação visual da cena/script reutilizável e os overrides visuais de entrada/saída nas duas salas.
5. Congelar arquivos para revisão somente leitura do principal/revisores disponíveis.

## Limites

Sem Godot, import, testes, quality audit, QA automatizado, alteração de colisões/física, atlas existente, regras de gameplay, índice global, commit ou push. O snapshot local anterior e seus SHA-256 estão em `historico/baseline-local/`; a decisão horizontal está em `historico/steering-horizontal-v2.txt`.
