#--
# (The MIT License + Free Software Foundation Advertising Prohibition)
#
# Copyright (c) 2007 Gregory N. Houston
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
# Except as contained in this notice, the name(s) of the above copyright holders
# shall not be used in advertising or otherwise to promote the sale, use or other
# dealings in this Software without prior written authorization.
#++

require 'rubygems'
require 'rubygems/gem_runner'
require 'rcov/rcovtask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'lib/tofuhash'

html_dir = 'doc'
rdoc_title = 'TofuHash (rdoc)'
rdoc_main = 'readme.txt'
rubyforge_user     = 'ghouston'
rubyforge_project = 'tofuhash'
rubyforge_path    = "/var/www/gforge-projects/#{rubyforge_project}/"

Rake::TestTask.new() do |t|
  files = FileList['test/test*.rb']
  t.test_files = files
end

Rake::RDocTask.new( :rdoc_work ) do |t|
  t.rdoc_dir = html_dir
  t.rdoc_files.add( rdoc_main, './lib', './test' )
  t.main = rdoc_main
  t.title = rdoc_title
end

#~ directory 'doc/doc_resources'
#~ task :rdoc_resources => "doc/doc_resources" do
  #~ copy Dir["doc_resources/*.png"], 'doc/doc_resources' 
#~ end
task :rdoc_resources
task :rdoc => [:rdoc_work, :rdoc_resources]
task :rerdoc => [:rerdoc_work, :rdoc_resources] 
task :clobber_rdoc => :clobber_rdoc_work

Rcov::RcovTask.new( :rcov ) do |t|
  files = FileList['test/test*.rb']
  #puts files.inspect  
  t.test_files = files
  t.output_dir = "#{html_dir}/rcov"
  # t.verbose = true     # uncomment to see the executed command
  ## get a text report on stdout when rake is run:
  #t.rcov_opts << "--text-report"  
  ## only report files under 80% coverage
  #t.rcov_opts << "--threshold 80"
end

desc "creates rdoc and rcov documents"
task :doc => [:rdoc, :rcov]

desc 'Upload documentation to RubyForge.'
task 'upload-docs' => ['rdoc'] do
  sh "scp -r #{html_dir}/* #{rubyforge_user}@rubyforge.org:#{rubyforge_path}"
end

gem_spec = Gem::Specification.new do |s|
  s.name = rubyforge_project
  s.summary = 'TofuHash, a Hash that is case-insensitive and treats symbols and strings as equals (customizable); always preserving the original key.'
  s.description = 'TofuHash, a Hash that is case-insensitive and treats symbols and strings as equals (customizable); always preserving the original key.'
  s.homepage = "http://#{rubyforge_project}.rubyforge.org/"
  s.version = TofuHash::Version::STRING
  s.author = 'Gregory N. Houston'
  s.rubyforge_project = rubyforge_project
  s.platform = Gem::Platform::RUBY
  
  s.has_rdoc = true
  s.rdoc_options << '--main' << rdoc_main << '--title' << rdoc_title
  
  s.test_files = FileList['test/**/*']
  s.extra_rdoc_files = FileList[rdoc_main]
  s.files = FileList['lib/**/*.*'] + s.test_files + s.extra_rdoc_files + FileList['doc/doc_resources/*']
  #s.executables
  
  s.require_path = 'lib'
  s.autorequire = rubyforge_project
end  


Rake::GemPackageTask.new(gem_spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end


desc 'Package into a gem and Install it locally'
task 'packup' => ['repackage'] do
  gem_runner = Gem::GemRunner.new
  gem_runner.run(['uninstall','tofuhash'])
  gem_runner.run(['install', 'pkg/tofuhash'])
end



task :clean => [:clobber_rdoc, :clobber_rcov] do
  # TODO clean other stuff
end


task :default => [] do |t|
  puts 'help'
end


if $0 == __FILE__
  Rake::Task[:default].invoke
end
