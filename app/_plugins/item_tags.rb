module Jekyll
  class DocsListTag < Liquid::Tag
    def render(context)
      site = context.registers[:site]
      collection = site.collections["wiki"]

      WikiUtils.get_docs_list(collection)
    end
  end
end

Liquid::Template.register_tag("docs_list", Jekyll::DocsListTag)

module Jekyll
  class RecentDocsTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @limit = text.strip.empty? ? nil : text.strip.to_i
    end

    def render(context)
      site = context.registers[:site]
      collection = site.collections["wiki"]

      WikiUtils.get_recent_docs(collection, @limit)
    end
  end
end

Liquid::Template.register_tag("recent_docs", Jekyll::RecentDocsTag)

module Jekyll
  class ChildDocsTag < Liquid::Tag
    def render(context)
      site = context.registers[:site]
      collection = site.collections["wiki"]
      page = context.registers[:page]

      WikiUtils.get_child_docs(collection, page)
    end
  end
end

Liquid::Template.register_tag("child_docs", Jekyll::ChildDocsTag)

module Jekyll
  class SubdirsTag < Liquid::Tag
    def render(context)
      site = context.registers[:site]
      collection = site.collections["wiki"]
      page = context.registers[:page]

      WikiUtils.get_subdirs(collection, page)
    end
  end
end

Liquid::Template.register_tag("subdirs", Jekyll::SubdirsTag)

module Jekyll
  class TagsTag < Liquid::Tag
    def render(context)
      site = context.registers[:site]
      collection = site.collections["wiki"]

      WikiUtils.get_tags(collection)
    end
  end
end

Liquid::Template.register_tag("tags", Jekyll::TagsTag)

module Jekyll
  class DocsByTagTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @tag = text.strip
    end

    def render(context)
      site = context.registers[:site]
      collection = site.collections["wiki"]

      tag = context[@markup.strip] || @tag

      WikiUtils.get_docs_by_tag(collection, tag)
    end
  end
end

Liquid::Template.register_tag("docs_by_tag", Jekyll::DocsByTagTag)
