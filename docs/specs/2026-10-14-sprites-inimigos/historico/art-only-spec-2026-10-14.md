# Especificação — reprodução Aseprite de TrainingTarget e RivetWorker

**Estado:** contato atualizado aprovado visualmente pelo agente principal para seguir à integração; integração ainda não executada nesta etapa.  
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

Fontes .aseprite, Lua reproduzível, dois atlas PNG RGBA, JSON de bounds/registro/timing, uma prancha comparativa 4× e uma cópia pixel-crop 64×64 do idle do protagonista, mantendo intactos os arquivos de origem. A prancha original não será alterada.

## Fora de escopo

Integração ou importação Godot, qualquer mudança de scripts/cenas/colisões/AI, flashes de runtime, criação de novos estados de gameplay, QA/auditoria/testes. A pose desativada existe somente na arte porque take_damage() letal atualmente emite derrota e chama queue_free() imediatamente.

## Baselines

Os snapshots e hashes pré-arte estão em historico/base/. A integração exige uma decisão posterior do agente principal após examinar visualmente o contact sheet.


