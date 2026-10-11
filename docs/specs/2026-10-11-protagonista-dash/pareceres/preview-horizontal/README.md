# Prévia horizontal do dash

## Resultado

GPT-6 Luna xhigh criou protagonista-dash-preview.lua; a interface não permite confirmar Fast/priority. Principal executou geração/exportação no Aseprite1.3.18.6 (exit0), gerou protagonista-dash-horizontal-v1.gif em escala6× e inspecionou o strip. Canvas136×64, 16quadros; holds de300ms e dois percursos de50px em140ms cada, com espelhamento para a volta. O ciclo mantém a posição/orientação ao retornar ao início. Runtime Godot e atlas de poses não foram alterados.

## Correção encontrada na exportação

O primeiro export gerou17quadros por deixar o frame inicial do Sprite vazio. Luna adicionou contador próprio para reutilizar frame1 e uma invariante de16quadros. Ajustou a amostragem horizontal para15,22,29,37,44,51,58 e51,44,37,29,22,15,8. Reexportação confirmou16quadros e todas as chamadas de export retornaram exit0.

## Revisões

| Revisor | Modelo / esforço | Resultado |
|---|---|---|
| Gemini via AGY | Gemini3.8 Flash (High), plan | Concluída, sem bugs de movimento/loop; export GIF separada documentada e executada |
| Muse via OpenCode | opencode-go/muse-spark-1.3-contributor, xhigh, plan | Concluída, sem bugs concretos |
| Grok via Cursor | grok-4.7-xhigh-fast, plan | Concluída, sem bugs concretos |
| Opus via Cursor | claude-opus-5-5-high, plan | Preflight bloqueado por quota, nenhum parecer |

Revisores trabalharam em leitura sobre Lua inline congelada, sem ferramentas/testes; timeout10min. Stdout original e erro do Opus preservados. Hashes da fonte, Aseprite e GIF em estado-revisado.json. Não foi atribuída aprovação estética dos binários aos revisores que não os visualizaram. Conferência visual do strip pelo principal; nenhum teste ou Godot executado.
