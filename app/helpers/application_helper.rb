# frozen_string_literal: true

# ApplicationHelper
module ApplicationHelper
  # ボタンスタイルの統一
  def button_classes(variant: :primary, size: :md, full_width: false)
    base_classes = 'font-medium rounded-lg transition duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2'
    size_classes = size_classes_for(size)
    width_classes = full_width ? 'w-full' : ''
    variant_classes = variant_classes_for(variant)

    "#{base_classes} #{size_classes} #{width_classes} #{variant_classes}".strip
  end

  private

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
