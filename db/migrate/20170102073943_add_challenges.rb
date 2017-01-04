class AddChallenges < ActiveRecord::Migration
  def change
    create_table :lets_encrypt_plugin_challenges do |t|
      t.string :token
      t.string :content

      t.timestamps
    end

    add_index :lets_encrypt_plugin_challenges, :token
  end
end
