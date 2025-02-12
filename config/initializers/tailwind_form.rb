# frozen_string_literal: true

require 'forme'

module TailwindConfig
  def self.label_attr
    {
      class: 'block text-gray-700 text-md leading-4 font-medium mb-2'
    }
  end

  def self.before
    lambda { |form|
      form.to_s << '<div class="rounded-xl bg-gray-50 shadow-sm border mb-6 divide-y divide-gray-200">'
    }
  end

  def self.after
    lambda { |form|
      form.to_s << '</div>'
    }
  end

  def self.options
    {
      labeler: :explicit,
      wrapper: :div,
      before:,
      after:,
      input_defaults: {
        text: {
          label_attr:,
          wrapper_attr: { class: 'p-6' },
          class: 'block mt-2 min-h-12 px-4 rounded-xl text-black bg-white block w-full p-0 outline-none text-sm border border-gray-300 focus:outline-none ring-2 ring-transparent focus:ring-2 ring-offset-gray-200 focus:ring-offset-2 focus:ring-offset-gray-200 focus:ring-blue-500 focus:border-transparent transition duration-150'
        },

        number: {
          label_attr:,
          wrapper_attr: { class: 'p-6' },
          class: 'block mt-2 min-h-12 px-4 rounded-xl text-black bg-white block w-full p-0 outline-none text-sm border border-gray-300 focus:outline-none ring-2 ring-transparent focus:ring-2 ring-offset-gray-200 focus:ring-offset-2 focus:ring-offset-gray-200 focus:ring-blue-500 focus:border-transparent transition duration-150'
        },

        time: {
          label_attr:,
          wrapper_attr: { class: 'p-6' },
          class: 'block mt-2 min-h-12 px-4 rounded-xl text-black bg-white block w-full p-0 outline-none text-sm border border-gray-300 focus:outline-none ring-2 ring-transparent focus:ring-2 ring-offset-gray-200 focus:ring-offset-2 focus:ring-offset-gray-200 focus:ring-blue-500 focus:border-transparent transition duration-150'
        },

        checkbox: {
          label_position: :before,
          label_attr:,
          wrapper_attr: { class: 'p-6' },
          class: 'h-8 w-8 rounded-full shadow'
        },

        submit: {
          label_attr:,
          attr: { class: 'cursor-pointer font-medium rounded-lg text-sm px-3 py-2 inline-flex items-center transition duration-150 justify-center shrink-0 gap-1.5 whitespace-nowrap text-white bg-blue-500 hover:bg-blue-600 focus:outline-none' },
          wrapper_attr: { class: 'p-6 text-right' }
        }
      }
    }
  end
end
