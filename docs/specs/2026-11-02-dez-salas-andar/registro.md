# Registro — dez salas por andar

## Escopo e resultado
Integradas 10 salas comuns mais a sala de chefe existente por andar (11 no total). run_root.tscn mantém floors_per_run = 1. O padrão em scripts/world/run_controller.gd agora é 10 dentro da faixa 1..10. A intenção futura de variar eventos e quantidades de inimigos está registrada, sem mudanças nesses sistemas.

## Integridade
Os arquivos runtime já tinham alterações locais antes da tarefa. Cópias binárias pré-edição em historico/base/ preservam esse estado. Comparação somente de leitura confirma que cada arquivo final difere de sua cópia-base apenas na linha autorizada. Diff: historico/diff.txt. Hashes base/final: historico/final-sha256.json.

- run_root.tscn: base 4646D010359F459F4681D9726FB397F61CA06D950228A283EEBD81D7A54F70B5; final 6FC7522C9F8E83F39C7CCA5694246CB6B241CC9D79C5B1C7E8275C4D91205C98.
- scripts/world/run_controller.gd: base 5959E2668F8B1E51B3B7FC712CE679BCB1B5D84D920C110E36051B574B38A28D; final 1FC1E81FF31EC8EBDFB928F5D41A2D7544C58B6721DB0C1AC10C7FCF82A757F6.

## Revisão e validação
O estado runtime está congelado para revisão estática. O principal registrou preflight dos três modelos disponíveis; a tentativa Claude Opus 5.5 High via Cursor terminou com exit 1 por cota e está registrada fora deste incremento. Os pareceres restantes estão pendentes de coordenação pelo principal. Nenhum teste, comando de Godot, import, parser, lint, auditoria ou simulação foi executado.
Sem commit, push, limpeza do Git ou edição do GDD externo.

## Fechamento do principal
Luna implementou as2linhas; root conferiu diffs e preservação local. Gemini/Muse favoráveis, Grok sem parecer e Opus pendente por quota. Saídas fiéis em pareceres/. Sem runtime/testes; balanceamento do andar maior ainda não medido.
