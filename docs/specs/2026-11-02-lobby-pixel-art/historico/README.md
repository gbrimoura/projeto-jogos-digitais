# Histórico e baseline

## Baseline preservado antes de produzir assets

Em 02/11/2026 foram copiadas byte a byte as versões presentes no workspace de:

- `scripts/world/lobby_visual.gd` → `baseline/scripts/world/lobby_visual.gd`
- `scenes/lobby.tscn` → `baseline/scenes/lobby.tscn`

O script de visualização estava untracked no Git e contém a placa âmbar local em `Rect2(888,384,176,40)` e os campos/métodos já usados pelo lobby. Essas alterações estavam presentes antes desta tarefa e devem sobreviver. A cena também estava untracked e foi preservada para comparação. Hashes SHA-256 estão no `baseline/sha256.txt`; o estado de trabalho completo foi registrado em `baseline/git-status-before-products.txt` antes da fase de produção.

Nenhum arquivo de produto, cena, asset ou código foi alterado nesta fase. O plano/especificação desta tarefa ficaram fora do índice `docs/README.md`, que ainda não foi atualizado.

## Próxima entrada

Somente após revisão e GO do principal: iniciar autoria Aseprite. Ao congelar os primeiros produtos, registrar novos snapshots/hash e o conjunto exato autorizado. Não substituir nem reescrever este baseline.
