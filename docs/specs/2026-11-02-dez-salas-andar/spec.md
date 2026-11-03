# Especificação — contagem de salas por andar

- run_root.tscn mantém floors_per_run = 1 e passa a definir common_rooms_per_floor = 10.
- O padrão exportado em scripts/world/run_controller.gd passa a ser @export_range(1, 10) var common_rooms_per_floor: int = 10.
- Cada andar continua contendo 10 salas comuns seguidas pela sala de chefe existente (11 salas no total), conforme o fluxo já implementado.
- A faixa exportada continua em 1..10. Nenhuma configuração de floors, boss, recompensa, sequência, layout, HUD, upgrades ou progressão muda.
- O orçamento técnico de 220 aquisições permanece inalterado e cobre a configuração de suporte máximo de 20 andares com 11 salas por andar.
- Quantidades variadas de inimigos e eventos são ideias para uma etapa futura sem desenho fechado; este incremento não altera conteúdo nem quantidade de encontros.
