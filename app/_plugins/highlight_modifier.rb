Jekyll::Hooks.register [:pages, :documents, :posts], :post_convert do |item|
  modified_content = item.content.dup

  code_pattern = /<div class="language-(\w+) highlighter-rouge"><div class="highlight"><pre class="highlight"><code>(.*?)<\/code><\/pre><\/div><\/div>/im

  modified_content.gsub!(code_pattern) do |match|
    language = $1
    code_content = $2

    %(<figure class="code-highlight">
      <figcaption>#{language}</figcaption>
      <div class="language-#{language} highlighter-rouge"><div class="highlight"><pre class="highlight"><code>#{code_content}</code></pre></div></div>
    </figure>)
  end

  item.content = modified_content
rescue => e
  Jekyll.logger.error "Code Block to Figure Converter:", "Error occurred: #{e.message}"
end
