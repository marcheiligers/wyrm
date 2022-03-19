require 'filewatcher'
require 'FileUtils'

UIEX_BASE_PATH = File.expand_path('../../uiex/lib/')
WYRM_BASE_PATH = File.expand_path('../../wyrm/app/lib/uiex/')

FileUtils.rm_rf(WYRM_BASE_PATH) rescue nil
FileUtils.cp_r(UIEX_BASE_PATH, WYRM_BASE_PATH)

Filewatcher.new('../../uiex/lib/**/*.rb').watch do |changes|
  puts changes.inspect
  puts '----'
  changes.each do |file, event|
    file_relative_path = file.delete_prefix(UIEX_BASE_PATH)
    case event
    when :created, :updated
      FileUtils.cp_r(file, File.join(WYRM_BASE_PATH, file_relative_path))
    when :deleted
      FileUtils.rm(File.join(WYRM_BASE_PATH, file_relative_path))
    else
      puts 'Dunno what to do with this'
    end
  rescue => e
    puts "Ugh, that failed: #{e.message}"
  end
end