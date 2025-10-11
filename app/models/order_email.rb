# frozen_string_literal: true

# 発注メールを生成するためのPlain Old Ruby Object
# データベースには保存せず、メモリ上で動作
class OrderEmail
  include ActiveModel::Model
  include ActiveModel::Attributes

  # 属性定義
  attribute :supplier        # 発注先
  attribute :user            # 発注者（ログインユーザー）
  attribute :items, default: -> { [] }       # 物品の配列（フォーム表示用）
  attribute :items_data, default: -> { [] }  # 物品データ（数量・納期含む）

  # バリデーション
  validates :supplier, presence: true
  validates :user, presence: true
  validate :items_data_present
  validate :items_data_valid

  # メール件名を生成
  def subject
    "【発注依頼】#{user.company.name}より"
  end

  # メール本文を生成
  def body
    <<~EMAIL
      #{supplier.name}
      #{contact_person_line}

      いつもお世話になっております。
      #{user.company.name}の#{user.name}です。

      下記の商品について発注をお願いいたします。

      ━━━━━━━━━━━━━━━━━━━━━━
      ■発注内容
      ━━━━━━━━━━━━━━━━━━━━━━

      #{items_section}

      ━━━━━━━━━━━━━━━━━━━━━━

      以上、よろしくお願いいたします。

      #{signature}
    EMAIL
  end

  # mailto:リンクを生成
  def mailto_link
    "mailto:#{to}?subject=#{encoded_subject}&body=#{encoded_body}"
  end

  # Gmail専用のリンクを生成
  def gmail_link
    base_url = 'https://mail.google.com/mail/?view=cm'
    params = "to=#{ERB::Util.url_encode(to)}&su=#{encoded_subject}&body=#{encoded_body}"
    "#{base_url}&#{params}"
  end

  # 送信先メールアドレス
  def to
    supplier.email
  end

  # 送信先メールアドレスが設定されているか
  def email_configured?
    supplier.email.present?
  end

  # フォーム表示用：itemsとitems_dataを統合したデータを返す
  def form_items
    return items_data if items_data.present? && items_data.any?

    # items_dataが空の場合は、itemsから生成
    items.map { |item| { item: item, quantity: nil, delivery_date: nil, notes: nil } }
  end

  private

  # 物品データが存在するかチェック
  def items_data_present
    return if items_data.present? && items_data.any?

    errors.add(:items_data, 'が選択されていません')
  end

  # 物品データの各項目が有効かチェック
  def items_data_valid
    return unless items_data.present?

    items_data.each_with_index do |item_data, index|
      item_name = item_data[:item]&.name || "物品#{index + 1}"

      # 数量チェック
      if item_data[:quantity].blank?
        errors.add(:base, "#{item_name}の発注数量を入力してください")
      elsif item_data[:quantity].to_i <= 0
        errors.add(:base, "#{item_name}の発注数量は1以上で入力してください")
      end
    end
  end

  # 担当者名の行を生成
  def contact_person_line
    if supplier.contact_person.present?
      "#{supplier.contact_person}様"
    else
      'ご担当者様'
    end
  end

  # 物品セクションの本文
  def items_section
    items_data.map.with_index(1) do |item_data, index|
      item = item_data[:item]
      quantity = item_data[:quantity]
      delivery_date = item_data[:delivery_date]
      notes = item_data[:notes]

      section = if items_data.size > 1
                  "【商品#{index}】\n"
                else
                  ''
                end
      section += "品名: #{item.name}\n"
      section += "型式: #{item.sku}\n" if item.sku.present?
      section += "発注数量: #{quantity}個\n" if quantity.present?
      section += "希望納期: #{delivery_date}\n" if delivery_date.present?
      section += "備考: #{notes}\n" if notes.present?
      section
    end.join("\n")
  end

  # 署名
  def signature
    <<~SIGNATURE.strip
      #{user.name}
      #{user.company.name}
      Email: #{user.email}
    SIGNATURE
  end

  # URLエンコード
  def encoded_subject
    ERB::Util.url_encode(subject)
  end

  def encoded_body
    ERB::Util.url_encode(body)
  end
end
