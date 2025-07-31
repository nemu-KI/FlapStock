# 開発環境用seedデータ
puts "🌱 開発環境用seedデータを作成中..."

# 企業データ（既存のものを使用または新規作成）
company = Company.find_or_create_by!(name: "FlapStock開発用") do |c|
  c.email = "info@flapstock-dev.com"
  c.active = true
end

puts "✅ 企業データを作成しました: #{company.name}"

# カテゴリデータ
categories = [
  { name: "文具・オフィス用品", description: "事務作業に必要な文具類" },
  { name: "電子機器・IT機器", description: "パソコン周辺機器やIT機器" },
  { name: "消耗品・清掃用品", description: "日常的な消耗品と清掃用品" },
  { name: "工具・設備機器", description: "作業用の工具や設備機器" },
  { name: "安全用品・防護具", description: "安全作業に必要な防護具" },
  { name: "包装・梱包用品", description: "商品の包装・梱包に使用" },
  { name: "医療・衛生用品", description: "医療・衛生関連の用品" },
  { name: "食品・飲料", description: "業務用の食品・飲料" }
]

categories.each do |category_data|
  category = company.categories.find_or_create_by!(name: category_data[:name]) do |c|
    c.description = category_data[:description]
  end
  puts "✅ カテゴリを作成しました: #{category.name}"
end

# 保管場所データ
locations = [
  { name: "メイン倉庫", description: "主要な在庫保管場所" },
  { name: "サブ倉庫", description: "補助的な在庫保管場所" },
  { name: "事務所", description: "事務作業エリア" },
  { name: "会議室", description: "会議・打ち合わせ用" },
  { name: "作業場", description: "製造・作業エリア" },
  { name: "冷蔵庫", description: "食品・飲料の保管" },
  { name: "危険物保管庫", description: "危険物の専用保管場所" }
]

locations.each do |location_data|
  location = company.locations.find_or_create_by!(name: location_data[:name]) do |l|
    l.description = location_data[:description]
  end
  puts "✅ 保管場所を作成しました: #{location.name}"
end

# 発注先データ
suppliers = [
  { name: "文具専門店", email: "info@bunbou.com", phone: "03-1234-5678", contact_person: "田中太郎", address: "東京都渋谷区1-1-1" },
  { name: "電器店", email: "info@denki.com", phone: "03-2345-6789", contact_person: "佐藤花子", address: "東京都新宿区2-2-2" },
  { name: "工具店", email: "info@kogu.com", phone: "03-3456-7890", contact_person: "鈴木一郎", address: "東京都品川区3-3-3" },
  { name: "清掃用品店", email: "info@seisou.com", phone: "03-4567-8901", contact_person: "高橋美咲", address: "東京都目黒区4-4-4" },
  { name: "安全用品店", email: "info@anzen.com", phone: "03-5678-9012", contact_person: "伊藤健太", address: "東京都世田谷区5-5-5" },
  { name: "包装材料店", email: "info@hoso.com", phone: "03-6789-0123", contact_person: "渡辺恵子", address: "東京都中野区6-6-6" },
  { name: "医療用品店", email: "info@iryou.com", phone: "03-7890-1234", contact_person: "山田次郎", address: "東京都杉並区7-7-7" },
  { name: "食品卸売店", email: "info@shokuhin.com", phone: "03-8901-2345", contact_person: "小林麻衣", address: "東京都豊島区8-8-8" }
]

suppliers.each do |supplier_data|
  supplier = company.suppliers.find_or_create_by!(name: supplier_data[:name]) do |s|
    s.email = supplier_data[:email]
    s.phone = supplier_data[:phone]
    s.contact_person = supplier_data[:contact_person]
    s.address = supplier_data[:address]
  end
  puts "✅ 発注先を作成しました: #{supplier.name}"
end

puts "🎉 基本データの作成が完了しました！"
