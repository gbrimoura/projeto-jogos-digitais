# Registro — travessia e transição de salas

**Data:** 19/10/2026  
**Fase:** R2 integrada; revisão estática Gemini encerrada sem P1/P2 remanescentes. Opus/Muse indisponíveis e Grok sem parecer útil; nenhuma validação de engine executada.

## Fontes lidas

`docs/README.md`, `AGENTS.md`, docs ativos de porta lateral, geração de salas e integração de game loop, GDD `04-combate-e-builds.md` §3, e fontes atuais de Main, ExitDoor, RunController, RoomTransition, cenas Main/SecondRoom/ExitDoor/Player/RunRoot, visual e movimento do Player.

## Baseline e revisões do plano

`historico/baseline-local/sha256.json` registra SHA-256 de cópias locais pré-runtime (sem comparação com HEAD e sem comandos Git), preservadas com caminhos relativos na mesma pasta. Abrangem fontes e cenas tocadas ou consultadas. `historico/r1/` preserva a primeira proposta antes da decisão de adicionar contenção exterior; seu próprio `sha256.json` registra os hashes.

Após orientação do principal, R2 inclui contenção permanente fora da viewport x=[1152,1160), y=[0,648), 8×648 em ambas salas e no validador. Isso impede saída livre e segura o Player em falha/retry, sem ampliar o piso. O restante do fluxo é descrito em `plano.md` e `spec.md`: gate lateral condicionado ao clear/recompensa/guard, cruzamento positivo do centro em x=1120, e fade com dono único por fluxo.

## Implementação e freeze

As sete fontes de runtime foram integradas conforme o plano R3, com as correções R2 descritas no adendo de `plano.md` e `spec.md`. A porta abre por clear/recompensa/guard e a amostragem física detecta cruzamento positivo do centro do collider sem interação por tecla. O layout divide a parede direita em gate e contenção permanente; Main valida o pedido antes do lock; a transição standalone usa overlay de fade próprio e a run gerenciada mantém a progressão e a recompensa no RunController. O estado final está em `historico/r2-final/sha256.json`; o delta exato do freeze R1 está em `historico/r2-final/delta-r1.md`. O freeze R1 imutável permanece em `pareceres/implementacao-r1-snapshot/` com hashes em `pareceres/implementacao-r1-hashes.json`.

## Validação

Foi feita revisão textual das fontes e comparação com o snapshot R1. Não foram executados Godot, import, testes ou QA, conforme as instruções locais. O estado runtime R2 está congelado para revisão delta; qualquer correção posterior deve gerar novo manifesto e novo freeze.


## Resultado da revisão final

GPT-6 Luna xhigh implementou e integrou as correções, sob coordenação do principal. Gemini R1 apontou inversão do gate; R2 corrigiu esse P1, apresentação managed, posição atual na linha, rollback tardio e espera padrão. Gemini encerrou a revisão delta sem novos P1/P2. Grok encerrou sem texto de parecer; Opus Cursor bloqueado por quota e Muse por chave expirada. A revisão desses modelos permanece indisponível, sem substituição. O principal confirmou integridade das sete fontes e preservação dos dez arquivos protegidos por hashes. Consulte pareceres/README.md e as saídas originais. Sem Godot/import/testes/QA, commit, push ou mudança de branch.
