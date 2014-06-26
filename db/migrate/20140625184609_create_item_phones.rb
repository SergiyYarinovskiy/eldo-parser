class CreateItemPhones < ActiveRecord::Migration
  def change
    create_table :item_phones do |t|
      t.belongs_to :phone
      t.string :code
      t.string :name
      t.text :description
      t.float :price

      t.timestamps
    end
  end
end
