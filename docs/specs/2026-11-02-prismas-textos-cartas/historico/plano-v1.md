# Plano prospectivo — prismas e leitura das cartas

## Objetivo
Tornar o nível oferecido legível por uma fileira compacta de prismas facetados e preservar os textos detalhados já produzidos para cada efeito. Corrigir o erro de array tipado que interrompe a preparação dos tópicos. Cobrir com fundo navy a faixa opaca de resumo/tópicos para não exibir marcadores decorativos antigos.

## Decisões
- Manter carta 160×240 e rodapé existente. Prismas ficam em y=190..202; status e contador continuam em y=205..228.
- Derivar o limite do próprio `rank_max` já entregue pela oferta: três espaços para máximos até 3, cinco até 5 e dez acima de 5. Se o limite superar dez, mostrar o progresso proporcional em dez espaços. Ciano representa níveis já adquiridos; amarelo representa somente o próximo nível ofertado; espaços vazios usam contorno metálico.
- O tipo `recovery` não exibe prismas. O contador textual de rank e os efeitos de recuperação permanecem como estão.
- Cobrir y=143..187 com navy antes de desenhar os tópicos; preservar a linha divisória y=188. O SummaryBackdrop existente continua cobrindo y=118..142.
- Construir o array de cores tipado por `append`, sem ternário de arrays genéricos. Preservar a quebra dos tópicos, traços cianos, valores novos amarelos, valores atuais/condições cinza e copy de resumo.
- Atualizar o Lua e os estudos Aseprite para representar os mesmos caps reais, incluindo Carga 0→1/220 e exemplos 1→2/3, 2→3/3. Prévia é estudo visual, não captura do jogo.

## Escopo
Somente `scripts/ui/upgrade_card.gd`, novo `scripts/ui/upgrade_rank_prisms.gd`, `scenes/ui/upgrade_card.tscn`, `assets/ui/upgrade_cards_v1/source/generate_upgrade_cards.lua`, os quatro PNGs de estudo, o README/manifest das cartas se necessário e este pacote documental com `docs/README.md`.

## Restrições
Não alterar catálogos, definições, recursos, oferta, gameplay, ícones, molduras, fonte ou caches. Não executar Godot, imports, testes, parser, linter, auditoria ou simulação. Produzir prévias somente pelo Aseprite real com `preview_only=true`, sem `clean_frames`. Sem Git, commit, push, troca de branch ou limpeza.

## Baseline
Os arquivos de entrada e suas cópias byte a byte em `historico/baseline/` foram capturados antes da implementação; os hashes estão em `historico/baseline-sha256.csv`.

## Estado
Plano prospectivo criado antes das alterações. A implementação será congelada e entregue ao agente principal para revisão estática somente leitura.