# Purgas e reforços do Supervisor-Caldeira

O redesenho usa um visor monocular com barras de pressão, uma chaminé dupla e um volante lateral que muda de posição na carga e na descarga. As poses e o retrato continuam na paleta dos robôs da fábrica. O atlas e o retrato passaram na auditoria de pixel art.

Nas purgas, marcas animadas identificam as bordas ativas. A descarga em coluna sobe. As descargas baixa e alta avançam dos lados para dentro. O pulso e as faixas de vapor usam a geometria da zona anunciada. O vapor residual existe apenas como efeito visual.

Os reforços são limitados por fase. Cada chegada tem aviso no piso e efeito de abertura. O chefe e os reforços pertencem à arena. Matar o chefe limpa as unidades auxiliares e libera o fluxo de recompensa e saída da sala.

## Verificação
Godot 4.7.2 na cópia isolada. As seeds 42 e 4162699858 produziram a mesma arena e a mesma sequência de reforços no roteiro de teste. A fase 1 executou a coluna de vapor. A fase 2 executou as purgas no chão e no alto. Em ambas as fases o aviso antecedeu a chegada. O pico observado foi de dois Cospe-Rebites, e a derrota do chefe removeu ambos e seus rebites. A run assistida da seed 42 percorreu as 13 etapas até a vitória e o retorno ao lobby.

O teste que mantém o jogador junto à escotilha cancela a chegada por segurança. O chefe avisa novamente em um ataque posterior e a chegada se concretiza com o ponto livre. Os efeitos são ancorados às coordenadas da arena. A captura do jogo registrou a animação em execução.

O Gemini 4 Neon High foi confirmado no Antigravity CLI. A rodada que acionou a ferramenta de imagem produziu a prancha de três silhuetas. São estudos visuais. O sprite jogável é a variante monocular redesenhada neste incremento.

## Revisão

R1 9CBE14222ABA57039980FD9A9319A43A0DC96B83669424CC56465973FAF98A75. O parecer Muse apontou perda de chamadas canceladas, remoção das unidades em desmontagem e estabilidade da âncora. No R2 foi testada nova tentativa após bloquear a chegada, foi adicionada remoção das unidades durante a desmontagem e os efeitos passaram a ter transformação de mundo independente do trilho.

R2 82B0A44024CB2411FC6A3EFD8A8D1EC8FA2D2AE04B564B216F21A85A161C6FB0. O Muse apontou suposta chamada duplicada de recompensa. A leitura da função existente `CombatRoom._clear_room()` confirmou que ela retorna antecipadamente quando `_player_was_defeated` ou `_room_was_cleared` estão ativos, antes de qualquer efeito. O manifesto identifica o snapshot enviado. A única diferença posterior é a remoção de uma linha vazia no fim do arquivo de efeitos.

Gemini Hydrogen e Gemini 3.8 Flash ficaram pendentes para revisão por isolamento não confirmado. A autenticação da listagem de modelos no Cursor falhou, deixando Grok e Opus pendentes. A geração de conceitos Gemini Neon recebeu apenas o briefing criativo. O mecanismo de delegação não expôs seletor Fast/priority.
