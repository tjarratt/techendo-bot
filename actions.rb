Dir.glob(File.dirname(__FILE__) + '/actions/*.rb').each do |file|
  require './actions/' + File.basename(file).split('.rb').first
end
