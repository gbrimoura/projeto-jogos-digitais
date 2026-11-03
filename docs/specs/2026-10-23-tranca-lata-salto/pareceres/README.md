# Pareceres e entradas imutáveis — 23/10/2026

Implementação: GPT-6 Luna xhigh, escritor único; principal coordenou, examinou arte/diffs/estados e decidiu correções. Fast/priority não confirmável na interface. Todos revisores em modo somente leitura, sem Godot/testes; entradas congeladas, saídas/stdout/stderr/exit originais preservadas. Preflight uma vez por tarefa: AGY, Cursor (autenticado e catálogo) e OpenCode Go/catálogo; identificadores exatos confirmados, sem ler/alterar segredos. Falha de quota real do Opus registrada separadamente da disponibilidade em catálogo.

## Plano
- R1: plano-r1-input.txt SHA922C779A12A3F23EFD1673F051E3D92E9387487BBE79439E0563C0CB8C00C756.
- R2: plano-r2-input.txt SHA3E13C9204120A1A16B13A9916123F1D9498D5C89122F0CDB62D461E0B98AD147.
- R3: plano-r3-input.txt SHA1E3F30AB156191F668A2C41A8D501BC877BF5CDCF795047342CF7D175ADF9F48.
- Decisão principal: plano-r4-decisao.txt incorporada à spec, sem reescrever históricoR1.

| Prefixo | Ferramenta/modelo/modo | Resultado real |
|---|---|---|
| plano-r1-gemini | AGY Gemini 3.8 Flash (High), plan | Exit0, stdout vazio: sem parecer útil. |
| plano-r1-grok | Cursor cursor-grok-4.6-xhigh-fast, plan | Exit0, apenas2bytes: sem parecer útil. |
| plano-r1-muse | OpenCode opencode-go/muse-spark-1.3-contributor xhigh, plan | Parecer útil com5P1 de precisão pré-código, avaliados e concretizados emR2/R3/R4. |
| plano-r1-opus-agy | AGY claude-opus-5-5-high, plan | Exit0, somente preâmbulo, sem parecer útil. Não conta como aprovação Opus. |
| plano-r2-muse | OpenCode Muse1.3 xhigh, plan | Parecer útil com precisões, avaliação crítica do principal incorporada emR3/R4. |
| plano-r3-muse | OpenCode Muse1.3 xhigh, plan | Parecer útil com precisões adicionais pré-código; não declarou plano sem achados. Critérios úteis aceitos emR4; contradição de tipoFloor rejeitada após conferir classe/cenas reais. |
| plano-r3-gemini | AGY Gemini3.8FlashHigh, plan | SemP1;4precisõesP2 aceitas emR4. |
 
Severidades dos pareceres de plano não são bugs de código existente: runtime ainda não havia sido modificado. Root encerrou especificação R4 com decisões normativas. Arte Aseprite só foi integrada depois de inspeção e aprovação do contact pelo principal.

## Runtime
R1 estável em historico/runtime-r1/sha256.json. Revisão interna root-runtime-r1.txt encontrou gravidade porremaining, escapePlayer sem tangente e intervalo de patrulha que não incluíaXatual. Luna corrigiu os3 emR2, com novo snapshot historico/runtime-r2/sha256.json.

Entrada integral R2: runtime-r2-input.txt, SHA8A84E0108643D8933E97F650A11E6A8B51B6D976D52F3A66F655B796D4BF494E, 63140caracteres. Entrada compacta preservada para referência: runtime-r2-compact-input.txt SHAA3C666696346CDBADADBE822362B9A590F6A43B05E50B4319641B5A022B515D0. Revisores recebem texto integral por caminho somenteleitura (Muse também anexo); nunca versão compacta truncada.

| Prefixo | Ferramenta/modelo/modo | Resultado real |
|---|---|---|
| runtime-r1-opus | Cursor claude-opus-5-5-high, plan | Exit1; ActionRequiredError de limite de uso até03/11/2026 (mensagem11/3/2026), sem parecer. Não substituído; revisão Opus permanece indisponível. |
| runtime-r2-gemini | AGY Gemini3.8FlashHigh, plan | Exit0, parecer útil semP1/P2. Principal aceita correções/contratos, sem tratar alegações absolutas sobre motor como runtime verificado. |
| runtime-r2-muse | OpenCode Muse1.3 xhigh, plan | Tentativa de anexar arquivo falhou pela ordem de argumentos (FileNotFound). Saídas preservadas; sem parecer, não é aprovação. |
| runtime-r2-muse-attach | OpenCode Muse1.3 xhigh, plan | Ordem de argumentos corrigida no mesmo modelo/variante. Exit0, parecer útil semP1/P2. |
| runtime-r2-grok | Cursor cursor-grok-4.6-xhigh-fast, plan | Timeout10min; processo específico encerrado pelo principal após limite, stdout vazio e stderr/exit preservados. Sem parecer útil, sem nova tentativa/substituição. |

A instrução global do usuário exige Grok4.6, prevalecendo sobre indicação4.7 do AGENTS local. Não houve substituição silenciosa. Entradas e snapshots estáveis não são alterados durante revisões.

## Preservação e limites
integridade-r2.json:19fontes protegidas do baseline e12dirtypreexistentes protegidos iguais;6arquivos de implementação iguais aos snapshotsR2. Código não foi executado. Godot/import/testes/lint/quality_audit não foram executados; produção Aseprite e leitura estática/hash/inspeção visual de arte são atividades distintas. Sintaxe/carregamento e aparência/física em jogo permanecem sem confirmação de motor.
## Encerramento R2
Principal aceita revisão estática de Gemini/Muse semP1/P2 e as correções do integrador/escape/bounds. Grok finalatingiulimite10min, registrado em runtime-r2-grok.timeout.txt; não é aprovação. Opuscontinuaindisponívelporquota. integridade-final-r2.json confirma6fontes congeladas e entrada integral imutáveis após revisões. Nenhuma execuçãoGodot/teste. Estes pareceres não confirmam sensação visual ou resultados do motor; apenas análise de fonte. Nenhum revisor foi substituído.