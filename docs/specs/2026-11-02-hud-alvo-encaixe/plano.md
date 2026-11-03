# Plano prospectivo — encaixe do painel de alvo

02/11/2026. A captura enviada mostra o painel nativo de 144×40 exibindo `NV1` junto ao nome, o que reduz a leitura do nome completo e mantém uma barra de 96×14 que invade as linhas. Ajustar somente a composição interna do painel de alvo e a passagem do nível separado.

## Escopo

Alterar `scripts/ui/hud/target_panel.gd`, `scenes/ui/hud/target_panel.tscn` e apenas os métodos de apresentação do alvo em `scripts/ui/hud/hud_root.gd` e `scripts/ui/hud/run_hud_bridge.gd`. Manter painel144×40, fonte bitmap5×11/avanço6, dados reais de HP, nome original, retratos e ciclo de vida da bridge. API da raiz aceita `level` opcional com default1 para compatibilidade.

Sem mudanças a assets, retratos, fonte, barra global/player, escala/âncoras da HUD, gameplay, IA, seleção de alvo ou cena raiz. O novo indicador compacto é desenhado dentro do painel do alvo, sem reutilizar ou redimensionar `HudHealthBar`.

Antes da implementação, cópias e SHA-256 dos cinco arquivos existentes no escopo foram guardados em `historico/baseline/`.

## Verificação

Implementação única. Revisão somente leitura após congelar o estado. Não executar Godot/importação, testes, parser, lint, audit, simulação, commit, push ou limpeza. A entrega reportará leitura estática e hashes, sem alegar captura de runtime.