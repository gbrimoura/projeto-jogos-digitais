# Plano prospectivo — correção do carregamento da oferta

## Contexto e diagnóstico

02/11/2026. O usuário relatou que nenhum upgrade apareceu. O log de Godot já observado aponta como primeiro erro a resolução de `UpgradeStatText` em `scripts/ui/upgrade_card.gd`. A definição é declarada em `scripts/ui/upgrade_stat_text.gd`, mas não consta no cache global de classes do projeto. Em seguida, a cena da carta falha ao carregar, a preparação da oferta encontra `load_card_font_bundle` ausente e `Main` registra definições inválidas. O erro inicial é a dependência de tipo não resolvida; os demais são consequências no carregamento.

## Objetivo e recorte

Tornar explícita a dependência da carta ao renderer local para que a compilação não dependa de `UpgradeStatText` estar no cache global. Alterações autorizadas somente em:

- `scripts/ui/upgrade_card.gd`: preload local para `upgrade_stat_text.gd` e uso do alias nas anotações de tipo, casts, arrays e parâmetros que hoje usam `UpgradeStatText`.
- `scripts/ui/upgrade_stat_text.gd`: manter `class_name UpgradeStatText` e declarar a classe-base por caminho para `scripts/ui/hud/bitmap_text.gd`.

A correção não altera desenho, fonte, wrapping, cores, conteúdo de cartas, oferta, recompensas, balanceamento, cenas ou cache do editor. Registrar a rodada em `docs/specs/2026-11-02-corrigir-oferta-tipo-local/`.

## Execução e revisão

Snapshots byte a byte dos dois arquivos autorizados foram guardados em `historico/baseline/`, com os SHA256 no manifesto. Após a edição, congelar esse estado e encaminhar revisão somente leitura ao agente principal. Não executar Godot, importação, testes, parser ou linter; fazer somente inspeção estática do diff e dos hashes. Preservar todas as alterações existentes, sem commit, push, troca de branch ou limpeza.