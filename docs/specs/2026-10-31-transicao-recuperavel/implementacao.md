# Transição recuperável e direção de HUD

A mensagem “Não foi possível continuar a run” vinha do caminho de erro de carregamento da próxima sala. O controlador removia a sala concluída antes de saber se a próxima poderia ser configurada; uma rejeição técnica era apresentada como derrota. A mensagem identifica esse fluxo, mas não revela qual validação de layout ou seed falhou no caso relatado.

## O que mudou no código

Main e RunController agora separam preparação, validação e confirmação da próxima sala. O destino usa uma proposta temporária de estágio, descritores e família; o estado corrente só muda na confirmação.

A sala concluída fica viva até a confirmação. Ela é destacada temporariamente da árvore durante a entrada da candidata para evitar que inimigos e CombatRoom encontrem jogadores ou inimigos da outra sala nos grupos globais. Uma falha descarta a candidata e reanexa a mesma sala concluída.

Falhas de preparação ou validação exibem um painel técnico com motivo, seed da run, seed da sala e destino. Quando há uma origem válida, o jogador pode retornar à sala concluída e atravessar a porta novamente. A tentativa usa o mesmo destino, sem reroll automático. Erros sem origem recuperável oferecem reinício deliberado. Morte real por HP e vitória final conservam os fluxos próprios.

A recuperação restaura o controle do jogador e rearma a porta com token e sinal próprios. A recompensa de chefe já concedida é preservada e não volta a ser aplicada ao repetir uma tentativa. HP e build não são apagados pela falha técnica.

## HUD escolhida

As três propostas iniciais e a revisão 02 estão em [hud-conceitos](hud-conceitos/README.md). O usuário escolheu o Painel de Caldeira e pediu vida, dash com recarga, acelerômetro da bola, contador de salas e HP inimigo fixo. O painel inimigo deverá acompanhar o inimigo mais próximo da mira. Os antigos botões de bola e raquete foram retirados da imagem revisada.

Esses são estudos visuais. A HUD, a remoção das barras sobre os inimigos e a futura aceleração da bola ainda não foram implementadas. A escala e as regras do acelerômetro dependem da definição dessa mecânica.

## Verificação e limites

Implementação por GPT-6 Luna xhigh; a interface não confirma Fast/priority. O principal leu o delta e os contratos de estado, sinais e pausa, e conferiu a identidade dos arquivos contra o snapshot congelado. Os pareceres e as limitações estão em [pareceres](pareceres/README.md).

Não foram executados Godot, parser, testes, linter, importação, QA ou benchmark. Revisão estática não comprova compilação nem jogabilidade. O layout determinístico que motivou o relato ainda pode ser rejeitado; esta correção preserva a run e expõe o motivo para investigar a combinação específica. Não houve commit ou push deste trabalho.

Resultado de revisão: Gemini e Muse não apontaram P1/P2 no fluxo completo nem na guarda final de retry. Grok completo expirou sem parecer e o delta retornou sem texto útil; Opus Cursor ficou indisponível por quota. O principal aceitou a correção com essas limitações, sem atribuir aprovação aos revisores indisponíveis. Os arquivos finais estão congelados no snapshot R2.
