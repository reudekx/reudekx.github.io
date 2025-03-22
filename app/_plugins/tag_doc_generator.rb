module Jekyll
  class TagDocGenerator < Generator
    safe true
    priority :low

    def generate(site)
      collection = site.collections["wiki"]
      return unless collection

      tags = collect_tags(collection)
      # return if tags.empty?

      generate_tag_list_doc(site, collection)

      tags.each_key do |tag|
        generate_tag_doc(site, collection, tag)
      end
    end

    private

    def collect_tags(collection)
      tags = {}

      collection.docs.each do |doc|
        next unless doc.data["tags"]

        doc_tags = doc.data["tags"]
        doc_tags = [doc_tags] unless doc_tags.is_a?(Array)

        doc_tags.each do |doc_tag|
          doc_tag = doc_tag.to_s.strip
          next if doc_tag.empty?

          tags[doc_tag] ||= 0
          tags[doc_tag] += 1
        end
      end

      tags
    end

    def generate_tag_list_doc(site, collection)
      tag_list_doc = Jekyll::Document.new(
        File.join(collection.directory, "/meta/tags.md"),
        site: site,
        collection: collection
      )

      tag_list_doc.data.merge!({
        "title" => "태그 목록",
        "summary" => "모든 태그 목록",
        "layout" => "tag_list",
        "permalink" => "/tags",
        "generated" => true
      })

      collection.docs << tag_list_doc
    end

    def generate_tag_doc(site, collection, tag)
      tag_doc = Jekyll::Document.new(
        File.join(collection.directory, "/meta/tags/#{tag}.md"),
        site: site,
        collection: collection
      )

      tag_doc.data.merge!({
        "title" => %(##{tag}),
        "summary" => %("#{tag}" 태그가 붙은 문서 목록),
        "layout" => "tag",
        "tag" => tag,
        "permalink" => "/tags/#{tag}",
        "generated" => true
      })

      collection.docs << tag_doc
    end
  end
end
