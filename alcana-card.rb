# coding: utf-8
# 2015.4.14 re-make version.2

require_relative "./alcana-rules.rb"
#-----------------------------------------------------------

#
# AlcanaCard: base class
#
class AlcanaCard
  include AlcanaRules
  
  def initialize(cardid, cardname)
    @cardid   = cardid
    @cardname = cardname
  end
  
  attr_reader :cardid, :cardname
end # AlcanaCard

#
# SetClockControl: クロックアップ/ダウン、レベル操作
#                  UnitCard/EvolveCardに適用される
#
module SetClockControl
  def clockup
    self.override
  end
  
  def clockdown
    if @level > 1
      @level -= 1
      set_basebp
    else
      puts @cardname + " is already level 1"
    end
  end
  
  def setlevel(level)
    if (1 <= level) && (level <= UnitLevelLimit)
      @level = level
      set_basebp
    else
      puts "Level " + level.to_s + " is invalid"
    end
  end
end # SetClockControl

#
# SetAttrVanish: 消滅操作付与
#
module SetAttrVanish
  attr_reader :vanished
  
  def vanish
    @vanished = true
  end
  
  def unvanish
    @vanished = false
  end
end # SetAttrVanish


#-----------------------------------------------------------

#
# UnitCard < AlcanaCard
#
class UnitCard < AlcanaCard
  include SetClockControl
  include SetAttrVanish
  
  attr_reader :cost, :rality, :color
  attr_reader :tribe, :level, :basebp, :bptable
  attr_reader :ability
  
  def add_info(unit_info, *ability)
    @rality   = unit_info[0]
    @cost     = unit_info[1]
    @color    = unit_info[2]
    @tribe    = unit_info[3]
    @bptable  = unit_info[4]
    @ability  = ability
    self.clean_status
  end
  
  def clean_status
    @level = 1
    set_basebp
  end
  
  def set_basebp
    @basebp = @bptable[@level - 1]
  end
  
  def override
    if @level < UnitLevelLimit
      @level += 1
      set_basebp
    else
      puts @name + " can't clock-up any more"
    end
  end
  
  def show_info
    str  = " CP" + @cost.to_s
    str += " " + @color
    str += " " + @cardname
    str += " LV" + @level.to_s
    str += " BP" + @basebp.to_s
    return str
  end
end # UnitCard

#
# EvolveCard < UnitCard (< AlcanaCard)
#
class EvloveCard < UnitCard
end # EvolveCard

#
# TriggerCard < AlcanaCard
#
class TriggerCard < AlcanaCard
  include SetAttrVanish
  
  attr_reader :cost, :rality, :color
  attr_reader :ability
  
  def add_info(trig_info, *ability)
    @rality  = trig_info[0]
    @cost    = trig_info[1]
    @color   = trig_info[2]
    @ability = ability
  end
  
  def show_info
    str  = " CP" + @cost.to_s
    str += " " + @color
    str += " " + @cardname
    return str
  end
end # TriggerCard

#
# InterceptCard < AlcanaCard
#
class InterceptCard < AlcanaCard
  include SetAttrVanish
  
  attr_reader :cost, :rality, :color
  attr_reader :ability
  
  def add_info(incep_info, *ability)
    @rality  = incep_info[0]
    @cost    = incep_info[1]
    @color   = incep_info[2]
    @ability = ability
  end
  
  def show_info
    str  = " CP" + @cost.to_s
    str += " " + @color
    str += " " + @cardname
    return str
  end
end # InterceptCard

#
# JokerCard < AlcanaCard
#

# TODO

#-----------------------------------------------------------


#
# GenCardList: 使用できるカード一覧の生成
#
module GenCardList
  ListName = %w(
    cardlist_v1_0
  )
    #cardlist_v1_1
    #cardlist_v1_2
    #cardlist_v1_3
    #cardlist_PR
    #cardlist_Joker
  
  def execute
    cards = []
    ListName.each { |n|
      # 入力ファイルは Shift_JISで保存されている？
      open("./"+n+".csv", encoding:'Shift_JIS:UTF-8') { |f|
        until !(line = f.gets)
          next if line =~ /^\s*$/
          next if line =~ /^\s*\#/
          info = line.chomp.split(/\s*,\s*/)
          cardid   = info[0]
          type     = info[1]
          cardname = info[2]
          rality   = info[3]
          cost     = info[4].to_i
          color    = info[5]
          tribe    = info[6]
          bptable  = [info[7].to_i,info[8].to_i,info[9].to_i]
          card_info = [rality, cost, color, tribe, bptable]
          ability  = []
          #ability.push(info[10]~info[end])
          case type
          when "Unit"
            card = UnitCard.new(cardid, cardname)
          when "Evolve"
            card = EvloveCard.new(cardid, cardname)
          when "Trigger"
            card = TriggerCard.new(cardid, cardname)
          when "Intercept"
            card = InterceptCard.new(cardid, cardname)
          when "Joker"
          end
          card.add_info(card_info, ability)
          cards.push(card)
        end
      }
    }
    return cards
  end
  
  module_function :execute
end # GenCardList

#================================ tentative check ================================
#=begin

require "pp"
cardlist = GenCardList.execute
#pp cardlist
cardlist.collect { |c| puts c.show_info }

#=end
