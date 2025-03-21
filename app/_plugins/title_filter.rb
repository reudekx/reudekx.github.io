module Jekyll
  module DocTitleFilter
    def doc_title(content)
      page = @context.registers[:page]

      title = %(<h1><a href="#{page["link"]}">)

      title += if page["title"]
        page["title"]
      elsif page["name"]
        File.basename(page["name"], ".*")
      else
        "무제"
      end

      title += %(</a></h1>)

      title
    end
  end
end

Liquid::Template.register_filter(Jekyll::DocTitleFilter)
