# frozen_string_literal: true

# GuideController
class GuideController < ApplicationController
  before_action :authenticate_user!

  def index; end
  def getting_started; end
  def master_data; end
  def items; end
  def stock; end
  def dashboard; end
end
