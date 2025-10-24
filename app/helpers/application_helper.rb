# frozen_string_literal: true

# ApplicationHelper
module ApplicationHelper
  # OGPタグを生成する
  def ogp_tags(page_title = nil, page_description = nil)
    title = page_title || default_ogp_title
    description = page_description || default_ogp_description
    image_url = default_ogp_image_url

    ogp_meta_tags(title, description, image_url) + twitter_meta_tags(title, description, image_url)
  end

  # ボタンスタイルの統一
  def button_classes(variant: :primary, size: :md, full_width: false)
    base_classes = 'font-medium rounded-lg transition duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2'
    size_classes = size_classes_for(size)
    width_classes = full_width ? 'w-full' : ''
    variant_classes = variant_classes_for(variant)

    "#{base_classes} #{size_classes} #{width_classes} #{variant_classes}".strip
  end

  # 戻るボタンの統一スタイル
  def back_button_link(path, text, options = {})
    default_classes = 'inline-flex items-center text-blue-600 hover:text-blue-800 transition text-sm sm:text-base'
    classes = options[:class] || default_classes

    link_to path, class: classes do
      content_tag(:i, '', class: 'fas fa-arrow-left mr-2') + text
    end
  end

  private

  def default_ogp_title
    'FlapStock - 在庫管理システム'
  end

  def default_ogp_description
    'FlapStockは、効率的な在庫管理を実現するWebアプリケーションです。物品の入出庫管理、在庫状況の把握、発注先管理などの機能を提供します。'
  end

  def default_ogp_image_url
    "#{request.base_url}#{asset_path('ogp/default-ogp-image.png')}"
  end

  def ogp_meta_tags(title, description, image_url)
    content_tag(:meta, nil, property: 'og:title', content: title) +
      content_tag(:meta, nil, property: 'og:description', content: description) +
      content_tag(:meta, nil, property: 'og:image', content: image_url) +
      content_tag(:meta, nil, property: 'og:url', content: request.url) +
      content_tag(:meta, nil, property: 'og:type', content: 'website') +
      content_tag(:meta, nil, property: 'og:site_name', content: 'FlapStock')
  end

  def twitter_meta_tags(title, description, image_url)
    content_tag(:meta, nil, name: 'twitter:card', content: 'summary_large_image') +
      content_tag(:meta, nil, name: 'twitter:title', content: title) +
      content_tag(:meta, nil, name: 'twitter:description', content: description) +
      content_tag(:meta, nil, name: 'twitter:image', content: image_url)
  end

  def size_classes_for(size)
    case size
    when :sm
      'px-3 py-1.5 text-sm'
    when :lg
      'px-6 py-3 text-base'
    else
      'px-4 py-2 text-sm'
    end
  end

  def variant_classes_for(variant)
    case variant
    when :secondary
      'bg-gray-400 hover:bg-gray-500 text-white focus:ring-gray-400'
    when :success
      'bg-green-400 hover:bg-green-500 text-white focus:ring-green-400'
    when :danger
      'bg-red-400 hover:bg-red-500 text-white focus:ring-red-400'
    when :warning
      'bg-yellow-400 hover:bg-yellow-500 text-white focus:ring-yellow-400'
    when :info
      'bg-indigo-400 hover:bg-indigo-500 text-white focus:ring-indigo-400'
    when :purple
      'bg-purple-400 hover:bg-purple-500 text-white focus:ring-purple-400'
    else
      'bg-blue-400 hover:bg-blue-500 text-white focus:ring-blue-400'
    end
  end
end
