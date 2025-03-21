Jekyll::Hooks.register [:pages, :documents, :posts], :post_convert do |item|
  if item.content.include?('<div class="footnotes" role="doc-endnotes">')
    item.content.gsub!(/<li id="fn:(\w+)">.*?<p>(.*?)<a href="#fnref:\1" class="reversefootnote".*?>.*?<\/a><\/p>/m) do |footnote|
      id = $1
      text = $2
      %(<li id="fn:#{id}">
        <p><a href="#fnref:#{id}" class="reversefootnote" role="doc-backlink">↩</a> #{text}</p>
      </li>)
    end
  end
rescue => e
  Jekyll.logger.error "Footnote Modifier:", "Error occurred: #{e.message}"
end
