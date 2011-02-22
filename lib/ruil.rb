Dir[File.dirname(File.expand_path(__FILE__)) + '/**/*.rb'].each do |f|
  require f
end
