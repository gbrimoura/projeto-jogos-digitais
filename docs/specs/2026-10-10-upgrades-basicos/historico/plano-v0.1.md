# Plano: upgrades básicos para o teaser

**Estado:** v0.1 congelada para pareceres; em revisão externa. Ainda não é autorização para implementar.  
**Data do plano:** 10/10/2026.  
**Entrega-alvo:** teaser em vídeo de aproximadamente 60 segundos, quarta-feira, 14/10/2026.  
**Estimativa preliminar:** 13–18 horas de trabalho técnico; edição do vídeo é adicional. Estimativa sujeita à revisão e às validações no Godot.

## Objetivo

Apresentar no teaser uma escolha legível entre três upgrades temporários, mostrar uma escolha em uso na Sala 02 e demonstrar uma sinergia de parry carregado. A escolha precisa ser aplicada uma única vez, sobreviver à transição para a sala seguinte e obedecer ao reinício da run após a morte.

## Recorte proposto para v1

- Após vencer a Sala 01, congelar gameplay e bloquear ações do jogador e da raquete enquanto a oferta estiver aberta.
- Exibir três cartões e exigir uma seleção válida antes de liberar a porta E. Fechar a interface ou clicar nela não pode converter o mesmo input em arremesso, parry ou pulo.
- Fazer `Main` coordenar o fluxo de oferta, seleção e saída. A porta continua responsável apenas por alcance, bloqueio e pedido de transição.
- Mostrar na Sala 02 a escolha feita na Sala 01. Para o teaser, a recompensa aparece apenas na rota principal; o terminal da Sala 02 fica sem recompensa na v1. Esse é um **recorte proposto**, não uma regra universal de progressão.
- Permitir uma aquisição por run nesta versão: sem acúmulos, slots adicionais ou seleção aleatória. A quantidade final de slots e outras regras que o GDD deixa pendentes continuam sem decisão.
- Na morte, R reinicia a sala atual com 5 HP e build vazia. F6 começa uma sala de teste fresca. Cair abaixo de `y = 760` teleporta ao spawn, preservando HP e build.

## Três upgrades candidatos

Todos os números são **provisórios para teste**, não balanceamento confirmado.

| Upgrade | Efeito proposto | Limites e leitura |
|---|---|---|
| **Impacto Reforçado** | Dano-base da bola: 1 → 2. | Não altera física, ricochete nem raio de colisão. |
| **Motor Acelerado** | Recarga do dash: 0,55 s → 0,40 s. | Recalcular a configuração a partir do valor-base; não acumular sobre o valor já modificado. |
| **Carga Reativa** | Após parry bem-sucedido da própria bola, ela ganha uma carga de +2 no próximo dano válido. | Dano-base 1 vira 3; com Impacto Reforçado combinado, o resultado proposto seria 4. Uma carga por bola; parry repetido não acumula nem renova 2,2 s. Parede, alvo inválido e projétil hostil não consomem a carga. Consumir no primeiro inimigo que aceite dano; remover ao terminar a bola. |

O brilho/aro da carga deve usar recursos visuais nativos da cena sem alterar raio ou colisão. A Carga Reativa aplica-se somente a uma bola lançada pelo jogador, nunca a um rebite hostil.

## Desenho técnico mínimo

1. **Dados e build:** criar `UpgradeDefinitionResource` com `id`, título, ícone, texto e efeitos tipados. Criar `RunBuild` transitório na raiz, com upgrades próprios e contagens por ID; não usar Autoload nem persistência em disco. Recursos de definição permanecem somente leitura durante a partida.
2. **Configuração sem mutação:** separar configuração-base de movimento e projétil. Recalcular valores de forma idempotente a partir da base, e copiar a configuração aplicável para cada bola no lançamento.
3. **Transição:** fazer `RoomTransition` ser o único consumidor do payload de HP e snapshot da build. Associar o payload ao caminho canônico `PackedScene.resource_path`, compatível com destino por UID. Não consumir HP antes de confirmar que o snapshot pode ser aplicado. Em falha, manter a sala de origem e limpar o payload one-shot, sem reaplicar o upgrade na tentativa seguinte.
4. **Reconstrução:** `Main` reconstrói a build própria antes de calcular configurações, depois que os filhos estiverem prontos, e verifica também uma sala que já inicia limpa.
5. **Dano:** propor que o método de dano dos inimigos retorne `bool` indicando se o dano foi aceito, para a carga só ser consumida em acerto válido. Verificar callbacks de derrota e encerramento da bola contra limpeza da sala no mesmo ciclo.
6. **Oferta e input:** validar seleção oferecida, jogador vivo, sala concluída e fase correta antes de aceitar. A aplicação é exatamente uma vez. O fechamento da interface não seleciona upgrade nem reabre o gameplay por um frame.

### Arquivos candidatos à implementação

Novos: classes de progressão (`UpgradeDefinitionResource`, `RunBuild`), três recursos de definição e cena/script nativo da escolha de upgrades. Existentes candidatos: `Player`, `BallLauncher`, `MovementController`, `Main`, `RoomTransition`, `CombatRoom`, `ExitDoor`, `RacketController`, bola ricocheteável e sua cena, dois inimigos e suas cenas, e HUD. A lista final depende da inspeção do projeto durante a implementação.

O trabalho de geração procedural que já está em outra frente/branch permanece fora deste plano. Evite conflito ao integrar a transição; não altere a área do outro trabalho sem coordenação.

## Fases propostas

| Data | Fase | Resultado esperado |
|---|---|---|
| Sáb., 10/10 | Revisão do plano | Pareceres externos, avaliação dos achados e congelamento do escopo. |
| Dom., 11/10 | A — dados, build e transferência | Recursos tipados, estado transitório e payload de transição recuperável. |
| Seg., 12/10 | B — oferta e interface | CanvasLayer com três cartões, mouse/foco, pausa com propriedade clara e encerramento seguro em morte ou input obsoleto. |
| Seg., 12/10 | C — carga reativa | Aplicação somente após parry e dano válidos; feedback visual nativo; sem mudança de física. |
| Ter., 13/10 | D — integração e validação | Revisões obrigatórias, checagens no Godot, correções relevantes, atualização do GDD e congelamento para captura. |
| Qua., 14/10 | Teaser | Capturar e editar o vídeo de cerca de 60 segundos. |

## Roteiro proposto do teaser

| Tempo | Cena |
|---|---|
| 0–6 s | Gancho: parry carregado e impacto. |
| 6–20 s | Movimento, dash, ricochete e aviso de ataque inimigo. |
| 20–30 s | Derrota do último inimigo e apresentação dos três cartões. |
| 30–36 s | Seleção de um upgrade e abertura da porta. |
| 36–52 s | Demonstração da escolha na Sala 02. |
| 52–60 s | Título do jogo e indicação “em desenvolvimento”. |

Não apresentar como implementadas moeda, lojas, raridade, slots finais, seleção aleatória ou outras ideias futuras.

## Critérios de aceite para implementação posterior

- Oferta aparece apenas após vitória válida da Sala 01 e pausa a simulação e os inputs de gameplay.
- Uma só escolha válida é aplicada; clique duplo, fechamento e tecla segurada não causam escolha duplicada nem ação de combate ao sair.
- Porta E só libera depois da seleção válida; Sala 02 reflete a build recebida.
- Morte e R limpam a build e restauram 5 HP na sala atual; F6 inicia teste fresco. Queda abaixo de `y = 760` preserva HP/build e reposiciona.
- Falha de transição mantém a sala de origem jogável; retry não duplica consumo nem aplicação de upgrades.
- Configurações-base não são alteradas e recálculos repetidos são idempotentes.
- Carga não pode ser obtida por parry inválido, duplicada por parry repetido ou consumida por parede, rebite hostil ou alvo que rejeite dano.
- Recompensa da Sala 02 segue o recorte proposto para v1; a exceção do terminal fica documentada.

## Checagens planejadas

Não executadas nesta etapa documental. Na implementação, validar clique duplo e input segurado; sala limpa e morte no mesmo frame; morte durante a oferta; configuração imutável/idempotente; transferência por UID, falha, retry, R, F6 e queda; carga em alvo válido/inválido, parede, duração, ricochete e bola encerrada; derrota do último inimigo durante callback de dano.

## Dependências e pendências

- A revisão externa deste plano deve encerrar antes de começar a implementação.
- Confirmar em runtime que a recarga-base do dash é 0,55 s e que os valores candidatos funcionam no ritmo do protótipo.
- Revisar a compatibilidade com o GDD `GDD_Dieselpunk_Noir/04-combate-e-builds.md`; os números da proposta não substituem pendências daquele documento.
- A revisão documental não valida importação de recursos, UID, comportamento de pausa, física ou timing no Godot.
