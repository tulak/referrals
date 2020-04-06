class AddReferrerToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :referrer, index: true
  end
end
