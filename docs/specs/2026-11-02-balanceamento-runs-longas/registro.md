# Registro — primeira curva candidata e recompensas de runs longas

## Resultado aplicado
Os sete upgrades principais têm3níveis. O crescimento ilimitado de Impacto/Carga e Chassi foi substituído pelos tetos curtos; o orçamento220permanece interno como proteção para o intervalo de configuração20andares*(10salascomuns+boss), sem definir duração final. Após todos os principais estarem completos, novas escolhas entre velocidade da bola(+2%base porrank,cap10), ajuste de recarga(-.01s/rank,cap5) e reparo(até1HP atual). As opções diminuem3->2->1sem esgotar serviço, inclusive emHPcheio; escolha/pausa/guardas/recovery originais preservados.

Atributos derivam de bases duplicadas, sem se reaplicar cumulativamente em restauração. Cura depende de acquired_id e jogador vivo; snapshots/restore não curam. Os3novosIDs usam schema counts_by_id/upgrade_ids já existente e validação atômica. Legacy binário com IDs novos ausentes normaliza0; ranks legados acima dos novos caps são inválidos, então usar nova run para aplicar o perfil.

## Parâmetros do candidato
Core: Impacto+1dano/rank; Carga+2no primeiroacerto apósrebaterprópriabola,cap6; Pressão+1/rank por parede,cap2paredes; Motor.48/.42/.36s; Mola+1rebote/+.20s; Dínamo.05s/rank; Chassi+1vidamax e cura1,3níveis. Basejogador5, máximoChassi8. Fonte exata nosresources, sem nova economia/slots.

Inimigos: Tranca6HP, Cospe4HP. HPceil(base*min(1+.06*(n-1),4)); dano1até16/2a partir17; cadência-.01/nível atépiso.75. Avisos/active/IA/locomoção/projéteis/geração/run_root intactos. Valores são hipótese para primeira avaliação, não resultado medido ou garantia de desafio final; boss e variedade finais ainda não fazem parte deste recorte.

## Artefatos visuais
Pares coerentes de estudo em576×324 e1728×972: upgrade-cards-study(core) epost-build-study(atributos/reparo). Gerados comAseprite preview_only, semregenerar7ícones/fontes/molduras. RootviuPNG. Metadados sincronizados comgerador noR2; logs preservados empareceres/production-r3-*. O usuário ainda avaliará a aparência e a experiência.

## RL e limites de validação
agente-avaliacao.md é proposta de contrato/pesquisa para um agente externo que joga, não um modelo treinado ou um adapter já executável. Documenta observações/ações/reset, métricas, prevenção de reward-farming, seeds de avaliação separadas e comparação humana. GodotRLAgents+SB3 é tecnologia candidata, compatibilidade exata/dependências/orçamento ainda precisam de fase própria. NenhumRL foi instalado, executado ou treinado; não háwinrates ou medidasTTK. GDDexterno foi consultado e preservado.

## Revisões e estado final
Auditoria inicialLunareadonly, plano complexo comGemini/Muse/Grok e tentativaOpusAGYquota; implementaçãoLunaxhigh e revisõesGemini/Muse sembloqueios, deltaMusefavorável, Grokfinalsemstdout, OpusCursorquota. Detalhes/saídas fiéis empareceres/README.md. SemGodot/imports/testes/parser/linter/auditoria/simulação/commit/push/troca debranch. Números precisam de avaliação real autorizada antes de declarar balanceamento validado.
## Especialidades por gatilho — 17/11/2026

Ajuste provisório para distinguir o papel dos upgrades nas cartas de sala e nos itens de loja. Não altera economia, raridades, limites/ranks, quantidade de recompensas nem progressão de salas. Valores e efeitos continuam candidatos a balanceamento.

- **Impacto Reforçado:** mantém +1 dano por rank. Cada bola recebe o bônus apenas no primeiro dano aceito antes do primeiro ricochete ambiental; dano rejeitado não consome o bônus. O estado reinicia no lançamento. Depois da parede, o bônus não volta: Ricochete de Pressão fica como especialidade de bank-shot, com o valor por rank e teto de paredes já existentes.
- **Motor Acelerado:** mantém a recarga por rank já configurada (0,48 s / 0,42 s / 0,36 s). Cada rank concede +5% de velocidade ao tiro cujo lançamento aceito ocorre enquanto o jogador está em dash, até +15% no rank 3. A checagem da prévia é somente leitura.
- **Punho de Guarda:** mantém +8° de arco por nível. Cada aparada bem-sucedida acelera a bola do jogador em +5% por nível, acumulando por tiro até +25%; o estado reinicia a cada lançamento. Projéteis hostis não usam essa aceleração. O bônus multiplica o ganho separado da Turbina Centrífuga.
- **Rolamento Livre:** mantém +25% de velocidade de retorno por nível (máximo atual +50%). Um retorno concluído marca +1 dano para o próximo lançamento aceito. O bit fica no `RunBuild`, atravessa a transição de sala no snapshot v2 e não se perde quando a mesma run reaplica o build. `clear()` limpa o estado; snapshots v1 continuam válidos e assumem o bit falso. O lançamento consome o bônus somente após `launch()`; a prévia e o cálculo da origem não o consomem. O snapshot v2 exige booleano e rejeita estado verdadeiro sem nível de Rolamento Livre.
- **Demais cartas e itens:** descrições e tópicos agora explicitam os gatilhos existentes e as sinergias pertinentes, inclusive coleta da Bolsa, aparada aérea da Mola/Bobina, cura após combate, bloqueio do Aegis e a interação com Fusível de Emergência. Seus efeitos, ranks e limites permanecem iguais.

Não foram executados Godot, importação, testes ou formatadores, conforme pedido.

## Revisão do incremento de identidade — 17/11/2026
Muse Spark 1.3 Contributor / OpenCode plan recebeu quatro snapshots estáveis contra os baselines desta tarefa. R1/R2 apontaram itens P3 e uma perda P2 do bônus do Rolamento ao cruzar sala; esses efeitos/cópias foram corrigidos e reavaliados. R3 apontou P3; a conversão bool em main.gd foi considerada não acionável porque consume_pending_snapshot valida o snapshot antes do retorno. R4, SHA-256 do diff 00271F5E260E8816B56DD1EA6FBCC5EAE99D28D57C8393C5AD01D79BDA65CDDD, sem achados P1/P2/P3. Saídas fiéis, diffs, metadados e preflight: pareceres/upgrades-unicos-2026-11-17.

Gemini 4 Hydrogen High e Gemini 3.8 Flash High estão pendentes porque o isolamento do AGY não pôde ser comprovado; nenhum diff foi enviado. Grok 4.7 XHigh Fast e Claude Opus 5.5 High via Cursor estão pendentes porque agent --list-models exigiu autenticação. O OpenCode confirmou o modelo pelo stderr, mas a variante efetiva/modelUsage não ficou visível. Não declarar aprovação externa completa. Sem testes, importação ou Godot.