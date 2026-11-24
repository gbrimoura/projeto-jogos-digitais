# Limpeza e atualização da HUD

A HUD de partida deve exibir vida, dash, alvo, progresso, saldo de sucata e velocidade bruta da bola. Indicadores técnicos, contagem redundante e nome do layout deixam de ocupar a área de jogo. A seed continua disponível no relatório técnico.

A cópia inicial já atualizava a sucata após uma coleta e após compras nas duas lojas, e a velocidade no disparo e nos ricochetes. A falha comum aos dois indicadores era verificável ao desativar a HUD pixelada e acionar a interface de reserva. 

Os rótulos de sala, contagem de inimigos, build e estado repetido ficaram ocultos na run gerenciada. O progresso conserva o andar e a sala. A HUD de reserva lê a sucata do controlador da run e a velocidade do lançador. A interface de recuperação continua mostrando seed e destino quando necessários.

## Verificação no Godot 4.7.2

- Seeds 42 e 4162699858 com HUD pixelada. O saldo foi de 0 a 7 na coleta e subiu a 9 após a queda de inimigo. O velocímetro marcou 760 no disparo, chegou a 1482 durante o voo com ricochetes e zerou no retorno. A agulha acompanhou.
- Seed 42 com HUD pixelada desativada. A reprodução inicial mostrou a seed e a ausência dos dois indicadores. Após a correção, a interface de reserva exibe saldo e velocidade ao vivo. A pausa esconde a linha, retomar volta a exibi-la e reativar a HUD pixelada esconde a linha de reserva.
- Run assistida na seed 42. O contador refletiu as compras nas duas lojas. A run passou por 13 etapas, chegou à vitória e retornou ao lobby.
- O aviso de UID duplicado entre cenas de exemplo e principal já ocorria na importação.

## Pareceres

Snapshot 99542E78A702C8F98C869741E61D3AF4D5D4FDD7DB2E4C1DD5DFE06397784440. Muse Spark 1.3 Contributor xhigh, com ferramentas desabilitadas. Conferi as mensagens do controlador e a remoção da alimentação da build. As mensagens técnicas e de nova tentativa continuam visíveis. O texto de build da HUD modular começa vazio e seu único produtor em partida foi removido. A seed continua disponível no relatório técnico. O teste de desativação e reativação cobre o retorno da HUD de reserva e a retirada da linha duplicada.

A autenticação da listagem no Cursor falhou. Antigravity listou Gemini 4 Hydrogen High, mas o isolamento exigido para enviar o diff não foi confirmado. As revisões Gemini e Cursor continuam pendentes. O modo Fast/priority do subagente não pôde ser verificado pela interface.
