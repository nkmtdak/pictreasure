class RemoveTitleFromPhotos < ActiveRecord::Migration[7.0]
  def change
    remove_column :photos, :title, :string
  end
end
