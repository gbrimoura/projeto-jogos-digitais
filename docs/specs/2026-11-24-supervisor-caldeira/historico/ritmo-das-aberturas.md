# Ritmo da luta do Supervisor-Caldeira

O núcleo aceita até 7 PV de dano por ciclo. Quando esse total é atingido, a blindagem fecha e a próxima abertura normal só ocorre depois de um novo ataque. Um rebite devolvido ainda pode abrir ou prolongar uma janela enquanto houver dano disponível no ciclo. O limite só é reposto ao concluir outro ataque ou na mudança de fase. O chefe começa com 60 PV, e a transição continua aos 30 PV.

A alteração limita a concentração de dano na abertura. A build de teste com Impacto Reforçado III, Ricochete de Pressão III, Chassi Reforçado III e Motor Acelerado I aproveita disparos que batem na parede e no teto antes do acerto. Na comparação, a arena e o piloto automatizado são os mesmos. A cura de teste foi usada para medir até a vitória com as mesmas condições.

## Validação

Godot 4.7.2 em cópia isolada, com o simulador medindo ticks de física. A build de ricochetes subiu de 15,73 s para 24,57 s (56% a mais). Fase 1 em 12,17 s e fase 2 em 12,40 s. A duração final se repetiu nas seeds 42 e 4162699858, com seeds de sala 761383069 e 3775596240. O chefe executou seis purgas e dois reforços no roteiro vencedor. Sem cura de teste, o mesmo roteiro caiu em 18,60 s, com 16 PV restantes no chefe.

O cenário sem upgrades e com cura de teste permaneceu em 102,10 s, com 60 acertos de 1 PV. O teste de contrato verificou o máximo de 7 em um único acerto, a soma de 4+3 na mesma abertura, o fechamento, a rejeição de um rebite devolvido depois de esgotar o limite e a recuperação do orçamento após o ataque seguinte.

A medição usa mira automatizada e começa na arena. A duração com jogadores humanos ainda precisa ser medida. Em algumas saídas do simulador ocorreu aviso de descarte de recursos após o resultado, como na rodada anterior. Os resultados brutos e o roteiro ficam na pasta de verificação temporária.

## Revisão

Snapshot 73039B283AFC07E4FA123FE8321D808FE256A4FC755DE20A6CB62A25C419D694. O Muse Spark 1.3 Contributor xhigh concluiu a revisão estática sem defeitos acionáveis no diff. As ferramentas estavam desabilitadas. O modelo e a variante foram selecionados por CLI. O JSON não trouxe confirmação independente.

O isolamento do Antigravity para revisão Gemini segue sem confirmação. A listagem autenticada do Cursor falhou. Os pareceres Gemini e Cursor ficaram pendentes. A interface não expôs a seleção de Fast/priority para o subagente.
