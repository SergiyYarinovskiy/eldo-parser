require './lib/tasks/parser.rb'
namespace :parser do

  task :do_it => :environment do
    parse_method
  end

end