# Registro — animações, patrulha e combate Tranca-Lata

**Data:** 19–20/10/2026.  
**Fase atual:** runtime R2 corrigido e congelado para revisão estática.  
As seções abaixo preservam o histórico das fases anteriores; seus estados de autorização descrevem o momento registrado.

R1 do plano permanece preservada em historico/plano-r1/anteseditar/plano.md; SHA-256: `43DA7A424DAA2AA04AD293A265D6D38464CA5D5722E2AFE752A43A19ECB7D1FB`. O estado documental R2 foi preservado antes do complemento em historico/plano-r2/antescomplemento/; sha256-before.json identifica os hashes de plano, spec e registro. R3 final especifica consulta de movimento `test_only=true`, margem zero, leitura de travel.x, pós-condição segura e aplicação somente em global_position.x; guardas de cena, vida, placement e bind; percurso mínimo 8 px e fallback estacionário seguro e determinístico. Sem percurso ou suporte válido, somente patrulha é desligada: combate/dano do alvo estacionário continuam ativos.

A exceção física permanece apenas no SolidPlatform compatível (um body de superfície com uma RectangleShape2D), removendo a anterior em novo bind; query física exclui RID do alvo e suporte, e LOS/AOE continuam considerando o suporte. Sweep AABB Main exclui o próprio objeto. Direção mantém-se em cancelamento e congela durante WINDUP/ACTIVE/RECOVERY; contato físico vertical do Player para e inverte sem bypass. Se o jogador conhecido estiver derrotado, o alvo congela em idle. Animações de ataque pausam AnimatedSprite2D e selecionam frames manualmente por thresholds de soma cumulativa do timer; `_apply_attack_area` conserva a consulta `intersect_shape` só em ACTIVE, sem Area2D ou query nova. O flash independente conserva 120 ms, usa shader por instância sem alterá-lo e só zera ao encerrar `_flash_remaining`. Layers de Ball/Worker/Player permanecem nos contratos atuais. Sem rota/suporte válido, só a patrulha desliga; combate/dano continuam e PROCESS_MODE_DISABLED fica restrito à falha de layout inválido já existente. Sidecars `.import` e arquivos UID estão protegidos.

O plano e a spec mantêm a conversão prospectiva para CharacterBody2D, patrulha limitada ao suporte, sincronização às fases de ataque e integração das 12 poses. O nome visível é Tranca-Lata; identificadores técnicos TrainingTarget e node paths ficam preservados.

historico/base/ contém cópias byte a byte dos seis arquivos autorizados para uma fase runtime futura e sha256-before.json com os hashes conferidos contra as fontes no momento da cópia. A base captura o estado local já existente; scripts/world/main.gd e scripts/world/training_target.gd tinham modificações antes desta fase. Nenhum arquivo fora desta pasta documental foi editado por este agente. O arquivo pareceres/README.md pertence ao principal e permaneceu intocado.

Não foram executados Aseprite, Godot, importação, testes ou QA. Não houve alteração de Git. R3 é somente documentação; arte e runtime ainda não estão autorizados.

## Fase 3 — arte-only v1 produzida

Em 19/10/2026 foi produzida a prancha de animação com Aseprite 1.3.18.6, usando `GDD_Dieselpunk_Noir/pitch-assets/tranca-lata-animacoes-v1/generate_tranca_lata.lua`. O documento `.aseprite` parte da fonte de três frames e mantém os frames legados 0–2 sem edição; a comparação de cada valor RGBA decodificado e de cada duração resultou em `true` durante a geração. Os tempos legados são 250, 120 e 250 ms. Foram acrescentadas doze poses em cels de 64×64: walk 3–6 (4×120 ms), windup 7–9 (180/220/250 ms), active 10–11 (2×70 ms) e recovery 12–14 (120/180/1100 ms). Os tags correspondentes, mais `attack` e `idle`, estão no source ASE.

O upper body desloca-se como grupo conectado nas poses de ataque; cabeça e tubo mantêm forma e proporção, os pés permanecem na base durante windup/active/recovery e os pistões têm detalhes marfim/cobre. Os contatos A/B deslocam as botas 3 px e a passada levanta o pé 2 px. O neutral novo (frame 14) substitui visualmente o pedestal somente nos cels novos; os cels antigos continuam acessíveis. O visor de windup/active ganha dois acentos escuros deliberados que formam uma sobrancelha angular, usando cores existentes. A paleta final contém 14 cores, sem adições; a contagem e os hexadecimais estão em metadata.json.

Artefatos de inspeção: `tranca-lata-animacoes-v1.aseprite` é a fonte editável; `tranca-lata-atlas-v1.png` é o atlas horizontal 960×64 sem padding; `contact-15-cels-4x.png` apresenta os quinze cels em grade 4×4 com fundo carvão e índices; `comparison-old-idle-new-neutral-player-frame1-4x.png` compara o idle antigo, o neutral novo e o primeiro frame da fonte atual do jogador; `walk-4x.gif` e `attack-4x.gif` foram exportados pelos tags Aseprite usando as durações dos frames. `metadata.json` registra pivô (32,56), limites observados, paleta, tags, bounds e durações. `historico/arte-v1-sha256.json` fixa os hashes dos artefatos finais e dos documentos usados para a entrega.

O pass-01 foi preservado em `GDD_Dieselpunk_Noir/pitch-assets/tranca-lata-animacoes-v1/passes/pass-01/`. A prancha ImageGen e seu prompt não foram alterados. Nesta fase não houve edição dos seis arquivos runtime protegidos, `.import`, GDD, `pareceres/README.md` ou Git; não foram executados Godot, importação, testes ou QA.

## Fase 4 — runtime R1 integrado e congelado

Em 20/10/2026, os seis arquivos runtime autorizados foram integrados sobre a baseline byte a byte de `historico/base/sha256-before.json`. `TrainingTarget` preserva seu `class_name`, nome de cena e grupos, passa a `CharacterBody2D` layer 8/mask 3 em modo FLOATING, mantém o collider 72×96, e apresenta `Tranca-Lata` em `display_name`/`NameLabel`.

O Main agora escolhe e expõe posição, suporte efetivo, caminho, limites e estado da patrulha do layout autoral. A ordem segue percurso primário livre e útil, percurso fallback livre e útil e primeira posição estacionária segura; sweeps usam o AABB completo do corpo contra World, excluindo apenas o suporte escolhido e mantendo margem autoral de 8 px. No spawn aleatório, o alvo retém o `SolidPlatform` selecionado, valida o sweep completo por query World excluindo seus próprios RIDs e usa uma posição estacionária segura quando a rota não serve. Bind incompatível ou ausência de rota desativa apenas patrulha e emite um aviso único; o combate estacionário segue ativo. Exceções físicas se limitam ao suporte atual. O passo consulta `move_and_collide(..., true, 0.0)` e aplica somente deslocamento X seguro; colisão/limite para, inverte e pausa 0,25 s.

`training_target_sprite_frames.tres` aponta para os 15 cels da arte congelada: walk 3–6 (120 ms), windup 7–9 (180/220/250 ms), active 10–11 (70/70 ms) e recovery 12–14 (120/180/1100 ms). Idle usa o cel 14; `impact` e `disabled` mantêm seus nomes e durações. Os frames de ataque são selecionados manualmente pelo timer, enquanto idle/walk usam playback normal apenas quando o clip muda. Windup/active/recovery mantêm o alvo parado, e o flash de 120 ms continua independente no shader existente. O atlas e a fonte Aseprite runtime foram copiados sem regeneração: SHA-256 `1E0D612975A251E117005472BD431CB68998B430200C5AF38CE61B0A484289A0` e `1274EAB69593B16350C1B94747DFCDBD085AA8DF3E192483667491AA83072BE8`, respectivamente.

`historico/runtime-r1/` contém o manifesto SHA-256 dos seis arquivos, snapshots textuais dos quatro arquivos de código/cena/recurso e diffs unificados contra a BASELOCAL, incluindo `main-base.diff`. Nenhum sidecar `.import`, arquivo UID, arquivo protegido ou sistema de transição/geração foi editado. Não foram executados Godot, importação, testes, parser, gdlint ou QA. Não houve alteração de Git. Revisão estática final permanece a cargo do principal.

## Fase 5 — runtime R2: correção textual P1

Após a revisão estática R1, foi corrigida em scripts/world/training_target.gd a junção acidental entre a chamada de bind no else interno e elif spawn_on_platform. O elif volta a ocupar uma linha própria no nível de if authored_support_enabled; o corpo do else permanece no nível de indentação interno. Nenhum outro arquivo runtime mudou entre R1 e R2, e todos os snapshots e arquivos de historico/runtime-r1/ permaneceram intocados.

historico/runtime-r2/ contém snapshots dos seis arquivos runtime, diff-r1-to-r2.patch, manifesto SHA-256 dos seis arquivos e seu sidecar de hash. A mudança entre os freezes se limita ao hash de scripts/world/training_target.gd, registrado no manifesto junto ao hash R1 correspondente.

A inspeção foi somente textual. Não foram executados parser, Godot, importação, testes, gdlint ou QA; a revisão estática segue sob coordenação do principal.
## Fechamento pelo principal — 20/10/2026

R2 permanece integrada e congelada nos seis arquivos autorizados. O principal leu as fontes/diffs, confirmou a correção do P1 textual e conferiu hashes dos seis arquivos/snapshots e dos25arquivos protegidos. Gemini concluiu revisão estática final sem P1/P2; Grok encerrou sem parecer útil; Muse estava com chave expirada e Cursor Opus estava bloqueado por quota até03/11/2026, sem parecer desses dois modelos. Limitações e saídas originais estão em pareceres/README.md e respectivos arquivos stdout/stderr/exit. A revisão Opus exigida continua indisponível, sem substituição.

O código e os assets estão salvos no projeto. O funcionamento visual/físico em jogo ainda precisa de confirmação no Godot: o agente não executou engine, importação, testes ou QA. As mudanças locais preexistentes foram preservadas; nenhum commit, push ou mudança de branch foi feito.
