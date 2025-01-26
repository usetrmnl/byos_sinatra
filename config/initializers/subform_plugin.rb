require 'forme'

module SubformsPlugin
  def self.options 
    {
      tag_methods: SubformsPlugin,
    }
  end

  module SubformForm
    def input(field, options={})
      super(field, options)
    end
  end

  def subform(field, options={})
    keys_to_exclude = [
      :before, :after, :obj
    ]
    namespace = sprintf("%s[%d]", field, options[:id])
    options = @opts.except(*keys_to_exclude).merge(options).merge({
      :parent => self,
      :namespace => namespace
    })
    subClass = self.obj.class.reflect_on_association(field).klass
    form = self.class.new(subClass.new, options)
    form.extend(SubformsPlugin::SubformForm)
    return form
  end

end

# Register the extension with Forme
Forme.register_config(:subforms, SubformsPlugin.options)