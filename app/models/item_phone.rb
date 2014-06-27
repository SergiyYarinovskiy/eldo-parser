class ItemPhone < ActiveRecord::Base
  has_many :phone_attributes, class_name: 'Attribute'
  has_many :photos, dependent: :destroy
  accepts_nested_attributes_for :photos, allow_destroy: true
  belongs_to :phone
end
