Jekyll::Hooks.register [:pages, :documents, :posts], :post_convert do |item|
  modified_content = item.content.dup

  img_pattern = /<p>\s*<img([^>]+)alt="([^"]*)"([^>]*)>\s*<\/p>/i

  modified_content.gsub!(img_pattern) do |match|
    img_attributes = "#{$1}alt=\"#{$2}\"#{$3}"
    caption = $2.strip

    if caption.empty?
      %(<figure class="image"><div class="img-container"><img#{img_attributes}></div></figure>)
    else
      %(<figure class="image"><div class="img-container"><img#{img_attributes}></div><figcaption>#{caption}</figcaption></figure>)
    end
  end

  item.content = modified_content
rescue => e
  Jekyll.logger.error "Image to Figure Converter:", "Error occurred: #{e.message}"
end
