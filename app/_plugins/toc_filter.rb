require "nokogiri"

module Jekyll
  module DocTOCFilter
    def doc_toc(content)
      doc = Nokogiri::HTML(content)
      toc = ""
      prev_level = 0
      numbers = []

      doc.css("h2, h3, h4, h5, h6").each do |heading|
        level = heading.name[1].to_i - 1

        # # 각주 링크 제거
        # heading_clone = heading.clone

        # heading_clone.css("sup[id^='fnref:']").each(&:remove)

        sec_title = heading.inner_html

        if level > prev_level
          (level - prev_level).times do
            numbers.push(0)
            toc += %(<ul>)
          end
        elsif level < prev_level
          (prev_level - level).times do
            numbers.pop
            toc += %(</ul>)
          end
        end

        numbers[level - 1] = numbers[level - 1].to_i + 1

        # 섹션 ID 생성
        sec_id = numbers[0..level - 1].join("-")

        sec_num = numbers[0..level - 1].join(".") + "."

        toc += %(<li><a href="#sec-#{sec_id}" class="toc-sec-num">#{sec_num}</a> <span class="toc-sec-title">#{sec_title}</span></li>)
        prev_level = level
      end

      toc += %(</ul>) * prev_level
      toc
    end
  end
end

Liquid::Template.register_filter(Jekyll::DocTOCFilter)
