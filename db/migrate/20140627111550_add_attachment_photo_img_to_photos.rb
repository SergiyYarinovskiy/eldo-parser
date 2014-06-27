class AddAttachmentPhotoImgToPhotos < ActiveRecord::Migration
  def self.up
    change_table :photos do |t|
      t.attachment :photo_img
    end
  end

  def self.down
    drop_attached_file :photos, :photo_img
  end
end
