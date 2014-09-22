require_relative '../../lib/everyday-cli-utils'
require 'rspec'
include EverydayCliUtils
import :format

def extract_format(text)
  (text.scan(/#{"\e"}\[(.+?)m([^#{"\e"}]+?)#{"\e"}\[0m|([^#{"\e"}]+)/))[0][0]
end

describe EverydayCliUtils::Format do
  it 'adds formatting methods to String' do
    str = 'hi'
    expect(str.respond_to?(:format_bold_underline_fg_yellow_bg_green)).to be true
    expect(str.respond_to?(:format_underline_bg_green)).to be true
  end

  it 'does the same formatting in the String methods and the Format methods' do
    str        = 'hi'
    format_str = EverydayCliUtils::Format.boldunderline(str, :yellow, :green)
    string_str = str.format_bold_underline_fg_yellow_bg_green
    expect(format_str).to eq string_str
  end

  it 'can parse a format it creates' do
    str                               = 'hi'
    format_str                        = EverydayCliUtils::Format.bold(str, :yellow, :green)
    piece                             = extract_format(format_str)
    bold, underline, fgcolor, bgcolor = EverydayCliUtils::Format.parse_format(piece)
    expect(bold).to be true
    expect(underline).to be false
    expect(fgcolor).to eq :yellow
    expect(bgcolor).to eq :green

    format_str                        = EverydayCliUtils::Format.underline(str, :yellow, :green)
    piece                             = extract_format(format_str)
    bold, underline, fgcolor, bgcolor = EverydayCliUtils::Format.parse_format(piece)
    expect(bold).to be false
    expect(underline).to be true
    expect(fgcolor).to eq :yellow
    expect(bgcolor).to eq :green

    format_str                        = EverydayCliUtils::Format.colorize(str, :yellow, :green)
    piece                             = extract_format(format_str)
    bold, underline, fgcolor, bgcolor = EverydayCliUtils::Format.parse_format(piece)
    expect(bold).to be false
    expect(underline).to be false
    expect(fgcolor).to eq :yellow
    expect(bgcolor).to eq :green

    format_str                        = EverydayCliUtils::Format.boldunderline(str, :yellow, :green)
    piece                             = extract_format(format_str)
    bold, underline, fgcolor, bgcolor = EverydayCliUtils::Format.parse_format(piece)
    expect(bold).to be true
    expect(underline).to be true
    expect(fgcolor).to eq :yellow
    expect(bgcolor).to eq :green
  end

  it 'still works with the default String method_missing and respond_to?' do
    str = 'hi'
    expect(str.respond_to?(:split)).to be true
    expect(str.respond_to?(:hi)).to be false
    expect { str.hi }.to raise_error(NameError)
  end

  it 'allows shorthand for formatting in-string' do
    str      = 'abc {def}(bdulfywbgr) ghi {jkl}(ulfyw) mno'
    expected = "abc #{'def'.format_bold_underline_fg_yellow_bg_green} ghi #{'jkl'.format_underline_fg_yellow} mno"
    expect(str.format_all).to eq expected
  end

  it 'allows color profiles for use in shorthand for formatting in-string' do
    EverydayCliUtils::Format.color_profile(:p1, bold: true, underline: true, fgcolor: :yellow, bgcolor: :green)
    EverydayCliUtils::Format.color_profile(:p2, underline: true, fgcolor: :yellow)
    str      = 'abc {def}(:p1) ghi {jkl}(:p2) mno'
    expected = "abc #{'def'.format_bold_underline_fg_yellow_bg_green} ghi #{'jkl'.format_underline_fg_yellow} mno"
    expect(str.format_all).to eq expected
  end

  it 'allows removing shorthand for formatting in-string' do
    str      = 'abc {def}(bdulfywbgr) ghi {jkl}(ulfyw) mno'
    expected = 'abc def ghi jkl mno'
    expect(str.remove_format).to eq expected
  end

  it 'allows removing color profile shorthand for formatting in-string' do
    EverydayCliUtils::Format.color_profile(:p1, bold: true, underline: true, fgcolor: :yellow, bgcolor: :green)
    EverydayCliUtils::Format.color_profile(:p2, underline: true, fgcolor: :yellow)
    str      = 'abc {def}(:p1) ghi {jkl}(:p2) mno'
    expected = 'abc def ghi jkl mno'
    expect(str.remove_format).to eq expected
  end

  it 'allows centering a formatted string' do
    str                   = 'abc'
    str2                  = str.center(10)
    strf                  = str.format_bold_underline_fg_yellow_bg_green
    strf2                 = strf.mycenter(10)
    leading_whitespace    = str2.length - str2.lstrip.length
    trailing_whitespace   = str2.length - str2.rstrip.length
    leading_whitespace_f  = strf2.length - strf2.lstrip.length
    trailing_whitespace_f = strf2.length - strf2.rstrip.length
    expect(leading_whitespace_f).to eq leading_whitespace
    expect(trailing_whitespace_f).to eq trailing_whitespace

    str                   = 'abcd'
    str2                  = str.center(10)
    strf                  = str.format_bold_underline_fg_yellow_bg_green
    strf2                 = strf.mycenter(10)
    leading_whitespace    = str2.length - str2.lstrip.length
    trailing_whitespace   = str2.length - str2.rstrip.length
    leading_whitespace_f  = strf2.length - strf2.lstrip.length
    trailing_whitespace_f = strf2.length - strf2.rstrip.length
    expect(leading_whitespace_f).to eq leading_whitespace
    expect(trailing_whitespace_f).to eq trailing_whitespace

    str                   = 'abc'
    str2                  = str.center(11)
    strf                  = str.format_bold_underline_fg_yellow_bg_green
    strf2                 = strf.mycenter(11)
    leading_whitespace    = str2.length - str2.lstrip.length
    trailing_whitespace   = str2.length - str2.rstrip.length
    leading_whitespace_f  = strf2.length - strf2.lstrip.length
    trailing_whitespace_f = strf2.length - strf2.rstrip.length
    expect(leading_whitespace_f).to eq leading_whitespace
    expect(trailing_whitespace_f).to eq trailing_whitespace

    str                   = 'abcd'
    str2                  = str.center(11)
    strf                  = str.format_bold_underline_fg_yellow_bg_green
    strf2                 = strf.mycenter(11)
    leading_whitespace    = str2.length - str2.lstrip.length
    trailing_whitespace   = str2.length - str2.rstrip.length
    leading_whitespace_f  = strf2.length - strf2.lstrip.length
    trailing_whitespace_f = strf2.length - strf2.rstrip.length
    expect(leading_whitespace_f).to eq leading_whitespace
    expect(trailing_whitespace_f).to eq trailing_whitespace
  end
end