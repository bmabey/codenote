class InitialModels < ActiveRecord::Migration

  def self.up
    create_table :presentations do |t|
      t.string :presenter, :title
      t.boolean :current
    end

    create_table :slides do |t|
      t.string  :source, :classes, :dynamic_slide_class, :dynamic_args
      t.integer :number, :presentation_id
      t.boolean :viewable_by_audience, :dynamically_updated, :default => false
      t.datetime :dynamically_updated_at, :default => nil
    end
  end

  def self.down
    drop_table :slides
    drop_table :presentations
  end


end
