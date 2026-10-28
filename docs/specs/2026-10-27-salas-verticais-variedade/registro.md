# Registro de implementação — 27/10/2026
## Planejamento e preflight
Tarefa complexa; diagnóstico/refinos read-only Luna6xhigh. PlanoR1 e spec preservados em historico; refinamentosR2/R3 na spec. Preflight único confirmou Cursorauth/modelosexatos4.6/Opus5.5, AGYGemini3.8High/Opus5.5High, OpenCodeGoMuse1.3. Primeiras chamadasAGYdeplano retornaramexit0semtexto porpermissaocommandautodenied; registradas comstderr, não aprovação. Retrymesmosmodelos comconteúdoinline eproibição explícitadeferramentas produziupareceres.
R1: Muse/Gemini/Opus apontaram lacunas/colisões. Rootreespecificouescadaprogressivaesp16/primeirosalto112/4ou5apoios/slot256/rollbackDOWN. R2Gemini/Muse permitiramcódigo; OpusdoisP1 (portainicialcoincidente/validargateaberto), resolvidosR3comconfirmaçãoOpus. GrokR1stdoutvazio; R2útil discordouenvelope assumindotakeoffdaborda260; rootrefutouequação e pediu reavaliaçãoR3. Originais semalteração. Modelos nãosubstituídos.
## Autorização de autoria
Plano liberaúnicoincrementointegrado45min. Luna6xhigh writerúnico; rootnãoaltera runtime nemdocs duranteautoria. Fast/priority não confirmável. Semtestes/Godot/parser/linter/QA/Git. Revisõesruntimequatro modelos ainda pendentes; planoOpusAGY nãosubstitui runtimeOpusCursor. Baseline24fontes e15protegidosadicionais preservados antesdeescrita.

## Freeze runtime R1 e revisão do principal — 28/10/2026
Dez scripts congelados, snapshotruntime-r1/SHA; pacote6624EED3F20182638A0E179A6BC0E808F77B2DBA70935656CA8E8281D581F31D,31/31protegidosidênticos. RevisoresR1leemsomentepacoteimutávelenquantoR2podesercorrigido, nuncalive. OpusCursorbloqueadoporquota, nãoaprovação; Geminiadapterstdinprimeiro--printparsing,depoisschemarequireeventerrou, arquivosoriginaisretidos; tentativa view_fileexplicitanãoshellparaevitarpermissãoauto-denied. Muse/Grokemandamento.

Achados concretos root autorizados para R2 antes da autoria:
- P1 Managedroof5: validador ainda fposmod(rect.position.x,8) exigebordas, width104centro8geraborda4; corrigeparaCENTRO8comoR3, larguras/alturas8. Váriasrunsfalhariam.
- P1 standaloneExitDoor: _line_point_in_room() passou a posiçãoDoor(1040,522), masgateem1120,496. Latchx1040ocorreforagate, aocenter1088nãohánovocross1040. Legado precisareferênciagate.global_position comtransformroom; managedDoorpositioncanônico/line32/604preservado.
- P1/P2validadordearcos: _managed_can_jump_between retornofalseprimeiroblockerabandonaTODAcandidatos e ignoraTARGETduranteascensão (aceitaunderside sólida), nãochecatetofechadoquando!top_open,nemboundsWorld. Rejeitarapenastrajetóriacandidatabloqueada, validarcorpo/arco contraapoiosincluindotargetexcetocontato válido na descida; limitarpontosdeorigem/destino e estruturas sólidas, gate aberto somente nas arestas de saída autorizadas. BFSpisoorigem/Signeddireção emfunçãodalaunchposition,nãoapenascentroFloorparaescolherlado. Nãoaprovartrajetoentrandonacolinabaixoplataformacomoela fosseone-way.
- P2variedade: generate_managed_layout retorna5geometriasfixas, RNGsó1espelho. Usuáriopediualgoritmomenosrepetitivo, planoexigevariaçãointerna. Introduzir parâmetrosseededlimitados dentrofamilias (larguras/vãos/alturas/posições),manterancoragensportal/spawn/roofsafe. Candidatoslimitados+fallbackcanônicorevalidado,sameseedmesmogeometry. Não sóadicionaroutrasseedsfixas nemmultiplicartemplatessemvariaçãogeométrica. Validaçãorotagerada/fallbackprecisareusaromesmocontrato,semerronaseedscomuns.
- P2 SolidPlatform.room_seed global atribuído emMainemboracontratoproíbaglobal; targetauthoredjárecebebindingdeterminístico e seedstaticsóusadonon-authored, nãoénecessárioparacaminhonovo. Removeratribuição/garantirpreservaçãovalorlegado,nãoeditarIA.
- Revercontratodescritor/idempotência/normalizaçãoe logsdeerroclaros, semampliarescopo, corrigeconcretosexaustivos.

RuntimeR2autoriatemjanela25min paraestas correções, mesmo Luna/escopo original, único escritor. PrincipalrevisaráR1somenteemcópiasenquantoautoriaR2. Rootnãoeditaarquivosduranteautoria. Nãoexecutar engine/testes/parser/linter/simulações/QA; sóinspeçãocódigo. PareceresR1posterioresserãoencaminhadossemduplicação. Ospacotes/snapshotsR1permanecemimutáveis.

## Runtime R2 congelado — 28/10/2026
Pacote R2 274076bytes SHA969A1023D8935746FC6F9EB14391C59CA38EE1453C76DC53C9C5894BDE78EB0B inclui delta+10scripts integrais+configs/cenasprotegidas. Snapshotruntime-r2 e31/31protegidosintactos. Gemini/Muse/GrokR2somenteinputimutável; OpusCursorquota eAGYsuplementoquota429, semnovatentativa/substituição. R1Gemini/Muse confirmaramroot, Groksemtexto; MuseP1de revisita refutado: sentidohorizontalúnico e nomáximo1verticalporcoluna, seu loopRIGHTDOWNLEFTUPnãoégerável.
R2fezvariaçõeslocaisseededlargura/vãos/alturas,12tentativasgeom+canônico físico,dropsamboslados/configatual/candidatos<=12,idemdescriptor,portastandalonegate/labels egeometriacontratoexplícito. RaizR2 removeseedstatic. Nãoengine/testes.

## Correção prospectiva runtime R3
MuseR2leupacote e identificouP1realemmanaged_room_topology.configure: renomeaçãopontualdevalidadores foi aplicadaao corpo configure e deixou ceiling_left_edge/ceiling_right_edge/right_widthindefinidos. Rootconfirmounafontecongelada. Apreloaddohelperpodeimpediraativação deMain,inclusiveoutrasorientações; corrigirdefinições/referênciasdentrofunção, semreplaceglobalnemmudarcontratosdimensionais.
MuseP2paridade real: larguras152/168/184/104meiaspartes4mod8 fazemcentrosderivados4mod8, geradorrejeitaeamplificafallback. Corrigir snap finalcentros ouconstruçãoparidade, preservarportalânotora e revalidargaps/bounds. Não relaxargrade nemclampqueignoregeometria.
Root+Luna read-onlyconfirmaramP2dois: force_canonicalbypassde_managed_entries_are_safe e pousograzing0.5aceitacentroaté13.5foradoplatform. Guardacanônicomesmocontratogeométrico, erropresciso. Pousoinset22restauradoparajump/dropcominterpolaçãoXnoinstantefootcross (sameparams integrador). Testemunhasanalíticasroot decores4/5fonte/candidatosmostramque22mantémrotascanônicas; nãoexecutadoteste. AcessibilidadeprovaumaROTAsegura,nãomodelaqualquerinput.
AutorizarLunaWRITE R3 restrito main.gd (doislandingchecks),room_layout_generator.gd(guardacanônica/snapcentros),managed_room_topology.gd(configurevars),até12min. Apósfreeze,delta+SHAe revisõesfocadas três disponíveis; Opusindisponívelregistrado. InputsR1/R2sempreimutáveis, revisoresR2NÃOleemruntime live. Seoutrosachadosreaischegaremagruparporcoordenação. Sem engine/testes/parser/linter/QA/commit/push/branch.

## R3 congelado e revisão — 28/10/2026
Snapshotruntime-r3 SHApor10arquivos; deltaR2→R3restrito3scripts,4correções. InputF3C532B851FC38212284151D9AE67CE71CC301FBA87883238C768F05DFC0F384,28091chars, enviadoinline aos3disponíveis. Gemini confirmaas4correções. Museconcordacomimplementação mas aponta faltadecontexto nas testemunhas: confundiu intervaloJÁINSETADOdest[874,934] comrecte aplicou22duasvezes; orectcanônicorealroof5é[852,956],centro904largura104, safeinterval874..934. NãoéfalhafísicaR3, fornecercontextoR4. MuseP1propagaçãovalidforceforaentrada: Mainjátestafallback.validantesaplicaçãoerepetephysicalvalidate; faltouessemétodonopacotefocado, nãoébugnovo. P2denominadorzeroimpossívelsobvy>0dt>0+descida; nãoreabrirparaatividadehipotética. Snappodealterargap4/8pxmas_managed_entries_safe rejeitaqualquerfora40..80, corretoparasegurança;variarcontinuapossível.

## Achado adicional do principal R4 — redeclaração de local em bloco filho
Leitura estática levantousombra deidentificadores locais; confere-se a regra na fonteprimáriaGodot, semexecutarparser:
https://raw.githubusercontent.com/godotengine/godot/master/modules/gdscript/gdscript_parser.cpp
parse_suite consultacurrent_suite->get_local e push_errorquandojáexiste; SuiteNode::get_local consultarecursivamenteparent_block (trechos1850..1854e4082..4089). Logo nãoéapenaswarningdeclassmember: duasdeclaraçõesmain atuais sãoerrodeescopo.
1. prepare_authored_layout: fallback_index jádeclarado no blocofunc antes, redeclarado dentroifcandidatefallback. Renomear segundo para canonical_fallback_index eapenasosusosnessebloco (guarda/NodePath).
2. _validate_authored_target: player_body jádeclarado nofunc evalidado antes; blocoif_run_controller_managed redeclaraplayer_body. Removera declaraçãoinner e reutilizarouter válido, ou renomearinner sepreciso, semalterarcomportamento.
Autorização prospectiva R4: LunaWRITE único até8min,SOMENTE main.gd nesses2locais,nenhumoutroajuste/engine/parser/testes/lint/QA. SnapshotR3+inputsimutáveisusadosrevisores. Depoisfreeze,deltaR4+contextofallback ecanônicoscorrigeambiguidadeMuse,3reviewsread-onlydisponíveis. Nãoatribuiraprovaçõesinexistentes; Opuscontinuaindisponível.

## R4 congelado
Snapshot runtime-r4 contém os10scripts, apenasMaindifereR3 comdoisajustesdelocais. Pacote finalR4 SHA5D5EDF5A186C4A7E24A7169862FF31B4E5456B77AFD6B12C6A104BF8E4A7C9CC (28931caracteres), deltaexato+Mainprepare/target+canônicos+físicadepouso+launch/config. R4tambémfornececontextofaltanteMuseR3 eexplicaintervalosjácominset. EnviadoinlineGemini/Grok/Muse,read-only10min; Opuscomprovadamenteindisponível,semrepetirpreflight/semnova tentativa/substituição. Nenhumaalteração posterior de runtime autorizada nesta anotação.

## Pareceres finais R4 recebidos
Gemini e Muse retornaram done/exit0, semP1/P2. Ambos confirmaram as duas correções de locais e o fechamento das pendências de contexto MuseR3. O principal aceita esse fechamento: as funções canônicas retornam bounds852..956/safe874..934 para roof5 e bounds824..984/safe846..962 para roof4, o fallback.valid é conferido antes de aplicar geometrias e a rota é revalidada. Não se afirma teste real de cinemática ou compilação. GrokR4 ainda em andamento nesta anotação. Nenhuma nova alteração de código necessária pelos pareceres recebidos.

## Resultado final — R4 integrado

Gemini, Muse e Grok encerraram a revisão final com `STATUS: done`, exit0 e sem P1/P2 remanescentes no delta/contexto fornecido. Grok R4 entregou parecer útil: as três rodadas anteriores de runtime não haviam produzido texto. O principal aceita o fechamento dos conflitos de locais e das duas pendências de contexto do Muse R3. Não há código alterado depois dessas revisões.

Integridade final: 10/10 scripts idênticos ao snapshot revisado e 31/31 arquivos protegidos idênticos à base local. Manifestos `historico/stable-final.json` e `historico/protected-final.json`. Entrada R4 permanece com SHA2565D5EDF5A186C4A7E24A7169862FF31B4E5456B77AFD6B12C6A104BF8E4A7C9CC. Estado de Git preservado em `historico/git-status-final.txt`.

Entrega: cinco famílias com variação geométrica local por seed; sequência linear com passagens laterais/UP/DOWN; descritores pareados, spawns e recortes; gate condicionado a combate/recompensa/guard; busca limitada de rotas e fallback canônico que passa pelos mesmos validadores. Caminho standalone legado preservado. Os parâmetros são do protótipo, não regras finais do GDD.

Luna6xhigh foi o único escritor de runtime; principal coordenou, leu fontes/diffs, confirmou a regra de escopo em fonte oficial e integrou os pareceres. Fast/priority não confirmável pela interface. As dez fontes mudadas foram explicitamente autorizadas; jogador, IA, cenas, arte, build, recompensas e configurações ficaram preservados.

Opus Cursor continua sem parecer de implementação por quota; tentativa complementar AGY também sem parecer por quota429. Não houve substituição ou aprovação fictícia. Os pareceres de plano não substituem a exigência via Cursor. As revisões estáticas disponíveis foram concluídas e suas saídas fiéis estão preservadas.

Não foram executados Godot, importação, parser, linter, testes, QA, simulações externas ou benchmarks. Não há confirmação de compilação, sensação de movimento ou performance no motor. Não houve stage/commit/push/troca de branch. Nenhuma permissão, lock ou configuração de autenticação foi alterada.

Branch mantida: corrigir-sprites-salas-plataformas.
