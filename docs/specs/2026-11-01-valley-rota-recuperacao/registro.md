# Registro da implementação R1 — 01/11/2026

Evidência recebida: imagem e log existente, run4162699858, sala3353966537, família valley, andar1/sala2. Log copiado em pareceres/godot-log-recebido.log. Não houve reprodução ou execução desta seed.

Diagnóstico e implementação delegados a /root/diagnosticar_valley_seed, gpt-6-luna xhigh; Fast/priority não selecionável/confirmável. Único escritor de código, escopo restrito a room_layout_generator.gd e run_hud_bridge.gd. Escrita congelada antes da revisão R1; snapshots da base dirty e resultado em historico/base e historico/r1. Nenhuma mudança de branch, commit ou push.

O principal rejeitou o diagnóstico inicial de que primary0 seria necessariamente inválido por estar160px acima do chão: Main faz busca em grafo e permite apoios intermediários. Preservou primary0/fallback1 e todas as validações; ajustou geometria de acesso. Depois de reanálise, Luna confirmou a rota indireta. O argumento inicial que confundia sobreposição horizontal parcial com corpo já além do apoio também foi corrigido antes da autorização de escrita.

R1: canônico valley centros216/456/696/936, largura160 e tops400/448/448/400; aleatório valley vãos80/88/96, internos448 após consumir os jitter RNG existentes. Outras famílias preservadas. A versão corrigida mantém determinismo de seed, sem prometer geometria idêntica à versão defeituosa. Referências Variant dos caches da HUD agora são validadas antes dos casts; entradas inválidas removidas/ignoradas nas rotinas de alvo, ocultação, desligamento e restauração. Aparência compacta preservada.

Revisão manual do diff: chamadas RNG de jitter/width mantidas; branches de gap das outras famílias mantidos; allowed_steps.assign preservado; nenhuma alteração de física/validador/Main/controller. Comparação dos hashes com a base confirma nove arquivos protegidos intactos; só os dois arquivos de código autorizados mudaram entre os onze amostrados (pareceres/estado-r1.sha256.json).

Sem testes, Godot, parser, linter, auditoria, benchmark ou simulação, conforme AGENTS. Leitura de fonte/diff, log prévio, cálculo manual e hashes de preservação não comprovam execução em runtime.

Revisões externas: em andamento sobre entrada imutável codigo-r1-input.txt. Opus exato via Cursor retornou limite de uso, exit1; ciclo reinicia03/11/2026. Não houve substituição silenciosa nem aprovação Opus. A rodada prospectiva via AGY também retornou quota429/exit3.

Rodada de código encerrada: Gemini e Grok sem achados; P2 Muse avaliado e não integrado por não demonstrar regressão no ciclo existente (justificativa em pareceres/README.md). Opus indisponível por cota, revisão obrigatória pendente. Implementação aplicada; runtime permanece não verificado. Não se declara conclusão integral da revisão exigida.

