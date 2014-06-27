class ItemPhonesController < ApplicationController

  def index
    @item_phones = ItemPhone.where(phone_id: phone_params[:phone_id])
    @phone = Phone.find(phone_params[:phone_id])
  end

  def show
    @item_phone = ItemPhone.find(params[:id])
    @attributes = @item_phone.phone_attributes.group_by{ |attribute| attribute.group_name }
  end

private
  def phone_params
    params.require(:phone).permit(:phone_id)
  end

end
