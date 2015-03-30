#!/usr/bin/env ruby

require 'mechanize'
require 'cgi'
require 'fileutils'

class AutoindexPhpScriptMechanize < Mechanize
  attr_accessor :root_url

  def initialize(root_url)
    @root_url = root_url
    super
  end

  def self.download(root_url)
    new(root_url).download
  end

  def download
    file_hrefs.each do |href|
      download_url = scheme_with_host + href
      download_uri = URI(download_url)
      params = CGI::parse(download_uri.query)
      directory = params['dir'].first
      file = params['file'].first
      if directory == ''
        system("wget '#{download_url}' -c -O '#{file}' && touch '#{file}.done'")
      else
        unless ::File.directory?(directory)
          FileUtils.mkdir_p(directory)
        end
        system("wget '#{download_url}' -c -O '#{directory}/#{file}' && touch '#{directory}/#{file}.done'")
      end
    end
    directory_hrefs.each do |href|
      self.class.download(scheme_with_host + href)
    end
  end

  def self.list_uri(root_url)
    new(root_url).list_uri
  end

  def list_uri
    file_hrefs.each do |href|
      puts scheme_with_host + href
    end
    directory_hrefs.each do |href|
      self.class.list_uri(scheme_with_host + href)
    end
  end

  def file_hrefs
    content_hrefs.select do |href|
      href.include?('&file=')
    end
  end

  def directory_hrefs
    content_hrefs.reject do |href|
      href.include?('&file=')
    end
  end

  def content_hrefs
    root_page.links.select do |link|
      link.href.include?('/index.php?dir=')
    end.reject do |link|
      link.href.include?('&sort')
    end.reject do |link|
      link.href == root_href
    end.reject do |link|
      link.href.size < root_href.size
    end.map(&:href)
  end

  private

  def root_page
    get(root_url)
  end

  def root_href
    root_url.gsub(scheme_with_host, '')
  end

  def uri
    URI(root_url)
  end

  def scheme_with_host
    uri.scheme + '://' + uri.host
  end
end

ARGV.each do |url|
  host = URI(url).host
  unless File.directory?(host)
    FileUtils.mkdir(host)
  end
  Dir.chdir(host)
  AutoindexPhpScriptMechanize.download(url)
  Dir.chdir('..')
end
