class CreateVideos < Model::Migration
  def self.change
    create_table 'videos' do |table|
      table.integer :user_id, references: :users
      table.string :title, constraints: 'NOT NULL'
      table.string :filename
    end
  end
end
