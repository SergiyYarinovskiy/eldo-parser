class CreateAttributes < ActiveRecord::Migration
  def change
    create_table :attributes do |t|
      t.belongs_to :item_phone
      t.string :group_name
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
