class ItemPhone < ActiveRecord::Base
  has_many :phone_attributes, class_name: 'Attribute'
  belongs_to :phone
end
