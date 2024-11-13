class String
  def cleanString
    cleanArray.join(', ')
  end

  def cleanUniqString
    cleanUniqArray.join(', ')
  end

  def cleanUniqArray
    cleanArray.uniq
  end

  def cleanArray
    cleanSplit.reject(&:empty?)
  end

  def cleanSplit
    split(/(?<!\\),/).map(&:strip)
  end

  def addEnum(e)
    replace((cleanArray << e).uniq.join(', '))
  end

  def removeEnum(e)
    arr = cleanArray
    arr.delete(e)
    replace(arr.join(', '))
  end

  def escapeHtmlOutside
    gsub(/&(?!(amp|lt|gt|quot|apos|emsp);)/, '&amp;')
      .gsub('<',  '&lt;')
      .gsub('>',  '&gt;')
      .gsub('"', '&quot;')
      .gsub("'",  '&apos;')
      .gsub("\t", '&emsp;')
      .gsub("\n", '<br>')
      .gsub('`', '&#96;')
      .gsub(/(?<= ) /, '&nbsp')
  end

  def escape_html_inside
    gsub('`', '&#96;')
      .gsub("\t", '&emsp;')
      .gsub("\n", ' ')
  end

  def get_next_escape_token(pos)
    ind = index(%r{<\s*(/?)\s*html\s*>}, pos)
    return [:none, length - pos, -1] if ind.nil?

    type = Regexp.last_match(1).empty? ? :start : :end
    [type, ind - pos, ind + Regexp.last_match(0).length]
  end

  def escape_html
    str = ''
    search_pos = 0
    nested = 0
    loop do
      next_token, token_pos, after_token_pos = get_next_escape_token(search_pos)
      if nested.zero?
        str << self[search_pos, token_pos].escapeHtmlOutside
        nested = 1 if next_token == :start
      else
        str << self[search_pos, token_pos].escape_html_inside
        nested += (next_token == :start ? +1 : -1)
      end
      break if next_token == :none

      search_pos = after_token_pos
    end
    str.strip
  end

  def sanitize
    gsub(/[^a-zA-Z0-9.\-_]/, '_')
  end

  def universal_newline
    encode(encoding, universal_newline: true)
  end
end
