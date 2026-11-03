# Registro da implementação — lobby e elevador

Data: 02/11/2026. O usuário autorizou a implementação após a fase de plano/spec; o principal concedeu GO e manteve um único escritor. Os arquivos de produto R2 estão congelados para revisão estática do principal.

## Resultado

- `project.godot` inicia em `res://scenes/lobby.tscn`; a comparação com a cópia baseline mostra somente a alteração de `run/main_scene`.
- O lobby reaproveita o Player, fonte bitmap e atlas de fábrica existentes. Inclui pátio contínuo com colisões, torre ao fundo, bancada apenas visual e cabine focal. Não foi criado PNG ou conteúdo de economia.
- A entrada exige a AABB da cápsula física inteira do Player, vivo e no chão. O latch e os modos de processamento são guardados antes da sequência; Player/BallContainer são bloqueados, bola ativa limpa, portas/luzes/vibração/fade executados sem pausar globalmente a árvore.
- Erro ao abrir a run restaura os modos e a porta, mostra mensagem e exige sair completamente da área interna antes de uma nova tentativa.
- A run mantém a configuração existente do RunRoot: um andar, dez salas comuns e o chefe. A nova instância do Controller inicia build/HP/multiplicadores/seed pelo fluxo atual. Nenhuma cena ou regra interandar foi adicionada.
- Vitória e morte reais mostram resumo pixelado com posição alcançada, HP/build atuais e botão `VOLTAR AO LOBBY`; `R` faz a mesma ação. O retorno limpa o snapshot, desativa a sala, faz fade e libera somente a pausa da própria tela de resultado. A falha síncrona restaura o estado anterior e mantém o mesmo resumo. Lobby não despausa uma pausa global arbitrária.
- O overlay do resumo está na camada 90, acima do HUD e abaixo do fade de transição na camada 100. A fonte bitmap do resumo usa escala inteira 2× e centralização vertical; texto do botão também usa a fonte existente.
- `_restart_run` e `fail_managed_room_transition` foram comparados linha a linha à cópia baseline e permanecem idênticos. O caminho técnico continua separado do fim legítimo de run.

## Arquivos de produto

| Arquivo | Alteração |
|---|---|
| `project.godot` | Somente `run/main_scene`. |
| `scenes/lobby.tscn` | Nova cena do lobby e colisões. |
| `scripts/world/lobby.gd` | Entrada física e sequência recuperável do elevador. |
| `scripts/world/lobby_visual.gd` | Desenho nativo pixelado com recursos existentes. |
| `scripts/world/run_controller.gd` | Resumo e retorno apenas no fim legítimo; retry técnico preservado. |

Outros arquivos de produto não foram alterados.

## Baseline e hashes SHA-256

As cópias binárias originais de `project.godot` e `scripts/world/run_controller.gd` ficam em `historico/baseline-produto/`; os hashes originais também estão em `historico/baseline-produto/sha256.json`.

| Arquivo | Baseline | Final R2 |
|---|---|---|
| `project.godot` | `42a90285feacc10034cbd02d270b66a48a88e33ac33f570a6cfb67329d9c5ff1` | `1b53f6877f8bb1653875ca7601ed364c8f40f491e34816eb06c614d4f09b3237` |
| `scripts/world/run_controller.gd` | `1fc1e81ff31ec8ebdfb928f5d41a2d7544c58b6721db0c1ac10c7fcf82a757f6` | `71e58b3cc43df01f0254d6819635970e137aa4c0e93d8380ae6380af5e478c65` |
| `scenes/lobby.tscn` | novo | `fc4e064d66a9702ef07556fe2008d20044708dd5e2cd0ee605691283b820cb10` |
| `scripts/world/lobby.gd` | novo | `3d9ead6b7b6ee553efe4c83d012c279b68fc962e2cacb8784deffec9de0d158e` |
| `scripts/world/lobby_visual.gd` | novo | `0186597d89c7a6421f6b9b925c948a438417abcb9593830940656467d28bc542` |

Diff estático versus baseline: `project.godot` tem uma linha alterada. O diff de `run_controller.gd` é limitado ao resultado legítimo/retorno e à apresentação bitmap; as rotinas técnicas citadas acima são idênticas à baseline.

## Validação e revisão

- Verificações estáticas de leitura, hash e diff foram feitas; não foram executados Godot, import, parser, lint, testes, auditoria ou simulação, conforme escopo autorizado.
- A revisão final de implementação por Cursor Agent com `claude-opus-5-5-high` permanece pendente: o preflight da tarefa indicou quota indisponível. Não foi usado substituto. O principal fará a consolidação da revisão do pacote congelado.
- Validação visual/runtime ainda não foi executada.

## Próximo passo

Revisar os cinco arquivos de produto congelados; depois da revisão requerida, corrigir apenas achados aceitos e atualizar este registro e os hashes.
## Consolidação do principal
Luna implementou os5produtos autorizados e preservou snapshots das correções; principal conferiu fontes/diff, ordem de desenho, referências e hashes. Foram mantidos os20arquivos críticos anteriores conforme pareceres/preservation-20.json. Gemini e Muse concluíram revisões estáticas favoráveis, com notas avaliadas em pareceres/README.md; Grok expirou sem parecer, Opus obrigatório continua pendente por cota. Falha de leitura de pacote Muse foi resolvida por conteúdo inline, sem alterar permissões. Não há teste ou execução do Godot nesta tarefa.

Entrada padrão: scenes/lobby.tscn em project.godot. Executar o projeto abre o pátio; executar uma cena isolada mantém o comportamento da cena escolhida. O ciclo configurado é lobby → cabine automática → RunRoot10salas comuns+chefe → resumo → lobby. Oficina funcional/economia/save/eventos não foram implementados.
