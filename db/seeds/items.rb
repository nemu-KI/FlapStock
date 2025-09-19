# 物品データ（30件程度）
puts "📦 物品データを作成中..."

# 企業とマスターデータを取得
company = Company.find_by(name: "FlapStock開発用")
categories = company.categories
locations = company.locations
suppliers = company.suppliers

# 物品データ（30件）
items_data = [
  # 文具・オフィス用品
  { name: "A4コピー用紙", sku: "PAPER-A4-500", stock_quantity: 50, unit: "箱", description: "500枚入り、白色、業務用", min_stock: 10, max_stock: 100, category: "文具・オフィス用品", location: "メイン倉庫", supplier: "文具専門店" },
  { name: "ボールペン", sku: "PEN-BLUE-12", stock_quantity: 120, unit: "本", description: "青色、12本セット", min_stock: 20, max_stock: 200, category: "文具・オフィス用品", location: "事務所", supplier: "文具専門店" },
  { name: "ノート", sku: "NOTE-A5-100", stock_quantity: 30, unit: "冊", description: "A5サイズ、100ページ", min_stock: 5, max_stock: 50, category: "文具・オフィス用品", location: "事務所", supplier: "文具専門店" },
  { name: "ホッチキス", sku: "STAPLER-24", stock_quantity: 15, unit: "個", description: "24枚留め、黒色", min_stock: 3, max_stock: 30, category: "文具・オフィス用品", location: "事務所", supplier: "文具専門店" },

  # 電子機器・IT機器
  { name: "USBメモリ 32GB", sku: "USB-32GB-PRO", stock_quantity: 15, unit: "個", description: "高速転送対応、防水・衝撃耐性", min_stock: 5, max_stock: 30, category: "電子機器・IT機器", location: "メイン倉庫", supplier: "電器店" },
  { name: "マウス", sku: "MOUSE-WIRELESS", stock_quantity: 25, unit: "個", description: "ワイヤレス、光学式", min_stock: 5, max_stock: 50, category: "電子機器・IT機器", location: "メイン倉庫", supplier: "電器店" },
  { name: "キーボード", sku: "KB-ERGO", stock_quantity: 8, unit: "個", description: "エルゴノミクス、静音", min_stock: 2, max_stock: 20, category: "電子機器・IT機器", location: "メイン倉庫", supplier: "電器店" },

  # 消耗品・清掃用品
  { name: "除菌スプレー", sku: "CLEAN-SPRAY-500", stock_quantity: 8, unit: "本", description: "アルコール配合、無香料、500ml", min_stock: 3, max_stock: 20, category: "消耗品・清掃用品", location: "事務所", supplier: "清掃用品店" },
  { name: "モップ", sku: "MOP-FLOOR", stock_quantity: 5, unit: "本", description: "フロア用、洗濯可能", min_stock: 2, max_stock: 10, category: "消耗品・清掃用品", location: "サブ倉庫", supplier: "清掃用品店" },
  { name: "洗剤", sku: "DETERGENT-1L", stock_quantity: 12, unit: "本", description: "中性洗剤、1L", min_stock: 3, max_stock: 25, category: "消耗品・清掃用品", location: "サブ倉庫", supplier: "清掃用品店" },
  { name: "ゴミ袋", sku: "BAG-45L", stock_quantity: 100, unit: "枚", description: "45L、黒色、100枚入り", min_stock: 20, max_stock: 200, category: "消耗品・清掃用品", location: "サブ倉庫", supplier: "清掃用品店" },

  # 工具・設備機器
  { name: "ドライバーセット", sku: "DRIVER-SET", stock_quantity: 10, unit: "セット", description: "十字・一字、6本セット", min_stock: 2, max_stock: 20, category: "工具・設備機器", location: "作業場", supplier: "工具店" },
  { name: "ペンチ", sku: "PLIERS-200", stock_quantity: 8, unit: "本", description: "200mm、万能ペンチ", min_stock: 2, max_stock: 15, category: "工具・設備機器", location: "作業場", supplier: "工具店" },
  { name: "ハンマー", sku: "HAMMER-500", stock_quantity: 6, unit: "本", description: "500g、木工用", min_stock: 1, max_stock: 10, category: "工具・設備機器", location: "作業場", supplier: "工具店" },
  { name: "ベアリング", sku: "BEAR-400", stock_quantity: 50, unit: "個", description: "400番、鋼製", min_stock: 10, max_stock: 100, category: "工具・設備機器", location: "メイン倉庫", supplier: "工具店" },

  # 安全用品・防護具
  { name: "安全靴", sku: "SAFETY-SHOE-26", stock_quantity: 20, unit: "足", description: "26cm、スチールトウ", min_stock: 5, max_stock: 40, category: "安全用品・防護具", location: "メイン倉庫", supplier: "安全用品店" },
  { name: "安全帽", sku: "HELMET-YELLOW", stock_quantity: 15, unit: "個", description: "黄色、ABS製", min_stock: 3, max_stock: 30, category: "安全用品・防護具", location: "メイン倉庫", supplier: "安全用品店" },
  { name: "作業用手袋", sku: "GLOVE-L", stock_quantity: 100, unit: "双", description: "Lサイズ、革製", min_stock: 20, max_stock: 200, category: "安全用品・防護具", location: "メイン倉庫", supplier: "安全用品店" },
  { name: "防塵マスク", sku: "MASK-N95", stock_quantity: 200, unit: "枚", description: "N95規格、50枚入り", min_stock: 50, max_stock: 500, category: "安全用品・防護具", location: "メイン倉庫", supplier: "安全用品店" },

  # 包装・梱包用品
  { name: "段ボール箱", sku: "BOX-A4", stock_quantity: 80, unit: "個", description: "A4サイズ、5個入り", min_stock: 20, max_stock: 150, category: "包装・梱包用品", location: "メイン倉庫", supplier: "包装材料店" },
  { name: "ガムテープ", sku: "TAPE-50M", stock_quantity: 40, unit: "巻", description: "50m、透明", min_stock: 10, max_stock: 80, category: "包装・梱包用品", location: "メイン倉庫", supplier: "包装材料店" },
  { name: "プチプチ", sku: "BUBBLE-1M", stock_quantity: 25, unit: "巻", description: "1m幅、10m巻", min_stock: 5, max_stock: 50, category: "包装・梱包用品", location: "メイン倉庫", supplier: "包装材料店" },
  { name: "結束バンド", sku: "TIE-200MM", stock_quantity: 1000, unit: "本", description: "200mm、100本入り", min_stock: 200, max_stock: 2000, category: "包装・梱包用品", location: "メイン倉庫", supplier: "包装材料店" },

  # 医療・衛生用品
  { name: "救急箱", sku: "FIRST-AID", stock_quantity: 5, unit: "個", description: "標準セット、壁掛け式", min_stock: 1, max_stock: 10, category: "医療・衛生用品", location: "事務所", supplier: "医療用品店" },
  { name: "絆創膏", sku: "BANDAGE-100", stock_quantity: 50, unit: "枚", description: "100枚入り、防水", min_stock: 10, max_stock: 100, category: "医療・衛生用品", location: "事務所", supplier: "医療用品店" },
  { name: "消毒液", sku: "DISINFECT-500", stock_quantity: 8, unit: "本", description: "500ml、アルコール系", min_stock: 2, max_stock: 20, category: "医療・衛生用品", location: "事務所", supplier: "医療用品店" },
  { name: "マスク", sku: "MASK-50", stock_quantity: 100, unit: "枚", description: "不織布、50枚入り", min_stock: 20, max_stock: 200, category: "医療・衛生用品", location: "事務所", supplier: "医療用品店" },

  # 食品・飲料
  { name: "コーヒー豆", sku: "COFFEE-1KG", stock_quantity: 10, unit: "kg", description: "1kg、中煎り", min_stock: 2, max_stock: 20, category: "食品・飲料", location: "冷蔵庫", supplier: "食品卸売店" },
  { name: "お茶", sku: "TEA-100G", stock_quantity: 20, unit: "g", description: "100g、緑茶", min_stock: 5, max_stock: 50, category: "食品・飲料", location: "冷蔵庫", supplier: "食品卸売店" },
  { name: "砂糖", sku: "SUGAR-1KG", stock_quantity: 8, unit: "kg", description: "1kg、上白糖", min_stock: 2, max_stock: 15, category: "食品・飲料", location: "冷蔵庫", supplier: "食品卸売店" },
  { name: "ミルク", sku: "MILK-1L", stock_quantity: 12, unit: "L", description: "1L、牛乳", min_stock: 3, max_stock: 25, category: "食品・飲料", location: "冷蔵庫", supplier: "食品卸売店" }
]

# 物品データを作成
items_data.each do |item_data|
  category = categories.find { |c| c.name == item_data[:category] }
  location = locations.find { |l| l.name == item_data[:location] }
  supplier = suppliers.find { |s| s.name == item_data[:supplier] }

  item = company.items.find_or_create_by!(name: item_data[:name]) do |i|
    i.sku = item_data[:sku]
    i.stock_quantity = item_data[:stock_quantity]
    i.unit = item_data[:unit]
    i.description = item_data[:description]
    i.min_stock = item_data[:min_stock]
    i.max_stock = item_data[:max_stock]
    i.category = category
    i.location = location
    i.supplier = supplier
  end

  puts "✅ 物品を作成しました: #{item.name} (#{item.stock_quantity}#{item.unit})"
end

puts "🎉 物品データの作成が完了しました！（#{items_data.count}件）"
