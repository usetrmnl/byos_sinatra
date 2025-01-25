module ExplicitFormePlugin
  attr_reader :_form_tag

  def form_tag(attrs)
    @_form_tag = ::Forme::Tag.new(self, :form, attrs)
  end

  def explicit_open()
    @to_s << self.serialize_open(@_form_tag)
    self.before_form_yield
    @to_s
  end

  def explicit_close()
    form_len = @to_s.length
    self.after_form_yield
    @to_s << self.serialize_close(@_form_tag)
    @to_s[form_len..]
  end
  
  def form_output(&block)
    form_str = String.new
    form_str << self.explicit_open()
    form_str << block.call if block_given?
    form_str << self.explicit_close()
    form_str
  end
end