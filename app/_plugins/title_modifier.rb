Jekyll::Hooks.register :pages, :pre_render do |page|
  unless page.data.key?("title")
    filename = File.basename(page.path, ".*")
    page.data["title"] = filename
  end
end

Jekyll::Hooks.register :documents, :post_init do |doc|
  if doc.data["title"].nil? || doc.data["title"].empty?
    doc.data["title"] = File.basename(doc.basename, ".*")
  end
end
