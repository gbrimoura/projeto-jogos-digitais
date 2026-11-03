# Integração da HUD Caldeira

Código integrado à cena da run em run_root.tscn. Cada painel é uma cena independente em scenes/ui/hud/ e recebe valores por métodos de apresentação. Scripts em scripts/ui/hud/ separam texto, barra, painéis, raiz, guarda de pausa e adaptador de run.

## Ajustes no editor

Abra scenes/ui/hud/hud_root.tscn para alterar posições dos cinco módulos e module_pixel_scale. A configuração padrão usa a composição nativa 576×324. A bridge ajusta a escala final à tela compensando o stretch, com nearest; a configuração global de vídeo continua intacta. Abaixo da resolução nativa pode haver corte, mantendo o pixel inteiro.

A opção show_ball_gauge inicia false: o instrumento tem arte e cena próprias, mas a aceleração ainda não tem fonte física definida. Quando habilitado no recurso da raiz, exibe apenas o conceito neutro, sem velocidade apresentada como aceleração.

Desative enabled na raiz para devolver a autoridade visual à HUD legada. Cenas de sala abertas diretamente continuam com HUD legada por não instanciar a bridge da run. Integração standalone dos novos painéis pode usar os mesmos métodos sem acoplar suas cenas a Player ou RunController.

## Contratos

- PlayerHealth: set_health(current, maximum), barra contínua e valores reais.
- Dash: set_dash(state, remaining, duration), cinza, relógio com17 estados e frases. O getter get_dash_cooldown_duration do MovementController lê a configuração efetiva com upgrades, sem mudar comportamento.
- Target: set_target(name,current,maximum,portrait) e clear_target; nome/valor dividem espaço conforme HP. Seleção pelo inimigo vivo mais próximo do ponto mundial da mira, dentro da sala corrente.
- RoomProgress: set_progress(floor_index,floor_total,room_index,room_total,is_boss). Índices vêm do controlador, chefe não mostra fração inválida.
- Root: também set_status e set_build, com texto bitmap. Erros técnicos detalhados e rewards continuam nos overlays existentes.

A bridge observa saída/entrada da sala, invalida callbacks com token, mantém cache de inimigos e restaura a visibilidade que alterou ao desligar. Os sprites, combate, AI e geração não recebem lógica da HUD. Main e RunController permanecem byte a byte como estavam antes desta tarefa.

## Estado de revisão

Implementação por um único GPT-6 Luna xhigh; Fast/priority não confirmável pela interface. R1 congelado em historico/implementacao-r1 e enviado para Gemini/Grok/Muse/Opus Cursor. Pareceres e limitações estão em pareceres/README.md. Nenhum teste, Godot, importação, parser, linter ou audit foi executado. A ligação foi avaliada por leitura estática; apresentação em runtime permanece sem verificação. Sem commit, push ou mudança de branch.

Revisão final R1: Gemini/Muse concluíram sem P1/P2 concretos; Grok expirou em10min sem parecer; Opus Cursor quota. Revisões sem execução, sem substituição do modelo exigido. Não houve alteração adicional após congelar R1. O uso da HUD está ligado à run; para avaliar aparência e comportamento será necessário executar o projeto numa etapa autorizada de verificação.
