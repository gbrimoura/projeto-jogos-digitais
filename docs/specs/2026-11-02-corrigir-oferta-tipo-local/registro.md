# Registro — 02/11/2026

A causa raiz indicada pelo log existente é uma referência ao tipo global `UpgradeStatText` sem entrada correspondente no cache de classes. A carta não conseguia carregar; os erros seguintes de carregamento da cena, função de fonte e definições de `Main` decorriam disso.

A correção adiciona preload explícito de `scripts/ui/upgrade_stat_text.gd` em `upgrade_card.gd` e troca as anotações, casts, array tipado e parâmetros do renderer para o alias local `UpgradeStatTextScript`. O script do renderer mantém seu `class_name` para o editor e estende o script-base por caminho explícito.

Os snapshots prévios dos dois scripts e o manifesto estão em `historico/baseline/`. A inspeção do estado editado confirmou a presença do preload e a conversão das referências de tipo. Nenhum conteúdo de renderização, texto, oferta ou gameplay mudou deliberadamente.

Não foi executado Godot, teste, importação, parser ou linter. A revisão independente de implementação está pendente no agente principal sobre o estado congelado.
## Resultado integrado
A carta agora preloada UpgradeStatTextScript e usa o alias local nos tipos/casts/arrays/parâmetros. O renderer mantém class_name e herda bitmap_text.gd por caminho. Não alteramos seleção, gameplay ou cache. Revisões Gemini/Grok/Muse sem bloqueios, Opus pendente por cota. 27arquivos protegidos intactos. Nenhuma execução de Godot/testes; log do usuário foi usado só para diagnóstico. Ao recarregar a execução, as novas dependências serão carregadas por caminho; a confirmação de runtime ainda não foi observada pelo agente.
