# Recorte jogável

- Íris trabalha no pátio. Ao se aproximar da bancada e apertar E, o jogador pode ver as Marcas da Oficina e comprar reforços. Esc ou o botão Fechar retoma o jogo.
- Completar a progressão de uma sala de combate vale uma marca. O resultado final da run registra o total. A vitória final soma mais três marcas. Lojas e falhas técnicas ficam fora desse cálculo.
- Reforço de estrutura acrescenta 1 PV inicial e máximo por nível. Bolsa de sucata acrescenta 2 de sucata inicial por nível. Ambos têm dois níveis e custam 2 e 4 marcas. Valores provisórios para balanceamento. Os efeitos entram na próxima subida.
- O progresso é salvo em um arquivo próprio da oficina. Uma tentativa de gravação escreve e valida um temporário antes de substituir o arquivo principal. A confirmação de compra depende da gravação. A recuperação usa o backup se o arquivo principal desaparecer durante a troca.
- A abertura apresenta a manutenção, o pacote de Pecúnia, a tomada da recepção e a oficina. Duas escolhas sob Você mudam a fala seguinte. As opções convergem para a chegada ao pátio. A abertura pode ser pulada.

## Recuperação do arquivo

O progresso usa `iris_workshop.cfg` em `user://`. No Windows, a pasta padrão deste projeto é `%APPDATA%\Godot\app_userdata\Selenite Tower`. Mantenha uma instância do jogo por arquivo. Caso o arquivo principal seja ilegível e o backup `iris_workshop.bak` esteja válido, o jogo abre o backup. Quando as duas cópias estiverem indisponíveis, o jogo preserva o arquivo ilegível e mostra a falha na oficina. Para recuperação manual, com o jogo fechado, arquive as cópias atuais antes de restaurar um `iris_workshop.cfg` válido conhecido. `iris_workshop.tmp` é usado para validar a próxima gravação.

Depois de uma falha de gravação, as marcas pendentes continuam na sessão. O resultado oferece outra tentativa e abrir a oficina tenta gravá-las novamente. Sair do aplicativo encerra a sessão. Compras só descontam o saldo quando gravadas.
