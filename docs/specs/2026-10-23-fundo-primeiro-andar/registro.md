# Registro de implementação — fundo do primeiro andar

Pedido: melhorar assets e ambientação do primeiro andar; o usuário reforçou durante o trabalho que as salas serão geradas proceduralmente.

Implementação delegada a GPT-6 Luna xhigh, escritor único. A interface não permite confirmar Fast/priority. O principal leu o GDD, coordenou a direção visual e inspecionou os previews antes de liberar a integração. GDD Notion: [Primeiro Andar](https://app.notion.com/p/3cf695c14e2780668784f80479cd0f9d) e [Direção Visual](https://app.notion.com/p/3cf695c14e2781619978cd3ba62c5f94), ambos pré-produção; paleta final/tipografia/slogans continuam pendentes. Direção local: fábrica de vapor/manutenção, ferrugem, âmbar pontual e propaganda.

## Resultado integrado R1

- Referência produzida com ImageGen integrado; prompt exato em [imagegen-prompt.txt](imagegen-prompt.txt). A imagem original foi preservada, sem uso direto como textura de gameplay.
- Produção nativa no Aseprite por Lua: duas bases 576×324, quatro módulos transparentes completos, atlas compacto e fontes ASE em camadas. V1, V2 completa e contato substituído preservados em `assets/environment/factory_v1/background_floor1/variants/`.
- Duas opções de base, duas de máquina esquerda e duas de máquina direita permitem oito combinações. Bits 0/1/2 da seed preparada selecionam essas opções, sem consumir RNG nem alterar a geração existente. Pode haver repetição de combinação.
- Ambas as cenas usam o seletor visual anônimo; no editor usam fallbacks 000/111 sem chamar Main. A composição acontece uma vez em _ready, sem processamento contínuo, câmera, física ou parallax.
- Substituídos o fundo plano e cinco props isolados dentro de SandboxVisual. Paredes, teto, colisões, plataformas, portas, atores, combate, HUD e progressão ficaram intactos. Novos recursos ImageTexture/AtlasTexture nativos evitam dependência de importação PNG pendente.
- O preview [contato procedural](../../../assets/environment/factory_v1/background_floor1/modular/factory-floor1-procedural-contact.png) é montagem estática com os assets atuais e quatro arranjos ilustrativos de plataformas; não é captura do Godot nem reprodução de uma seed física real.

## Evidências e limites

A geração produtiva do Aseprite terminou com ExitCode 0; stdout/stderr estão junto aos assets. O erro anterior de coleta de `$LASTEXITCODE` no PowerShell não foi tratado como aprovação: o processo final foi acompanhado explicitamente e os logs preservados. O principal inspecionou V1, pediu caldeira menos concêntrica, continuidade de tubulações/volumes discretos e lâmpadas; aprovou V2 e depois a composição modular. A quarta legenda/combinação foi corrigida de base0 para base1 antes da integração/revisão; o contato anterior foi preservado.

Snapshot integral e SHA256: `historico/runtime-r1/sha256.json`. Os 12 arquivos protegidos do baseline permanecem idênticos em `historico/protected-r1.json`. Diffs das cenas estão em `historico/main-diff.txt` e `historico/second_room-diff.txt`; nenhum bloco de WallVisuals ou gameplay foi alterado. Sem Godot, importação, parser, linter, testes ou QA conforme AGENTS. Revisão estática não confirma carregamento ou gameplay. Sem commit, push ou troca de branch; trabalho local anterior preservado.

Revisões externas: consultar [pareceres](pareceres/README.md) para saídas fiéis e decisão final. Opus exato tentou a rodada, mas está bloqueado por quota; não foi substituído e não há aprovação Opus.


## Fechamento R1
Gemini e Muse concluíram revisão estática sem P1/P2. Observações P3 do Gemini foram avaliadas e mantidas como melhorias opcionais (nomenclatura, setters de preview, custo textual dos recursos). Grok encerrou exit0 com stdout em branco, sem parecer útil; Opus exato falhou por quota, sem substituição. Saídas originais e decisões preservadas em pareceres/README.md. Nenhuma correção runtime posterior à revisão;47/47 arquivos do snapshot permanecem estáveis. A integração está concluída estaticamente; nenhuma validação de gameplay/carregamento foi executada.

## Incremento posterior — compatibilidade dos vidros
O usuário apontou canos/objetos sobre vidro nas combinações. R2corrigiu a arte das duas bases, reservando vão livre comum e preservando os módulos/runtime. HistóricoR1 permanece intacto; plano ativo/registro/revisões estão em [compatibilidade-janelas](compatibilidade-janelas/registro.md). Sem Godot/testes/commit/push.
