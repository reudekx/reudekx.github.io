require "cgi"

module Jekyll
  class DocsListGenerator < Generator
    safe true
    priority :low

    def generate(site)
      collection = site.collections["wiki"]
      return unless collection

      docs_list_doc = Jekyll::Document.new(
        File.join(collection.directory, "/meta/docs.md"),
        site: site,
        collection: collection
      )

      docs_list_doc.data.merge!({
        "title" => "문서 목록",
        "summary" => "위키의 모든 문서 목록입니다",
        "layout" => "docs_list",
        "permalink" => "/docs",
        "generated" => true
      })

      collection.docs << docs_list_doc
    end
  end
end
