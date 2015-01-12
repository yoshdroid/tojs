# -*- coding: utf-8 -*-

#
# AlcanaCard
# csvファイル カード情報を格納する
#
class AlcanaCard
  attr_reader :id, :type
  attr_reader :name, :rarity, :cost, :color
  attr_reader :tribe, :basebp, :ability
  attr_accessor :lv, :bp, :tapped, :attackable
  attr_accessor :status_till_turnend
  attr_accessor :status_always
  attr_accessor :status_forever
  attr_accessor :status_thorough_battle
  attr_accessor :destructed, :vanished
  
  def initialize(info)
    # csv記載 ここから
    @id      = info[0]
    @type    = info[1]
    @name    = info[2]
    @rarity  = info[3]
    @cost    = info[4].to_i
    @color   = info[5]
    @tribe   = info[6]
    @basebp  = []; 7.upto(9) { |i| @basebp.push(info[i].to_i) }
    @ability = []; 10.upto(info.length - 1) { |i| @ability.push(info[i]) }
    # csv記載 ここまで
    # 以下適宜追加
    # ユニット/進化ユニットは、手札時点でレベルの概念がある(override)
    if (@type == 'Unit' || @type == 'Evolve')
      @lv = 1
      @bp = @basebp[@lv - 1]
      @tapped = false
      if (@type == 'Unit')
        @attackable = false
        # 【SpeedMove】は登場時 true、ただし先攻 1turn目のみ false
      else
        @attackable = true
        # ただし先攻 1turnのみ false、進化元が tappedのとき false
      end
      # BP変動/追加ability展開 for ユニット
      # Turn終了まで有効
      @status_till_turnend = []
      # 常時有効
      @status_always = []
      # 常時有効、かつフィールド判定不要
      @status_forever = []
      # 戦闘終了まで有効
      @status_through_battle = []
      # 破壊フラグ fieldからtrash移動時に falseに戻す
      @destructed = false
    end
    # 消滅フラグ 本家ではデッキアウト時に復活するが、仕様改変予定
    @vanished = false
  end
  
end # AlcanaCard

#
# 複数の csvファイルから一行ずつ card生成する
# (classでためしたとき、外から各変数が参照できず？、とりあえず moduleにしてみた)
#
module CardGenerator
#  ListName = [
#    "cardlist_v1_0",
#    #"cardlist_v1_0_EX",
#    #"cardlist_v1_1",
#    #"cardlist_v1_1_EX1",
#    #"cardlist_v1_1_EX2",
#    #"cardlist_v1_2",
#    #"cardlist_v1_2_EX",
#    #"cardlist_PR",
#  ]
  ListName = %w(
    cardlist_v1_0
  )
    #cardlist_v1_0_EX
    #cardlist_v1_1
    #cardlist_v1_1_EX1
    #cardlist_v1_1_EX2
    #cardlist_v1_2
    #cardlist_v1_2_EX
    #cardlist_PR
    #cardlist_Joker
#p ListName

  def execute
    cards = []
    ListName.each { |n|
      open('./cards/'+n+'.csv', encoding:'Shift_JIS:UTF-8') { |f|
        until !(line = f.gets)
          next if line =~ /^\s*$/
          next if line =~ /^\s*\#/
          info = line.chomp.split(/\s*,\s*/)
          cards.push(AlcanaCard.new(info))
        end
      }
    }
    return cards
  end
  
  module_function :execute
end # CardGenerator

#---------------- tentative check ----------------
=begin

cards = []
open("cardlist_v1_0.csv", encoding: 'Shift_JIS:UTF-8') { |file|
  until !(line = file.gets)
    next if line =~ /^\s*$/
    next if line =~ /^\s*\#/
    info = line.chomp.split(/\s*,\s*/)
    cards.push(AlcanaCard.new(info))
  end
}

#p cards
#cards.collect {|c| p c if c.tribe == "Beast" }
#cards.collect {|c| p c.name if c.tribe == "獣" }
#cards.collect {|c| p c if c.tribe == "神" }
#cards.collect {|c| p c.name if c.tribe == "神" }
#cards.collect {|c| p c.name if c.color == "Blue" }
#cards.collect {|c| p c.name if c.type == "Trigger" }

cards.collect {|c| p c.name.to_s }

=end
