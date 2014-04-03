class CreateUsers < Model::Migration
  def self.change
    create_table 'users' do |table|
      table.string :login, constraints: 'NOT NULL'
      table.string :password
    end
  end
end
