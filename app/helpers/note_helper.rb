# coding: utf-8
module NoteHelper
  def self.clean_content content
    content.gsub(/\r\n/, "\n\n")
      .gsub(/\n{3,}/, "\n\n")
      .gsub(/(\n$){2,}/, '') # 去除最后一段和下一行的换行符
  end
end
