# Registro — correção de inferência de Main

28/10/2026. Diagnóstico fornecido pelo usuário: Dictionary.get mantém Variant na expressão encadeada e impede inferência de inside_open_hatch com := em Godot4.7. Configuração comum/boss em run_root.tscn aponta corretamente para scenes/main.tscn. Falha has_method de RunController é efeito de Main não carregar.

Plano/spec escritos antes da implementação. Luna gpt-6-luna xhigh alterou exclusivamente a declaração local para `var inside_open_hatch: bool = top_open ...`, expressão preservada; Main congelado para revisão. Principal conferiu o delta de uma linha por leitura. Não houve engine/parser/testes/linter/import nem nova publicação.

Base de publicação anterior: commit178dfdd, branch corrigir-sprites-salas-plataformas. Esta correção permanece local. Dados do editor e alterações de plugin continuam preservados.

Preflight único verificou ferramentas, autenticação e IDs. Opus Cursor requisitado no modelo exato claude-opus-5-5-high e indisponível por ActionRequiredError/limite de uso com reset informado03/11/2026. stderr contém também erro do auto-updater .promote-lock; não houve alteração de locks/credenciais/planos nem troca de modelo. Detalhes e saídas em pareceres/.

Encerramento: Gemini, Grok e Muse concluíram revisão estática sem P1/P2 no delta; Opus sem parecer por quota. Principal aceitou a correção restrita de uma linha e conferiu hash do snapshot final contra Main integrado. Nenhum runtime/teste foi executado e não houve novo commit/push. Saídas originais e limitações preservadas.
