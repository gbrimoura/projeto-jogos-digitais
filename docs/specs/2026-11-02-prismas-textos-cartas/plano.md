# Plano prospectivo v2 — prismas e leitura das cartas

## Objetivo
Tornar o rank oferecido legível com uma fileira compacta de prismas facetados. Preservar os textos detalhados já presentes nos dados das cartas e corrigir o erro de array tipado que impede a construção dos tópicos. Cobrir a área de resumo/tópicos com navy opaco para ocultar marcadores decorativos antigos.

## Decisões
- Manter carta 160×240 e rodapé existente. Prismas ficam em y=190..202; status e contador continuam em y=205..228.
- Usar exatamente `rank_max` espaços somente para os tetos finitos atuais 3, 5 e 10. Ciano indica ranks adquiridos, amarelo indica o próximo rank ofertado, vazios usam contorno metálico. Não interpolar, arredondar ou inventar níveis.
- Derivar quantidade/estado de `rank_before`, `rank_after`, `rank_max` e `reward_kind` entregues pela oferta. Para caps fora de 3/5/10, omitir prismas e manter o contador numérico. `recovery` sempre omite prismas e conserva `CURA ATÉ 1 VIDA`, sem representar seu teto contábil 220.
- Tetos atuais: sete upgrades principais cap3; atributo de velocidade da bola cap10; ajuste de recarga do dash cap5. Nenhum upgrade finito atual excede10.
- Cobrir y=143..187 com navy antes de desenhar os tópicos; preservar a divisória y=188. O SummaryBackdrop existente cobre y=118..142.
- Construir `Array[Color]` vazio e adicionar prefixo com `append`; não atribuir array genérico de ternário. Preservar wrapping, spans de cor, copy de resumo e tópicos já detalhados.
- Atualizar o Lua e os estudos Aseprite para mostrar os mesmos dados atuais: Carga 0→1/3, Mola 1→2/3, Dínamo 2→3/3; pós-build 0→1/10, 0→1/5 e recuperação sem prismas. Prévia é estudo visual, não captura do jogo.

## Escopo
Somente `scripts/ui/upgrade_card.gd`, novo `scripts/ui/upgrade_rank_prisms.gd`, `scenes/ui/upgrade_card.tscn`, `assets/ui/upgrade_cards_v1/source/generate_upgrade_cards.lua`, os quatro PNGs de estudo, README/manifest das cartas e este pacote com `docs/README.md`.

## Restrições
Não alterar catálogo, recursos, valores, caps, oferta, gameplay, ícones, molduras, fonte ou cache. Não executar Godot, imports, testes, parser, linter, auditoria ou simulação. Produzir prévias somente pelo Aseprite real com `preview_only=true`, sem `clean_frames`. Sem Git, commit, push, troca de branch ou limpeza.

## Correção de versão
A V1 foi criada antes de consultar o plano aplicado de balanceamento e herdou indevidamente Carga cap220 e mapeamento proporcional. Essa decisão foi corrigida nesta V2 antes da produção visual; a V1 original está preservada em `historico/plano-v1.md` e `historico/spec-v1.md`. A fonte de verdade são os tetos ativos confirmados em `docs/specs/2026-11-02-balanceamento-runs-longas/plano.md` e nos metadados atuais.

## Baseline
Os arquivos-alvo e suas cópias byte a byte em `historico/baseline/` foram capturados antes da implementação; os hashes estão em `historico/baseline-sha256.csv`.

## Estado
Implementação e quatro prévias Aseprite congeladas para revisão estática somente leitura. O agente principal integra e avalia os pareceres antes de declarar a entrega concluída.