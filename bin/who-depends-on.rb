#!/usr/bin/env ruby
# frozen_string_literal: true

# Usage: bin/who-depends-on.rb libfoo.so.1
#
# Prints every binary package in the APKINDEX that depends on the given
# shared library, as "origin package: subpackage name".

require "net/http"
require "rubygems/package"
require "stringio"
require "uri"
require "zlib"

INDEX_URL = "https://pub-3a8f2e6595544a6a883e17caa4383bdd.r2.dev/x86_64/APKINDEX.tar.gz"

def fetch(url)
  response = Net::HTTP.get_response(URI(url))
  abort "Failed to fetch #{url}: #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)

  response.body
end

# APKINDEX.tar.gz is several concatenated gzip streams (signature + index),
# so read every member and join them into one tar stream.
def gunzip_all(data)
  out = +"".b
  io = StringIO.new(data)

  until io.eof?
    gz = Zlib::GzipReader.new(io)
    out << gz.read
    unused = gz.unused
    gz.finish
    io.pos -= unused.bytesize if unused
  end

  out
end

def read_apkindex(data)
  Gem::Package::TarReader.new(StringIO.new(gunzip_all(data))).each do |entry|
    return entry.read.force_encoding("UTF-8") if entry.full_name == "APKINDEX"
  end

  abort "APKINDEX not found in archive"
end

def parse_records(text)
  text.split(/\n\n+/).filter_map do |block|
    record = {}
    block.each_line do |line|
      key, value = line.chomp.split(":", 2)
      record[key] = value if value
    end
    record unless record.empty?
  end
end

library = ARGV[0]
abort "Usage: #{$PROGRAM_NAME} library.so.1" if library.nil? || library.empty?

needle = "so:#{library.delete_prefix("so:")}"

records = parse_records(read_apkindex(fetch(INDEX_URL)))

records
  .select { |r| r["D"].to_s.split.include?(needle) }
  .map { |r| [r["o"] || r["P"], r["P"]] }
  .uniq
  .sort
  .each { |origin, name| puts "#{origin}: #{name}" }
