# Revisões — porta horizontal na parede

Data: 18/10/2026. Escopo somente leitura; sem engine, importação, testes ou QA. Implementação delegada a GPT-6 Luna xhigh; interface não permite confirmar Fast/priority. Preflight executado uma vez nesta tarefa: modelos exatos disponíveis nos catálogos, Cursor autenticado, credencial OpenCode armazenada; isso não garante cota/validade da API.

## Plano horizontal R1

- Gemini 3.8 Flash (High), AGY plan: parecer recebido. Geometria geral coerente. Alertas de sensor menor que abertura, emendas de painel, recolhimento lateral e label.
- Cursor cursor-grok-4.6-xhigh-fast, plan: parecer recebido. Alertas semelhantes e condicionais sobre z/parede e soleira.
- Muse opencode-go/muse-spark-1.3-contributor xhigh, OpenCode plan: chave expirada, sem parecer; exit do wrapper0 não significa revisão realizada.
- Opus claude-opus-5-5-high, AGY plan: sem parecer. Leitura por ferramenta exigiu command permission, auto-negada em headless mesmo com conteúdo inline. Nenhuma permissão foi alterada.

Saídas originais em *.stdout.txt / *.stderr.txt e códigos em *.exit.txt. O conteúdo do plano e spec foi fornecido inline; revisores não receberam permissão de escrita.

## Decisões do principal

1. Manter sensor96×108 e mecânica E; escopo é visual. Localizar indicador/label junto ao sensor para evitar promessa de alcance por toda largura.
2. Open representa folha telescópica ou entrando em bolso da parede, sem exigir estacionamento de128px em margem16px.
3. Label dentro da região jogável, sem cruzar parede lateral.
4. Confirmado por leitura: fundo SandboxVisual z=-10, paredes somente faixas0..64 e1088..1152 em z=-1; pais das portas z0. Painel z=-2 permanece visível. Não existe backdrop cheio acima do painel.
5. Compensar costuras com linguagem de chapa/rebaixo do atlas; soleira baixa e vão útil>=48px. Flip para o bolso apontar à parede em cada lado quando necessário.
6. Parede física não recebe passagem; estados visuais representam transição E existente.

Implementador recebeu essas decisões antes do freeze. Revisão da implementação ainda pendente.
## Freeze e proveniência da implementação

Entrada R1: `implementacao-r1-input.txt` SHA256 E1BE3D91AA0C1E4221047CDEA70E4D3563AF8F0C15275397B5A481F682FE9D36; 24347 caracteres. Inclui diffs de Main/SecondRoom e ExitDoor.gd contra baseline local, cena reutilizável completa, script completo e Lua completo. Não foram usados diffs de HEAD que misturassem tarefas anteriores.

`implementacao-r1-hashes.json` registra 10 fontes/arte no primeiro freeze. O implementador acrescentou apenas CRLF no EOF de exit_door.tscn e exit_door.gd depois do aviso inicial; o principal comparou as linhas e confirmou ausência de mudança semântica. Os demais8 hashes permaneceram iguais. Estado final em `implementacao-final-hashes.json`. Esta formatação não dispara revisão recursiva. Nenhuma outra escrita runtime foi permitida durante revisão.

O principal inspecionou os PNGs 4× e montagem final. A montagem é composição estática Aseprite com atlas e personagem atuais, não captura do Godot. Aseprite batch foi usado exclusivamente para criação/exportação do asset solicitado; sem Godot/importação/testes/QA. Metadados .import surgiram no checkout e foram preservados; implementador declara que não os criou nem editou.

Mudança local alheia THIRDPARTY.md preservada: SHA256 D6F97DF007248867ABD7371DB54295FEDC6A77A496B8BFD7A9A86C4B7C1426F7. Nenhum commit/push/troca de branch.

## Implementação R1 — pareceres e decisões

Gemini AGY e Grok Cursor concluíram revisão estática; stdout integral preservado. Muse confirmou chave expirada; Opus Cursor confirmou ActionRequiredError por limite de uso até03/11/2026. Não houve substituição silenciosa de revisor, nem parecer atribuído a eles.

- Aceito: `local out` da Lua relativo ao CWD enquanto atlas/player usam root absoluto. Implementador fará correção pontual para root..caminho e atualizará hash do manifesto; nenhum novo desenho/exportação é necessário, pois a saída original foi produzida na raiz correta.
- Não é regressão: quadro fechado durante transition_busy já é mapeamento explícito da apresentação baseline e do plano. Grok reconheceu isso; Gemini classificou como regressão visual, classificação rejeitada pelo principal. Nenhuma regra de transição será alterada neste escopo visual.
- Amostra de entrada aberta: não é estado de jogo. A legenda e README dizem explicitamente que é amostra e a entrada em jogo permanece fechada. Mantida para mostrar arte espelhada.
- Hipótese de drawImage apagar alfa: não observada. Principal inspecionou PNG runtime, preview4x e montagem; todos têm parede, folhas e caixilho íntegros. Sem justificativa para alterar composição já exportada.
- Dependência do atlas/player: são fontes explícitas para composição neste projeto, não defeito de runtime. Não ampliar tratamento genérico de pipeline.
- Contexto fora dos hunks: confirmado pelo principal na leitura das cenas/helpers (raízes, paredes64px, backdrop-10, WallVisuals-1, atores1). `rg` não encontrou referências legadas DoorPanel/PortalGlow/DoorRim/DoorSeal em scenes nem scripts/world.

R2 limitada ao caminho de saída Lua pendente.

## Resultado final R2

Gemini AGY e Grok Cursor revisaram a correção pontual e não identificaram defeito concreto remanescente no delta. Pareceres integrais `gemini-implementacao-r2.*` e `grok-implementacao-r2.*`. Entrada R2 SHA256 C15B16D27C6E80890ABAD3ADAB88A1393210809D44A759DE785D3005BF0113B4; estado final R2 em `implementacao-r2-hashes.json`. Manifesto de6 arquivos corresponde aos hashes presentes no disco, por leitura de metadados.

Integrado: arte horizontal embutida em painel de parede, fontes editáveis, dois estados, montagem estática, cena reutilizável e overrides das duas salas. Trabalho delegado ao GPT-6 Luna xhigh; principal inspecionou e consolidou as decisões. Fast/priority não confirmável nesta interface.

Limitações: Opus Cursor sem quota, Muse API expirada e Opus AGY sem parecer por auto-negação de ferramenta. Portanto não há aprovação universal dos revisores exigidos. Sem Godot, importação, testes, QA, commit, push ou troca de branch. Aparência e progressão em execução ainda não verificadas.
