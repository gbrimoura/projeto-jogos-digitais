# Plano prospectivo — cartas mecânicas

## Contexto
Em 02/11/2026, o usuário rejeitou a rodada de ícones simplificados e pediu que os sete objetos fossem redesenhados como peças industriais cartoon com volume, silhuetas fortes e identidade própria. As referências externas servem apenas para orientar princípios de leitura visual. A autoria continua original.

## Escopo
Redesenhar os sete desenhos do gerador canônico Aseprite e substituir os sete PNGs e as sete fontes ASE nos caminhos existentes. Atualizar o contato visual, as prévias de três cartas e a documentação/manifesto de arte correspondentes. O desenho é nativo em 64×40 e exportado em escala inteira 2× para 128×80. A fonte ASE preserva o contrato de 128×80 em camadas escaladas que o gerador atual já produz.

Os objetos previstos são:
- Impacto: esfera metálica grande com rebites visíveis.
- Motor: propulsor compacto com corpo, bocal e escape/chama.
- Carga: bobina elétrica industrial com faísca.
- Pressão: conjunto de válvula/regulador com manômetro integrado.
- Mola: mola helicoidal comprimida verdadeira entre bases metálicas.
- Dínamo: gerador compacto com volante lateral claramente mecânico.
- Chassi: placa de blindagem espessa com rebites grandes.

## Restrições
Manter IDs, dimensões, caminhos, paleta travada de 19 cores do HUD, alpha somente 0/255, filtro de exportação pixelado e contorno nativo coerente de 1 px. Cada ícone usa até cerca de 10 cores da paleta. Usar 2–3 tons por material, luz comum vinda do alto à direita, volumes arredondados exagerados e clusters intencionais, sem microdetalhe. Não usar bola+raio, raquete+relógio, coração ou relógio sobrepostos.

Manter textos, layout, molduras, fontes, IDs, comportamento, conteúdo mecânico, scripts de jogo, cenas e demais recursos intactos. O gerador pode ser alterado somente nas funções de desenho, nos rótulos de estilo/metadados e na descrição do contato; leitura de quadros e fonte permanece como está. Preservar os arquivos de fontes/fontes tipográficas, molduras e seus imports.

## Baseline e revisão
Antes de substituir qualquer arte, esta rodada cria uma cópia de segurança dos arquivos exatos que serão substituídos, junto a hashes e tamanhos em historico/r0-baseline. A implementação será congelada para inspeção visual do contato e das cartas. Resultados de revisores só serão registrados depois que o agente principal os obtiver; não antecipar ou inventar pareceres.

## Validação permitida
Produção somente pelo Aseprite 1.3.18.6 usando o gerador canônico. Conferir visualmente os PNGs gerados. Não executar Godot, importações, testes, parser, linter, auditorias, simulações ou scripts de qualidade.