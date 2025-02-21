# frozen_string_literal: true

module ExplicitFormePlugin
  attr_reader :_form_tag

  def form_tag attrs
    @_form_tag = ::Forme::Tag.new self, :form, attrs
  end

  def explicit_open
    @to_s << serialize_open(@_form_tag)
    before_form_yield
    @to_s
  end

  def explicit_close
    form_len = @to_s.length
    after_form_yield
    @to_s << serialize_close(@_form_tag)
    @to_s[form_len..]
  end

  def form_output = "#{explicit_open}#{yield if block_given?}#{explicit_close}"
end
