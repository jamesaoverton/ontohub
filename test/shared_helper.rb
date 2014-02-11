require 'pathname'

module SharedHelper

  def app_root
    Pathname.new(File.expand_path('../../', __FILE__))
  end

  def gemset_definition_file
    rbenv = app_root.join('.rbenv-gemsets')
    rvm = app_root.join('.ruby-gemset')
    if rbenv.exist?
      rbenv
    elsif rvm.exist?
      rvm
    end
  end

  def gemsets
    file = gemset_definition_file
    file.readlines.map { |line| line.strip }.select { |line| !line.empty? }
  end

  def use_simplecov
    require 'simplecov'
    SimpleCov.start do
      gemset_definition = app_root.join('.rbenv-gemsets')
      gemsets.each do |gemset|
        add_filter "/#{gemset}/"
      end
    end
  end

end
