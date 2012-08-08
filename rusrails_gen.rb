# coding: utf-8

require "RedCloth"

Dir.chdir("/home/almaz/projects/rusrails/source")

dirs = []
Dir.glob('*').each do |f|
  if f =~ /^(\d+)-/
    article_id = $~[0].to_s.to_i
    sub_dirs = []
    Dir.glob(f + '/*.textile') do |sub_file|
      dir, file = sub_file.split '/'
      if file[0, 2] == '--'
        sub_dirs[0] = file
        next
      end
      if file =~ /^(\d+)-/
        sub_dirs[$~[0].to_i + 1] = file
      end
    end

    dirs[article_id] = [f, sub_dirs]
  end
end


def my_prepare!(text)
  text.gsub!(/\<(ruby|erb|shell|sql|html|plain|yaml)\>/, '^^\1')
  text.gsub!(/\<\/(ruby|erb|shell|sql|html|plain|yaml)\>/, '_^^_')

  text.gsub!(/\<tt\>/, '%%')
  text.gsub!(/\<\/tt\>/, '% % %')

  text.gsub!(/\<plus\>/, '+')

  text
end

def post_processing!(text)
  #text.gsub!(/\<plus\>/, '+')
  text
end

def my_prepare_decode!(text)
  text.gsub!(/\^\^(ruby|erb|shell|sql|html|plain|yaml)/, '<pre><code class="block \1">')
  text.gsub!(/_\^\^_/, '</code></pre>')

  text.gsub!(/%%/, '<code="inline">')
  text.gsub!(/% % %/, '</code>')
  text
end


puts <<-HTML
<!DOCTYPE html>
<html>
<head>
    <title></title>
    <meta charset="utf-8">
    <link rel="stylesheet" href="highlight/xcode.css">
    <link rel="stylesheet" href="main.css">
    <script src="highlight/hl.js"></script>
</head>
<body>
HTML

dirs.each do |dir, files|
  files.each do |file|
    next unless file
    File.open(dir + '/' + file) do |fd|
      text = fd.read
      puts post_processing!(RedCloth.new(my_prepare_decode!(my_prepare!(text))).to_html)

    end
  end

end


puts <<-HTML

</body>

<script>hljs.initHighlightingOnLoad();</script>
</head>
HTML 
