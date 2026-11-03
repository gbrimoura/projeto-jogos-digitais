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