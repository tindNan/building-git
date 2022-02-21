require 'fileutils'
require 'pathname'
require_relative './workspace'
require_relative './database'

command = ARGV.shift

case command
when 'init'
  path = ARGV.fetch(0, Dir.getwd)

  root_path = Pathname.new(File.expand_path(path))
  git_path = root_path.join('.git')

  ['objects', 'ref'].each do |dir|
    begin
      FileUtils.mkdir_p(git_path.join(dir))
    rescue Errno::EACCES => err
      $stderr.puts "fatal: #{err.message}"
    end
  end

  puts "Initialized empty jit repository in #{git_path}"
  exit 0
when 'commit'
  root_path = Pathname.new(Dir.getwd)
  git_path = root_path.join('.git')
  db_path = git_path.join('objects')

  workspace = Workspace.new(root_path)
  database = Database.new(db_path)

  workspace.list_files.each do |path|
    data = workspace.read_file(path)
    blob = Blob.new(data)

    database.store(blob)
  end
else
  $stderr.puts "jit: #{command} is not a jit command"
  exit 1
end
