# 📦 RSG Postman Job

A fully-featured **Postman Delivery Job** for [RSG Core](https://github.com/RedEM-RP/rsg-core) on **RedM**, using **ox_lib**, **ox_target** and **rsg-inventory**.

Players can work as a postman, collect packages from an NPC, deliver them around Saint Denis (or any configured town), earn money, and return unused packages.

---

## ✨ Features

- 🧍‍♂️ **NPC Interaction** via **ox_target**  
- 📦 **Physical `package` item** in `rsg-inventory`  
- 📍 **Random delivery locations** (configurable)  
- 🚶 **Progress bars** on deliver & return (ox_lib)  
- 🎬 **Delivery animation** (`handover_money` animscene)  
- ⏱️ **Configurable delay** between deliveries  
- ❌ **Stop Deliveries option** – return all packages to NPC  
- 🗺️ **Waypoint & blip** for each delivery destination  
- 🔔 **All notifications** via **ox_lib**  


🕹️ Usage

Approach the Postman NPC (blip on map).

Interact (E key via ox_target):

Take packages (choose amount, up to 50).

Stop Deliveries (return unused packages).

Follow blip/waypoint to random delivery address.

Press E at destination to hand over package (with animation).

Get paid in cash.

Wait a short delay, then receive your next delivery location.

Continue until all packages are delivered, or stop at NPC.
---

## 📂 Installation

1. Clone or download this resource into your RedM server’s `resources` folder:  
   ```bash
   resources/[jobs]/rsg-postman
add item in your rsg-core shared items 
    package       = { name = 'package',       label = 'Pachet',       weight = 1, type = 'item', image = 'package.png',       unique = true, useable = true, shouldClose = true, description = 'Pachet Livrare' },

Dependencies

rsg-core

ox_lib

ox_target

rsg-inventory
📜 License

This script is released under the MIT License.
Feel free to use, modify, and share with proper credit.