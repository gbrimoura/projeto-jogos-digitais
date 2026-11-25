# R3 — Resgate de Ampère

A primeira abertura foi difícil de ler. Esta revisão coloca o resgate antes da exposição e mostra o despertar em quadros desenhados para a cena. Íris verifica se Ampère responde. O visor acende e o carteiro se apoia no chão para levantar. O pacote, a recepção bloqueada e a passagem lateral dão suporte visual às falas.

- Íris ganhou rosto exposto, coque, óculos de proteção, lenço laranja, macacão com faixas e cinto de ferramentas. Seis quadros cobrem ajoelhar, tocar o ombro, reagir, erguer-se, conversar e apontar.
- Ampère ganhou sete quadros, de repouso sem sinal a ficar em pé segurando o pacote. O capacete marfim, a antena amarela e o visor ciano mantêm a identificação com o sprite de gameplay.
- A nova passagem de serviço separa a recepção bloqueada à esquerda do acesso iluminado à direita. O foco âmbar no piso enquadra o resgate.
- PNGs e arquivos editáveis ficam em `assets/narrative/intro/rework`. A referência de poses veio do ImageGen. Os quadros foram registrados, limpos e limitados às paletas no Aseprite. O cenário foi desenhado no Aseprite.
- A auditoria visual e de PNG confirmou as três dimensões esperadas, ausência de pixels semitransparentes e ausência de pixels isolados.

## Prancha de referência

Prompt em inglês enviado ao ImageGen integrado. Seis poses de uma técnica ferroviária com traços humanos, cabelo escuro preso, óculos de bronze, macacão jade, lenço laranja e ferramentas. Seis poses do robô carteiro com capacete marfim, visor ciano e antena amarela, caído, despertando, erguendo-se e recolhendo o pacote. Fundo escuro liso e figuras separadas.



## Verificação no Godot 4.7.2

A cópia isolada importou os gráficos da abertura. Jogar abriu a cutscene, as cinco poses do despertar apareceram na sequência, os diálogos avançaram por teclado e clique, e o pátio abriu pelo fluxo completo, por Esc e pelo botão de pular. Um segundo clique em Jogar na mesma sessão foi direto ao pátio. A composição foi capturada em 1152 × 648 com o renderizador Compatibility. A importação emitiu um aviso de UID duplicado nas duas cópias preexistentes de main.tscn.
