def cool(req_file, source)
  source_dir = File.dirname(source)
  req_dir = req_file.split('/')[0]  
  req_file = req_file.split('/')[1]  
  folders = source_dir.split req_dir
  path_nav = folders[1].split('/').inject([]){|res, f| res << '..' }.join('/')     
  puts File.expand_path(source_dir + "#{path_nav}/#{req_file}")  
end

cool 'spec/spec_helper', __FILE__

