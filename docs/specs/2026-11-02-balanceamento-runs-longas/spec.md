# Especificação candidata — perfil inicial

## Valores derivados
| Sistema | Base / progressão proposta | Limite |
|---|---|---|
| Vida jogador | 5 base, Chassi+1/rank e cura1 na escolha | Chassi3 -> 8 |
| Dano bola | 1 base, Impacto+1/rank | Impacto3 -> 4 |
| Carga | +2extra/rank, próximo acerto após rebater própria bola | 3 -> até6extra |
| Pressão | +1/rank por parede contada | rank3,2paredes -> +6 |
| Dash | base0.55, Motor0.48/0.42/0.36s | 3 |
| Dínamo | restitui0.05s/rank de recarga restante | 3 ->0.15s |
| Mola | +1rebote/+0.20s porrank | 3 ->6rebotes/2.80s |
| HP Tranca / Cospe | 6 / 4 base | 4x a base pelo perfil |
| HP por nível n | ceil(base*min(1+0.06*(n-1),4)) | máximo4x |
| Dano inimigo | 1 até16,2 a partir17 | bônus1 |
| Cadência | 1-0.01*(n-1) | piso0.75 |

Exemplos aritméticos manuais do perfil: níveis1/4/16/32/64 -> Tranca6/8/12/18/24 e Cospe4/5/8/12/16. Não são resultados de combate/simulação. Manter tempo de aviso/alcance/velocidade/movimento/IA existentes. Aumentar faixa exportada de damage_increase_every_levels (atualmáximo10) para comportar16 e manter defaults/recurso coerentes.

## Recursos e contrato pós-build
Dado do Resource separa upgrade principal, ajuste e recuperação; usar IDs novos conhecidos pelo catálogo/RunBuild para aproveitar snapshot v1 sem novos campos obrigatórios. Novos IDs sugeridos ajuste_velocidade_bola, ajuste_recarga_dash, reparo_campo. Ícones atuais de Carga/Motor/Chassi, respectivamente. Os7IDs existentes mantêm identidade.

Atributos só entram quando todos os principais estiverem no máximo efetivo. Velocidade da bola derivada base*(1+0.02*rank), cap10; redução da recarga base/Motor -0.01*rank cap5, mantendo menor valor0.31 no perfilpadrão. Reparo conta escolha repetível em ranks internos para idempotência/limite técnico mas não exibe esse contador como upgrade. Cura somente se PlayerHealth vivo e acquired_upgrade_id for o serviço, até1HPmáximoatual; reapply/restore sem acquired_id não cura. Serviço sempre disponível até orçamento de salas suportado, mesmo cheia a vida (benefício0 permitido e texto 'até1' honesto). Não revive nem aumenta vida máxima.

Status/cartas pixeladas: atributos mostram AJUSTE/AJUSTAR + contador atual>próximo/max10ou5; reparo mostra MANUTENÇÃO e CURA ATÉ 1 VIDA. Até3opções, todasIDs distintas; ao capar atributos oferecer serviço único. Mantêm-se seleção única, pausa/inputguard/deathwins, cleanupflush, recovery de sala concluída sem reapresentar oferta ou reaplicar cura. Main e RoomTransition devem permanecer iguais se fluxo existente bastar.

## Implementação orientada a risco
Luna escritor único depois da revisão de plano. Snapshot dos arquivos antes de editar. Campo recovery pode reutilizar health_recovered_per_rank, ajustando acquisition_heal para não depender de maximum_health_per_rank>0. Não criar números fixos duplicados em helpers/UI quando campoResource existir. Ajustes de configs sempre partem de cópiasbase; MovementController.update_config_preserving_state continua obrigatório, sem reconfigurar/refill. Não aplicar bônus duas vezes por multiplicadores antigos da run. Recursosprecarregados não mutados. Legacy snapshots binários com campos novos ausentes=0 continuam; fora dos novos caps rejeita atomicamente, sem clamping parcial. Novo perfil exige nova run se a antiga tiver ranks fora dos novos limites.

## Apresentação e documentação
Atualizar fallback effect_topics nos7resources e prévia de3cartas para Carga0>1/3, Mola1>2/3(2.4>2.6s), Dínamo2>3/3(0.1>0.15s). Pode adicionar estudo pós-build com2atributos/reparo usando mesmo gerador/assets sem regenerarfont/molduras/ícones. No texto de tela não incluir a palavra provisório; registrar status de hipótese nos documentos. Caps de gameplay3/10/5 não equivalem a slots. Preservar GDD externo sem edição; documento local aponta lacunas finais.

## RL
Documento local agente-avaliacao.md registra pesquisa, interface observações/ações/reset, métricas e proposta de cenários/seeds/episódios. Não é agente executável, não é treinamento pronto. Integração real do agente demanda fase própria com execução/testes explicitamente autorizados pelo usuário e dependências/compatibilidade avaliadas. Não há desempenho/taxa de vitória inventados nem promessa de finalbalance. Fontes: https://github.com/edbeeching/godot_rl_agents e https://stable-baselines3.readthedocs.io/en/master/guide/rl_tips.html e https://deepmind.google/blog/specification-gaming-the-flip-side-of-ai-ingenuity/ .
## Contrato congelado de implementação
IDs exatos: ajuste_velocidade_bola, ajuste_recarga_dash, reparo_campo. UpgradeDefinitionResource: reward_kind:StringName com default &core e valores &attribute/&recovery; projectile_speed_multiplier_per_rank:float default0; dash_cooldown_reduction_per_rank:float default0; reutilizar health_recovered_per_rank:int default0. Novosresources respectivamente kindattribute cap10 valor.02; kindattribute cap5 valor.01; kindrecovery cap220 heal1. 7resourcescore usamdefaultcore e cap3.

Catalog helpers sugeridos congelados: projectile_speed_multiplier_for_rank(rank:int)->float =1+clamp(rank,0,10)*campo.02; dash_cooldown_with_adjustment(motor_rank:int,adjustment_rank:int)->float = max(cooldownMotor-clamp(rank,0,5)*campo.01, min(cooldownMotor,0.31)), para não aumentar cooldown de base custom menor. CamposRESOURCE como fonte de números, não duplicar mágicos nos consumers. recovery mantém acquisition_heal(id,previous_rank,next_rank)->int já existente, permite per_rankheal>0 sem exigir maximum_health_per_rank>0. Contrato de única aquisição garante next=previous+1; PlayerHealth calcula cura só quando acquired_id explícito e current_health>0. Restore não passa acquired_id.

EnemyLevelConfigResource.maximum_health_multiplier:float=4.0 e resourcehomônimo; healthrate.06, damageevery16 com export_range(0,64,1), damagebonus1, cdreduction.01,minmult.75. HPbase6/4 nos2defaults/scripts (_base_max_health também) e scenes/training_target.tscn/scenes/rivet_worker.tscn. Não tocar windup/active/IA. FonteMola recursos/projectile_config.tres lifetime2.2/maxbounces3 e baseadaMotor resources/player_movement_config.tres .55, intactos.

Pool: candidatoscore são somente definitions.kindcore quecan_acquire; exaustão = nenhum dos7IDs core podeadquirir (não um erro/transienteUI). Se1ou2coreelegíveis, oferecer1ou2 sem duplicar ou anteciparpósbuild. No pósbuild, todos osattributeelegíveis e recoveryelegível sãoasopções:3inicial,2seumatributocapado,1seamboscapados. SemprehealmesmofullHP, não filtrar porhealth. Orçamento técnico220existente permanece1aquisição/roomaté220comumkit; parâmetrosdorun nãoeditados. Snapshotv1 validadoatomicamenteemRunBuild.replace_state, consumidoone-shotporRoomTransition; novoIDausentenormaliza0 via knownidsarray. Não adicionar versão/campos extras semnecessidade.

Metadados Catalog.card_preview incluem reward_kind; cardconfigure recovery usafooterstatusMANUTENÇÃO(10glifos) e textoCURA ATÉ 1 VIDA(14), semcounter; atributosAJUSTE(6)/AJUSTAR(7) +countermax10ou5,cabe22 mesmo withMÁXIMO. Tópicos24colunas com'- ' reservado2 (conteúdo22),até3linhas; descrição24×2. Serviço descrição 'Faça um reparo no robô.' e tópicos 'Cura: até 1 de vida'/'Aplicada nesta escolha', fonteexistentetodosglyphs. ConsumerOffer chamaCatalogpara10IDsconhecidos, nãoinjetaridfakeforaenum; mesmaMain_on_upgrade_selected/SELECTED/add/apply/close/release; preferirMainintocado.
