# Correção pontual de inferência — 28/10/2026

Plano anterior à edição: substituir somente `var inside_open_hatch :=` por `var inside_open_hatch: bool =` em scripts/world/main.gd. Dictionary.get retorna Variant e impede inferência do resultado encadeado no Godot 4.7, conforme diagnóstico fornecido pelo usuário. Manter expressão, condições e comportamento. Não alterar cenas, RunController ou outros scripts.

Aceite: delta de uma declaração; revisão estática da fonte estável por Gemini, Grok, Muse e Opus Cursor, registrando indisponibilidades. Sem executar Godot, parser, testes, importação ou linter. Sem commit/push nesta correção. Preservar alterações locais do plugin/editor.

Implementação: GPT-6 Luna xhigh, única escrita no runtime. Fast/priority não confirmável pela interface. Principal registra documentação e revisões após congelamento.
