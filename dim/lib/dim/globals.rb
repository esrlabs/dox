OPTIONS ||= {}
SUBCOMMANDS ||= {}
EXPORTER ||= {}
CATEGORY_ORDER = {
  'input' => 1,
  'system' => 2,
  'software' => 3,
  'architecture' => 4,
  'module' => 5
}.freeze
ALLOWED_CATEGORIES = CATEGORY_ORDER.keys.each_with_object({}) { |k, obj| obj[k.to_sym] = k }.freeze
SRS_NAME_REGEX = /[^a-zA-Z0-9-]+/.freeze
