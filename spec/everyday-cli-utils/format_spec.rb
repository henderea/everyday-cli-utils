require_relative '../../lib/everyday-cli-utils'
include EverydayCliUtils
import :format

def extract_format(text)
  (text.scan(/#{"\e"}\[(.+?)m([^#{"\e"}]+?)#{"\e"}\[0m|([^#{"\e"}]+)/))[0][0]
end

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

  it 'can parse a format it creates' do
    str                               = 'hi'
    format_str                        = EverydayCliUtils::Format.bold(str, :yellow, :green)
    piece                             = extract_format(format_str)
    bold, underline, fgcolor, bgcolor = EverydayCliUtils::Format.parse_format(piece)
    bold.should be_true
    underline.should be_false
    fgcolor.should eq :yellow
    bgcolor.should eq :green

    format_str                        = EverydayCliUtils::Format.underline(str, :yellow, :green)
    piece                             = extract_format(format_str)
    bold, underline, fgcolor, bgcolor = EverydayCliUtils::Format.parse_format(piece)
    bold.should be_false
    underline.should be_true
    fgcolor.should eq :yellow
    bgcolor.should eq :green

    format_str                        = EverydayCliUtils::Format.colorize(str, :yellow, :green)
    piece                             = extract_format(format_str)
    bold, underline, fgcolor, bgcolor = EverydayCliUtils::Format.parse_format(piece)
    bold.should be_false
    underline.should be_false
    fgcolor.should eq :yellow
    bgcolor.should eq :green

    format_str                        = EverydayCliUtils::Format.boldunderline(str, :yellow, :green)
    piece                             = extract_format(format_str)
    bold, underline, fgcolor, bgcolor = EverydayCliUtils::Format.parse_format(piece)
    bold.should be_true
    underline.should be_true
    fgcolor.should eq :yellow
    bgcolor.should eq :green
  end

  it 'still works with the default String method_missing and respond_to?' do
    str = 'hi'
    str.respond_to?(:split).should be_true
    str.respond_to?(:hi).should be_false
    expect { str.hi }.to raise_error(NameError)
  end
end