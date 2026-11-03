# Especificação — dependência local do renderer de texto

1. `upgrade_card.gd` declara `UpgradeStatTextScript = preload("res://scripts/ui/upgrade_stat_text.gd")` junto às dependências de script já carregadas por caminho.
2. Todas as referências de tipo a `UpgradeStatText` no script da carta usam `UpgradeStatTextScript`: o array de tópicos, casts dos nós, campos de rodapé e parâmetros dos helpers.
3. `upgrade_stat_text.gd` preserva `class_name UpgradeStatText` e herda explicitamente de `res://scripts/ui/hud/bitmap_text.gd`.
4. Nenhum arquivo fora dos dois scripts autorizados e deste pacote documental é alterado pela implementação.
5. A validação desta rodada é estática. Nenhuma execução de Godot ou teste será declarada.