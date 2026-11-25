# Integração e verificação

A Íris do pátio foi redesenhada a partir do sprite de pé da cutscene depois que a primeira versão ficou irreconhecível. No Aseprite, os quadros foram ajustados à grade de 64 × 64, com repintura de destaques, olhos e ferramenta. O retrato usa o mesmo quadro de origem. Os PNGs finais passaram na auditoria de grade, paleta, transparência e pixels isolados. A personagem ficou junto à bancada já desenhada no cenário.

## Godot 4.7.2 em cópia isolada

- As quatro opções da cutscene foram verificadas por teclado e mouse. As falas convergiram para o pátio. A chegada e a oficina foram conferidas em captura de 1152 × 648.
- Um perfil vazio passou por quatro salas de combate e uma loja com sinais de conclusão controlados. A derrota creditou exatamente quatro marcas. Abrir a oficina com E, comprar os dois primeiros níveis e fechar com Esc funcionou.
- Outro processo carregou os dois níveis comprados e o saldo gasto. A nova run abriu com 6 de 6 PV e 2 de sucata. A troca de sala preservou 5 de 6 PV após dano e a sucata ficou em 2.
- Uma simulação de arquivo inválido com backup recuperou o saldo. A falha de gravação em ambiente de teste manteve o saldo anterior. O retry creditou as marcas pendentes uma única vez.
- A importação reportou UID duplicado em duas cenas main.tscn preexistentes. O teste automatizado de troca de sala reportou dois objetos pendentes no encerramento do processo.
