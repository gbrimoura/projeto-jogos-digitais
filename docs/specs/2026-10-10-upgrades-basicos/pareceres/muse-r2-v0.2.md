# Parecer dirigido — opencode-go/muse-spark-1.3-contributor

- Data: 10/10/2026
- Rodada: v0.2
- Ferramenta: OpenCode; xhigh; plan
- Estado: concluído; interpretação dos achados em `consolidado.md`
- Entrada: AGENTS.md, plano.md e spec.md integrais inline; sem execução/inspeção de código nesta rodada
- Plano SHA-256: `88DD4D0255164659530F37E0043D8BF6CE69A52793151E4F56E5A39A699896EF`
- Spec SHA-256: `6F7574262363CB7F680C1CC229FEABD9F4515ACC0514B578BE45AB95F50A55C9`
- Saída original: [muse-r2.stdout.json](muse-r2.stdout.json)

## Saída do revisor


> plan · muse-spark-1.3-contributor

STATUS: done
SUMMARY: v0.2 corrige as 6 ambiguidades apontadas e está coerente com AGENTS.md, dados estáveis e2855c2 e escolhas do usuário. Timer extra negado, lifetime 2.2s preservado sem restart; duplicate(true) + derivação idempotente da base; take_damage bool + defeated única + consumo só em RicochetBall ramo próprio; pausa com dono + guarda 0.25s observável; snapshot one-shot copiar-e-limpar-uma-vez com replace e ordem pós-_ready; R/F6/queda y=760 e 5HP/build vazia consistentes. Pasta docs/specs/2026-10-10-upgrades-basicos/plano.md+spec.md e modelos/instruções conferem. Nenhum blocker documental impeditivo; há 4 polimentos e 2 riscos de execução futura.
CHANGED_FILES: none
TESTS: apenas análise documental inline, sem Godot/execução. Conferido: plano §Contrato/§Snapshot/§Vitória/§Dano/§Reinício x spec §§1-8 x AGENTS.md §§Leitura/Escopo/Revisões. Aceites observáveis: oferta única, seleção-antes-efeito, E consumido, duplo-clique/tecla segurada/guard-reset, morte>vitória, pending inválido/mismatch→fixture segura, carga 1/vida sem stack/rearme, bases intactas.
RISKS:
1. [Baixa-doc] spec §2 guarda 0.25s “configurável/observável” sem dono explícito — fix documental: nomear export em Main/UI antes de implementar, não blocker.
2. [Baixa-doc] snapshot `version/canonical_destination` sem valor/formato — fix documental: fixar ex. `version=1` e path canônico string, regra de incompatibilidade.
3. [Baixa-doc] plano §Roteiro vs §Aceite: “terminal Sala02” vs `reward_enabled=false` em Main — uniformizar termo, não blocker.
4. [Baixa-doc] link GDD `../../../../GDD...` escapa repo — confirmar localização/índice, não blocker.
5. [Média-execução futura, não bug atual] Cronograma 11-13/10 com 3 revisões/incremento A/B/C + Opus Cursor + 13-18h sem filas/edição: risco de fila estourar 14/10. Mitigação já prevista: não concentrar véspera, ajustar escopo. Não inventar code-freeze.
6. [Média-execução futura] Lista “arquivos candidatos” ampla; plano já diz que não é autorização e congela após inspeção — exigir freeze de escopo em A antes de B/C.
NEXT_STEP: Manter v0.2 congelada, aplicar 4 polimentos doc em v0.3 sem mudar contratos, depois seguir cronograma A→B→C com revisões por incremento e validação Godot só em frente autorizada.

