def catches_exception(&block)
  begin
    block.call
  rescue ActiveRecord::StatementInvalid ; end
end

module DatabaseHelper
  def self.connect
    db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

    ActiveRecord::Base.establish_connection(
      :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      :host     => db.host,
      :port     => db.port,
      :username => db.user,
      :password => db.password,
      :database => db.path[1..-1],
      :encoding => 'utf8'
    )
  end

  def self.migrate!
    ActiveRecord::Schema.define do
      catches_exception do
        create_table :topics do |table|
          table.column :id, :integer
          table.column :created_at, :datetime, :null => false, :default => Time.now
          table.column :author, :string
          table.column :description, :string
        end
      end

      catches_exception do
        create_table :links do |table|
          table.column :id, :integer
          table.column :created_at, :datetime, :null => false, :default => Time.now
          table.column :author, :string
          table.column :url, :string
          table.column :showlink, :boolean
          table.column :description, :string
          table.column :authname, :string
        end
      end

      catches_exception do
        create_table :ideas do |table|
          table.column :id, :integer
          table.column :created_at, :datetime, :nill => false, :default => Time.now
          table.column :author, :string
          table.column :description, :string
        end
      end

      catches_exception do
        create_table :votes do |t|
          t.column :topic_id, :integer
          t.column :whom, :string
        end
      end

      catches_exception do
        create_table :tutorials do |table|
          table.column :id, :integer
          table.column :created_at, :datetime, :null => false, :default => Time.now
          table.column :author, :string
          table.column :description, :string
        end
      end
    end
  end
end

Dir.glob(File.dirname(__FILE__) + '/models/*.rb').each do |file|
  filename = File.basename(file).sub('.rb', '')
  require "./models/#{filename}"
end
