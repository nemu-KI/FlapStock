# frozen_string_literal: true

# HelpController
class HelpController < ApplicationController
  before_action :authenticate_user!

  def index; end
  def faq; end
  def troubleshooting; end
  def contact; end
end
