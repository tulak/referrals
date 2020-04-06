class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.belongs_to :user, index: true
      t.decimal :amount, precision: 8, scale: 2
      t.string :code

      t.timestamps
    end
  end
end
