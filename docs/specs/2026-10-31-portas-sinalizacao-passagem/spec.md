# Especificação inicial

Portas atuais: standalone ExitDoor em(1040,522), visual(80,-26), resulta centro(1120,496), fundo560. Player origin representa pés560, collider centro522. Managed lateraiscentro496; DOWNcentro604, abertura256×96; visual vertical recebe z_index1. O cruzamento é por centro real do collider e projeção da normal do portal; não mudar a regra nesta rodada.

ExitDoor._update_presentation atualmente preenche DoorLabel com ENTRADA, SAÍDA BLOQUEADA, SAÍDA ABERTA, transição/falha/terminal. O desenho aberto SideDoorVisual inclui VOID+frame no mesmo nó. A apresentação visual precisa deixar abertura e limite físico legíveis sem cobrir o ator com todo o fundo da porta. Causa final e arquivos permitidos serão registrados após leitura inicial de Luna.

Aceite estático: nenhum texto de entrada/saída renderizado nas portas; saída liberada claramente indicada na direção correta; setas ocultas nos estados não atravessáveis; desenho de hatch difere de piso; fundos atrás do ator e borda frontal controlada; transformações/latch/gates/física e integração de run preservados.
