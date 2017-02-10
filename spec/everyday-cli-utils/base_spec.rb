require_relative '../../lib/everyday-cli-utils'

describe 'everyday-cli-utils' do
  it 'raises an exception when an unknown module name is passed to import' do
    expect { EverydayCliUtils.import(:unknown_module) }.to raise_exception('unknown_module not found!')
  end
end