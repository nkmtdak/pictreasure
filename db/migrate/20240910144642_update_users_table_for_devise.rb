class UpdateUsersTableForDevise < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:users, :encrypted_password)
      # password_digest カラムが存在する場合のみ変更を行う
      if column_exists?(:users, :password_digest)
        rename_column :users, :password_digest, :encrypted_password
      else
        add_column :users, :encrypted_password, :string, null: false, default: ""
      end
    end

    # encrypted_password のデフォルト値と null 制約を設定
    change_column_default :users, :encrypted_password, "" if column_exists?(:users, :encrypted_password)
    change_column_null :users, :encrypted_password, false if column_exists?(:users, :encrypted_password)

    # email のデフォルト値を設定
    change_column_default :users, :email, "" if column_exists?(:users, :email)

    # username にユニークインデックスを追加
    add_index :users, :username, unique: true, if_not_exists: true if column_exists?(:users, :username)
  end

  def down
    if column_exists?(:users, :encrypted_password)
      rename_column :users, :encrypted_password, :password_digest
      change_column_default :users, :password_digest, nil
      change_column_null :users, :password_digest, true
    end

    change_column_default :users, :email, nil if column_exists?(:users, :email)
    remove_index :users, :username, if_exists: true if column_exists?(:users, :username)
  end
end