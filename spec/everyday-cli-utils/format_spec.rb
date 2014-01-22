require_relative '../../lib/everyday-cli-utils/format'

describe EverydayCliUtils::Format do
  it 'adds formatting methods to String' do
    str = 'hi'
    str.respond_to?(:format_bold_underline_fg_yellow_bg_green).should be_true
    str.respond_to?(:format_underline_bg_green).should be_true
  end

  it 'does the same formatting in the String methods and the Format methods' do
    str        = 'hi'
    format_str = EverydayCliUtils::Format.boldunderline(str, :yellow, :green)
    string_str = str.format_bold_underline_fg_yellow_bg_green
    format_str.should eq string_str
  end
end