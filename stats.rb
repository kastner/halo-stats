require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'memcache'

class HaloPlayer
  BASE = "http://haloapi.com/api/player/"
  #http://www.haloapi.com/api/player/maps/ranked/index.php?gamertag=%s&key=%s
  
  attr_reader :gamertag
  
  def initialize(gamertag, api_key)
    @key = api_key
    @gamertag = gamertag
  end
  
  def call(options = {})
    Hpricot.XML(url_contents(options))
  end
  
  def url_contents(options = {})
    open(url(options)).read
  end
  
  def url(options = {})
    method = options.delete(:method)
    options.merge!({ :key => @key, :gamertag => @gamertag })
    options = options.sort { |a,b| a.to_s <=> b.to_s }
    BASE + method + "index.php?" + options.map{|k,v| "#{k}=#{v}"}.join("&")
  end
  
  def general
    @general ||= sub_hash(call(:method => "").at("root"))
  end
  
  def sub_hash(node)
    return {} unless node

    hash = {}
    node.children.map do |elem|
      if elem.children.size > 1
        hash[elem.name] = sub_hash(elem)
      else
        hash[elem.name] = elem.children.first.to_s
      end
    end
    hash
  end
end

if $0 == __FILE__
  KEY = "TESTKEY"
  require 'test/spec'
  require 'mocha'
  
  describe "the HaloPlayer class" do
    setup do
      @yonnage = HaloPlayer.new("yonnage", KEY)
    end
    
    it "should have the gamertag available outside of itself" do
      @yonnage.gamertag.should == "yonnage"
    end
    
    it "should not have the api key available outside" do
      should.raise(NoMethodError) { @yonnage.key }
    end
    
    it "should generate the proper url for the halostats service" do
      @yonnage.url(:method => "").should == "http://haloapi.com/api/player/index.php?gamertag=yonnage&key=#{KEY}"
    end
  end
  
  describe "a call to the player stats" do
    setup do
      @yonnage = HaloPlayer.new("yonnage", KEY)
      @yonnage.stubs(:url_contents).with(any_parameters).returns(XML_DATA)
    end
    
    it "should return # of campaignMissions" do
      @yonnage.general["campaignMissions"].should == "10"
    end
    
    it "should access sub stuff" do
      @yonnage.general["ranked"]["kills"].should == "4881"
    end
    
    it "should also get sub sub stuff" do
      @yonnage.general["ranked"]["weapons"]["Melee"].should == "965"
    end
  end
end

XML_DATA = %q{<?xml version="1.0" encoding="UTF-8"?>
<root><gamertag>Yonnage</gamertag><calltag>K77</calltag><totalGames>1140</totalGames><matchmadeGames>999</matchmadeGames><customGames>131</customGames><campaignMissions>10</campaignMissions><highestSkill>31</highestSkill><experience>616</experience><enemiesKIA>204</enemiesKIA><lastPlayed>5/7/2008</lastPlayed><firstPlayed>9/21/2007</firstPlayed><rank>Major, Grade 3</rank><imageOfRank>http://www.bungie.net/images/halo3stats/xp/aa8b3c7d-aa10-4099-8af4-06b2d546e59b.gif</imageOfRank><imageOfPlayer>http://www.bungie.net/Stats/Halo3/PlayerModel.ashx?p1=0&amp;p2=0&amp;p3=5&amp;p4=5&amp;p5=0&amp;p6=0&amp;p7=1&amp;p8=1</imageOfPlayer><emblem>http://www.bungie.net/Stats/halo2emblem.ashx?s=70&amp;0=0&amp;1=19&amp;2=24&amp;3=10&amp;fi=29&amp;bi=20&amp;fl=1&amp;m=1</emblem><ranked><kills>4881</kills><deaths>4852</deaths><kDRatio>1.01</kDRatio><games>422</games><weapons><BattleRifle>1159</BattleRifle><Melee>965</Melee><AssaultRifle>712</AssaultRifle><FragGrenade>373</FragGrenade><Shotgun>277</Shotgun><SniperRifle>201</SniperRifle><RocketLauncher>167</RocketLauncher><Guardians>163</Guardians><PlasmaGrenade>142</PlasmaGrenade><Needler>119</Needler><Mauler>80</Mauler><EnergySword>76</EnergySword><WarthogGunner>66</WarthogGunner><Spiker>59</Spiker><Carbine>50</Carbine><Ghost>39</Ghost><Banshee>24</Banshee><BeamRifle>22</BeamRifle><SpikeGrenade>22</SpikeGrenade><MissilePod>21</MissilePod><Magnum>21</Magnum><GravityHammer>19</GravityHammer><BruteShot>13</BruteShot><WarthogDriver>13</WarthogDriver><HeavyMachineGun>12</HeavyMachineGun><Chopper>12</Chopper><FlameThrower>11</FlameThrower><Ball>11</Ball><SpartanLaser>10</SpartanLaser><Explosion>7</Explosion><SubMachineGun>5</SubMachineGun><PlasmaRifle>5</PlasmaRifle><WraithDriver>3</WraithDriver><Fall>1</Fall><Mongoose>1</Mongoose></weapons><medals><KillingSpree>110</KillingSpree><KillingFrenzy>9</KillingFrenzy><ShotgunSpree>4</ShotgunSpree><SniperSpree>2</SniperSpree><DoubleKill>309</DoubleKill><TripleKill>16</TripleKill><Overkill>1</Overkill><BeatDown>900</BeatDown><Assassin>171</Assassin><SniperKill>87</SniperKill><GrenadeStick>78</GrenadeStick><LaserKill>10</LaserKill><OddballKill>11</OddballKill><Incineration>11</Incineration><Killjoy>111</Killjoy><DeathfromtheGrave>58</DeathfromtheGrave><Splatter>24</Splatter><Highjacker>3</Highjacker><Bulltrue>7</Bulltrue><Wheelman>91</Wheelman><Skyjacker>2</Skyjacker><KilledFlagCarrier>7</KilledFlagCarrier><FlagScore>1</FlagScore><KilledBombCarrier>1</KilledBombCarrier><Steaktacular>27</Steaktacular><Linktacular>3</Linktacular></medals></ranked><social><kills>6128</kills><deaths>5391</deaths><kDRatio>1.14</kDRatio><games>571</games><weapons><Melee>1026</Melee><BattleRifle>953</BattleRifle><AssaultRifle>922</AssaultRifle><SniperRifle>412</SniperRifle><GravityHammer>358</GravityHammer><FragGrenade>341</FragGrenade><Shotgun>312</Shotgun><RocketLauncher>291</RocketLauncher><Guardians>273</Guardians><PlasmaGrenade>168</PlasmaGrenade><EnergySword>165</EnergySword><Needler>125</Needler><Banshee>110</Banshee><WarthogGunner>76</WarthogGunner><SubMachineGun>58</SubMachineGun><BruteShot>53</BruteShot><MissilePod>53</MissilePod><HeavyMachineGun>53</HeavyMachineGun><Chopper>50</Chopper><Mauler>48</Mauler><SpartanLaser>40</SpartanLaser><SpikeGrenade>39</SpikeGrenade><BeamRifle>31</BeamRifle><Ghost>30</Ghost><Carbine>29</Carbine><Spiker>29</Spiker><Magnum>26</Magnum><WarthogDriver>14</WarthogDriver><Explosion>10</Explosion><Elephant>10</Elephant><FlameThrower>10</FlameThrower><PlasmaRifle>3</PlasmaRifle><Ball>3</Ball><Bomb>2</Bomb><Fall>2</Fall><Flag>1</Flag><Tripmine>1</Tripmine><WraithDriver>1</WraithDriver></weapons><medals><Extermination>3</Extermination><KillingSpree>158</KillingSpree><KillingFrenzy>13</KillingFrenzy><ShotgunSpree>5</ShotgunSpree><SwordSpree>2</SwordSpree><SniperSpree>6</SniperSpree><SplatterSpree>1</SplatterSpree><VehicularManslaughter>1</VehicularManslaughter><DoubleKill>392</DoubleKill><TripleKill>47</TripleKill><Overkill>15</Overkill><Killtacular>4</Killtacular><Killtrocity>1</Killtrocity><Killimanjaro>1</Killimanjaro><Killtastrophe>1</Killtastrophe><BeatDown>1323</BeatDown><Assassin>232</Assassin><SniperKill>172</SniperKill><GrenadeStick>89</GrenadeStick><LaserKill>40</LaserKill><OddballKill>3</OddballKill><FlagKill>1</FlagKill><Incineration>10</Incineration><Killjoy>149</Killjoy><DeathfromtheGrave>58</DeathfromtheGrave><Splatter>55</Splatter><Highjacker>2</Highjacker><Bulltrue>19</Bulltrue><Wheelman>141</Wheelman><Skyjacker>1</Skyjacker><LastManStanding>2</LastManStanding><KilledFlagCarrier>9</KilledFlagCarrier><FlagScore>5</FlagScore><KilledJuggernaut>9</KilledJuggernaut><KilledVIP>29</KilledVIP><KilledBombCarrier>40</KilledBombCarrier><BombPlanted>18</BombPlanted><InfectionSpree>1</InfectionSpree><ZombieKillingSpree>1</ZombieKillingSpree><JuggernautSpree>1</JuggernautSpree><Steaktacular>53</Steaktacular><Linktacular>2</Linktacular></medals></social></root>}