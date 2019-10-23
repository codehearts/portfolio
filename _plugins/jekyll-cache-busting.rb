require 'fileutils'
require 'digest'

module Jekyll
  module CacheBusting
    # Mapping of file paths to their cache busting versions
    @@cached_files = Hash.new do |cache, path| 
      # If an entry doesn't exist, hash and create it
      hash = Digest::MD5.hexdigest(File.read(path))[0..7]
      cache[path] = path.sub(/(\.)([^.]*)$/, ".#{hash}.\\2")
    end

    # Create a liquid filter which marks the uri for post processing
    def cache_busting(uri)
      "cache_bust(#{uri})"
    end

    def self.cache_busting(uri)
      @@cached_files[uri]
    end
  end
end

# Renames static and css files with thier md5 sum for cache busting
Jekyll::Hooks.register :site, :post_write, priority: Jekyll::Hooks::PRIORITY_MAP[:high] do |site|
  # Creates an array of relative paths to all static files
  static_file_paths = site.static_files.map { |file|
    if file.destination_rel_dir.empty?
      relative_file_path = file.name
    else
      relative_path = file.destination_rel_dir
      relative_file_path = File.join relative_path, file.name
    end

    File.join site.dest, relative_file_path
  }

  # Creates an array of all pages to add cache busting to
  cached_page_paths = site.pages
    .map { |page| File.join site.dest, page.url }
    .filter { |page| page.end_with? '.css' }

  # Creates an array of all existent pages
  existent_page_paths = site.pages
    .map { |page| File.join site.dest, page.url.sub(/\/$/, '/index.html') }
    .filter { |page| File.exists? page }

  # Append a hash to each cache-controlled file
  (static_file_paths + cached_page_paths).each do |file_path|
    FileUtils.mv file_path, Jekyll::CacheBusting.cache_busting(file_path)
  end

  (static_file_paths + existent_page_paths).each do |file_path|
    # Read the cached filename if possible, or read the non-cached file
    if File.exists? Jekyll::CacheBusting.cache_busting file_path
      output_file_path = Jekyll::CacheBusting.cache_busting file_path
    else
      output_file_path = file_path
    end

    file_contents = File.read output_file_path

    # Replace all cache_bust() instances if found
    if file_contents.valid_encoding? and file_contents.index 'cache_bust'
      updated_file_contents = file_contents.gsub(/cache_bust\(([^)]+)\)/) { |_|
        Jekyll::CacheBusting.cache_busting(File.join site.dest, $1)
          .sub("#{site.dest}/", '')
      }

      # Write the updated file contents
      File.write output_file_path, updated_file_contents
    end
  end
end

Liquid::Template.register_filter(Jekyll::CacheBusting)
