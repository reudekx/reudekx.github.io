require "cgi"
require "uri"

module Jekyll
  module WikiUtils
    def self.escape_url(url)
      url.split("/").map { |part| CGI.escape(part) }.join("/")
    end

    # 공통 HTML 생성 함수 추가
    def self.render_info_list(docs_list)
      html = %(<ul class="info-list">)

      docs_list.each do |doc|
        html += "<li>"
        html += %(<span class="info-title"><a href="#{doc["url"]}">#{doc["title"]}</a></span>)
        if doc["updated_at"]
          html += %(<span class="info-date">#{doc["updated_at"].strftime("%Y-%m-%d")}</span>)
        end
        if doc["tags"] && !doc["tags"].empty?
          html += %(<span class="info-tag-list">)
          html += doc["tags"].map { |tag| %(<a href="#{escape_url("/tags/#{tag}")}" class="info-tag">##{tag}</a>) }.join(" ")
          html += %(</span>)
        end
        if doc["summary"]
          html += %(<br><span class="info-summary">&#8251; #{doc["summary"]}</span>)
        end
        html += "</li>"
      end

      html += "</ul>"

      html
    end

    def self.get_docs_list(collection)
      return [] unless collection

      docs_list = []

      collection.docs.each do |doc|
        next if doc["generated"] == true
        next if doc.url == "/wiki"

        title = CGI.unescape(doc.url.sub(/^\/wiki\//, ""))

        doc_info = {
          "title" => title,
          "url" => doc.url,
          "summary" => doc["summary"],
          "updated_at" => doc["updated_at"]
        }

        if doc.data["tags"]
          tags = doc.data["tags"]
          tags = [tags] unless tags.is_a?(Array)
          doc_info["tags"] = tags.map(&:to_s).reject(&:empty?)
        end

        docs_list << doc_info
      end

      docs_list = docs_list.sort_by { |doc| doc["title"].downcase }

      render_info_list(docs_list)
    end

    def self.get_recent_docs(collection, limit = nil)
      return [] unless collection

      recent_docs = []

      collection.docs.each do |doc|
        next if doc["generated"] == true
        next if doc.url == "/wiki"

        title = CGI.unescape(doc.url.sub(/^\/wiki\//, ""))

        doc_info = {
          "title" => title,
          "url" => doc.url,
          "summary" => doc["summary"],
          "updated_at" => doc["updated_at"]
        }

        if doc.data["tags"]
          tags = doc.data["tags"]
          tags = [tags] unless tags.is_a?(Array)
          doc_info["tags"] = tags.map(&:to_s).reject(&:empty?)
        end

        recent_docs << doc_info
      end
      recent_docs = recent_docs.sort_by { |doc| doc["updated_at"] || Time.new(1970, 1, 1) }.reverse

      if limit
        recent_docs = recent_docs.take(limit)
      end

      render_info_list(recent_docs)
    end

    def self.get_child_docs(collection, page)
      return [] unless collection

      child_docs = []

      page_path = CGI.unescape(page["url"])

      collection.docs.each do |doc|
        next if doc["generated"] == true

        doc_path = CGI.unescape(doc.url)

        next if doc_path == page_path

        doc_dir = File.dirname(doc_path)

        next if doc_dir != page_path

        doc_info = {
          "title" => doc["title"],
          "url" => doc.url,
          "summary" => doc["summary"],
          "updated_at" => doc["updated_at"]
        }

        if doc.data["tags"]
          tags = doc.data["tags"]
          tags = [tags] unless tags.is_a?(Array)
          doc_info["tags"] = tags.map(&:to_s).reject(&:empty?)
        end

        child_docs << doc_info
      end

      child_docs = child_docs.sort_by { |doc| doc["title"].downcase }

      render_info_list(child_docs)
    end

    def self.get_subdirs(collection, page)
      return [] unless collection

      subdirs = {}
      subdir_counts = {}

      page_path = CGI.unescape(page["url"])

      collection.docs.each do |doc|
        next if doc["generated"] == true

        doc_path = CGI.unescape(doc.url)
        next if doc_path == page_path

        doc_dir = File.dirname(doc_path)

        next unless doc_dir.start_with?(page_path)

        relative_path = doc_dir[page_path.length..]
        next if relative_path.empty?

        first_subdir = relative_path.start_with?("/") ? relative_path[1..].split("/").first : relative_path.split("/").first
        next if first_subdir.nil? || first_subdir.empty?

        first_subdir_path = page_path.end_with?("/") ? "#{page_path}#{first_subdir}" : "#{page_path}/#{first_subdir}"

        subdirs[first_subdir_path] ||= {
          "url" => escape_url(first_subdir_path),
          "title" => first_subdir
        }

        subdir_counts[first_subdir_path] ||= {"docs" => 0, "subdirs" => 0, "subdir_paths" => []}

        if doc_dir == first_subdir_path
          subdir_counts[first_subdir_path]["docs"] += 1
        end
      end

      collection.docs.each do |doc|
        next if doc["generated"] == true

        doc_path = CGI.unescape(doc.url)
        doc_dir = File.dirname(doc_path)

        subdirs.keys.each do |subdir_path|
          if doc_dir.start_with?(subdir_path + "/")
            relative_to_subdir = doc_dir[subdir_path.length + 1..]

            if relative_to_subdir && !relative_to_subdir.empty?
              direct_subdir = relative_to_subdir.split("/").first
              direct_subdir_path = "#{subdir_path}/#{direct_subdir}"

              unless subdir_counts[subdir_path]["subdir_paths"].include?(direct_subdir_path)
                subdir_counts[subdir_path]["subdir_paths"] << direct_subdir_path
                subdir_counts[subdir_path]["subdirs"] += 1
              end
            end
          end
        end
      end

      subdirs = subdirs.sort_by { |path, subdir| subdir["title"].downcase }

      docs_list = subdirs.map do |path, subdir|
        doc_count = subdir_counts[path] ? subdir_counts[path]["docs"] : 0
        subdir_count = subdir_counts[path] ? subdir_counts[path]["subdirs"] : 0

        {
          "title" => subdir["title"],
          "url" => subdir["url"],
          "summary" => "#{doc_count}개의 하위 문서와 #{subdir_count}개의 서브 디렉터리가 있습니다."
        }
      end

      render_info_list(docs_list)
    end

    def self.get_tags(collection)
      return [] unless collection

      tags = {}

      collection.docs.each do |doc|
        next if doc["generated"] == true
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

      tags = tags.sort_by { |tag, count| tag.downcase }

      docs_list = tags.map do |tag, count|
        {
          "title" => tag,
          "url" => "/tags/#{CGI.escape(tag)}",
          "summary" => "#{count}개의 문서가 있습니다."
        }
      end

      render_info_list(docs_list)
    end

    def self.get_docs_by_tag(collection, tag)
      return [] unless collection

      tag_docs = []

      collection.docs.each do |doc|
        next if doc["generated"] == true
        next unless doc.data["tags"]

        tags = doc.data["tags"]
        tags = [tags] unless tags.is_a?(Array)

        next unless tags.include?(tag)

        doc_info = {
          "title" => doc["title"],
          "url" => doc.url,
          "summary" => doc["summary"],
          "updated_at" => doc["updated_at"]
        }

        doc_info["tags"] = tags.map(&:to_s).reject(&:empty?)

        tag_docs << doc_info
      end

      tag_docs = tag_docs.sort_by { |doc| doc["title"].downcase }

      render_info_list(tag_docs)
    end
  end
end
