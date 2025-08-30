Config = {}

-- NPC Poștaș (Saint Denis)
Config.PostmanNPC = {
    model = "U_M_M_NbxGeneralStoreOwner_01",
    coords = vector4(2754.00, -1386.54, 45.80, 25.76) -- ajustat Z (-0.5) ca să fie pe pământ
}

-- Locații de livrare (Saint Denis)
Config.DeliveryLocations = {
    { coords = vector3(2750.74, -1226.08, 49.61), name = "Main Street" },
    { coords = vector3(2651.06, -1208.24, 53.33), name = "Residential Area" },
    { coords = vector3(2656.68, -1280.35, 52.24), name = "Bank" },
    { coords = vector3(2715.18, -1191.91, 51.67), name = "Luxury Shops" },
    { coords = vector3(2787.80, -1320.43, 46.34), name = "Docks" },
    { coords = vector3(2788.43, -1186.41, 47.65), name = "Grand Hotel" },
    { coords = vector3(2668.61, -1385.98, 46.69), name = "Cattle Market" },
    { coords = vector3(2621.82, -1417.60, 46.45), name = "Sawmill" },
    { coords = vector3(2592.41, -1251.39, 53.31), name = "Casino" },
    { coords = vector3(2762.43, -1351.45, 46.34), name = "Dockside Bar" },
    { coords = vector3(2812.87, -1190.25, 47.21), name = "Warehouse" },
    { coords = vector3(2715.48, -1125.96, 50.13), name = "Northern District" },
    { coords = vector3(2661.01, -1196.57, 53.30), name = "Tailor" },
    { coords = vector3(2535.53, -1272.42, 49.23), name = "Pharmacy" },
    { coords = vector3(2862.30, -1234.75, 46.35), name = "Harbor Depot" },


}

-- Item-ul folosit pentru pachete
Config.PackageItem = "package"

-- Plata pe pachet livrat ($)
Config.PayPerPackage = 1

-- Numărul maxim de pachete ce pot fi luate de la NPC
Config.MaxPackages = 50

-- Număr minim/maxim de pachete pe livrare
Config.MinPackagesPerDelivery = 1
Config.MaxPackagesPerDelivery = 5

-- Câte milisecunde să aștepte până dă următoarea livrare (ex. 5000 = 5 secunde)
Config.NextDeliveryDelay = 5000
