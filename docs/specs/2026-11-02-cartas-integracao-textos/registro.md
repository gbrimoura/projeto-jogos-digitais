# Registro — integração de textos das cartas

Baseline R0 criado antes das alterações nos alvos. Cópias exatas e tamanho/SHA-256 por caminho estão em historico/r0-baseline/.

A proposta limita as mudanças à copy, helpers de apresentação e prévias de cartas descritas em plano.md. Campos mecânicos, caminhos, IDs, arte, fontes, molduras e demais cenas permanecem protegidos.

## Evidência de baseline

- scripts/progression/upgrade_catalog.gd — 13321 bytes — SHA-256 893842F712E9C335C0608E7BEDF002F78504BF8C49010C80CD55A2376ED18E70
- resources/upgrades/impacto_reforcado.tres — 677 bytes — SHA-256 84E3DA63E670F925E15BE4C721B631B1332D3D49A9E1B13A53A87FFD544C6EC9
- resources/upgrades/motor_acelerado.tres — 710 bytes — SHA-256 F9A2242252B20F20907E20D5FCB1831F1BA7E10D08F65DA8652D3733D2ECFC73
- resources/upgrades/carga_reativa.tres — 735 bytes — SHA-256 AEE2DD70674881345A60E65997299E71ACFBE8719CE4E25294CC05C79AA4BCCE
- resources/upgrades/ricochete_pressao.tres — 760 bytes — SHA-256 0A9204EA1938318A1ECC3A6AF345CB883313BF670110C84D0FF802343C825A15
- resources/upgrades/mola_retorno.tres — 706 bytes — SHA-256 DBE2E0E76DD38A817986EE9C93ADBB8A5302B0033189DB68494D6E361A24BE5A
- resources/upgrades/dinamo_defesa.tres — 684 bytes — SHA-256 87321E1F629E2E3C5BA0DC43D93E96E9D5E8733CB97F195384B608A548168B81
- resources/upgrades/chassi_reforcado.tres — 726 bytes — SHA-256 74304FF68DB24012BACB145762BC0C1B49D1F12AF650C0003E71EF4192525863
- scripts/ui/upgrade_card.gd — 6727 bytes — SHA-256 211211A6DEBF5A607113D2454DEBFFF0EAA5D8126125A603FEEA05EEF2335C61
- scripts/ui/upgrade_offer.gd — 4353 bytes — SHA-256 B3BAF504DB2086D4476BCA573D0C35F190054F34AA49225264F39FB252A0F425
- scenes/ui/upgrade_card.tscn — 3128 bytes — SHA-256 BF596D403556A1C9036DCAEC595CE069C1DAFBADBA657B333B9B5C33EDDFB764
- assets/ui/upgrade_cards_v1/source/generate_upgrade_cards.lua — 23738 bytes — SHA-256 F6B9BEEF9CDBD816872CC5743FFA8E5A3594849495E0740BBF43500F33B06230
- assets/ui/upgrade_cards_v1/preview/upgrade-cards-study-576x324.png — 8231 bytes — SHA-256 D1BBDB6E15865D32C055A4AE8F2D269E04A6AE13F8D6C0F48B786EFC994C9B42
- assets/ui/upgrade_cards_v1/preview/upgrade-cards-study-1728x972.png — 18600 bytes — SHA-256 BBA80887A81BCFE60D961CA5ABD52810CB06093940B49695BA3E48E23A3EB344
- assets/ui/upgrade_cards_v1/README.md — 1716 bytes — SHA-256 CC90A96A4FEC065EE4CF65E79F3D42C50C9E0E53719DEF92DAD1CD27902BF4A4
- assets/ui/upgrade_cards_v1/export/manifest.json — 1398 bytes — SHA-256 335E7F27D9C71F95C37BF72942E084120161C80B14003C1F9B4B5C4F38613A75

## Resultado integrado
Sete cartas existentes usam os novos ícones já referenciados. Descrições e tópicos foram revisados, incluindo comparação atual > próximo nas evoluções; Motor compara recarga padrão, Dínamo descreve redução restante por rebatida, Carga exige rebater sua bola e vale para o próximo acerto, Pressão mostra cap de paredes, Chassi mostra cura na escolha. Título da tela ESCOLHA UMA MELHORIA e instrução UMA ESCOLHA POR SALA. Dimensões, arte, fonte e mecânicas preservadas. Card e cenas não precisaram de alterações.

A prévia acompanha o componente final em posição/cor de texto e mostra NOVO Carga / EVOLUIR NÍVEL 2 Mola e Dínamo. Modo preview_only lê ícones existentes e não escreve arte, fontes, molduras, contato nem manifesto. Aseprite R4 exit 0; root viu PNG. Produções anteriores com falha preservadas em logs.

Revisão: Gemini favorável, Muse sem bloqueios e observações avaliadas; Grok sem parecer por falha interna da ferramenta; Opus pendente por cota. Evidências em pareceres/README.md. Sem execução de Godot/testes, commit/push ou troca de branch. A revisão obrigatória Opus ainda não foi satisfeita.
