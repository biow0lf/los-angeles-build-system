#!/usr/bin/env ruby
# frozen_string_literal: true

# Usage: bin/who-provides-pc.rb gstreamer-1.0
#
# Prints every binary package in the APKINDEX that provides the given
# pkg-config module (pc:<name>), as "origin package: subpackage name".

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


name = ARGV[0]
abort "Usage: #{$PROGRAM_NAME} gstreamer-1.0" if name.nil? || name.empty?

needle = "pc:#{name.delete_prefix("pc:")}"

records = parse_records(read_apkindex(fetch(INDEX_URL)))

records
  .select { |r| r["p"].to_s.split.any? { |provide| provide.split(/[<>=~]/, 2).first == needle } }
  .map { |r| [r["o"] || r["P"], r["P"]] }
  .uniq
  .sort
  .each { |origin, pkg| puts "#{origin}: #{pkg}" }
