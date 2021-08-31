require 'ruby-prof'
namespace :strategy do
  desc "profile"
  task :profile => :environment do
    name1 = 'Testacornibus'
    name2 = 'Scorpius Rex Gen 3'
    @stats = HashWithIndifferentAccess.new({name1 => 0, name2 => 0, 'draw' => 0, "#{name1} swapped out" => 0, "#{name2} swapped out" => 0})
    @logs = []

    MinMaxStrategy.reset
    EventSink.reset
    d1 = Dinosaur.find_by_name name1
    d1.strategy = MinMaxStrategy
    d1.reset_attributes!
    @d1 = d1 #Utilities.deep_clone2(d1)
    d2 = Dinosaur.find_by_name name2
    d2.reset_attributes!
    d2.strategy = TQStrategy
    @d2 = d2 #Utilities.deep_clone2(d2)
    @d1.color = '#03a9f4'
    @d2.color = '#03f4a9'
    profile = RubyProf::Profile.new
    profile.exclude_common_methods!
    profile.start
      result = Match.new(@d1, @d2).execute
    profile_result = profile.stop
    printer = RubyProf::FlatPrinter.new(profile_result)
    printer.print(STDOUT)
  end
end

namespace :simulation do
  desc "profile"
  task :profile => :environment do
    d1 = Dinosaur.find_by_name('Dracoceratops')
    d2 = Dinosaur.find_by_name('Erlikospyx')
    d1.reset_attributes!
    d2.reset_attributes!
    if d1.name == d2.name
      d1.name += '-1'
      d2.name += '-2'
    end
    d1.color = '#81d4fa'
    d2.color = '#b2dfdb'
    @simulation = Simulation.new(d1, d2)
    profile = RubyProf::Profile.new
    profile.exclude_common_methods!
    profile.start
    @result = @simulation.execute
    profile_result = profile.stop
    printer = RubyProf::FlatPrinter.new(profile_result)
    printer.print(STDOUT)
  end
end
