# Preflight e revisão

Preflight único deste incremento em23/10/2026: Cursor status autenticado; catálogo confirmou cursor-grok-4.6-xhigh-fast e claude-opus-5-5-high. AGY listou Gemini3.8FlashHigh; OpenCodeGo autenticado e muse-spark-1.3-contributor confirmado. Grok4.6global prevalece sobre indicação4.7local. Catálogo não garante quota; Opus exato deve ser tentado na revisão do estado estável, sem substituição. Nenhum preflight será repetido sem mudança de evidência.

Revisões finais do incremento, não da antiga R1: Gemini AGY High/plan; Grok Cursor xhigh-fast/plan; Muse OpenCode xhigh/plan; Opus Cursor High/plan. Somente leitura e stdout, timeout10min, entradas/SHA/snapshots/saídas originais preservados. Sem Godot/testes/import/parser/linter/QA. Ainda não iniciadas.

## Estado R2 congelado

Entrada `runtime-r2-input.txt`, SHA256 `0B8CAD25B7BD7092B5A37FCB81F4AD915C16095D58E65FA6BF81B34C4DEEF9C4` (93140 bytes). Snapshot completo70arquivos em `../historico/runtime-r2-final/sha256.json`; snapshot anterior ao ajuste de reprodutibilidade preservado em `runtime-r2`. Provas por hashes:29/29 protegidos intactos em `../historico/protected-r2.json` (runtime/cenas/seletor/módulos/wrappers/arte antiga/gameplay). Dados numéricos ImageTexture omitidos só da entrada; arquivo completo e hashes preservados, fonte do serializador incluída.

Revisões somente leitura iniciadas23/10/2026 ~21:35SP: Gemini AGY3.8FlashHigh/plan, Grok Cursor4.6xhigh-fast/plan, MuseOpenCode1.3Contributor/xhigh/plan, OpusCursor5.5High/plan,10min. Nenhuma execuçãoGodot/testes/import/parser/linter/QA. Opus exato retornou exit1 por quota; stderr originalpreservado, não foi substituído. Demais pareceres em andamento; não atribuir aprovação pendente.

## Resultado e decisão final

| Revisor | Ferramenta/modelo/modo | Resultado fiel |
|---|---|---|
| Gemini | AGY Gemini3.8FlashHigh, plan | exit0, semP1; P2 de redação do README resolvido por delta documental, confirmado em novo stdout exit0 |
| Grok | Cursor cursor-grok-4.6-xhigh-fast, plan | exit0, semP1 de vidro; trêsP2 apontados e avaliados pelo principal abaixo |
| Muse | OpenCode muse-spark-1.3-contributor, xhigh, plan | exit0, semP1/P2 concreto; limitações de proveniência/duplicação de âncoras registradas |
| Opus | Cursor claude-opus-5-5-high, plan | exit1 por quota; semparecer, semsubstituição |

Saídas originais preservadas em runtime-r2-{gemini,grok,muse,opus}.{stdout,stderr,exit}.txt. A correção documental feita por Luna alterou apenas README e hash/tamanho desse arquivo no manifesto; Lua/arte/recursos/runtime/cenas permaneceram byte-exatos ao R2 revisado. Snapshot dessas duas fontes finais em ../historico/documentacao-final. Entrada delta runtime-r2-docs-input.txt SHA2566634C970BE46BB7A92A532D1F382DD683BE719E2A1290B71DB6D8D8F5500B7A5; stdout/stderr/exit do Gemini em runtime-r2-gemini-docs.*. Sem novo preflight, nova execução de produtor ou mudança substantiva runtime. Gemini confirmou explicitamente P2 resolvido.

### Avaliação crítica dos achados
1. O JSON registra parâmetros da abertura344,56,38,78; não promete AABB exato da tinta exterior. steppedWindow pinta também o pixel de contorno x382, já descrito no plano antes das revisões; todos os módulos atuais deixam esse pixel livre, conforme Grok/Muse/Gemini e inspeção do principal. A observação Grok sobre futura peça usar só w38 é recomendação de contrato futuro: novos módulos devem considerar contorno/folga, não apenas parâmetros. Não há vidro/moldura atual sobreposto a corrigir. Não se alterou a arte para resolver risco hipotético.
2. bases-only preserva regiões/âncoras dos módulos e atualiza legendas, sem regravar regions-and-anchors.json. Essa preservação é intencional e mantém o recorte de arte mínima; a descrição ambígua de metadata no README foi corrigida. O JSON atual contém a abertura correta, e full emite esse campo. Futuras alterações de abertura/limites precisam manter definições/exportação consistentes e usar full. Gemini confirmou que a documentação agora reflete o código; não foi criado exportador novo para bases-only.
3. A coluna opaca boiler em420 pode ficar parcialmente atrás do montante opaco da prensa. Isso é profundidade de cenário: máquina em frente a estrutura sólida da parede. A coluna não atravessa o vidro e seu trecho exposto permanece ligado à estrutura; não equivale ao defeito relatado pelo usuário. O principal inspecionou001/101 em tamanho1152x648 e aprovou a composição. Logo não adotou esse achado como defeitoP2 obrigatório.
4. Estudos V2 completos permanecem históricos e não são texturas de runtime; seletor usa apenas wrappers das bases modulares corrigidas. O modo full ainda produz esses estudos históricos por compatibilidade, e termina com oito contextos de produção. Âncoras duplicadas e I/O intermediário dos quatro contextos são manutenção futura, sem divergência atual. Mudança posterior de Lua foi limitada a documentação de parâmetros, exportador de metadata no full e chamada final de oito contextos; arte produzida não foi alterada depois. Nenhuma afirmação de execução dessa versão fonte final ou de carregamento de engine.
5. Gemini contou27 protegidos em seu texto; o manifesto local completo contém29 e a conferência do principal preserva29/29. As saídas originais não foram editadas para corrigir essa contagem ou links/linhas agregados.

Decisão: manter correção integrada. Não há unanimidade inventada: Grok manteve trêsP2 no seu stdout, avaliados acima pelo principal. Gemini/Muse sem bloqueios atuais; Opus indisponível por quota. Estado final70/70 estável:68fontes/arte/recursos/logs do snapshotR2 e2documentos do delta final;29/29 protegidos intactos. Evidências em ../historico/stable-final.json e protected-final.json. Sem Godot/testes/import/parser/linter/QA, commit/push/troca de branch. Inspeção estática/visual não confirma gameplay.
