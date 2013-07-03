class AlterUsers < ActiveRecord::Migration
  def up
    add_column("users","token",:string)
    add_column("users","activated",:boolean)
  end

  def down
    remove_column("users","token")
    remove_column("users","activated")
  end
end
