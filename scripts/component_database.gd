extends Node

enum ComponentType {
	CPU,
	MOTHERBOARD,
	RAM,
	STORAGE,
	GPU,
	COOLING,
	PSU,
	CASE
}

enum StorageSubtype { HDD, SSD, M2, SSHD }
enum CoolingSubtype { AIR, WATER }

var _components: Dictionary = {}

func _ready() -> void:
	_build_database()

func _build_database() -> void:
	# ===== ПРОЦЕССОРЫ (20) =====
	_add("cpu_01", ComponentType.CPU, "CoreX 100", 150, 1.5, "Начальный процессор с 2 ядрами")
	_add("cpu_02", ComponentType.CPU, "CoreX 200", 280, 2.8, "2 ядра, повышенная частота")
	_add("cpu_03", ComponentType.CPU, "CoreX 300", 450, 4.5, "4 ядра, стабильная работа")
	_add("cpu_04", ComponentType.CPU, "CoreX 400", 700, 7.0, "4 ядра с гиперпоточностью")
	_add("cpu_05", ComponentType.CPU, "CoreX 500", 1100, 11.0, "6 ядер, высокая производительность")
	_add("cpu_06", ComponentType.CPU, "TurboCore 1", 1600, 16.0, "6 ядер TurboCore серия")
	_add("cpu_07", ComponentType.CPU, "TurboCore 2", 2400, 24.0, "8 ядер TurboCore")
	_add("cpu_08", ComponentType.CPU, "TurboCore 3", 3500, 35.0, "8 ядер разблокированный")
	_add("cpu_09", ComponentType.CPU, "TurboCore 4", 5000, 50.0, "10 ядер премиум")
	_add("cpu_10", ComponentType.CPU, "TurboCore 5", 7500, 75.0, "12 ядер флагман")
	_add("cpu_11", ComponentType.CPU, "UltraCore S", 11000, 110.0, "UltraCore серия, 12 ядер")
	_add("cpu_12", ComponentType.CPU, "UltraCore M", 15000, 150.0, "16 ядер UltraCore")
	_add("cpu_13", ComponentType.CPU, "UltraCore L", 22000, 220.0, "20 ядер UltraCore")
	_add("cpu_14", ComponentType.CPU, "UltraCore XL", 32000, 320.0, "24 ядра UltraCore")
	_add("cpu_15", ComponentType.CPU, "UltraCore XXL", 48000, 480.0, "32 ядра UltraCore")
	_add("cpu_16", ComponentType.CPU, "MegaProc A1", 70000, 700.0, "MegaProc серия, 32 ядра")
	_add("cpu_17", ComponentType.CPU, "MegaProc A2", 100000, 1000.0, "40 ядер MegaProc")
	_add("cpu_18", ComponentType.CPU, "MegaProc A3", 150000, 1500.0, "48 ядер MegaProc")
	_add("cpu_19", ComponentType.CPU, "MegaProc A4", 220000, 2200.0, "56 ядер MegaProc")
	_add("cpu_20", ComponentType.CPU, "MegaProc A5", 350000, 3500.0, "64 ядра, абсолютный флагман")

	# ===== МАТЕРИНСКИЕ ПЛАТЫ (20) =====
	_add("mb_01", ComponentType.MOTHERBOARD, "BaseBoard Mini ITX", 120, 0.5, "Мини плата, базовые слоты")
	_add("mb_02", ComponentType.MOTHERBOARD, "BaseBoard Micro", 200, 0.8, "Micro-ATX, расширенные слоты")
	_add("mb_03", ComponentType.MOTHERBOARD, "BaseBoard Mid", 350, 1.2, "ATX формат, стандарт")
	_add("mb_04", ComponentType.MOTHERBOARD, "BaseBoard Full", 550, 1.8, "Full-ATX, много слотов")
	_add("mb_05", ComponentType.MOTHERBOARD, "TechBoard Mini X", 900, 2.5, "TechBoard серия Mini")
	_add("mb_06", ComponentType.MOTHERBOARD, "TechBoard Micro X", 1400, 3.5, "TechBoard Micro улучшенный")
	_add("mb_07", ComponentType.MOTHERBOARD, "TechBoard ATX", 2200, 5.0, "TechBoard ATX полный")
	_add("mb_08", ComponentType.MOTHERBOARD, "TechBoard E-ATX", 3500, 7.5, "TechBoard расширенный")
	_add("mb_09", ComponentType.MOTHERBOARD, "TechBoard E-ATX Pro", 5500, 11.0, "Профессиональная серия")
	_add("mb_10", ComponentType.MOTHERBOARD, "TechBoard Supreme", 8500, 16.0, "TechBoard топ модель")
	_add("mb_11", ComponentType.MOTHERBOARD, "ProBoard Lite", 13000, 22.0, "ProBoard серия начало")
	_add("mb_12", ComponentType.MOTHERBOARD, "ProBoard Standard", 20000, 32.0, "ProBoard стандарт")
	_add("mb_13", ComponentType.MOTHERBOARD, "ProBoard Plus", 30000, 45.0, "ProBoard расширенный")
	_add("mb_14", ComponentType.MOTHERBOARD, "ProBoard Max", 45000, 62.0, "ProBoard максимальный")
	_add("mb_15", ComponentType.MOTHERBOARD, "ProBoard Ultra", 70000, 85.0, "ProBoard ультра")
	_add("mb_16", ComponentType.MOTHERBOARD, "MegaBoard Elite S", 110000, 115.0, "MegaBoard Elite серия")
	_add("mb_17", ComponentType.MOTHERBOARD, "MegaBoard Elite M", 170000, 160.0, "MegaBoard Elite M")
	_add("mb_18", ComponentType.MOTHERBOARD, "MegaBoard Elite X", 260000, 220.0, "MegaBoard Elite X")
	_add("mb_19", ComponentType.MOTHERBOARD, "MegaBoard Titan", 400000, 300.0, "MegaBoard Titan")
	_add("mb_20", ComponentType.MOTHERBOARD, "MegaBoard Titan X", 650000, 420.0, "Флагман материнских плат")

	# ===== ОПЕРАТИВНАЯ ПАМЯТЬ (20) =====
	_add("ram_01", ComponentType.RAM, "FastRAM DDR4 4GB", 60, 0.3, "DDR4 базовая планка")
	_add("ram_02", ComponentType.RAM, "FastRAM DDR4 8GB", 110, 0.6, "DDR4 стандартная")
	_add("ram_03", ComponentType.RAM, "FastRAM DDR4 16GB", 200, 1.2, "DDR4 16GB хорошая частота")
	_add("ram_04", ComponentType.RAM, "FastRAM DDR4 32GB", 380, 2.2, "DDR4 32GB")
	_add("ram_05", ComponentType.RAM, "FastRAM DDR4 64GB", 750, 4.2, "DDR4 64GB серверная")
	_add("ram_06", ComponentType.RAM, "SpeedRAM DDR5 8GB", 1200, 6.0, "DDR5 начало")
	_add("ram_07", ComponentType.RAM, "SpeedRAM DDR5 16GB", 2000, 10.0, "DDR5 16GB")
	_add("ram_08", ComponentType.RAM, "SpeedRAM DDR5 32GB", 3500, 17.0, "DDR5 32GB популярная")
	_add("ram_09", ComponentType.RAM, "SpeedRAM DDR5 64GB", 6500, 30.0, "DDR5 64GB")
	_add("ram_10", ComponentType.RAM, "SpeedRAM DDR5 128GB", 13000, 60.0, "DDR5 128GB профи")
	_add("ram_11", ComponentType.RAM, "TurboRAM DDR5 Pro 8GB", 20000, 85.0, "TurboRAM Pro серия")
	_add("ram_12", ComponentType.RAM, "TurboRAM DDR5 Pro 16GB", 30000, 125.0, "TurboRAM Pro 16GB")
	_add("ram_13", ComponentType.RAM, "TurboRAM DDR5 Pro 32GB", 48000, 180.0, "TurboRAM Pro 32GB")
	_add("ram_14", ComponentType.RAM, "TurboRAM DDR5 Pro 64GB", 80000, 260.0, "TurboRAM Pro 64GB")
	_add("ram_15", ComponentType.RAM, "TurboRAM DDR5 Pro 128GB", 140000, 380.0, "TurboRAM Pro 128GB")
	_add("ram_16", ComponentType.RAM, "UltraRAM ECC 16GB", 220000, 540.0, "ECC серверная память")
	_add("ram_17", ComponentType.RAM, "UltraRAM ECC 32GB", 360000, 780.0, "ECC 32GB")
	_add("ram_18", ComponentType.RAM, "UltraRAM ECC 64GB", 580000, 1100.0, "ECC 64GB")
	_add("ram_19", ComponentType.RAM, "UltraRAM ECC 128GB", 950000, 1600.0, "ECC 128GB")
	_add("ram_20", ComponentType.RAM, "UltraRAM ECC 256GB", 1500000, 2400.0, "ECC 256GB максимум")

	# ===== НАКОПИТЕЛИ (20) — HDD/SSD/M.2/SSHD =====
	_add_storage("hdd_01", "SpinDrive HDD 500GB", 80, 0.2, StorageSubtype.HDD, "HDD 500GB базовый")
	_add_storage("hdd_02", "SpinDrive HDD 1TB", 140, 0.4, StorageSubtype.HDD, "HDD 1TB стандарт")
	_add_storage("hdd_03", "SpinDrive HDD 2TB", 240, 0.7, StorageSubtype.HDD, "HDD 2TB")
	_add_storage("hdd_04", "SpinDrive HDD 4TB", 420, 1.2, StorageSubtype.HDD, "HDD 4TB")
	_add_storage("hdd_05", "SpinDrive HDD 8TB", 750, 2.0, StorageSubtype.HDD, "HDD 8TB")
	_add_storage("ssd_01", "SwiftSSD 256GB", 1200, 3.5, StorageSubtype.SSD, "SSD SATA 256GB")
	_add_storage("ssd_02", "SwiftSSD 512GB", 2000, 6.0, StorageSubtype.SSD, "SSD SATA 512GB")
	_add_storage("ssd_03", "SwiftSSD 1TB", 3500, 10.0, StorageSubtype.SSD, "SSD SATA 1TB")
	_add_storage("ssd_04", "SwiftSSD 2TB", 6000, 17.0, StorageSubtype.SSD, "SSD SATA 2TB")
	_add_storage("ssd_05", "SwiftSSD 4TB", 11000, 30.0, StorageSubtype.SSD, "SSD SATA 4TB")
	_add_storage("m2_01", "TurboM2 256GB", 18000, 50.0, StorageSubtype.M2, "M.2 NVMe 256GB")
	_add_storage("m2_02", "TurboM2 512GB", 30000, 80.0, StorageSubtype.M2, "M.2 NVMe 512GB")
	_add_storage("m2_03", "TurboM2 1TB", 50000, 130.0, StorageSubtype.M2, "M.2 NVMe 1TB")
	_add_storage("m2_04", "TurboM2 2TB", 85000, 210.0, StorageSubtype.M2, "M.2 NVMe 2TB")
	_add_storage("m2_05", "TurboM2 4TB", 150000, 340.0, StorageSubtype.M2, "M.2 NVMe 4TB")
	_add_storage("sshd_01", "FusionDrive 500GB", 250000, 520.0, StorageSubtype.SSHD, "Гибридный 500GB")
	_add_storage("sshd_02", "FusionDrive 1TB", 400000, 800.0, StorageSubtype.SSHD, "Гибридный 1TB")
	_add_storage("sshd_03", "FusionDrive 2TB", 650000, 1200.0, StorageSubtype.SSHD, "Гибридный 2TB")
	_add_storage("sshd_04", "FusionDrive Pro 4TB", 1000000, 1900.0, StorageSubtype.SSHD, "Гибридный Pro 4TB")
	_add_storage("sshd_05", "FusionDrive Ultra 8TB", 1800000, 3000.0, StorageSubtype.SSHD, "Флагман накопителей")

	# ===== ВИДЕОКАРТЫ (20) =====
	_add("gpu_01", ComponentType.GPU, "PixelForce 1", 200, 3.0, "Начальная видеокарта")
	_add("gpu_02", ComponentType.GPU, "PixelForce 2", 450, 7.0, "PixelForce базовая")
	_add("gpu_03", ComponentType.GPU, "PixelForce 3", 900, 14.0, "PixelForce средняя")
	_add("gpu_04", ComponentType.GPU, "PixelForce 4", 1800, 25.0, "PixelForce хорошая")
	_add("gpu_05", ComponentType.GPU, "PixelForce 5", 3500, 45.0, "PixelForce топ серия")
	_add("gpu_06", ComponentType.GPU, "RenderX Pro 1", 6000, 75.0, "RenderX начало")
	_add("gpu_07", ComponentType.GPU, "RenderX Pro 2", 10000, 120.0, "RenderX Pro 2")
	_add("gpu_08", ComponentType.GPU, "RenderX Pro 3", 17000, 190.0, "RenderX Pro 3")
	_add("gpu_09", ComponentType.GPU, "RenderX Pro 4", 28000, 300.0, "RenderX Pro 4")
	_add("gpu_10", ComponentType.GPU, "RenderX Pro 5", 45000, 460.0, "RenderX Pro флагман")
	_add("gpu_11", ComponentType.GPU, "MegaGPU S", 75000, 700.0, "MegaGPU серия S")
	_add("gpu_12", ComponentType.GPU, "MegaGPU M", 120000, 1100.0, "MegaGPU серия M")
	_add("gpu_13", ComponentType.GPU, "MegaGPU L", 200000, 1700.0, "MegaGPU серия L")
	_add("gpu_14", ComponentType.GPU, "MegaGPU XL", 320000, 2600.0, "MegaGPU серия XL")
	_add("gpu_15", ComponentType.GPU, "MegaGPU Pro", 520000, 4000.0, "MegaGPU Pro")
	_add("gpu_16", ComponentType.GPU, "MegaGPU Ultra", 850000, 6200.0, "MegaGPU Ultra")
	_add("gpu_17", ComponentType.GPU, "TitanGPU 1", 1400000, 9500.0, "TitanGPU серия")
	_add("gpu_18", ComponentType.GPU, "TitanGPU 2", 2200000, 14000.0, "TitanGPU 2")
	_add("gpu_19", ComponentType.GPU, "TitanGPU 3", 3500000, 21000.0, "TitanGPU 3")
	_add("gpu_20", ComponentType.GPU, "TitanGPU Ultimate", 6000000, 32000.0, "Абсолютный флагман GPU")

	# ===== ОХЛАЖДЕНИЕ (20) — воздух/вода =====
	_add_cooling("cool_01", "AirCool 80mm", 50, 0.2, CoolingSubtype.AIR, "Маленький кулер 80мм")
	_add_cooling("cool_02", "AirCool 92mm", 90, 0.4, CoolingSubtype.AIR, "Кулер 92мм")
	_add_cooling("cool_03", "AirCool Tower 120", 160, 0.8, CoolingSubtype.AIR, "Башенный кулер 120мм")
	_add_cooling("cool_04", "AirCool Tower Pro", 280, 1.4, CoolingSubtype.AIR, "Башенный Pro")
	_add_cooling("cool_05", "AirCool Dual Tower", 480, 2.2, CoolingSubtype.AIR, "Двойной башенный")
	_add_cooling("cool_06", "AirCool Top-Flow", 800, 3.5, CoolingSubtype.AIR, "Top-Flow охлаждение")
	_add_cooling("cool_07", "AirCool Extreme", 1400, 5.5, CoolingSubtype.AIR, "Экстремальный воздушный")
	_add_cooling("cool_08", "AirCool Titan 140", 2400, 8.5, CoolingSubtype.AIR, "Titan 140мм")
	_add_cooling("cool_09", "AirCool Titan Dual", 4200, 13.0, CoolingSubtype.AIR, "Titan двойной")
	_add_cooling("cool_10", "AirCool Titan MAX", 7000, 20.0, CoolingSubtype.AIR, "Titan максимальный")
	_add_cooling("cool_11", "WaterFlow 120мм", 12000, 30.0, CoolingSubtype.WATER, "СВО 120мм однорадиаторный")
	_add_cooling("cool_12", "WaterFlow 240мм", 20000, 48.0, CoolingSubtype.WATER, "СВО 240мм")
	_add_cooling("cool_13", "WaterFlow 280мм", 33000, 72.0, CoolingSubtype.WATER, "СВО 280мм")
	_add_cooling("cool_14", "WaterFlow 360мм", 55000, 110.0, CoolingSubtype.WATER, "СВО 360мм")
	_add_cooling("cool_15", "WaterFlow 420мм", 90000, 165.0, CoolingSubtype.WATER, "СВО 420мм")
	_add_cooling("cool_16", "WaterFlow Pro 240", 150000, 250.0, CoolingSubtype.WATER, "СВО Pro 240мм")
	_add_cooling("cool_17", "WaterFlow Pro 360", 250000, 380.0, CoolingSubtype.WATER, "СВО Pro 360мм")
	_add_cooling("cool_18", "WaterFlow Elite 360", 420000, 580.0, CoolingSubtype.WATER, "СВО Elite 360мм")
	_add_cooling("cool_19", "WaterFlow Elite 480", 700000, 880.0, CoolingSubtype.WATER, "СВО Elite 480мм")
	_add_cooling("cool_20", "WaterFlow Ultra 480", 1200000, 1300.0, CoolingSubtype.WATER, "СВО Ultra 480мм флагман")

	# ===== БЛОКИ ПИТАНИЯ (20) =====
	_add("psu_01", ComponentType.PSU, "PowerBox 300W", 70, 0.3, "БП 300W базовый")
	_add("psu_02", ComponentType.PSU, "PowerBox 400W", 120, 0.5, "БП 400W")
	_add("psu_03", ComponentType.PSU, "PowerBox 500W", 200, 0.8, "БП 500W стандарт")
	_add("psu_04", ComponentType.PSU, "PowerBox 600W", 320, 1.2, "БП 600W")
	_add("psu_05", ComponentType.PSU, "PowerBox 700W", 520, 1.8, "БП 700W")
	_add("psu_06", ComponentType.PSU, "MegaPower 600W", 850, 2.5, "MegaPower 600W Bronze")
	_add("psu_07", ComponentType.PSU, "MegaPower 750W", 1400, 3.8, "MegaPower 750W Silver")
	_add("psu_08", ComponentType.PSU, "MegaPower 850W", 2300, 5.5, "MegaPower 850W Gold")
	_add("psu_09", ComponentType.PSU, "MegaPower 1000W", 3800, 8.0, "MegaPower 1000W Platinum")
	_add("psu_10", ComponentType.PSU, "MegaPower 1200W", 6500, 12.0, "MegaPower 1200W Titanium")
	_add("psu_11", ComponentType.PSU, "TitanPSU 850W", 11000, 17.0, "TitanPSU 850W")
	_add("psu_12", ComponentType.PSU, "TitanPSU 1000W", 18000, 25.0, "TitanPSU 1000W")
	_add("psu_13", ComponentType.PSU, "TitanPSU 1200W", 30000, 36.0, "TitanPSU 1200W")
	_add("psu_14", ComponentType.PSU, "TitanPSU 1600W", 50000, 52.0, "TitanPSU 1600W")
	_add("psu_15", ComponentType.PSU, "TitanPSU 2000W", 85000, 75.0, "TitanPSU 2000W")
	_add("psu_16", ComponentType.PSU, "UltraPSU 1200W", 140000, 110.0, "UltraPSU 1200W")
	_add("psu_17", ComponentType.PSU, "UltraPSU 1600W", 230000, 160.0, "UltraPSU 1600W")
	_add("psu_18", ComponentType.PSU, "UltraPSU 2000W", 380000, 230.0, "UltraPSU 2000W")
	_add("psu_19", ComponentType.PSU, "UltraPSU 2500W", 620000, 340.0, "UltraPSU 2500W")
	_add("psu_20", ComponentType.PSU, "UltraPSU 3000W", 1000000, 500.0, "УBП 3000W флагман")

	# ===== КОРПУСА (20) =====
	_add("case_01", ComponentType.CASE, "MiniCase ITX", 80, 0.0, "Маленький корпус Mini-ITX")
	_add("case_02", ComponentType.CASE, "MiniCase ITX Pro", 150, 0.0, "Mini-ITX улучшенный")
	_add("case_03", ComponentType.CASE, "SlimTower mATX", 250, 0.0, "Тонкая башня mATX")
	_add("case_04", ComponentType.CASE, "SlimTower mATX Pro", 400, 0.0, "Тонкая башня Pro")
	_add("case_05", ComponentType.CASE, "MidTower ATX", 650, 0.0, "Стандартный MidTower")
	_add("case_06", ComponentType.CASE, "MidTower ATX Pro", 1000, 0.0, "MidTower улучшенный")
	_add("case_07", ComponentType.CASE, "MidTower Glass", 1600, 0.0, "MidTower со стеклянной панелью")
	_add("case_08", ComponentType.CASE, "MidTower RGB", 2500, 0.0, "MidTower с RGB подсветкой")
	_add("case_09", ComponentType.CASE, "FullTower ATX", 4000, 0.0, "Большой FullTower")
	_add("case_10", ComponentType.CASE, "FullTower ATX Pro", 6500, 0.0, "FullTower Pro")
	_add("case_11", ComponentType.CASE, "FullTower E-ATX", 10000, 0.0, "FullTower E-ATX")
	_add("case_12", ComponentType.CASE, "FullTower E-ATX Pro", 16000, 0.0, "FullTower E-ATX Pro")
	_add("case_13", ComponentType.CASE, "TowerMax Glass", 26000, 0.0, "TowerMax со стеклом")
	_add("case_14", ComponentType.CASE, "TowerMax RGB Pro", 42000, 0.0, "TowerMax RGB Pro")
	_add("case_15", ComponentType.CASE, "TowerMax Ultra", 68000, 0.0, "TowerMax Ultra")
	_add("case_16", ComponentType.CASE, "ObsidianCase S", 110000, 0.0, "Obsidian серия S")
	_add("case_17", ComponentType.CASE, "ObsidianCase M", 180000, 0.0, "Obsidian серия M")
	_add("case_18", ComponentType.CASE, "ObsidianCase L", 290000, 0.0, "Obsidian серия L")
	_add("case_19", ComponentType.CASE, "ObsidianCase XL", 480000, 0.0, "Obsidian серия XL")
	_add("case_20", ComponentType.CASE, "ObsidianCase Titan", 800000, 0.0, "Корпус-флагман Titan")

func _add(id: String, type: ComponentType, name: String, price: float, income: float, desc: String) -> void:
	_components[id] = {
		"id": id,
		"type": type,
		"name": name,
		"price": price,
		"income_value": income,
		"description": desc,
		"subtype": -1
	}

func _add_storage(id: String, name: String, price: float, income: float, subtype: StorageSubtype, desc: String) -> void:
	_components[id] = {
		"id": id,
		"type": ComponentType.STORAGE,
		"name": name,
		"price": price,
		"income_value": income,
		"description": desc,
		"subtype": subtype
	}

func _add_cooling(id: String, name: String, price: float, income: float, subtype: CoolingSubtype, desc: String) -> void:
	_components[id] = {
		"id": id,
		"type": ComponentType.COOLING,
		"name": name,
		"price": price,
		"income_value": income,
		"description": desc,
		"subtype": subtype
	}

func get_component(id: String) -> Dictionary:
	return _components.get(id, {})

func get_all_by_type(type: ComponentType) -> Array:
	var result = []
	for comp in _components.values():
		if comp["type"] == type:
			result.append(comp)
	result.sort_custom(func(a, b): return a["price"] < b["price"])
	return result

func get_type_name(type: ComponentType) -> String:
	match type:
		ComponentType.CPU: return "Процессор"
		ComponentType.MOTHERBOARD: return "Материнская плата"
		ComponentType.RAM: return "Оперативная память"
		ComponentType.STORAGE: return "Накопитель"
		ComponentType.GPU: return "Видеокарта"
		ComponentType.COOLING: return "Охлаждение"
		ComponentType.PSU: return "Блок питания"
		ComponentType.CASE: return "Корпус"
	return "Неизвестно"

func get_slot_key(type: ComponentType) -> String:
	match type:
		ComponentType.CPU: return "cpu"
		ComponentType.MOTHERBOARD: return "motherboard"
		ComponentType.RAM: return "ram"
		ComponentType.STORAGE: return "storage"
		ComponentType.GPU: return "gpu"
		ComponentType.COOLING: return "cooling"
		ComponentType.PSU: return "psu"
		ComponentType.CASE: return "case"
	return ""

func is_multi_slot(type: ComponentType) -> bool:
	return type == ComponentType.RAM or type == ComponentType.STORAGE or type == ComponentType.GPU
