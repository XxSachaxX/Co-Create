module ButtonLinkHelper
  # Returns computed attributes for button links
  # @param variant [Symbol] The button variant (:primary, :secondary, :danger, :success)
  # @param html_class [String, nil] Additional CSS classes to append
  # @param http_method [Symbol, String, nil] HTTP method for Turbo (e.g., :post, :delete)
  # @param confirm [String, nil] Confirmation message for Turbo
  # @return [Hash] Hash with :class and :data keys for link_to
  def button_link_attributes(variant: nil, html_class: nil, http_method: nil, confirm: nil)
    # Button variants with Tailwind classes
    variants = {
      primary: "px-4 py-2 bg-gradient-to-r from-lavender to-lavender-400 text-white rounded-lg hover:from-lavender-700 hover:to-lavender-400 hover:shadow-md transition-all duration-200 font-medium",
      secondary: "px-4 py-2 border border-charcoal-300 text-charcoal-700 rounded-lg hover:bg-charcoal-50 transition-all duration-200 font-medium",
      danger: "px-4 py-2 border border-red-300 text-red-600 rounded-lg hover:bg-red-50 hover:border-red-400 transition-all duration-200 font-medium",
      success: "px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition font-medium"
    }

    # Default to secondary if variant not specified or invalid
    variant ||= :secondary
    button_class = variants[variant] || variants[:secondary]

    # Merge custom classes if provided
    button_class = "#{button_class} #{html_class}" if html_class.present?

    # Build data attributes
    data_attrs = {}
    data_attrs[:turbo_method] = http_method if http_method.present?
    data_attrs[:turbo_confirm] = confirm if confirm.present?

    { class: button_class, data: data_attrs }
  end
end
