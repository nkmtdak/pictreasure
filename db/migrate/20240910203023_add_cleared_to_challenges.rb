class AddClearedToChallenges < ActiveRecord::Migration[7.0]
  def change
    add_column :challenges, :cleared, :boolean, default: false
  end
end
