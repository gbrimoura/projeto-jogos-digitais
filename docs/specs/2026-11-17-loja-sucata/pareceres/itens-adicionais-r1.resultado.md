# Revisao dos cinco itens adicionais — R1

- Snapshot revisto: `itens-adicionais-r1.snapshot.md`
- SHA-256 do snapshot: `6114FFE3CE3C972424C5A1D73A28B692DAF8750BADAA22A7D0D807A382D61157`
- Manifesto de hashes dos 15 arquivos de código/documentação e 20 artefatos de arte: `itens-adicionais-r1.files.json`; hashes conferidos antes da revisão.

## Muse Spark

OpenCode 1.17.13, modelo solicitado `opencode-go/muse-spark-1.3-contributor`, variante `xhigh`, agente `plan`, `--pure`; exit code 0, sem timeout e sem stderr. A resposta foi: “No actionable findings were found in this scope.” O preflight `opencode debug agent plan --pure` confirmou todas as ferramentas desativadas (`read`, shell, busca, tarefas, web e edição incluídas). A saída não expôs `modelUsage`, portanto modelo/variante efetivos não puderam ser confirmados. Resposta bruta: `muse-itens-r1.stdout.jsonl`; stderr: `muse-itens-r1.stderr.txt`.

## Revisoes pendentes

Gemini 4 Hydrogen (High), exigido para esta superfície média, não recebeu o snapshot porque a política exige prova de isolamento além de `--mode plan --sandbox`; essa prova não foi obtida. O Gemini 3.8 Flash High solicitado pela política local também permanece pendente pela mesma lacuna. Cursor Grok 4.7 XHigh Fast não foi executado: a autenticação/listagem de modelos falhou e não foi usado fallback. Essas lacunas impedem declarar aprovação externa completa.

## Verificacoes locais

Os cinco PNGs finais passaram `quality_audit.py`: canvas 32×32, até 16 cores, alfa binário e zero pixels isolados. `git diff --check` não reportou whitespace inválido; apenas avisos de normalização CRLF em quatro arquivos já modificados. Nenhum teste, import ou comando Godot foi executado.
