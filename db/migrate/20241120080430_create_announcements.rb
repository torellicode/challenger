class CreateAnnouncements < ActiveRecord::Migration[7.1]
  def change
    create_table :announcements do |t|
      t.string :title
      t.text :content
      t.string :status, default: 'draft'
      t.datetime :published_at
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
