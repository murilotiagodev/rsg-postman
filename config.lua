Config = {}

-- NPC Carteiro (Saint Denis)
Config.PostmanNPC = {
    model = "U_M_M_NbxGeneralStoreOwner_01",
    coords = vector4(2754.00, -1386.54, 45.80, 25.76) -- ajustado Z (-0.5) para ficar no chão
}

-- Locais de entrega (Saint Denis)
Config.DeliveryLocations = {
    { coords = vector3(2750.74, -1226.08, 49.61), name = "Rua Principal" },
    { coords = vector3(2651.06, -1208.24, 53.33), name = "Área Residencial" },
    { coords = vector3(2656.68, -1280.35, 52.24), name = "Banco" },
    { coords = vector3(2715.18, -1191.91, 51.67), name = "Lojas de Luxo" },
    { coords = vector3(2787.80, -1320.43, 46.34), name = "Docas" },
    { coords = vector3(2788.43, -1186.41, 47.65), name = "Grande Hotel" },
    { coords = vector3(2668.61, -1385.98, 46.69), name = "Mercado de Gado" },
    { coords = vector3(2621.82, -1417.60, 46.45), name = "Serraria" },
    { coords = vector3(2592.41, -1251.39, 53.31), name = "Cassino" },
    { coords = vector3(2762.43, -1351.45, 46.34), name = "Bar das Docas" },
    { coords = vector3(2812.87, -1190.25, 47.21), name = "Armazém" },
    { coords = vector3(2715.48, -1125.96, 50.13), name = "Distrito Norte" },
    { coords = vector3(2661.01, -1196.57, 53.30), name = "Alfaiate" },
    { coords = vector3(2535.53, -1272.42, 49.23), name = "Farmácia" },
    { coords = vector3(2862.30, -1234.75, 46.35), name = "Depósito do Porto" },
}

-- Item usado para pacotes
Config.PackageItem = "package"

-- Pagamento por pacote entregue ($)
Config.PayPerPackage = 1

-- Número máximo de pacotes que podem ser retirados no NPC
Config.MaxPackages = 50

-- Quantidade mínima/máxima de pacotes por entrega
Config.MinPackagesPerDelivery = 1
Config.MaxPackagesPerDelivery = 5

-- Tempo de espera (em milissegundos) até a próxima entrega (ex: 5000 = 5 segundos)
Config.NextDeliveryDelay = 5000
