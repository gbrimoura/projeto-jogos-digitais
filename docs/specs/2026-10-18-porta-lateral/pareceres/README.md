# Pareceres — abertura na parede lateral

Escopo: correção visual pedida pelo usuário em18/10/2026. Implementador GPT-6 Luna xhigh; Fast/priority não confirmável. Um escritor runtime; principal só coordenação e metadados de revisão. Preflight único: AGY modelos exatos, Cursor autenticado/modelos exatos, OpenCodeGo/Muse no catálogo; credencial armazenada não comprova validadeAPI.

## Plano

Opus5.5High via AGY plan: parecer recebido por contexto inline (`plano-input.txt`), sem acesso a arquivos. Não apontou bloqueio; pediu default de gap desativado, UV exato, espelho sóvisual, refs retargeteadas e zfixo. Gemini/Grok plano por conteúdo completo inline (`plano-completo-input.txt`) confirmam geometria, com alertas de clipping/origem/alpha/estado/escopo. Muse retornou API key expired, sem parecer apesar de exit0 do wrapper.

Decisões do principal: gap exportado default0 e habilitado apenas nas4paredes visuais atuais; helper já desenha exclusivamente64px, nãofillde fundo. Corte semiaberto[432,560), UV conserva coordenadas originais por região parcial, sem escalaextra. Visual local centradoRect(-32,-64,64,128), offsets direita(+80,-26)/esquerda(-80,-26), espelho somente no desenho. Fundo opaco da abertura, zefetivo-1 igualparede, atores1. Entrada fechada; gameplay e paredefísica intactos. Label juntoE e inteiramente na regiãojogável, não precisa caber no vão64px. Só Main/Second instanciam packeddoor (confirmado rg).

Todos os pareceres são stdout original preservado com stderr/exit. Alertas condicionais não são automaticamente defeitos. Principal leu helper e cenas para avaliar. Sem Godot/import/testes/QA/commit/push/troca debranch.

## Implementação

Aguardando freeze e revisão final. Nenhum parecer OpusCursor atribuído antes de tentativa.
## Freeze da implementação

Entrada revisada `implementacao-r1-input.txt`, SHA256 44BFFC3E10F5AAB259AB1280368212BCB65F9ED7578658363326C07FE8397E51, 22500 caracteres. Inclui diffs Main/SecondRoom e apresentação ExitDoor contra snapshot LOCAL; helpers parede/porta, packedscene e Lua da montagem completos. Hashes8 fontes/preview em `implementacao-r1-hashes.json`; principal confirmou nenhum delta após freeze.

Principal inspecionou composição estática: porta no corte das laterais, piso contínuo e personagem à frente. Não é screenshot/runtime. `rg` não encontrou DoorArt/DoorPanel/PortalGlow/DoorRim/DoorSeal em scenes e scripts/world. SHA256 da mudança local alheia THIRDPARTY.md continua D6F97DF007248867ABD7371DB54295FEDC6A77A496B8BFD7A9A86C4B7C1426F7.

Quatro revisores de implementação solicitados sobre conteúdo inline estável. Opus Cursor retornou ActionRequiredError de quota até03/11/2026. Muse retornou API key expired. Sem parecer deles; exit0 do wrapper não é aprovação. Opus AGY revisou apenas plano e não substitui Opus Cursor na implementação. Gemini/Grok ainda em execução nesta anotação.

## Achados R1 recebidos de Grok — decisões do principal

Geometria/clipping/preservação de interação coerentes. Dependências de posição e z foram confirmadas por leitura das cenas, não são defeitos pendentes. Alegação de load_steps ausente em Main foi rejeitada: header não tem o campo opcional; não existe contador explícito obsoleto. Aceita remoção dos ext_resources redundantes dos dois arquivos (packedscene járeferencia helper), com Second21→20.

Aceitos dois detalhes da composição estática: sombra inferior y122→124 para reproduzir runtime e clipping de cada faixa inteira do preview em224px (incluindo paredes/piso), sem vazamento nas legendas. Não são P1 runtime: afetam apenas material de inspeção.

R2 liberada para implementador no escopo acima enquanto Gemini R1 ainda recebe somente conteúdo INLINE imutável, sem ler workspace. R1 permanece integralmente preservada em input/hashes; revisão não depende de arquivos sendo editados. Helpers e ExitDoor.gd não sofrerão alteração. PreviewR1 será preservado no histórico.

## R1 consolidada e R2

Gemini R1 também confirmou matemática/UV/camadas e preservação de gameplay, com os mesmos detalhes de recursos redundantes e sombra. A classificação de recurso não usado como P1 foi reduzida pelo principal a higiene de cena; `load_steps` opcional ausente em Main não é contador obsoleto. Amostra de entrada aberta permanece intencional e legendada, sem mudar runtime.

R2 removeu apenas recursos redundantes de Main/Second (Second21→20), alinhou sombra do preview y124 e passou a compor cada faixa em imagem1152×224 com clipping e skip de alpha0. Este último ajuste veio da leitura do principal para não apagar fundo com pixels transparentes do protagonista. Runtime helpers e ExitDoor/script/cena não foram alterados. PreviewR1/Lua preservados em historico/R1; previewR2 inspecionado visualmente pelo principal.

EntradaR2 `implementacao-r2-input.txt` SHA256 F6AE6D936667D20AAF006691652DDC840C1D029707BFD7CB98680A639B4C433D,6452caracteres, diff do previewR1→R2 e cenas finais contra baseline local. Fontes finais em implementacao-r2-hashes.json. Gemini/Grok delta solicitados; Muse/OpusCursor continuam indisponíveis pelos erros já registrados nesta tarefa, sem substituição.

## Resultado final

Gemini e Grok concluíram R2 sem regressão concreta identificada no delta. Saídas originais e stderr/exit preservados. Ressalvas de Grok resolvidas por leitura do principal: C.void usa rgba comalpha255; main/second não contêm mais ext_resource12_side_door_visual; Second headerload_steps20, Main campo opcional ausente. Recomendação externa de merge/staging de Gemini está fora do escopo e não foi executada.

Integrado por GPT-6 Luna xhigh: clipping exato da faixa lateral, helper compacto de passagem/grade, cena reutilizável e duas salas, prévia estática Aseprite. Principal inspecionou montagem, avaliou/corrigiu achados com o implementador e preservou snapshots/hashes. Nenhum teste, engine/import ou QA executado. Física continua sólida e transição E preservada. Arte anterior mantida sem uso ativo.

Limitações de revisão: Opus AGY revisou plano por contexto inline; Opus Cursor implementação indisponível porquota e Muse APIexpirada. Não há parecer universal desses revisores nem substituição silenciosa. Nenhum commit/push/merge/staging/troca debranch.
