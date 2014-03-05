require_relative '../../lib/everyday-cli-utils'
include EverydayCliUtils
import :option

class Option1
  include EverydayCliUtils::OptionUtil
end

describe EverydayCliUtils::OptionUtil do
  it 'supports adding boolean options' do
    expected = { opt1: true }
    clean    = { opt1: false }
    opt      = Option1.new
    opt.option :opt1, %w(-1 --opt-1)
    opt.options.should eq clean
    opt.default_options opt1: false
    opt.options.should eq clean
    opt.parse!(['-1'])
    opt.options.should eq expected
    opt.default_options opt1: false
    opt.options.should eq clean
    opt.parse!(['--opt-1'])
    opt.options.should eq expected
  end

  it 'supports adding boolean toggle options' do
    expected = { opt1: false }
    clean    = { opt1: true }
    opt      = Option1.new
    opt.option :opt1, %w(-1 --opt-1), toggle: true
    opt.options.should eq expected
    opt.default_options opt1: true
    opt.options.should eq clean
    opt.parse!(['-1'])
    opt.options.should eq expected
    opt.default_options opt1: true
    opt.options.should eq clean
    opt.parse!(['--opt-1'])
    opt.options.should eq expected
  end

  it 'supports adding an option with a parameter' do
    expected = { opt1: 'hi' }
    clean    = { opt1: nil }
    opt      = Option1.new
    opt.option_with_param :opt1, ['-1', '--opt-1 PARAM']
    opt.options.should eq clean
    opt.default_options opt1: nil
    opt.options.should eq clean
    opt.parse!(%w(-1 hi))
    opt.options.should eq expected
    opt.default_options opt1: nil
    opt.options.should eq clean
    opt.parse!(%w(--opt-1 hi))
    opt.options.should eq expected
  end

  it 'adds the parameter into a name if it is missing from all' do
    expected = { opt1: 'hi' }
    clean    = { opt1: nil }
    opt      = Option1.new
    opt.option_with_param :opt1, %w(-1 --opt-1)
    opt.options.should eq clean
    opt.default_options opt1: nil
    opt.options.should eq clean
    opt.parse!(%w(-1 hi))
    opt.options.should eq expected
    opt.default_options opt1: nil
    opt.options.should eq clean
    opt.parse!(%w(--opt-1 hi))
    opt.options.should eq expected
  end

  it 'supports adding an option with a parameter and type' do
    expected = { opt1: 1 }
    clean    = { opt1: nil }
    opt      = Option1.new
    opt.option_with_param :opt1, ['-1', '--opt-1 PARAM'], type: Integer
    opt.options.should eq clean
    opt.default_options opt1: nil
    opt.options.should eq clean
    opt.parse!(%w(-1 1))
    opt.options.should eq expected
    opt.default_options opt1: nil
    opt.options.should eq clean
    opt.parse!(%w(--opt-1 1))
    opt.options.should eq expected
  end

  it 'supports adding an option with a parameter that store multiple instances' do
    expected = { opt1: %w(hi bye) }
    clean    = { opt1: [] }
    opt      = Option1.new
    opt.option_with_param :opt1, ['-1', '--opt-1 PARAM'], append: true
    opt.options.should eq clean
    opt.default_options opt1: []
    opt.options.should eq clean
    opt.parse!(%w(-1 hi -1 bye))
    opt.options.should eq expected
    opt.default_options opt1: []
    opt.options.should eq clean
    opt.parse!(%w(--opt-1 hi --opt-1 bye))
    opt.options.should eq expected
    opt.default_options opt1: []
    opt.options.should eq clean
    opt.parse!(%w(-1 hi --opt-1 bye))
    opt.options.should eq expected
    opt.default_options opt1: []
    opt.options.should eq clean
    opt.parse!(%w(--opt-1 hi -1 bye))
    opt.options.should eq expected
  end

  it 'supports setting the default for the toggle setting' do
    expected = { opt1: false }
    clean    = { opt1: true }
    opt      = Option1.new
    opt.default_settings toggle: true
    opt.option :opt1, %w(-1 --opt-1)
    opt.options.should eq expected
    opt.default_options opt1: true
    opt.options.should eq clean
    opt.parse!(['-1'])
    opt.options.should eq expected
    opt.default_options opt1: true
    opt.options.should eq clean
    opt.parse!(['--opt-1'])
    opt.options.should eq expected
  end

  it 'supports setting the default for the type setting' do
    expected = { opt1: 1 }
    clean    = { opt1: nil }
    opt      = Option1.new
    opt.default_settings type: Integer
    opt.option_with_param :opt1, ['-1', '--opt-1 PARAM']
    opt.options.should eq clean
    opt.default_options opt1: nil
    opt.options.should eq clean
    opt.parse!(%w(-1 1))
    opt.options.should eq expected
    opt.default_options opt1: nil
    opt.options.should eq clean
    opt.parse!(%w(--opt-1 1))
    opt.options.should eq expected
  end

  it 'supports adding an option with a parameter that store multiple instances' do
    expected = { opt1: %w(hi bye) }
    clean    = { opt1: [] }
    opt      = Option1.new
    opt.default_settings append: true
    opt.option_with_param :opt1, ['-1', '--opt-1 PARAM']
    opt.options.should eq clean
    opt.default_options opt1: []
    opt.options.should eq clean
    opt.parse!(%w(-1 hi -1 bye))
    opt.options.should eq expected
    opt.default_options opt1: []
    opt.options.should eq clean
    opt.parse!(%w(--opt-1 hi --opt-1 bye))
    opt.options.should eq expected
    opt.default_options opt1: []
    opt.options.should eq clean
    opt.parse!(%w(-1 hi --opt-1 bye))
    opt.options.should eq expected
    opt.default_options opt1: []
    opt.options.should eq clean
    opt.parse!(%w(--opt-1 hi -1 bye))
    opt.options.should eq expected
  end

  it 'supports setting a banner and description' do
    opt = Option1.new
    opt.banner 'option1'
    opt.option :opt1, %w(-1 --opt-1), desc: 'option #1'
    opt.option_with_param :opt2, %w(-2 --opt-2), desc: 'option #2 (takes parameter)'
    opt.defaults_option 'defaults.yaml', %w(-0 --set-defaults), desc: 'set defaults'
    expected = 'option1
    -1, --opt-1                      option #1
    -2, --opt-2 PARAM                option #2 (takes parameter)
    -0, --set-defaults               set defaults
'
    opt.to_s.should eq expected
  end

  it 'supports layers' do
    global       = { opt1: false, opt2: [], opt3: 'hi', opt4: [5] }
    global_arg   = { opt1: true, opt2: [], opt3: 'hi', opt4: [5] }
    arg          = { opt1: false, opt2: [], opt3: nil, opt4: [] }
    total        = { opt1: true, opt2: %w(hi bye), opt3: 'bye', opt4: [5, 4] }
    global_local = { opt1: false, opt2: %w(hi bye), opt3: 'bye', opt4: [5, 4] }
    local        = { opt1: true, opt2: %w(hi bye), opt3: 'bye', opt4: [4] }
    local_arg        = { opt1: false, opt2: %w(hi bye), opt3: 'bye', opt4: [4] }
    clean        = { opt1: false, opt2: [], opt3: nil, opt4: [] }
    clean2       = { opt1: true, opt2: [], opt3: nil, opt4: [] }
    opt          = Option1.new
    opt.default_settings toggle: true, append: true
    opt.option :opt1, %w(-1 --opt-1)
    opt.option_with_param :opt2, %w(-2 --big-opt-2)
    opt.option_with_param :opt3, %w(-3 --bigger-opt-3), append: false
    opt.option_with_param :opt4, %w(-4 --even-bigger-opt-4), type: Integer
    opt.options.should eq clean
    opt.option_list.show_defaults.should eq <<SHOW
Script Defaults:
    -1, --opt-1                      false
    -2 PARAM, --big-opt-2            []
    -3 PARAM, --bigger-opt-3         nil
    -4 PARAM, --even-bigger-opt-4    []

SHOW
    opt.default_options opt1: true
    opt.options.should eq clean2
    opt.option_list.show_defaults.should eq <<SHOW
Script Defaults:
    -1, --opt-1                      true
    -2 PARAM, --big-opt-2            []
    -3 PARAM, --bigger-opt-3         nil
    -4 PARAM, --even-bigger-opt-4    []

SHOW
    opt.apply_options :global, opt1: true, opt3: 'hi', opt4: [5]
    opt.options.should eq global
    opt.option_list.show_defaults.should eq <<SHOW
Script Defaults:
    -1, --opt-1                      true
    -2 PARAM, --big-opt-2            []
    -3 PARAM, --bigger-opt-3         nil
    -4 PARAM, --even-bigger-opt-4    []

Script + Global Defaults:
    -1, --opt-1                      false
    -3 PARAM, --bigger-opt-3         'hi'
    -4 PARAM, --even-bigger-opt-4    [5]

SHOW
    opt.apply_options :local, opt1: false, opt2: %w(hi bye), opt3: 'bye', opt4: [4]
    opt.options.should eq global_local
    opt.option_list.show_defaults.should eq <<SHOW
Script Defaults:
    -1, --opt-1                      true
    -2 PARAM, --big-opt-2            []
    -3 PARAM, --bigger-opt-3         nil
    -4 PARAM, --even-bigger-opt-4    []

Script + Global Defaults:
    -1, --opt-1                      false
    -3 PARAM, --bigger-opt-3         'hi'
    -4 PARAM, --even-bigger-opt-4    [5]

Script + Global + Local Defaults:
    -2 PARAM, --big-opt-2            ['hi', 'bye']
    -3 PARAM, --bigger-opt-3         'bye'
    -4 PARAM, --even-bigger-opt-4    [5, 4]

SHOW
    opt.apply_options :arg, opt1: true
    opt.options.should eq total
    opt.option_list.composite(:global, :arg).should eq global_arg
    opt.option_list.composite(:global, :local).should eq global_local
    opt.option_list.composite(:global).should eq global
    opt.option_list.composite(:local).should eq local
    opt.option_list.composite(:local, :arg).should eq local_arg
    opt.option_list.composite(:arg).should eq arg
    opt.option_list.composite(:global, :local, :arg).should eq total
  end
end