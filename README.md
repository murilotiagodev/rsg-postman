# 📦 RSG Postman Job

Creditos @silentsound12

Um **trabalho completo de Carteiro/Entregador** para [RSG Core](https://github.com/RedEM-RP/rsg-core) no **RedM**, utilizando **ox_lib**, **ox_target** e **rsg-inventory**.  

Os jogadores podem trabalhar como carteiro, coletar pacotes de um NPC, entregá-los em locais aleatórios (Saint Denis ou qualquer cidade configurada), ganhar dinheiro e devolver pacotes não utilizados.  

🎥 **Vídeo de Demonstração:** [Clique aqui](https://medal.tv/games/red-dead-2/clips/kZqZrxdK3FfXhZXQC?invite=cr-MSxDZ1osMjI4MTc2ODAw&v=121)

---

## ✨ Recursos

- 🧍‍♂️ **Interação com NPC** via **ox_target**  
- 📦 **Item físico `package`** no **rsg-inventory**  
- 📍 **Locais de entrega aleatórios** (configuráveis)  
- 🚶 **Barras de progresso** em entregas e devoluções (ox_lib)  
- 🎬 **Animação de entrega** (`handover_money` animscene)  
- ⏱️ **Atraso configurável** entre entregas  
- ❌ **Opção de parar entregas** – devolver todos os pacotes ao NPC  
- 🗺️ **Blip e waypoint** para cada destino  
- 🔔 **Todas notificações** via **ox_lib**  

---

## 🕹️ Como Jogar

1. Vá até o NPC Carteiro (blip no mapa).  
2. Interaja com **E (ox_target)**:  
   - **Pegar Pacotes** (escolha a quantidade, até 50).  
   - **Parar Entregas** (devolve pacotes restantes).  
3. Siga o blip/waypoint até o endereço aleatório.  
4. Pressione **E** no destino para entregar o pacote (com animação).  
5. Receba o pagamento em dinheiro.  
6. Aguarde um curto intervalo para receber o próximo destino.  
7. Continue até entregar todos os pacotes ou encerrar no NPC.  

---

## 📂 Instalação

1. Baixe ou clone o recurso na pasta `resources` do seu servidor RedM:  
   ```bash
   resources/[jobs]/rsg-postman
add item in your rsg-core shared items 
    package       = { name = 'package',       label = 'Caixa de Entrega',       weight = 1, type = 'item', image = 'package.png',       unique = true, useable = true, shouldClose = true, description = 'Caixa de Entrega' },

Dependencies

rsg-core

ox_lib

ox_target

rsg-inventory
📜 License

This script is released under the MIT License.
Feel free to use, modify, and share with proper credit.
