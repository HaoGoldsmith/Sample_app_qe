class Micropost < ApplicationRecord
  belongs_to :user #добавлена при помощи user:references в генерации модели в рельсах
  has_one_attached :image
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true  #проверяет наличие юзер ид
  validates :content, presence: true, length: { maximum: 140 }  #проверяет, что контент есть и он меньше 140 символов
  validates :image,
            content_type: { in: %w[image/jpeg image/gif image/png],
                            message: "must be a valid image format" },
            size:
              { less_than: 5.megabytes,
                message:
                  "should be less than 5MB" }


  # Returns a resized image for display.
  def display_image
    image.variant(resize_to_limit: [500, 500])
  end
end
