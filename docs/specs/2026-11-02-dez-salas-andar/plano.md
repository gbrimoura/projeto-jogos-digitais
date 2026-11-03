# Plano — dez salas comuns por andar

## Pedido e decisão
02/11/2026: pedido de cerca de dez salas por andar. Recorte acordado: 10 salas comuns e a sala de chefe já existente, totalizando 11 salas por andar. A cena run_root.tscn conserva floors_per_run = 1.

## Alteração autorizada
Somente:
- run_root.tscn: common_rooms_per_floor de 3 para 10.
- scripts/world/run_controller.gd: valor padrão de common_rooms_per_floor de 3 para 10, mantendo @export_range(1, 10).

O controlador já calcula uma sala de chefe além das comuns. Preservar faixa, fluxo do chefe, geração, cenas e layouts. O orçamento técnico de até 220 aquisições segue compatível com a configuração máxima já suportada: 20 andares × (10 salas comuns + 1 chefe).

## Fora deste incremento
Eventos e variação de quantidades/encontros de inimigos ficam registrados como intenção futura; não implementar agora. Não mudar floors, chefes, IA/inimigos, geração, layouts, HUD, upgrades ou progressão. Sem alteração do GDD externo.

## Procedimento
Snapshot binário dos dois arquivos autorizados antes da edição em historico/base/. Depois do incremento, congelar os dois arquivos e entregar hashes/diff para revisão estática. Verificação limitada à leitura do diff e hashes; sem Godot/import/testes/parser/lint/auditoria/simulação. Preservar todas as alterações locais preexistentes; sem limpeza do Git, commit ou push.
