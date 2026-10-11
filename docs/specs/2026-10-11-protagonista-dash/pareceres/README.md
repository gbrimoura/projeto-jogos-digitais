# Pareceres — animação dash

## Estado final

Implementação e exportação integradas; R2 Gemini, Muse e Grok recebidas e avaliadas sem bugs concretos pendentes nas fontes. Opus bloqueado por quota, nenhum parecer. Runtime Godot não executado.

## Processo

Implementador GPT-6 Luna xhigh; a ferramenta não permite selecionar ou confirmar Fast/priority. Principal exportou pela instalação Aseprite 1.3.18.6, exit0, copiou atlas 960×64 e fonte combinada para assets/player e inspecionou as três poses. Inspeção visual read-only adicional do Luna sem clipping/desconexões evidentes.

## Achado e correção

A inspeção do JSON exportado pelo Luna identificou autoexpansão da tag walk para 6..14 quando frames foram anexados. R1 Gemini/Muse não detectaram esse efeito do Aseprite. Luna corrigiu o gerador para restaurar todos os intervalos originais após append, antes de criar dash, com invariantes finais. Regeneração Aseprite confirmou idle0..5, walk6..11, dash12..14 e repeat1. Pose e integração Godot permaneceram intactas. R1 Grok foi encerrada sem stdout por ter sido substituída pela R2 sobre a fonte corrigida; não é um parecer recebido.

## Revisores R2

| Revisor | Modelo / esforço | Resultado |
|---|---|---|
| Gemini via AGY | Gemini 3.8 Flash (High), plan | Concluído, sem bug concreto na fonte |
| Muse via OpenCode | opencode-go/muse-spark-1.3-contributor, xhigh, plan | Concluído, sem bug concreto na fonte |
| Grok via Cursor | grok-4.7-xhigh-fast, plan | Concluído, sem bug concreto na fonte |
| Opus via Cursor | claude-opus-5-5-high, plan | Preflight bloqueado por quota; nenhum parecer |

Todos foram somente leitura, sem ferramentas/testes/Godot, com timeout10min. As análises usaram Lua, PlayerVisual e SpriteFrames inline congelados; R1 incluiu a spec. Stdout originais R1/R2 e erro de preflight preservados nesta pasta. Não é atribuída aprovação visual dos binários aos revisores externos. SHA-256 do estado corrigido em estado-revisado.json; estado-r1.json e histórico preservam a versão anterior à correção.

## Validação e limites

Exportações Aseprite e inspeção visual concluídas. Revisão estática e git diff --check nos caminhos atribuídos pelo implementador. Não foram executados testes, Godot ou quality_audit. Aparência e cadência no gameplay permanecem para conferência manual. Nenhum commit/push realizado.

## Prévia com deslocamento

A correção do GIF demonstrativo está em preview-horizontal/README.md. Gemini, Muse e Grok concluíram revisão; Opus por quota. O GIF usa arquivo separado e não altera física nem atlas de runtime.

## Pose lateral v2

O usuário esclareceu que o dash deveria pôr o personagem de lado. V2 redesenha os três quadros em perfil e integra novo atlas/fonte/GIF. Muse/Gemini recebidos e avaliados; Grok timeout10min sem parecer e Opus quota. Estado e pendências em pose-lateral-v2/README.md. Pareceres R2 anteriores não aprovam os novos desenhos.

## Postura compacta v3

Nova arte baseada no diagnóstico de referências, implementada por Luna xhigh e exportada/integrada pelo principal. Revisão visual principal/Luna: silhueta mais baixa/compacta, sem clipping ou membros desconectados. Gemini/Muse sem regressões concretas nas fontes; Grok timeout10min sem parecer, Opus quota. Estado e hashes em pose-compacta-v3/README.md. Pareceres anteriores não aprovam a nova arte. Sem Godot/testes.
