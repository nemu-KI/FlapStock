# frozen_string_literal: true

# お問い合わせフォームのコントローラー
class ContactsController < ApplicationController
  before_action :authenticate_user!

  def new
    @contact = Contact.new
    @contact.user = current_user
    @contact.company = current_user.company
    @contact.name = current_user.name
    @contact.email = current_user.email
  end

  def create
    @contact = Contact.new(contact_params)
    @contact.user = current_user
    @contact.company = current_user.company

    if @contact.save
      redirect_to contact_confirm_path(id: @contact.id)
    else
      render :new
    end
  end

  def confirm
    @contact = Contact.find(params[:id])
  end

  def complete
    @contact = Contact.find(params[:id])

    # POSTリクエストの場合のみメール送信
    if request.post?
      ContactMailer.notify_admin(@contact).deliver_now
      redirect_to contact_complete_path(id: @contact.id)
    else
      # GETリクエストの場合は完了画面を表示
      render :complete
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :category, :priority, :subject, :message)
  end
end
