class AddEncryptedPasswordToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :encrypted_password, :string, null: false, default: "" unless column_exists?(:users, :encrypted_password)
  end
end
