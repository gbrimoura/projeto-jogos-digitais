# Plano prospectivo — integração de textos das cartas

## Objetivo
Aprimorar a leitura das sete cartas de melhoria já integradas. Cada carta deve explicar a condição em uma frase curta e mostrar estatísticas com nomes e números derivados das definições reais. Para EVOLUIR, comparar o valor atual com o próximo quando isso esclarecer a mudança; para NOVO, destacar o ganho nominal.

## Escopo permitido
- scripts/progression/upgrade_catalog.gd: somente card_preview, card_topics, effect_summary e helpers de apresentação necessários.
- resources/upgrades/*.tres: somente title, description, effect_summary, effect_topics.
- scripts/ui/upgrade_offer.gd: somente textos de título e instrução.
- assets/ui/upgrade_cards_v1/source/generate_upgrade_cards.lua: somente copy e montagem/apresentação da prévia, incluindo modo preview_only que lê os ícones existentes sem reexportar arte.
- As duas prévias de cartas existentes, com texto atualizado. Nenhum outro PNG, ASE, fonte, moldura, geometria ou integração de ícones.

## Restrições
Preservar IDs, caminhos dos ícones, campos numéricos e mecânicas. Manter 24 glifos por linha, descrição de até duas linhas, no máximo três linhas de estatísticas e badge com até 22 glifos; usar somente glifos já existentes. Explicitar que a carga afeta o próximo acerto após rebater a própria bola; que o dínamo reduz a recarga restante do dash uma vez por rebatida; e que a cura do chassi ocorre na escolha. Não chamar Godot, imports, testes, parser, linter, auditoria ou simulação. A produção de prévias é permitida somente no Aseprite, em modo que não toque na arte.

## Estado de revisão
Baseline dos alvos será arquivada antes da implementação. Após congelar os arquivos, o agente principal executará o preflight único e solicitará a revisão obrigatória somente leitura.