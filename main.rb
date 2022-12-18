# typed: true

Bundler.require

require "json"
require "sorbet-runtime"
require "date"

PATH = "pinboard_export.2022.12.18_23.19.json"
data = JSON.parse(File.read(PATH))

def str_to_bool(str)
  if str == "yes"
    true
  elsif str == "no"
    false
  end
end

class Pin < T::Struct
  const :href, String
  const :description, T.any(String, FalseClass)
  const :extended, String
  const :meta, String
  const :pinboard_hash, String
  const :time, Date
  const :shared, T::Boolean
  const :to_read, T::Boolean
  const :tags, T::Array[String]

  def self.from_hash(json)
    new(
      href: json["href"],
      description: json["description"],
      extended: json["extended"],
      meta: json["meta"],
      pinboard_hash: json["hash"],
      time: Date.iso8601(json["time"]),
      shared: str_to_bool(json["shared"]),
      to_read: str_to_bool(json["toread"]),
      tags: json["tags"].split(" ")
    )
  end
end

pins =
  data.map do |json|
    begin
      Pin.from_hash(json)
    rescue => e
      binding.b
    end
  end

pins_by_tag = {}
pins.each do |pin|
  pin.tags.each do |tag|
    pins_by_tag[tag] ||= []
    pins_by_tag[tag] << pin
  end
end
# binding.b
