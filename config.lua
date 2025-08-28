Config = {}

-- NPC Postman (Saint Denis)
Config.PostmanNPC = {
    model = "U_M_M_NbxGeneralStoreOwner_01",
    coords = vector4(2754.00, -1386.54, 45.80, 25.76) -- ajustat Z (-0.5) ca să fie pe pământ
}

-- Delivery Locations (Saint Denis)
Config.DeliveryLocations = {
    { coords = vector3(2747.43, -1223.12, 49.37), name = "Main Street" },
    { coords = vector3(2705.12, -1284.33, 49.63), name = "Residential Area" },
    { coords = vector3(2635.56, -1229.78, 53.30), name = "Bank" },
    { coords = vector3(2721.17, -1188.23, 49.37), name = "Luxury Shops" },
    { coords = vector3(2791.45, -1327.11, 46.75), name = "Docks" },
    { coords = vector3(2786.32, -1182.43, 47.55), name = "Grand Hotel" },
    { coords = vector3(2653.10, -1399.54, 46.10), name = "Cattle Market" },
    { coords = vector3(2688.75, -1432.22, 46.30), name = "Sawmill" },
    { coords = vector3(2619.88, -1281.55, 52.60), name = "Casino" },
    { coords = vector3(2762.40, -1362.17, 46.25), name = "Dockside Bar" },
    { coords = vector3(2811.15, -1218.43, 46.80), name = "Warehouse" },
    { coords = vector3(2711.82, -1129.22, 49.40), name = "North District" },
    { coords = vector3(2662.74, -1200.56, 53.20), name = "Tailor Shop" },
    { coords = vector3(2595.32, -1298.21, 53.10), name = "Pharmacy" },
    { coords = vector3(2804.25, -1305.11, 46.75), name = "Harbor Storage" },
}

-- Package item
Config.PackageItem = "package"

-- Payment per package
Config.PayPerPackage = 1

-- Maximum packages
Config.MaxPackages = 50

-- Min/Max packages per delivery
Config.MinPackagesPerDelivery = 1
Config.MaxPackagesPerDelivery = 5
-- Câte ms să aștepte până dă următoarea livrare (ex. 5 secunde)
Config.NextDeliveryDelay = 5000
