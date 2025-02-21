# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe('MAC Validation') do
  it('rejects_short_macs') do
    expect(MacValidation.valid?('a0:Ab:00:00:00')).to be(false)
  end

  it('rejects_short_octets') do
    expect(MacValidation.valid?('a0:Ab:c:00:00:00')).to be(false)
  end

  it('rejects_long_macs') do
    expect(MacValidation.valid?('a0:Ab:cc:00:00:00:00')).to be(false)
  end

  it('rejects_long_octets') do
    expect(MacValidation.valid?('a0:Ab:cde:00:00:00')).to be(false)
  end

  it('rejects_multicast_mac_addresses') do
    [
      '01:00:00:00:00:00',
      '03:00:00:00:00:00',
      '05:00:00:00:00:00',
      '07:00:00:00:00:00',
      '0B:00:00:00:00:00',
      '0D:00:00:00:00:00',
      '0F:00:00:00:00:00'
    ].each do |mac|
      expect(MacValidation.valid?(mac)).to be(false)
    end
  end

  it('rejects_invalid_digits') do
    expect(MacValidation.valid?('a0:ab:cz:00:00:01')).to be(false)
  end

  it('accepts_a_valid_mac') do
    expect(MacValidation.valid?('a0:ab:cc:00:01:02')).to be(true)
  end

  it('accepts_dashes') do
    expect(MacValidation.valid?('a0-ab-cc-00-01-02')).to be(true)
  end

  it('accepts_mixed_case') do
    expect(MacValidation.valid?('a0:Ab:cC:00:01:02')).to be(true)
  end
end
