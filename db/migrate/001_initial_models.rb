class InitialModels < ActiveRecord::Migration

  def self.up
    create_table :presentations do |t|
      t.string :presenter, :title
      t.boolean :current
    end

    create_table :slides do |t|
      t.string  :source
      t.string  :classes
      t.integer :number, :presentation_id
      t.boolean :viewable_by_audience, :default => false
    end
  end

  def self.down
    drop_table :slides
    drop_table :presentations
  end


end
