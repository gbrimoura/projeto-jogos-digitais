# Tranca-Lata — salto entre plataformas e impacto maior

23/10/2026. Estado atual: implementado R2; Gemini/Muse semP1/P2, Grok timeout e Opus indisponível porquota. SemGodot/testes. Proposta original preservada em historico/plano-r1/.

Pedido: ampliar o sprite de impacto existente (esclarecido pelo usuário) e permitir saltos entre plataformas com sprite novo. Preservar todas as alterações locais, incluindo fullscreen. Esta extensão substitui somente a restrição antiga de patrulhar uma plataforma; contratos de combate permanecem.

1. Ler GDD04, contratos de plataforma e alvo, preservar baseline em historico/base/. GPT-6 Luna xhigh é escritor de implementação; Fast/priority não confirmável.
2. Revisar a proposta abaixo em somente leitura. Principal consolida achados antes de liberar escrita runtime.
3. Referência ImageGen já gerada e inspecionada: seis poses, cabeça/tubo/proporções coerentes. Reproduzir em Aseprite sobre a fonte atual, atlas de salto separado, sem alterar os15quadros anteriores. Aprovar contact visual antes de ligar ao runtime.
4. Integrar locomoção e ampliação visual delimitadas; revisar estado final estável por Gemini/Grok/Muse/CursorOpus. Sem Godot/import/testes/QA/gdlint/quality_audit, conforme AGENTS. Produção/exportação Aseprite autorizada.

Allowlist futura: scripts/world/training_target.gd; scripts/enemy/containment_attack_visual.gd; novo helper de salto scripts/enemy/tranca_lata_jump.gd se necessário; scenes/training_target.tscn somente configuração; resources/enemy/training_target_sprite_frames.tres; assets/enemy/training_target/jump/**; ../GDD_Dieselpunk_Noir/pitch-assets/tranca-lata-salto-v1/**; esta pasta docs. Main, gerador, cenas das salas, Player, Worker, projéteis, portas, fullscreen, assets e source antigos, imports/UIDs existentes e Git protegidos. docs/README.md e pareceres sob coordenação do principal.

A primeira frente Luna de documentação foi interrompida ao limite de planejamento de10min, após entregar proposta pelo stdout e snapshots/hashes; sem mudança runtime. Principal consolidou essa proposta nesta revisão. Não houve substituição de modelo. Próxima frente do mesmo Luna terá escopo de produção de arte e depois runtime, etapas dependentes.
## Estado R4: aprovado pelo principal para implementação delimitada. Arte inspecionada; integrar segundo spec consolidada R4, depois revisão final sobre código estável. Histórico R1 preservado. Precisões aceitas/rejeitadas e saídas originais em pareceres/. Sem Godot/testes.