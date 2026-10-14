# Pareceres — sentinela de contenção

Estado: implementação local congelada e revisão estática R2 concluída por Gemini, Muse e Grok sem correções obrigatórias remanescentes. Opus bloqueado por quota do Cursor, sem parecer. Nenhum Godot/import/runtime/teste/QA executado.

## Autoria, escopo e método
GPT-6 Luna xhigh implementou exclusivamente training_target.gd, training_target.tscn, containment_attack_visual.gd e documentos desta pasta. Fast/priority não selecionável ou confirmável pela interface. Principal coordenou, inspecionou fontes, registrou os pareceres e integrou a correção via mesmo implementador. Cartoon V2 foi publicado primeiro em a19968fa, conforme pedido; ataque permanece local sem commit/push. Baseline pré-código e pré-correção preservados em historico/.

Preflight realizado uma vez nesta tarefa, autenticado com identificadores exatos. Todos os revisores em modo somente leitura/plan, timeout10min, pacote inline congelado, sem comandos ou acesso mutável ao workspace. Entrada R1 completa dos três runtime + plano/spec e fatos dos contratos existentes; R2 delta completo da margem e spec, não revisão integral nova. Fontes de player/health/salas foram conferidas pelo principal/implementador, não executadas pelos revisores.

## Resultados fiéis
- Gemini 3.8 Flash (High), AGY plan: R1 e R2 native exit0, STATUSdone; sem bloqueios.
- Muse opencode-go/muse-spark-1.3-contributor, xhigh, OpenCode plan: R1 e R2 exit0, STATUSdone; R2 encerra margem e contrato textual.
- Grok cursor-grok-4.6-xhigh-fast, Cursor plan: R1 e R2 exit0, pareceres úteis STATUSdone; R2 encerra margem e contrato textual.
- Opus claude-opus-5-5-high, Cursor plan: R1 e R2 exit1 ActionRequiredError por usage limit; nenhum parecer, não substituído. Revisão obrigatória permanece indisponível.

Stdout original: gemini/muse/grok/opus-r1.txt e -r2.txt. Códigos nativos separados em *-exit.txt. Entradas em review-input-r1.txt e review-input-r2.txt; hashes estado-implementacao-sha256.json e estado-pos-correcao-margem-sha256.json.

## Decisões do principal
Muse/Grok apontaram margem física0.08 maior que raio visual: corrigida para0.0 por Luna e confirmada R2. Uso de impact durante ACTIVE era decisão explícita de reutilizar arte atual; plano/spec esclarecidos, sem shader flash de golpe; shader permanece reservado ao dano recebido. R2 confirma contrato.

Hipóteses de player persistente fora de current_scene, escala/rotação futura do alvo, co-op e alterações de parâmetros durante o golpe não são defeitos atuais: salas atuais instanciam alvo sem escala/rotação e jogador descendente da cena. Não ampliar arquitetura por essas hipóteses. Tentativa única durante invulnerabilidade, LOS ao centro da cápsula e cancelamento de recuperação quando jogador morre correspondem ao contrato aprovado.

Limites: revisores inferem comportamento das fontes; não confirmam compilação/runtime. Raio140, windup650ms, active140ms, recovery1400ms e dano1 são valores provisórios. Leitura visual e sensação do golpe aguardam observação no jogo. Revisão Opus pendente, sem alegação de aprovação total.
