# Animação dash do protagonista — plano

**Estado:** implementado e exportado; R2 Gemini/Muse/Grok concluídas. Opus pendente por quota; conferência manual no Godot pendente.

## Objetivo

Adicionar uma animação visual de dash em três poses, mantendo intactos o idle v2,
a caminhada v3 e a mecânica de dash já aprovada com duração de 0,14 s.

## Escopo

- Criar uma fonte Lua Aseprite que abra `protagonista-walk-v3.aseprite`, preserve
  seus doze quadros e acrescente três quadros de dash editáveis.
- Definir as poses de impulso, avanço e sustentação, com inclinação para +X,
  braços recolhidos para trás e pernas flexionadas conectadas ao quadril.
- Exportar no Aseprite, pelo agente principal, um atlas horizontal de quinze
  quadros 64×64 e copiar fonte/editável e PNG para os assets de runtime.
- Adicionar a animação `dash` ao recurso `SpriteFrames` com 40, 40 e 60 ms e
  reprodução não cíclica.
- Integrar a prioridade de apresentação em `PlayerVisual`: morte, dash, pose
  estática no ar e caminhada/idle no chão.
- Reiniciar o dash somente na transição de entrada; manter a última pose se o
  estado de dash durar além dos 0,14 s, e voltar imediatamente ao estado visual
  apropriado ao terminar.
- Registrar decisões e pendências sem alterar física, controlador, duração,
  input, combate, raquete ou animações idle/walk.

## Critérios de aceite

1. Os seis frames de idle e seis de caminhada do arquivo v3 de origem permanecem
   pixel a pixel e com as durações já aprovadas.
2. Os três frames novos ocupam os índices 12–14, têm 64×64 px e durações
   40/40/60 ms, totalizando 0,14 s.
3. As poses mantêm a identidade e as cores do protagonista, usam somente a
   paleta de 27 cores com alpha binário, não sofrem clipping e têm silhueta de
   corrida/dash legível.
4. `SpriteFrames` contém as regiões do atlas em x=768, 832 e 896, com `dash`
   não cíclico e velocidade base 1 fps.
5. `PlayerVisual` reinicia o quadro 0 uma vez ao iniciar dash; atualizações de
   chão/caminhada não reiniciam a animação já ativa ou concluída.
6. Ao terminar o dash, volta imediatamente à pose estática no ar ou à caminhada/
   idle no chão. Morte e reset param o dash e a trilha existente continua intacta.
7. Nenhuma física, cena, mecânica de dash, duração ou código fora da apresentação
   visual é alterado.

## Arquivos previstos

- `GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash/protagonista-dash.lua`
- `GDD_Dieselpunk_Noir/pitch-assets/protagonista-dash/README.md`
- `scripts/player/player_visual.gd`
- `resources/player_sprite_frames.tres`
- Esta pasta de especificação e o índice `docs/README.md`.

## Limites e validação

O agente principal executa a exportação do PNG e do Aseprite e registra os
pareceres. A integração descrita é estática. Não estão previstos testes, execução
do Godot ou `quality_audit`; a conferência de cadência e aparência no jogo fica
pendente de inspeção manual.

## Incremento v2: pose de movimento lateral

Pedido: durante o dash, o robô deve ficar de perfil, em postura de impulso lateral. Implementador Luna xhigh redesenha somente os três quadros de dash; preserva idle/walk, atlas64x64 por frame, paleta27 e timings40/40/60ms. Principal exporta e integra Aseprite/PNG, atualiza o GIF demonstrativo e conduz revisões de fontes estáveis por Gemini/Muse/Grok. Opus obrigatório teve preflight bloqueado por quota. Sem execução de testes/Godot. Pareceres e hashes em pareceres/pose-lateral-v2.
