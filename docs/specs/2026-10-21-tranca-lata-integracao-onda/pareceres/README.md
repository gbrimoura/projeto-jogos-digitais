# Pareceres — integração da onda

21/10/2026. Preflight único desta nova tarefa em andamento; revisão final só depois do congelamento. Integração convencional de asset já aprovado, sem nova produção raster. Root coordena e revisa; único implementador GPT-6 Luna xhigh. Sem Godot/testes/QA/Git.

Preflight único21/10 concluído antes da implementação: AGY lista Gemini3.8FlashHigh; Cursor autenticado e lista cursor-grok-4.6-xhigh-fast e claude-opus-5-5-high; OpenCode lista credencialGo e muse-spark-1.3-contributor. Catálogo não garante disponibilidade de API; serão registradas as respostas reais dos modelos. Preferência global do usuário por Grok4.6 prevalece sobre4.7 local. Nenhum segredo lido ou alterado. Revisões finais só após congelamento do incremento.

## Implementação R1 e análise do principal

GPT-6 Luna xhigh entregou três arquivos congelados em historico/runtime-r1/: scripts/world/training_target.gd, scripts/enemy/containment_attack_visual.gd e scenes/training_target.tscn. O principal leu o visual completo, o diff contra a base local e as conexões de cena/ciclo do ataque. Somente uma chamada após o match e um helper visual foram adicionados ao alvo; dano, timers, raio, queries, poeira e corpo permanecem iguais. O helper usa o estado/timer final do tick, cobrindo overshoot e mantendo a fase visual impact de acerto. O visual pausa o sprite, seleciona os quadros por pesos cumulativos e oculta/reseta fora de active/impact. Assinatura antiga set_area_state de quatro argumentos e desenho do círculo foram preservados.

A nova Shockwave é filha de AttackAreaVisual: centro capturado herdado, filtro nearest, recurso aprovado impact, escala raio/70, z0 absoluto acima do piso por ordem da árvore e atrás do corpo z1. Nenhum novo relógio, autoplay ou chamada de dano. A cena compartilhada cobre as duas salas. O root comparou os três arquivos e snapshots com o manifesto e os33protegidos com a base, sem divergências, em integridade-r1.json. Não houve execução de Godot, importação, testes ou QA.

Entrada final inline runtime-r1-input.txt:23225caracteres, SHA-256 137CE7CDDF12F48498B4BA9461F8F4741B1C9B6DCF19E53184C140B1A9C46EBF. Contém diff integral, visual/cena completos, contexto de estados/cancelamento do alvo, SpriteFrames aprovado e manifesto. Quatro revisores receberam entrada imutável, somente leitura e sem ferramentas/comandos, timeout10min: Gemini3.8FlashHigh via AGY plan; Cursor Grok4.6xhighfast plan; Muse1.3Contributor xhigh via OpenCode plan; Cursor Opus5.5High plan. Saídas/erros/exits originais separados.

Cursor Opus retornou quota até03/11/2026, sem parecer. Muse retornou chave expirada, sem parecer; exit0 do wrapper não é aprovação. Não foram substituídos e nenhum segredo foi lido/alterado. Gemini/Grok seguem em revisão neste registro parcial.

## Resultado final — 21/10/2026

Gemini e Grok retornaram pareceres úteis, somente leitura, sem defeitos concretos P1/P2. O principal aceita esses achados junto com sua análise do diff e dos estados, sem tratar afirmações do modelo sobre arquivos preservados como hash calculado pelo revisor. Os revisores receberam texto inline, não executaram comandos nem Godot. Fontes, snapshots e33protegidos foram comparados pelo root; integridade-final-r1.json confirma os três arquivos congelados e os33arquivos protegidos ainda iguais após revisão.

Cursor Opus5.5High permaneceu indisponível por quota até03/11/2026; Muse permaneceu com chave expirada, ambos sem parecer e sem substituição. Saídas originais stdout/stderr/exit dos quatro revisores preservadas. Nenhum exit0 de wrapper é tratado como aprovação. Revisão Cursor Opus exigida continua indisponível; não foi silenciosamente trocada por outro modelo.

Integração realizada pelo GPT-6 Luna xhigh e revisada/coordenada pelo principal. O sprite aprovado agora está conectado à cena compartilhada, com sincronia pelos timers de ACTIVE. Círculo, poeira, dano, animações do corpo, movimento e demais mudanças locais preservados. Nenhum Godot/import/teste/parser/QA/commit/push ou troca de branch foi executado. Funcionamento visual em execução ainda não confirmado.
