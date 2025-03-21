require "cgi"

module Jekyll
  class DirDocGenerator < Generator
    safe true
    priority :low

    def generate(site)
      collection = site.collections["wiki"]
      return unless collection

      # 디렉터리 정보 수집
      dirs = collect_dirs(collection)
      return if dirs.empty?

      # 각 디렉터리별 문서 생성
      dirs.each do |dir, is_dir|
        next unless is_dir
        generate_dir_doc(site, collection, dir)
      end
    end

    private

    def collect_dirs(collection)
      dirs = {}

      collection.docs.each do |doc|
        doc_path = CGI.unescape(doc.url)
        cur_dir = File.dirname(doc_path)

        dirs[doc_path] = false

        while cur_dir != "/"
          dirs[cur_dir] = true unless dirs.key?(cur_dir)
          cur_dir = File.dirname(cur_dir)
        end
      end

      dirs
    end

    def generate_dir_doc(site, collection, dir)
      dir_doc = Jekyll::Document.new(
        File.join(collection.directory, "#{dir}.md"),
        site: site,
        collection: collection
      )

      dir_doc.data.merge!({
        "title" => File.basename(dir),
        "summary" => %("#{File.basename(dir)}" 디렉터리에 속한 문서 목록),
        "layout" => "directory",
        "generated" => true
      })

      collection.docs << dir_doc
    end
  end
end
