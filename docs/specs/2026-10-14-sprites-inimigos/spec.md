# Especificação — reprodução Aseprite de TrainingTarget e RivetWorker

**Estado:** integração visual congelada para revisão estática; Godot/import/runtime/testes não executados. O contato de arte foi aprovado visualmente pelo agente principal.  
**Referência:** ../../../GDD_Dieselpunk_Noir/pitch-assets/inimigos-referencia-v1/referencia-alvo-rebiteiro-v1.png.

## Proveniência e estilo

A prancha foi gerada com ImageGen e confirmada como referência desta reprodução; os placeholders atuais TrainingTarget e RivetWorker também foram confirmados pelo usuário. A prancha não recebeu aprovação estética explícita e não é asset de jogo. Reproduzir os personagens reconhecíveis na grade nativa, preservando silhueta, proporções, materiais ferrugem/cobre/aço e ferramenta do trabalhador.

## Formato e alinhamento

- Canvas de cada pose: 64×64; alpha totalmente opaco ou transparente.
- Redução nearest, fator comum entre as poses de cada personagem.
- Corpo quantizado pela paleta industrial existente de 20 cores; três cores de ameaça já existentes no jogo são preservadas somente em pixels amostrados nas luzes/visores: RivetWorker #F0524E, WarningMark #FF7256 e HostileRivet highlight #FFB3A0. Teto ativo total: 23 cores, abaixo do limite de 31. Alpha permanece binário.
- TrainingTarget: 3 poses. A silhueta será centrada no eixo x=32; soles/base em y=56 em todas as poses.
- RivetWorker: 5 poses para a direita. Base em y=56; pivô planejado (32,56). Corpo de referência 23×32 nativo. A ferramenta continua presa à mão; boca estimada em (43,38) na pose mirando/disparo. Diferença máxima de 4 px é tolerância de aparência e não muda a origem física atual.
- Os tempos exportados são propostas visuais informativas e não alteram os relógios de gameplay. O GDD/estado atual fixa windup 650 ms e recovery 800 ms.

## Entregáveis da etapa

Fontes .aseprite, Lua reproduzível, dois atlas PNG RGBA, JSON de bounds/registro/timing, prancha comparativa 4× e cópia pixel-crop 64×64 do idle do protagonista, todos preservados no pitch-assets. PNGs/ASE aprovados são copiados byte-a-byte para assets/enemy/{training_target,rivet_worker}; resources/enemy contém SpriteFrames 64×64.

## Integração visual autorizada nesta etapa

- TrainingTarget: AnimatedSprite2D centrado em `(0,0)` com escala 2; a base nativa y=56 cai em y=+48 mundo e coincide com o collider 72×96 centrado na origem. Idle padrão; impacto durante `_flash_remaining` original (120 ms). Pose desativado é somente recurso de arte; letal permanece `defeated.emit()` + `queue_free()` imediato.
- RivetWorker: AnimatedSprite2D 64×64 em `(0,-48)`, escala 2 e pivô de pés `(32,56)`, nativamente virado para a direita sob `Visuals.scale.x` existente. `idle`, `walk` (idle+andando), `aim` em WINDUP, `fire` após aceite do projétil por até 120 ms e `recovery` em RECOVERY. A animação segue `_state`/velocidade sem alterar movimento, queries, launch, windup (650 ms) ou recovery (800 ms).
- Shader CanvasItem local à cena mistura BodySprite com `#FFF1C7` pelo tempo de flash atual e preserva alpha; healthbar e WarningMark não recebem o flash. Nós antigos de corpo permanecem na cena, ocultos; healthbar/alertas/som ficam ativos.
- Escopo de código: somente `scripts/world/training_target.gd`, `scripts/enemy/rivet_worker.gd`, `scenes/training_target.tscn`, `scenes/rivet_worker.tscn`; criação de assets sob `assets/enemy`, resources sob `resources/enemy` e shader sob `scripts/enemy`. Sem mudança de collider, IA, física, tempos, HP, spawn, alcance, projétil, input ou demais cenas.

A pose desativado existe somente na arte porque `take_damage()` letal remove o alvo imediatamente. Não executar Godot/import/runtime, QA, auditorias ou testes.

## Baselines

Os snapshots e hashes pré-arte estão em historico/base/. A integração exige uma decisão posterior do agente principal após examinar visualmente o contact sheet.




## Estado congelado de arte

A aprovação visual do agente principal refere-se ao contact sheet atualizado em pitch-assets. O script Aseprite, fontes editáveis, atlas/contato e metadata permanecem imutáveis durante a integração. O log de exportação registra fielmente avisos `libpng: Write Error`; apesar deles, arquivos foram decodificados e tiveram dimensões/CRC e cabeçalhos ASE conferidos. Os snapshots de runtime pré-arte permanecem em `historico/base/`; os documentos art-only substituídos foram preservados em `historico/art-only-*`.

## Resultado da integração e revisão estática
Arte reproduzida e inspecionada no Aseprite; os dois sprites integrados às cenas com materiais de flash e poses ligadas aos estados existentes. Gemini/Muse concluídos sem bloqueios; Grok retornou exit0 sem parecer em duas tentativas do mesmo modelo e Opus indisponível por quota. [Saídas fiéis, decisões, hashes e limites](pareceres/README.md). Fontes/PNG/ASE preservados e cópias runtime idênticas. Sem Godot/import/testes/gameplay. Aparência em jogo ainda não verificada.

