# Implementação — 23/10/2026

Pedido: algoritmo de perseguição do Tranca-Lata e nome para o operário. Incremento delegado a GPT-6 Luna xhigh (Fast/priority não selecionável pela interface); escritor único, sem testes ou motor. Revisão externa somente leitura sobre snapshot R1 estável.

Tranca-Lata encontra Player vivo na mesma sala por referência de nó; persegue horizontalmente, respeita alcance/LOS e usa grafo dirigido com custo geométrico entre plataformas/Floor, com replanejamento limitado a450ms. Conserva o último apoio do jogador durante saltos. Aproxima ponto de decolagem com margem96px, bloqueia temporariamente arestas impossíveis/sem progresso, pode usar apoio intermediário e contornar obstáculos no mesmo chão. Só o primeiro salto é fisicamente validado por casts/overlaps existentes; PREPARE revalida. Física, dano, cooldown e bloqueio de ataque no ar/pouso preservados. Nome proposto e implementado: Cospe-Rebite, texto root separado do espelhamento de Visuals.

O log real do usuário registrou TrancaLataJump desconhecido e novos atlas PNG sem loader, impedindo carga de TrainingTarget e validação de sala. Helpers agora usam preload explícito, sem depender de novas classes globais. Dois ImageTexture .tres nativos contêm pixels RGBA8 dos atlas de salto e onda; SpriteFrames apontam para esses recursos. O Lua empacotar_atlas_tranca_lata.lua preserva os PNGs e torna a produção reproduzível pelo Aseprite. Não houve importação Godot, fabricação de cache ou alteração do validador de Main.

Snapshot completo e hashes: historico/runtime-r1/sha256.json. Entrada de revisão runtime-r1-input.txt SHA256 EDA8F76DD78F5DB1A32145D88B7388A5AC5CFB41ABDF6A620AD08895C37E0CBC. Apenas os payloads numéricos extensos foram omitidos da entrada textual; o schema, gerador, dimensões e hashes foram incluídos, com recursos completos preservados no snapshot.

Dimensões: salto384x64 RGBA8 =98304bytes de pixels, arquivo329166B; onda960x160 RGBA8 =614400bytes, arquivo1940442B. O custo em tamanho é aceito neste incremento para apenas dois recursos e evita depender de importação PNG pendente. Fontes Godot oficiais consultadas na spec.

Integridade estática confirmou Main, duas salas, fullscreen, visual de impacto25%, PNG/ASE originais e atlas atuais intactos em relação à base desta tarefa (historico/protected-integrity-r1.json). Não há validação de execução/gameplay: sem autorização para Godot/testes/import/parser/linter/QA conforme AGENTS. Nenhum commit/push/troca de branch.

Revisões finais em andamento; resultados serão registrados em pareceres/README.md. Catálogo/auth conferidos uma vez; Cursor Opus5.5High bloqueado por quota na tentativa real, sem parecer, saída original preservada. Não foi substituído.

## Correção R2 após revisão
Grok R1 identificou cobertura insuficiente do fallback e detour preso. Principal confirmou os dois casos, preservou R1 e delegou correção pontual ao mesmo Luna xhigh, somente training_target.gd. R2: fallback reutiliza aproximação segura com bounds/LOS/deadzone e detour desativado; rota falha limpa detour_active; standoff para subida é o mais próximo, com desempate pelo objetivo. Limites físicos, arte, recursos, dano, tempos e histerese aéreo permanecem R1. O replanejamento após pouso continua seguro; não se introduziu persistência adicional de sucessores neste incremento.

Snapshot R2 e diff em historico/runtime-r2; actor SHA256 34C0C967148DFB1C6297A590F3BD7D0CEF3A66A8FCF648B7EA9E4C717264EBB7. Entrada de revisão delta SHA256 D8E1AB5E01B14BB95CB7F249327D939CAB049731ED27BD99ED382B2B36BA56BA. Comparação de manifestos confirma que só o actor mudou entre R1/R2. Gemini/Grok/Muse receberam diff+actor completo, somente leitura, sem execução; Opus continua indisponível pela quota comprovada nesta tarefa, sem substituição ou aprovação inventada. Metadata dos atlas em historico/atlas-native-metadata.json.

## Guardas R3 após Gemini R2
O principal confirmou o bloqueio sem LOS dentro da distância de parada e aceitou a proteção local de origem obsoleta em detour. Luna mudou somente duas guardas do actor: stuck acompanha a intenção de aproximação após ausência de progresso, e rota cuja origem não corresponde ao apoio atual é limpa antes do cooldown. A lógica de ataque, movimentação física, recursos e helpers permanecem inalterados.

R3 integral em historico/runtime-r3; diff actor-r2-r3.diff e manifesto. Actor EBBDC2443C71DEB91100793D50FE5D37882A16068E91DC45A0EB68769BE1C6BE; entrada R3 D92395D907E55E96AED69E8C45D4B540A195CE947A0BC7D8255D4973EF869A76. Revisores receberam somente as guardas e funções completas pertinentes; demais contratos/arquivos são os já revisados em R1/R2. Nenhuma execução de motor ou testes.

## Estado final
R3 integrada. Gemini e Muse concluíram a revisão final das guardas sem bloqueios; observações defensivas avaliadas em pareceres/README.md. Grok R2 confirmou a correção; tentativa R3 terminou exit0 sem conteúdo útil e não conta como aprovação. Opus Cursor permaneceu bloqueado por quota (tentativa real exit1), sem substituição. Preflight único respeitado.

A implementação foi delegada ao GPT-6 Luna xhigh; o principal coordenou, examinou os deltas e achados, integrou as correções e conferiu hashes de estabilidade/preservação. Fast/priority não selecionável/confirmável pela interface. Runtime R3 e arquivos protegidos estão íntegros conforme manifestos finais. Branch corrigir-sprites-salas-plataformas mantida, sem commit/push. Nenhum Godot/teste/import/parser/linter/QA foi executado; funcionamento em gameplay ainda não foi confirmado.
