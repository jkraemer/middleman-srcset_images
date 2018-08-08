# frozen_string_literal: true
require "rake"
require "rake/tasklib"
require "middleman-srcset_images/create_image_versions"

module SrcsetImages

  # Create a task that generates image versions
  #
  # Example:
  #   require "middleman-srcset_images/generate_task"
  #
  #   SrcsetImages::GenerateTask.new do |t|
  #     t.base_dir = File.dirname(__FILE__)
  #     t.config = "data/srcset_images.yml"
  #   end
  #
  #
  # Examples:
  #
  #   rake srcset_images:generate
  #
  class GenerateTask < Rake::TaskLib

    # Name of test task. (default is generate_srcset_images)
    attr_accessor :name

    # base directory of your middleman project. Defaults to '.'.
    attr_accessor :base_dir

    # config file location relative to base_dir.
    # Defaults to "data/srcset_images.yml".
    attr_accessor :config

    attr_accessor :deps


    # Create the image generation task.
    def initialize(name = :generate)
      @description = "Generates image versions"
      @name = name
      @base_dir = "."
      @config = "data/srcset_images.yml"
      @deps = []
      if @name.is_a?(Hash)
        @deps = @name.values.first
        @name = @name.keys.first
      end
      yield self if block_given?
      define
    end

    def define
      namespace :srcset_images do
        desc @description
        task @name => Array(deps) do
          SrcsetImages::CreateImageVersions.(base_dir: @base_dir, config: @config)
        end
        self
      end
    end

  end
end


