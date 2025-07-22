OPTIONS ||= {}
SUBCOMMANDS ||= {}
EXPORTER ||= {}
CATEGORY_ORDER = {
  'input' => 1,
  'system' => 2,
  'software' => 3,
  'architecture' => 4,
  'module' => 5,
}.freeze
ALLOWED_CATEGORIES = CATEGORY_ORDER.keys.each_with_object({}) { |k, obj| obj[k.to_sym] = k }.freeze
SRS_NAME_REGEX = /[^a-zA-Z0-9-]+/.freeze

JSON_SCHEMA = {
  '$schema': 'http://json-schema.org/draft-07/schema#',
  title: 'Dim Schema',
  description: 'Schema for Dim files',
  type: 'object',
  properties: {
    text:                   { type: 'string', description: 'Any string value, It is requirement text' },
    verification_criteria:  { type: 'string', description: 'Any string value, Describes what is needed to pass the a test' },
    feature:                { type: 'string', description: 'Any string value, Can be empty. Describes to what feature the requirement belongs' },
    change_request:         { type: 'string', description: 'Any string value, Used to specify attributes of the current requirement' },
    tags:                   { type: 'string', description: 'Any string, comma separated values' },
    developer:              { type: 'string', description: 'Any string value, Used to assign developer responsible' },
    tester:                 { type: 'string', description: 'Used to assign tester responsible, can be any string' },
    comment:                { type: 'string', description: 'Add comments here inclusive name of the commenter and the date' },
    miscellaneous:          { type: 'string', description: 'Can be used to store project specific information' },
    sources:                { type: 'string', description: 'A comma separated list of source code files' },
    refs:                   { type: 'string', description: 'A comma separated list of all references to other requirements' },
    type:                   { type: 'string', description: '',
                                default: 'requirement',
                                anyOf: [
                                  { const: 'information' },
                                  { const: 'requirement' },
                                  { const: 'process' },
                                  { pattern: '^heading_[0-9]+' }
                                ]
                              },
    asil:                   { type: 'string', description: 'asil value', default: 'auto',
                                enum: %w[auto
                                  QM QM(A) QM(B) QM(C) QM(D)
                                  ASIL_A ASIL_A(A) ASIL_A(B) ASIL_A(C) ASIL_A(D)
                                  ASIL_B ASIL_B(B) ASIL_B(C) ASIL_B(D)
                                  ASIL_C ASIL_C(C) ASIL_C(D)
                                  ASIL_D ASIL_D(D)
                                ]
                              },
    cal:                    { type: 'string', description: 'Specifies the Cybersecurity Assistance Level', default: 'not_set',
                                enum: %w[QM CAL_1 CAL_2 CAL_3 CAL_4 not_set]
                              },
    verification_methods:   { type: 'string', description: 'Any string, comma separated',
                                enum: ['auto', 'none', 'off_target', 'on_target', 'manual', '']
                              },
    status:                 { type: 'string', description: 'Allowd values',
                                enum: %w[valid draft invalid]
                              },
    review_status:          { type: 'string', description: '', default: 'auto',
                                enum: %w[accepted unclear rejected not_reviewed not_relevant auto]
                              },
    Config:                 { type: 'array',
                                items: {
                                  type: 'object',
                                  properties: {
                                    originator: { type: 'string', description: 'originator is typically company name' },
                                    category:   { type: 'string', description: 'category string',
                                                    enum: %w[input software architecture module system]
                                                  },
                                    files:      { type: %w[array string], uniqueItems: true }
                                  },
                                  required: %w[originator category files],
                                  additionalProperties: false
                                }
                              },
    Properties:             { type: 'string', description: 'Property file path' },
    Attributes:             { type: 'string', description: 'Custom attributes file path' },
    module:                 { type: 'string', minLength: 1 },
    metadata:               { type: 'string', minLength: 0 },
    enclosed:               { type: %w[array string], uniqueItems: true },
  },
  if: {
    properties: { Config: true },
    required: %w[Config]
  },
  then: {
    properties: { Config: true, Properties: true, Attributes: true },
    additionalProperties: false
  },
  else: {
    not: {
      properties: { Config: true },
      required: %w[Config]
    }
  },
  additionalProperties:     false
}

