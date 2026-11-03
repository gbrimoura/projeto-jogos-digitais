# Integração e parâmetros

Estado aplicado, sem execução Godot/testes. Documentação de resultado não substitui revisão Opus pendente por quota.

## Cartas

Componentes `UpgradeOffer` (palco576×324, até3opções) e `UpgradeCard` (Button160×240), ícones128×80 doAseprite, estadosnormal/foco/pressionado, máscara de fontebitmap local. Todasinformaçõesnuméricasantes/depois são do catálogo. Novidade traz NOVO; evolução mostra NV.atual>seguinte. Há1escolha após cada sala da run, inclusivechefefinal, semmodalextra dechefe. Escolha/HP/build preservados em recuperação; duplicatas não concedem outra vez.

Seteupgrades: ImpactoReforçado(dano-base), MotorAcelerado(recargadash), CargaReativa(própria bola rebatida ganha bônus para um acerto), RicochetePressão(bônuspós-parede), MolaRetorno(maisricochetes/tempoativo), DínamoDefesa(reembolso de recarga restante por rebatida, uma vezpor golpe), ChassiReforçado(HPmáximo/atual no instante da aquisição).

Catálogo central: `scripts/progression/upgrade_catalog.gd`; parâmetros e caps em `resources/upgrades/*.tres`. Valoresprovisórios: Impacto+1porrank; Motor0.40/0.32/0.26s; Carga+2porrank; Pressãorank×min(paredes,3); Mola+1ricochete/+0.35s até3; Dínamo0.15s×rankaté3; Chassi+1HPmax/+1atual limitado100. Soma220 é teto técnico de aquisições para exportsatuais, NÃO define slots de equipamento/raridade/economia final. Impacto/Carga repetíveis mantêm oferta disponível ao esgotar caps dos outros.

Layouts de estudo em `assets/ui/upgrade_cards_v1/integration_geometry.json`/README descrevem arteAseprite. Cena runtime adapta campos para144px/24glyphs, sem alterar bitmapglobal: Titlex8y8h12; imagemx16y34w128h80; Summaryx8y118w144h24, com placaescura mascarando réguas para2linhas; tópicosx8y146/160/174w144h12, hyphenantesconteúdo; Badgex12y210w136h12 centralizado na faixa24px. Study não é screenshotGodot e pode terfrases distintasdaUIruntime, quevemdosdados. PNGs/frame/fontesoriginais preservados.

Atlasfont das cartas84×105 copia HUD72×105 e adiciona+'>' emcélulas5×11; glifosoriginais intactos. Espaços/acentos/fonte5×11advance6/lineheight12; metadataResourceLoaderJSON, atlasTexture2D. Delimitadores';'normalizadospara'/' naUI; builddebugusa'/'. FramesPNG sãoestadosvisuais; estilosButtonvazios. Fonte/card/imagefilterNEAREST e escala inteira; mínimo de composição576×324. HUDcompacta não cresceu; alvoagora prefixaNVantesnome quepodeencurtar.

## Níveis

Curva em `resources/progression/enemy_levels.tres`, tipo EnemyLevelConfigResource. Nívelordinal contínuo1+(andar-1)×(salascomuns+1)+(sala-1), configurado nos dois inimigosfora daárvoreantesdeready. HP=ceil(base×[1+0.12×(NV-1)]), bônusdano+1emNV11 e+2emNV21 emdiante, cadênciamult=max(0.65,1-0.015×[NV-1]). Não escalam movimento/jump/alcances/velocidaderebite/windup/ativo; Trancaescala recuperação e Cospeintervalodisparo. Idempotente porinstância, semcurar inimigo emcombate.

CenaRunRoot atual continua1andarcom3salascomuns+bossplaceholder, portantoNV1..4; defaults do script8andares nãoalterados. Nívelnão criaumcheferealnemfecha balanceamentofinal. ExemplomanualbaseHP3: NV1=3HP, NV2=4, NV3=4, NV4=5. Nenhumreplay/simulação executado.

## Fontes e limites

Modelo híbrido adaptado de novos poderes/níveis em Hades (https://www.supergiantgames.com/blog/hades-the-blood-price-update-patch-notes/) e arma jáobtida evoluída em VampireSurvivors (https://vampire.survivors.wiki/w/Weapons). Inferência de design própria, sem copiar regras finais/arte dos jogos. GDD 04-combate-e-builds histórico10/10 permanece preservado; este pedido novo define o recorte por sala, sem decidirslots/economia.

Lógica/UI e arte foram delegadas a gpt-6-luna xhigh, Fast/priority não confirmável; arte antecipada emworktreeisolada, integrada apósfreezeprincipal. Rootinspecionou PNGs fonte/estudo emview_image, leudiffs/fontmetadados e preservou hashes. Não rodou Godot, imports, testes, parser, linter, quality_audit, benchmarks ou simulações. Aseprite1.3.18.6 foi executadoprodutivamente paraarte, font epreview, não como teste. Opus5.5High exato viaCursor quota, semaprovação formal. Semcommit/push/trocadabranchprincipal.

Umapply_patch doagentegeroucópia fora do repositório. Versãocorreta está na pasta principal; tentativa deRemove-Item doarquivoavulso foi rejeitada pela revisãoautomática apenascomo blockedbypolicy, semmotivoespecífico. Nenhumcontorno/novatentativa deRoot, cópiapreservadaforadaarvoreGodot e registrada em pareceres/residual-preservado.json.
