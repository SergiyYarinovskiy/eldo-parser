class Photo < ActiveRecord::Base
  belongs_to :item_phone

  has_attached_file :photo_img, :styles => { :thumb => "100x100>" }
  validates_attachment :photo_img, presence: true,
                       content_type: { content_type: /\Aimage\/.*\Z/ },
                       size: { in: 0..10.megabytes }
end
