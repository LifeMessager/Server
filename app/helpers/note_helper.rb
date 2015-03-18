# coding: utf-8

module NoteHelper
  def self.clean_content content
    # 将过多的换行符变成正常的换行符
    formatted_content = content.gsub(/\r/, '').gsub(/\n{3,}/, "\n\n")
    # 纯文本模式下，很多邮件客户端会在 80 个字符后插入一个换行符，需要删除
    unexpected_linebreak_cleaned = formatted_content.gsub(/(?<!\n)\n(?!\n)/, '')
    # 去除最后一段和下一行的换行符
    unexpected_linebreak_cleaned.gsub(/(\n$){2,}/, '')
  end
end
