#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "net/http"
require "open3"
require "rubygems/package"
require "stringio"

PACKAGES_DIR = File.join(__dir__, "..", "packages")
APKINDEX_URL = "https://pub-3a8f2e6595544a6a883e17caa4383bdd.r2.dev/x86_64/APKINDEX.tar.gz"

def build_requires
  requires = []

  Dir.glob(File.join(PACKAGES_DIR, "*.yaml")).sort.each do |path|
    doc = YAML.load_file(path)
    requires.concat(doc.dig("environment", "contents", "packages") || [])
  end

  requires
end

def strip_version(name)
  name[/\A[^<>=~]+/]
end

def download_apkindex
  uri = URI.parse(APKINDEX_URL)
  response = Net::HTTP.get_response(uri)
  raise "failed to download APKINDEX: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

  response.body
end

# APKINDEX.tar.gz is concatenated (multistream) gzip -- a signature member
# followed by the content member. Ruby's Zlib::GzipReader only decompresses
# the first member, so shell out to gzip(1), which handles concatenation
# correctly.
def parse_apkindex(tar_gz_data)
  tar_data, status = Open3.capture2("gzip", "-dc", stdin_data: tar_gz_data, binmode: true)
  raise "gzip -dc failed" unless status.success?

  index_text = nil
  Gem::Package::TarReader.new(StringIO.new(tar_data)) do |tar|
    tar.each do |entry|
      index_text = entry.read if entry.full_name == "APKINDEX"
    end
  end
  raise "APKINDEX entry not found in archive" unless index_text

  index_text
end

# Returns the set of names the index can satisfy a dependency with: every
# package's own name (P:) plus everything it provides (p:, space-separated,
# each optionally version-suffixed with "=...").
def provided_names(index_text)
  names = {}

  index_text.each_line do |line|
    line = line.chomp
    case line
    when /\AP:(.+)/
      names[Regexp.last_match(1)] = true
    when /\Ap:(.+)/
      Regexp.last_match(1).split(" ").each { |entry| names[strip_version(entry)] = true }
    end
  end

  names
end

requires = build_requires.map { |r| strip_version(r) }.uniq.sort
available = provided_names(parse_apkindex(download_apkindex))

requires.reject { |r| available[r] }.each { |r| puts r }
