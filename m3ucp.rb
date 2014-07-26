## TO DO: 
#  - rewrite m3u with relative path
#  - playlist copied to sansa is mt?
#  - rdoc, post to github

# given BASE_DIR='/path/to/mp3/', /path/to/mp3/files/file.mp3 in playlist files 
#   will get copied to DEST_DIR/files/file.mp3, along with playlist


require 'fileutils'

BASE_DIR=File.realdirpath("/D/mp3/")

options= {:verbose => true }
# options= {:verbose => true, :noop => true }

unless ARGV[0] and !ARGV[0].empty? and ARGV[1] and !ARGV[1].empty?
  puts 'Usage: m3ucp </path/to/file.m3u> </dest/dir>' 
  exit 1
end

dest=Dir.new(ARGV[ARGV.size - 1])
ARGV.pop
srcfn=File.realdirpath(ARGV.join ' ')
puts "srcfn=#{srcfn}"
src=File.new(srcfn)

fail "File not found: #{ARGV[0]}" unless File.file?(src) 
fail "Dest dir don't exist, sport." unless File.directory?(dest)

FileUtils.cd(File.dirname(src))
missing_files = false
cplist= [File.realdirpath(src).chomp.strip.tr("\\", File::SEPARATOR)]

File.foreach(File.expand_path(src)) do |line|
  next unless nil == (line =~ /^ *#/)
  mp3= line.chomp.strip.tr "\\", File::SEPARATOR
  if !File.file?(mp3)
    puts "Missing Files:" unless missing_files
    missing_files = true
    puts "  #{mp3}"
  else
    cplist << File.expand_path(File.realdirpath(mp3))
  end
end

if missing_files
  printf "Continue? [Yn] "
  s= $stdin.gets.chomp
  exit unless s=='' or s=='Y' or s=='y'
end

cplist.each do |mp3|
  mp3file= File.new(mp3)
  srcdir= File.dirname(mp3file)
  destdir=dest.path + File::SEPARATOR + srcdir.sub(BASE_DIR, '')
  destfile= destdir + File::SEPARATOR + File.basename(mp3file)

  FileUtils.mkdir_p(destdir, options) unless File.directory?(destdir)
  FileUtils.cp(mp3, destdir, options) unless File.file?(destfile) # and FileUtils.identical?(mp3, destfile)
end

