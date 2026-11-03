# Plano prospectivo — HUD no Aseprite, 31/10/2026

## Objetivo e escopo

Produzir o primeiro kit de elementos reais e editáveis no Aseprite, a partir do Painel de Caldeira revisão04 aprovado. O usuário também pediu pesquisa de distribuição de HUDs de jogos famosos. A pesquisa visual do principal está em referencias.md; as imagens estrangeiras são referências de composição, nunca texturas do kit.

Saída: componentes PNG transparentes e fontes .aseprite em camadas, Lua reprodutível, atlas/manifesto com regiões e pivôs/margens, fonte bitmap própria e composição de estudo editável com overlay e contexto. Somente NOVOS arquivos em assets/ui/hud_caldeira_v1/**. Principal escreve documentação em docs/specs/2026-10-31-hud-aseprite/** e índice docs/README.md. Não alterar scripts de gameplay/HUD Godot, cenas, recursos existentes, configurações, atores, sprites anteriores, project.godot, addons, imports/UIDs ou Git. Preservar correção de transições e demais arquivos locais sem commit.

## Método e coordenação

Aplicar skills Aseprite e pixel-art: referência ImageGen04 existente → reprodução nativa na grade por Lua executado no Aseprite real → exportar componentes e composições, inspecionar visualmente os arquivos. Não gerar nova referência ImageGen nem importar a prancha como asset de produção. A execução produtiva de Aseprite foi solicitada pelo usuário. Não executar Godot, testes, parser, linter, scripts de audit/QA, benchmarks ou simulações; instrução do usuário em AGENTS prevalece sobre rotinas de auditoria de skills. Não afirmar que o kit passou em auditoria automatizada ou integração.

Implementador único GPT-6 Luna xhigh, timeout30min. Interface não confirma Fast/priority. Pode ler arquivos de referência existentes e skills, escrever SOMENTE o novo diretório do kit. Root não escreve enquanto Luna é escritor. Revisores são read-only sobre pacotes congelados, não executam comandos/arte nem alteram arquivos. Timeout de plano/revisão10min, produção30min. Handoff stdout STATUS/SUMMARY/CHANGED_FILES/TESTS/RISKS/NEXT_STEP.

Preflight feito uma vez nesta tarefa e salvo em pareceres/preflight-*. Cursor autenticado e IDs exatos Claude claude-opus-5-5-high e Grok cursor-grok-4.6-xhigh-fast disponíveis; AGY Gemini3.8High e Opus5.5High; OpenCodeGo/Muse1.3 presentes. Grok4.6 segue instrução global do usuário. Revisão de plano Gemini/Grok/Muse/Opus AGY; após congelar arte e Lua, revisão de implementação Gemini/Grok/Muse/Opus Cursor. Quota/saída vazia não é aprovação, sem substituição de modelo.

## Produção

1. Fixar paleta e tamanho antes de desenhar; fontes/imagens locais somente para identidade. Criar formas pixeladas opacas/transparência binária, sem antialias, blur ou escala fracionária.
2. Fazer painéis modulares e trilhos de barra, fill separado e recortável em pixels inteiros. Bordas/cantos preservados por 9-slice, não escalar moldura inteira de modo que estique parafusos.
3. Criar ícone de dash pronto/cinza, relógio cinza com passos de progresso, medidor de aceleração com agulha separada/passos normalizados e retratos baseados nos sprites reais. Não atribuir duração final à sequência nem criar mecânica de aceleração.
4. Criar fonte bitmap 5x7/acentos e atlas+mapa, com números, barra, vírgula, segundos e rótulos PT-BR. Texto e valores dinâmicos separados da arte de produção. Labels e HP da composição são exemplos editáveis, não regras de jogo.
5. Montar fontes de layout em576x324 (metade do espaço lógico1152x648) com layers por peça e metadados de anchors. Preview3x inteiro1728x972. Composição só estudo, não captura de runtime. Se usar fundo real, layer de referência separada, nunca empacotado como textura da HUD.
6. Exportar .aseprite, PNG de peças, atlas, overlay, folha de elementos e contexto legíveis. Imagens da pesquisa não entram em exportações. Documentar formatos, margens de corte/fill e ajustes de escala futuros. Congelar e passar revisões de código/contratos; principal inspeciona visualmente o resultado, coordena correções necessárias.

Comando produtivo conhecido: Aseprite.exe -b --script-param root=<repo> --script <kit/generate_hud.lua>. Parâmetros vêm ANTES de --script, pois Aseprite executa ao encontrar essa flag. Binário confirmado em C:/Program Files (x86)/Steam/steamapps/common/Aseprite/Aseprite.exe. Não pedir escalonamento; ambiente já permite execução.

R2 prospectivo: specsrefinadas apósrevisõesGemini/Muse/Grok antesdeescrita. Ajustesdealtura/cantos,90pxdefill,clockhorário17estados, glyphset/acentos+s, retratoscompaletaoriginal, paths reais eJSONconcretos. OpusAGY ainda lêinputR1imutável; incorporar achadosconcretos quandoencerrar, semalterarinputs emcurso.

R2.1 prospectivo fechaP1Opus de espaço e acentos e registra prova factual sobre grade2xdo mundo. Produção ajustada a45min, um writer, mesmos paths novos. A mudança de layout é estudo ajustável autorizado pelo pedido atual; manter ambosanchors sem criarapprovalflow. Inspeção ecorreçõesda arte são autoria, semautotestes/QA. Revisão de deltaOpus decontratos antes deliberarprodução.

## Liberação de produção

Opus deltaR2 confirmou resolução no mérito dos3P1; apontou apenas redação de precedência das métricas. Principal consolidou contrato-v1.md que prevalece, incluindo fonte5x11/linha12 e arquivos-fonte de retrato semambiguidade. Player/alvo40altura evita o risco de caption+trilho25>24 de interior; dash40/dados2linhas eclock24cabem. Demais modelosR1têmcontratosendereçados. Autorizar únicoLuna45min, mesmospathsnovos, sem integraçãoGodot.

## Correções prospectivas de autoria R2

Principal inspecionou contextos/folha/retratosR1. Corrigir antes da entrega:1) amostra PRONTO não deve mostrar restante0,3s; usarDASH ePRONTO ou0s, sem alterar cooldownreal;2) nota de layout diz13glifosRECARREGANDO, corrigir12glifos,72pxadvance/71pxink, mantendo78pxrectcomo folga;3) README atual sugere reexecutar geradorapóseditarASE, o que sobrescrevefontesredesenhadas. Distinguir reconstruçãoLua (revertealteraçõesmanuais) de exportarversãomanualviaAsepriteFile>Export/SaveCopy, com novosnomespara preservaroriginais. Semnovopipelineimport/aberturaGodot.

Quatro órfãosexploratóriosnãoreferenciadosmanifest foram preservados apósrejeiçãoautomáticaBlockedByPolicy semmotivoespecífico. Nãotentarremovernemmover; registrar emREADME comoexploratóriosnãoentregues, para não confundirretrato24antigocom32x28atual. Isto completaatarefa degerararte de formamaisseguira semdependência de limpeza.

AutorizarLuna único writer15min no kitnovo paraesses3ajustes eREADME; regeneraçãoAsepriteprodutiva, capturarstdout/stderr, inspecionarready. DemaisinputsR1imutáveispara4revisores. CongelarR2depois,deltarevisado. Nada de testes/Godot/audit/Git.

## Correção prospectiva R3 — paleta editável Aseprite

Principal leu a função palette(spr) e confirmou na documentação oficial https://www.aseprite.org/api/sprite#spritesetpalette: o método suportado é sprite:setPalette(palette); Sprite.palettes é array de leitura. A atribuição spr.palette=p dentro de pcall silencioso não assegura swatches de autoria no .aseprite e pode ocultar erro. Substituir somente esse trecho por spr:setPalette(p), sem pcall que engula falha; manterpixelsRGB/paleta19definida/identidades/posições. Não executar validação/audit; a execução produtiva Aseprite recria fontes com paleta correta e registra sucesso/erro normalmente. Esse ajuste é necessário para os .aseprite realmente editáveis com swatchesHUD corretos.

Autorizar mesmoLuna writer8min somentekitnovo, semdelete/move nemGPU/runtime/Godot/testes. R2snapshot preservado antes da escrita. Regeneraroutputs/losslesscommesmosdesenhos; conferirvisualdeautoria e congelar. R3delta conterá também3correçõesR2 para revisão conjunta pósR1.

## Correções prospectivas R4 — achados concretos da revisão R1

Gemini/Muse/Grok completos identificaram o mesmo P1: build() ainda usa coordenadas de retrato24x24, mas o Tranca passou a32x28. O compacto/layout.json estão corretos, o contexto está errado. Corrigir build() para retrato(222,14), barra(258,28), fill(261,31), preferencialmente lendo A.targetPortrait/A.targetBar em vez de repetir números. Não alterar fontes, corte ou fonte original. Valores de texto permanecem nos retângulos atuais e não devem cobrir retrato.

Paddingpack: root confirma gapverticaltotal2 e fundo0 no algoritmo atual. Corrigir para x,y=2 com places=(x,y), avançar x por width+4, nova linha y porrow+4 e altura y+row+2, condição de largura reservando2àdireita. Isso dá bordas≥2 e gap4 entre linhas/colunas, dois porasset. Regenerar atlas e JSON/source correspondente sem mudar imagens avulsas dos componentes.

CONCEITO: imagem é58x13 apesar de arquivo e layout dizerem74x15. Gerar de fato74x15, desenho e texto centralizados nesse retângulo. Default(489,110) e alternativo(489,238) mantêm margem5 na coluna84. Metadados/tamanhos de produção devem coincidir, não apenas ocupar umslotmáximo.

Clock: alinhar centro/pivô de desenho a(11,11) e raiosinteiros10/8/7, amostra consistente no centro de pixel expressado na gradeinteira. Ponteiro também usa essecentro; manter convençãohorária/demais17estados/cores. Nãointroduzirrotaçãofracionária nemtemposgameplay.

ASEstates: contrato falava17frames/tags, mas sourceatualéumframecomlayers de sheet. Corrigir fontes clock-states.aseprite para24x24/17frames e tag de índice normalizado; gauge-needle-states.aseprite para37x20/9frames e tag, usando APIAseprite de frames/tags. PNGssheets/estados já existentes continuam. Duração de frame é apenas playback de estudo, explicitamente não cooldown da ação. README/manifests indicam normalização e que a integração deverá escolher índice, não reproduzir timing fixo. Fontsheet/component atlas/composição seguemcamadaseditáveis.

Autorizar únicoLuna20min somentepasta nova do kit, mesmasrestrições sem testes/Godot/audit/Git/delete/move. R3snapshot salvo e todospareceresR1preservados. R4deverá ser congelado com logAsepriteprodutivoeinspection visual; deltaR1→R4 será revisto pelos revisores correspondentes. OpusCursor quota járegistrada,nãorepetir. Esta é correção decontratos de arte/edição; não adiciona mecânica de game.

## Consolidação documental R5 — sem regeneração de arte

Gemini e Muse R4 confirmaram fechamento dos achados de geração e encontraram repetição literal da descrição das timelines no README. O principal classifica como editorial, sem risco funcional. Remover somente a segunda repetição e registrar o tamanho CONCEITO 74×15 inline para conveniência. Luna único writer por até 5 minutos exclusivamente em assets/ui/hud_caldeira_v1/README.md. Proibido executar gerador ou modificar PNG/ASE/JSON/Lua; sem Godot, testes, audit, Git, delete/move. R4 está congelado em histórico, portanto Grok pode terminar sua leitura estática. Depois, revisão documental curta dos trechos alterados, sem reabrir contratos de arte. Nenhuma nova mecânica ou regra.
