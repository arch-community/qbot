# frozen_string_literal: true

# rubocop: disable Metrics/ModuleLength
# X-SAMPA to IPA conversion
module XSConverter
  XSAMPA_MAP = {
    'b_<' => 'ɓ',
    'd`' => 'ɖ',
    'd_<' => 'ɗ',
    'g_<' => 'ɠ',
    'h\\' => 'ɦ',
    'j\\' => 'ʝ',
    'l`' => 'ɭ',
    'l\\' => 'ɺ',
    'n`' => 'ɳ',
    'p\\' => 'ɸ',
    'r`' => 'ɽ',
    'r\\' => 'ɹ',
    'r\\`' => 'ɻ',
    's`' => 'ʂ',
    's\\' => 'ɕ',
    't`' => 'ʈ',
    'v\\' => 'ʋ',
    'x\\' => 'ɧ',
    'z`' => 'ʐ',
    'z\\' => 'ʑ',
    'A' => 'ɑ',
    'B' => 'β',
    'B\\' => 'ʙ',
    'C' => 'ç',
    'D' => 'ð',
    'E' => 'ɛ',
    'F' => 'ɱ',
    'G' => 'ɣ',
    'G\\' => 'ɢ',
    'G\\_<' => 'ʛ',
    'H' => 'ɥ',
    'H\\' => 'ʜ',
    'I' => 'ɪ',
    'I\\' => 'ᵻ',
    'J' => 'ɲ',
    'J\\' => 'ɟ',
    'J\\_<' => 'ʄ',
    'K' => 'ɬ',
    'K\\' => 'ɮ',
    'L' => 'ʎ',
    'L\\' => 'ʟ',
    'M' => 'ɯ',
    'M\\' => 'ɰ',
    'N' => 'ŋ',
    'N\\' => 'ɴ',
    'O' => 'ɔ',
    'O\\' => 'ʘ',
    'P' => 'ʋ',
    'Q' => 'ɒ',
    'R' => 'ʁ',
    'R\\' => 'ʀ',
    'S' => 'ʃ',
    'T' => 'θ',
    'U' => 'ʊ',
    'U\\' => 'ᵿ',
    'V' => 'ʌ',
    'W' => 'ʍ',
    'X' => 'χ',
    'X\\' => 'ħ',
    'Y' => 'ʏ',
    'Z' => 'ʒ',
    '.' => '.',
    '"' => 'ˈ',
    '%' => 'ˌ',
    "'" => 'ʲ',
    '_j' => 'ʲ',
    ':' => 'ː',
    ':\\' => 'ˑ',
    '-' => '',
    '@' => 'ə',
    '@\\' => 'ɘ',
    '{' => 'æ',
    '}' => 'ʉ',
    '1' => 'ɨ',
    '2' => 'ø',
    '3' => 'ɜ',
    '3\\' => 'ɞ',
    '4' => 'ɾ',
    '5' => 'ɫ',
    '6' => 'ɐ',
    '7' => 'ɤ',
    '8' => 'ɵ',
    '9' => 'œ',
    '&' => 'ɶ',
    '?' => 'ʔ',
    '?\\' => 'ʕ',
    '<\\' => 'ʢ',
    '>\\' => 'ʡ',
    '^' => 'ꜛ',
    '!' => 'ꜜ',
    '!\\' => 'ǃ',
    '|' => '|',
    '|\\' => 'ǀ',
    '||' => '‖',
    '|\\|\\' => 'ǁ',
    '=\\' => 'ǂ',
    '-\\' => '‿',
    '_"' => ' ̈',
    '_+' => '̟',
    '_-' => '̠',
    '_/' => '̌',
    '_0' => '̥',
    '_<' => '',
    '=' => '̩',
    '_=' => '̩',
    '_>' => 'ʼ',
    '_?\\' => 'ˤ',
    '_\\' => '̂',
    '_^' => '̯',
    '_}' => '̚',
    '`' => '˞',
    '~' => '̃',
    '_~' => '̃',
    '_A' => '̘',
    '_a' => '̺',
    '_B' => '̏',
    '_B_L' => '᷅',
    '_c' => '̜',
    '_d' => '̪',
    '_e' => '̴',
    '<F>' => '↘',
    '_F' => '̂',
    '_G' => 'ˠ',
    '_H' => '́',
    '_H_T' => '᷄',
    '_h' => 'ʰ',
    '_k' => '̰',
    '_L' => '̀',
    '_l' => 'ˡ',
    '_M' => '̄',
    '_m' => '̻',
    '_N' => '̼',
    '_n' => 'ⁿ',
    '_O' => '̹',
    '_o' => '̞',
    '_q' => '̙',
    '<R>' => '↗',
    '_R' => '̌',
    '_R_F' => '᷈',
    '_r' => '̝',
    '_T' => '̋',
    '_t' => '̤',
    '_v' => '̬',
    '_w' => 'ʷ',
    '_X' => '̆',
    '_x' => '̽'
  }.sort_by { |k, _| k.length }.reverse!.freeze

  def self.convert(ipa)
    XSAMPA_MAP.each do |k, v|
      ipa.gsub!(k, v)
    end

    ipa
  end
end
# rubocop: enable Metrics/ModuleLength