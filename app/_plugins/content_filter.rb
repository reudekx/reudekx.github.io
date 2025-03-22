require "nokogiri"

module Jekyll
  module DocContentFilter
    def doc_content(content)
      doc = Nokogiri::HTML(content)

      numbers = []  # 현재 섹션 번호를 저장
      prev_level = 0  # 이전 헤딩의 레벨

      doc.css("h1").remove

      doc.css("h2, h3, h4, h5, h6").each do |heading|
        level = heading.name[1].to_i - 1

        # 레벨에 따른 번호 조정
        if level > prev_level
          # 더 깊은 레벨로 들어갈 때
          (level - prev_level).times { numbers.push(0) }
        elsif level < prev_level
          # 상위 레벨로 올라갈 때
          (prev_level - level).times { numbers.pop }
        end

        # 현재 레벨의 번호 증가
        numbers[level - 1] = numbers[level - 1].to_i + 1

        # ID 생성
        id = numbers[0..level - 1].join("-")

        # sec_num = numbers[0..level - 1].join(".")

        # 기존 링크 보존하면서 번호 추가
        heading.inner_html = if heading.name == "h2"
          %(<div id="sec-#{id}" class="sec-title">#{heading.inner_html}</div><a href="#toc" class="toc-backlink">&#8634;</a>)
        # elsif heading.name == "h3"
        #   %(<div id="sec-#{id}" class="sec-title">#{numbers[level - 1]}. #{heading.inner_html}</div>)
        else
          %(<div id="sec-#{id}" class="sec-title">#{heading.inner_html}</div>)
        end

        # heading.inner_html = %(<div id="sec-#{id}" class="sec-title"><a href="#toc" class="toc-backlink">#</a> <span class="sec-title-text">#{heading.inner_html}</span></div>)
        # heading.inner_html = %(<div id="sec-#{id}" class="sec-title"><span class="sec-title-text">#{heading.inner_html}</span></div>)

        prev_level = level
      end

      doc.to_html
    end
  end
end

Liquid::Template.register_filter(Jekyll::DocContentFilter)
