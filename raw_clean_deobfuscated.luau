local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
LocalPlayer = Players.LocalPlayer
end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)
if _G.SerennityHuntingCleanup then
pcall(_G.SerennityHuntingCleanup)
end
local Connections: { RBXScriptConnection } = {}
local ScriptAlive = true
local CONFIG_FILE = "serennity_hunting_v1.json"
local DISCORD_INVITE = "https://discord.gg/3K6BSxhAkn"
local SCRIPT_VERSION = "v1.6"
local DefaultConfig = {
AutoProgression = false,
AutoMainQuest = false,
AutoDailyRepeatQuest = false,
AutoUnlockBossGates = false,
AutoRestockBossPotions = false,
SelectedHpPotionTier = "Red Potion (M) - 20% HP (100 Silver)",
SelectedSpPotionTier = "Blue Potion - 20% SP (200 Silver)",
MinPotionCheckCount = 20,
BuyPotionQuantity = 50,
AutoFarmZone = false,
CombatMode = "Behind",
OrbitDistance = 5.5,
OrbitSpeed = 2.0,
AntiLeashBoundary = false,
MaxLeashRadius = 22,
AutoDodgeBossSkills = false,
SelectedZone = "Auto Best Zone (Lv.1-99)",
TargetPriority = "Smart Leveling (Normal First)",
AutoBossHunter = false,
HuntBoss01 = false,
HuntBoss02 = false,
HuntBoss03 = false,
HuntBoss04 = false,
HuntBoss05 = false,
SelectedBosses = {
["Boss01 (Gorilla King Lv.25)"] = true,
["Boss02 (Sabertooth Lv.50)"] = true,
["Boss03 (Obsidian Pharaoh Lv.75)"] = true,
["Boss04 (Tempest Dragon Lv.99)"] = true,
["Boss05 (Volcano Turtle Lv.99)"] = true,
},
AutoCastSkills = false,
SkillCastMode = "Spam Mode (รัวตามเวลาที่ตั้ง)",
UseSlot1 = false,
UseSlot2 = false,
UseSlot3 = false,
UseSlot4 = false,
UseSlot5 = false,
UseSlot6 = false,
UseSlot7 = false,
UseSlot8 = false,
Slot1Delay = 0.1,
Slot2Delay = 0.2,
Slot3Delay = 0.2,
Slot4Delay = 0.5,
Slot5Delay = 0.2,
Slot6Delay = 0.2,
Slot7Delay = 0.2,
Slot8Delay = 0.2,
AutoUpgradeSkills = false,
AutoPickupDrops = false,
AutoOpenLootBoxes = false,
AutoPotion = false,
HpPotionThreshold = 60,
SpPotionThreshold = 35,
AutoRespawn = false,
AutoClaimBetaPet = false,
AutoClaimAllRewards = false,
AutoTrickOrTreat = false,
AutoHalloweenDungeon = false,
AutoEquipBest = false,
AutoAllocateStats = false,
StatBuildMode = "balance",
AutoRefineGear = false,
MaxRefineTarget = "+5",
RefineSlotWeapon = false,
RefineSlotBody = false,
RefineSlotGarment = false,
RefineSlotHeadTop = false,
RefineSlotHeadMid = false,
RefineSlotShoes = false,
RefineSlotAcc1 = false,
RefineSlotAcc2 = false,
AutoSellJunk = false,
SellJunkBagPct = 65,
AutoSellEquipment = false,
SellEquipBagPct = 60,
SellWeapons = false,
SellArmors = false,
SellRarityTier1 = false,
SellRarityTier2 = false,
SellRarityTier3 = false,
SellRarityTier4 = false,
SellRarityTier5 = false,
SellRarityTier6 = false,
KeepRefinedGear = false,
SelectedTeleportZone = "Field01 (Rabbit Field Lv.1-8)",
SelectedTeleportNpc = "blacksmith",
WalkOrTeleportMode = "Instant Teleport + Walk",
BoostFPS = false,
AntiAFK = false,
MenuKeybind = "RightControl",
}
_G.SerennityHuntConfig = {}
local Cfg = _G.SerennityHuntConfig
for k, v in pairs(DefaultConfig) do
if type(v) == "boolean" then
Cfg[k] = false
elseif type(v) == "table" then
if type(Cfg[k]) ~= "table" then
Cfg[k] = table.clone(v)
end
else
if Cfg[k] == nil then
Cfg[k] = v
end
end
end
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
local Shared = ReplicatedStorage:WaitForChild("Shared", 15)
local function safeRequire(modName: string)
if not Shared then return nil end
local mod = Shared:FindFirstChild(modName)
if not mod then return nil end
local ok, res = pcall(require, mod)
return ok and res or nil
end
local MapData = safeRequire("MapData") or {}
local QuestData = safeRequire("QuestData") or {}
local MonsterData = safeRequire("MonsterData") or {}
local ItemData = safeRequire("ItemData") or {}
local GearData = safeRequire("GearData") or {}
local GearUtil = safeRequire("GearUtil")
local GameConfig = safeRequire("GameConfig") or {}
local AchievementData = safeRequire("AchievementData") or {}
local BattlePassData = safeRequire("BattlePassData") or {}
local EventNpcData = safeRequire("EventNpcData") or {}
local SkillData = safeRequire("SkillData") or {}
local ClassRange = safeRequire("ClassRange")
local function decodeAttrJson(attrName: string): { [any]: any }
local raw = LocalPlayer:GetAttribute(attrName)
if type(raw) ~= "string" or raw == "" then
return {}
end
local ok, tbl = pcall(function()
return HttpService:JSONDecode(raw)
end)
if ok and type(tbl) == "table" then
return tbl
end
return {}
end
local function getNavMap(): { [any]: any }
local raw = ReplicatedStorage:GetAttribute("NavMapJson")
if type(raw) == "string" and raw ~= "" then
local ok, decoded = pcall(function()
return HttpService:JSONDecode(raw)
end)
if ok and type(decoded) == "table" then
return decoded
end
end
return {}
end
local ZONE_ORDER = {
{
Id = "Field01",
Label = "Field01 (Rabbit Field Lv.1-8)",
MinLv = 1, MaxLv = 8,
Pos = Vector3.new(0, 4.0, -203),
RepeatQuests = { { Id = "r01", ReqLv = 1 }, { Id = "r02", ReqLv = 5 } },
Monsters = { "budkin", "briar_sprite", "leader_briar_sprite", "boss_bramble_king" },
MiniBoss = "boss_bramble_king",
},
{
Id = "Field02",
Label = "Field02 (Boar Forest Lv.9-16)",
MinLv = 9, MaxLv = 16,
GateReq = "Field01",
Pos = Vector3.new(0, 32.0, -459),
RepeatQuests = { { Id = "r03", ReqLv = 9 }, { Id = "r04", ReqLv = 13 } },
Monsters = { "nectar_moth", "resin_beetle", "leader_resin_beetle", "boss_amber_goliath" },
MiniBoss = "boss_amber_goliath",
},
{
Id = "Field03",
Label = "Field03 (Bear Forest Lv.17-25)",
MinLv = 17, MaxLv = 25,
GateReq = "Field02",
Pos = Vector3.new(0, 60.0, -715),
RepeatQuests = { { Id = "r05", ReqLv = 17 } },
Monsters = { "glacier_hare", "borealis_fox", "leader_borealis_fox", "boss_aurora_ninetail" },
MiniBoss = "boss_aurora_ninetail",
},
{
Id = "Boss01",
Label = "Boss01 (Gorilla King Lv.25)",
MinLv = 25, MaxLv = 25,
GateReq = "Field03",
IsBossRoom = true,
BossId = "terra_colossus",
UnlocksGate = "Boss01",
Pos = Vector3.new(0, 60.0, -906),
PillarId = "Boss01",
},
{
Id = "Field04",
Label = "Field04 (Hyena Den Lv.26-33)",
MinLv = 26, MaxLv = 33,
GateReq = "Boss01",
Pos = Vector3.new(0, 60.0, -1097),
RepeatQuests = { { Id = "r06", ReqLv = 26 } },
Monsters = { "scarab_guard", "prickle_imp", "leader_prickle_imp", "boss_cactus_tyrant" },
MiniBoss = "boss_cactus_tyrant",
},
{
Id = "Field05",
Label = "Field05 (Rhino Thicket Lv.34-41)",
MinLv = 34, MaxLv = 41,
GateReq = "Field04",
Pos = Vector3.new(0, 88.0, -1353),
RepeatQuests = { { Id = "r07", ReqLv = 34 } },
Monsters = { "mire_toad", "reed_stalker", "leader_reed_stalker", "boss_mire_leviathan" },
MiniBoss = "boss_mire_leviathan",
},
{
Id = "Field06",
Label = "Field06 (Tiger Thicket Lv.42-50)",
MinLv = 42, MaxLv = 50,
GateReq = "Field05",
Pos = Vector3.new(0, 116.0, -1609),
RepeatQuests = { { Id = "r08", ReqLv = 42 } },
Monsters = { "glow_wisp", "ivy_lynx", "leader_ivy_lynx", "boss_grove_warden" },
MiniBoss = "boss_grove_warden",
},
{
Id = "Boss02",
Label = "Boss02 (Sabertooth Lv.50)",
MinLv = 50, MaxLv = 50,
GateReq = "Field06",
IsBossRoom = true,
BossId = "bigboss_thornback_behemoth",
UnlocksGate = "Boss02",
Pos = Vector3.new(0, 116.0, -1800),
PillarId = "Boss02",
},
{
Id = "Field07",
Label = "Field07 (Scorpion Dunes Lv.51-58)",
MinLv = 51, MaxLv = 58,
GateReq = "Boss02",
Pos = Vector3.new(0, 116.0, -1991),
RepeatQuests = { { Id = "r09", ReqLv = 51 } },
Monsters = { "tusk_boar", "dune_drake", "leader_dune_drake", "boss_crimson_wyrm" },
MiniBoss = "boss_crimson_wyrm",
},
{
Id = "Field08",
Label = "Field08 (Ram Cliffs Lv.59-66)",
MinLv = 59, MaxLv = 66,
GateReq = "Field07",
Pos = Vector3.new(0, 144.0, -2247),
RepeatQuests = { { Id = "r10", ReqLv = 59 } },
Monsters = { "frost_bat", "rubble_golem", "leader_rubble_golem", "boss_frostfang_titan" },
MiniBoss = "boss_frostfang_titan",
},
{
Id = "Field09",
Label = "Field09 (Stone Golem Valley Lv.67-75)",
MinLv = 67, MaxLv = 75,
GateReq = "Field08",
Pos = Vector3.new(0, 172.0, -2503),
RepeatQuests = { { Id = "r11", ReqLv = 67 } },
Monsters = { "ash_hound", "onyx_scorpion", "leader_onyx_scorpion", "boss_magma_queen" },
MiniBoss = "boss_magma_queen",
},
{
Id = "Boss03",
Label = "Boss03 (Obsidian Pharaoh Lv.75)",
MinLv = 75, MaxLv = 75,
GateReq = "Field09",
IsBossRoom = true,
BossId = "bigboss_obsidian_pharaoh",
UnlocksGate = "Boss03",
Pos = Vector3.new(0, 172.0, -2694),
PillarId = "Boss03",
},
{
Id = "Field10",
Label = "Field10 (Polar Bear Plain Lv.76-83)",
MinLv = 76, MaxLv = 83,
GateReq = "Boss03",
Pos = Vector3.new(0, 172.0, -2885),
RepeatQuests = { { Id = "r12", ReqLv = 76 } },
Monsters = { "marrow_hound", "tomb_knight", "leader_tomb_knight", "boss_tomb_lord" },
MiniBoss = "boss_tomb_lord",
},
{
Id = "Field11",
Label = "Field11 (Snow Wolf Forest Lv.84-91)",
MinLv = 84, MaxLv = 91,
GateReq = "Field10",
Pos = Vector3.new(0, 200.0, -3141),
RepeatQuests = { { Id = "r13", ReqLv = 84 } },
Monsters = { "gem_armadillo", "violet_wyvern", "leader_violet_wyvern", "boss_amethyst_wyvern" },
MiniBoss = "boss_amethyst_wyvern",
},
{
Id = "Field12",
Label = "Field12 (Ice Golem Peak Lv.92-99)",
MinLv = 92, MaxLv = 98,
GateReq = "Field11",
Pos = Vector3.new(0, 228.0, -3397),
RepeatQuests = { { Id = "r14", ReqLv = 92 } },
Monsters = { "gale_roc", "squall_drake", "leader_squall_drake", "boss_storm_sovereign" },
MiniBoss = "boss_storm_sovereign",
},
{
Id = "Boss04",
Label = "Boss04 (Tempest Dragon Lv.99)",
MinLv = 99, MaxLv = 99,
GateReq = "Field12",
IsBossRoom = true,
BossId = "bigboss_tempest_dragon_king",
UnlocksGate = "Boss04",
Pos = Vector3.new(0, 228.0, -3588),
PillarId = "Boss04",
},
{
Id = "Field13",
Label = "Field13 (Lava Turtle Hill Lv.99)",
MinLv = 99, MaxLv = 99,
GateReq = "Boss04",
Pos = Vector3.new(0, 228.0, -3778),
RepeatQuests = { { Id = "r14", ReqLv = 92 } },
Monsters = { "ember_turtle", "magma_turtle", "leader_magma_turtle", "boss_turtle_elder" },
MiniBoss = "boss_turtle_elder",
},
{
Id = "Field14",
Label = "Field14 (Fire Bat Cliffs Lv.99)",
MinLv = 99, MaxLv = 99,
GateReq = "Boss04",
Pos = Vector3.new(0, 256.0, -4034),
RepeatQuests = { { Id = "r14", ReqLv = 92 } },
Monsters = { "fire_bat", "blaze_bat", "leader_blaze_bat", "boss_bat_lord" },
MiniBoss = "boss_bat_lord",
},
{
Id = "Field15",
Label = "Field15 (Hellhound Ash Fields Lv.99)",
MinLv = 99, MaxLv = 99,
GateReq = "Boss04",
Pos = Vector3.new(0, 284.0, -4290),
RepeatQuests = { { Id = "r14", ReqLv = 92 } },
Monsters = { "cinder_hellhound", "ash_hellhound", "leader_ash_hellhound", "boss_hellhound_alpha" },
MiniBoss = "boss_hellhound_alpha",
},
{
Id = "Boss05",
Label = "Boss05 (Volcano Turtle Lv.99)",
MinLv = 99, MaxLv = 99,
GateReq = "Boss04",
IsBossRoom = true,
BossId = "bigboss_volcano_turtle_king",
Pos = Vector3.new(0, 284.0, -4540),
PillarId = "Boss05",
},
}
local ZONE_BY_ID = {}
local ZONE_BY_LABEL = {}
local ZONE_DROPDOWN_LIST = { "Auto Best Zone (Lv.1-99)" }
local TELEPORT_ZONE_LIST = { "Town (Main Village)" }
for _, z in ipairs(ZONE_ORDER) do
ZONE_BY_ID[z.Id] = z
ZONE_BY_LABEL[z.Label] = z
table.insert(ZONE_DROPDOWN_LIST, z.Label)
table.insert(TELEPORT_ZONE_LIST, z.Label)
end
local NPC_POSITIONS = {
["blacksmith"] = Vector3.new(-33.4, 4.7, -4.4),
["merchant"] = Vector3.new(-50.4, 4.7, 30.5),
["masterclass"] = Vector3.new(31.4, 4.7, -1.6),
["craftsmith"] = Vector3.new(-41.9, 4.7, -0.9),
["statmaster"] = Vector3.new(50.4, 4.7, 31.5),
["storage"] = Vector3.new(41.9, 4.7, -0.9),
}
local function getCharacterAndRoot(): (Model?, Humanoid?, BasePart?)
local char = LocalPlayer.Character
if not char then return nil, nil, nil end
local hum = char:FindFirstChildOfClass("Humanoid")
local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
return char, hum, hrp
end
local ActiveCombatTarget: Model? = nil
local LastAttackHoldTarget: Model? = nil
local LastTargetFireClock = 0
local LastSafeCombatCFrame: CFrame? = nil
local IsVisitingTownNpc = false
local function stopAllActiveMovementAndCombat()
ActiveCombatTarget = nil
LastAttackHoldTarget = nil
pcall(function()
local cTarget = LocalPlayer:FindFirstChild("CurrentTarget")
if cTarget and cTarget:IsA("ObjectValue") then
cTarget.Value = nil
end
if Remotes and Remotes:FindFirstChild("SetTarget") then
Remotes.SetTarget:FireServer(nil, false, false)
end
if LocalPlayer:GetAttribute("QuestNavId") ~= "" then
LocalPlayer:SetAttribute("QuestNavId", "")
end
if LocalPlayer:GetAttribute("AutoOn") == true then
if Remotes and Remotes:FindFirstChild("AutoHuntToggle") then
Remotes.AutoHuntToggle:FireServer(false)
end
LocalPlayer:SetAttribute("AutoOn", false)
end
local _, hum, hrp = getCharacterAndRoot()
if hum and hrp then
hum:Move(Vector3.zero, false)
hum:MoveTo(hrp.Position)
end
end)
end
local function isAnyCombatToggleActive(): boolean
return (Cfg.AutoProgression == true)
or (Cfg.AutoFarmZone == true)
or (Cfg.AutoBossHunter == true)
or (Cfg.AutoMainQuest == true)
or (Cfg.AutoUnlockBossGates == true)
or (Cfg.AutoHalloweenDungeon == true and workspace:GetAttribute("PlaceRole") == "Dungeon")
end
local function isBossMonsterAlive(bossMonsterId: string): Model?
for _, m in ipairs(CollectionService:GetTagged("Monster")) do
if m:IsA("Model") and m.PrimaryPart and m:GetAttribute("MonsterId") == bossMonsterId then
local hp = tonumber(m:GetAttribute("HP")) or 0
if hp > 0 and m:GetAttribute("AnimDead") ~= true then
return m
end
end
end
if workspace:FindFirstChild("Monsters") then
for _, m in ipairs(workspace.Monsters:GetChildren()) do
if m:IsA("Model") and m.PrimaryPart and m:GetAttribute("MonsterId") == bossMonsterId then
local hp = tonumber(m:GetAttribute("HP")) or 0
if hp > 0 and m:GetAttribute("AnimDead") ~= true then
return m
end
end
end
end
return nil
end
local function isGateUnlocked(gateId: string?): boolean
if not gateId or gateId == "" then
return true
end
local gates = decodeAttrJson("BossGatesJson")
if gates[gateId] == true then
return true
end
local lv = tonumber(LocalPlayer:GetAttribute("Level")) or 1
local fieldReqLv = {
Field01 = 9,
Field02 = 17,
Field03 = 25,
Field04 = 34,
Field05 = 42,
Field06 = 50,
Field07 = 59,
Field08 = 67,
Field09 = 75,
Field10 = 84,
Field11 = 92,
Field12 = 99,
}
if fieldReqLv[gateId] and lv >= fieldReqLv[gateId] then
return true
end
return false
end
local LastBossStreamClock: { [string]: number } = {}
local function streamBossRoomInBackground(bZone: { [string]: any })
if not bZone or not bZone.Pos or not bZone.Id then return end
local now = os.clock()
if (now - (LastBossStreamClock[bZone.Id] or 0)) >= 5.0 then
LastBossStreamClock[bZone.Id] = now
task.spawn(function()
pcall(function()
LocalPlayer:RequestStreamAroundAsync(bZone.Pos, 2)
end)
end)
end
end
local function resolveBestProgressionZone(): ({ [string]: any }, string)
local lv = tonumber(LocalPlayer:GetAttribute("Level")) or 1
local gates = decodeAttrJson("BossGatesJson")
if Cfg.AutoMainQuest then
local qJson = decodeAttrJson("QuestsJson")
local done = qJson.Done or {}
if not done["q01"] then
return ZONE_BY_ID["Field01"], "Main Quest: ล่ากระต่ายป่า (Field01)"
end
end
local bossGates = {
{ BossZone = "Boss01", ReqLv = 25, FallbackField = "Field03" },
{ BossZone = "Boss02", ReqLv = 50, FallbackField = "Field06" },
{ BossZone = "Boss03", ReqLv = 75, FallbackField = "Field09" },
{ BossZone = "Boss04", ReqLv = 99, FallbackField = "Field12" },
}
local waitingGateBossLabel: string? = nil
if Cfg.AutoUnlockBossGates == true then
for _, bg in ipairs(bossGates) do
if lv >= bg.ReqLv and gates[bg.BossZone] ~= true then
local bZone = ZONE_BY_ID[bg.BossZone]
if bZone and isGateUnlocked(bZone.GateReq) then
streamBossRoomInBackground(bZone)
if isBossMonsterAlive(bZone.BossId) ~= nil then
return bZone, string.format("Unlock Gate: %s (%s)", bg.BossZone, bZone.BossId)
else
waitingGateBossLabel = bg.BossZone
end
end
end
end
end
local bestField = ZONE_BY_ID["Field01"]
for _, z in ipairs(ZONE_ORDER) do
if not z.IsBossRoom then
if lv >= z.MinLv and isGateUnlocked(z.GateReq) then
bestField = z
end
end
end
if waitingGateBossLabel then
return bestField, string.format("Waiting %s Spawn -> Farming %s", waitingGateBossLabel, bestField.Id)
end
return bestField, string.format("Auto Stage Lv.%d -> %s", lv, bestField.Label)
end
local function movePlayerToPosition(targetPos: Vector3, reachDist: number?)
if IsVisitingTownNpc then return end
local _, hum, hrp = getCharacterAndRoot()
if not hum or not hrp or hum.Health <= 0 then
return
end
local reach = reachDist or 12
local flatDiff = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z)
if flatDiff.Magnitude <= reach then
return
end
for _, b in ipairs(CollectionService:GetTagged("BossLock")) do
if b:IsA("BasePart") then
pcall(function()
b.CanCollide = false
end)
end
end
if Cfg.WalkOrTeleportMode == "Instant Teleport + Walk" and flatDiff.Magnitude > 45 then
task.spawn(function()
pcall(function()
LocalPlayer:RequestStreamAroundAsync(targetPos, 1)
end)
end)
hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3.5, 0))
hrp.AssemblyLinearVelocity = Vector3.zero
else
hum:Move(flatDiff.Unit, false)
end
end
local ActiveBossTelegraphs: { { boss: Instance?, zone: { [string]: any }, expiresAt: number } } = {}
local PrevMonsterPosMap: { [Model]: Vector3 } = {}
local MonsterVelocityMap: { [Model]: Vector3 } = {}
local MonsterHomePosMap: { [Model]: Vector3 } = {}
local MonsterSpawnAtMap: { [Model]: number } = {}
local ServerSkillReadyAt: { [string]: number } = {}
local SkillCastCountMap: { [string]: number } = {}
local SmoothedTargetPos: Vector3? = nil
local SmoothedTargetModel: Model? = nil
local OrbitKiteAngle = 0
local OrbitDirectionSign = 1
local function updateMonsterHomeAnchor(m: Model)
if not m or not m.PrimaryPart then return end
local p = m.PrimaryPart.Position
local spAt = tonumber(m:GetAttribute("SpawnAt")) or 0
if not MonsterHomePosMap[m] or (spAt > 0 and MonsterSpawnAtMap[m] ~= spAt) then
MonsterHomePosMap[m] = p
MonsterSpawnAtMap[m] = spAt
elseif (tonumber(m:GetAttribute("ThreatUserId")) or 0) == 0 then
local hp = tonumber(m:GetAttribute("HP")) or 0
local maxHp = tonumber(m:GetAttribute("MaxHP")) or hp
local v = MonsterVelocityMap[m]
if hp >= maxHp and (not v or v.Magnitude < 1.2) then
MonsterHomePosMap[m] = p
end
end
end
local function resolveNearestZoneCenter(pos: Vector3): Vector3?
local bestZonePos: Vector3? = nil
local bestDist = math.huge
for _, z in ipairs(ZONE_ORDER) do
if z.Pos then
local dz = math.abs(pos.Z - z.Pos.Z)
if dz < bestDist and dz <= 145 then
bestDist = dz
bestZonePos = z.Pos
end
end
end
return bestZonePos
end
if Remotes and Remotes:FindFirstChild("BossFx") then
local bossFx = Remotes.BossFx
if bossFx:IsA("RemoteEvent") then
table.insert(Connections, bossFx.OnClientEvent:Connect(function(action, bossModel, moveIdx, zones, warnDur)
local now = os.clock()
if action == "warn" and type(zones) == "table" then
local exp = now + (tonumber(warnDur) or 1.5) + 0.30
for _, z in ipairs(zones) do
if type(z) == "table" then
table.insert(ActiveBossTelegraphs, {
boss = bossModel,
zone = z,
expiresAt = exp,
})
end
end
elseif action == "jump" and typeof(moveIdx) == "Vector3" then
local exp = now + (tonumber(zones) or 0.9) + 0.30
table.insert(ActiveBossTelegraphs, {
boss = bossModel,
zone = { Kind = "circle", Center = moveIdx, Radius = 14 },
expiresAt = exp,
})
elseif action == "hit" or action == "cancel" then
for i = #ActiveBossTelegraphs, 1, -1 do
if ActiveBossTelegraphs[i].boss == bossModel then
table.remove(ActiveBossTelegraphs, i)
end
end
end
end))
end
end
if Remotes and Remotes:FindFirstChild("SkillUsed") then
local su = Remotes.SkillUsed
if su:IsA("RemoteEvent") then
table.insert(Connections, su.OnClientEvent:Connect(function(skillId, cdSeconds, _castDur)
if type(skillId) == "string" and skillId ~= "" then
local cd = tonumber(cdSeconds) or 0
ServerSkillReadyAt[skillId] = os.clock() + math.max(0.05, cd)
SkillCastCountMap[skillId] = (SkillCastCountMap[skillId] or 0) + 1
end
end))
end
end
local function isDashSuicideSkill(skillId: string): boolean
local catalog = type(SkillData.Skills) == "table" and SkillData.Skills or {}
local def = catalog[skillId]
if type(def) == "table" and def.Dash == true then
return true
end
if skillId == "venomknife" then
return true
end
return false
end
local function findTargetInZone(zoneEntry: { [string]: any }?, specificMonsterId: string?): Model?
local _, hum, hrp = getCharacterAndRoot()
if not hum or not hrp or hum.Health <= 0 then
return nil
end
if ActiveCombatTarget and ActiveCombatTarget.Parent and ActiveCombatTarget.PrimaryPart then
local curHp = tonumber(ActiveCombatTarget:GetAttribute("HP")) or 0
local curDead = ActiveCombatTarget:GetAttribute("AnimDead") == true
if curHp > 0 and not curDead then
local zPos = zoneEntry and zoneEntry.Pos or hrp.Position
local maxZoneRadius = (zoneEntry and zoneEntry.IsBossRoom) and 115 or 150
local mPos = ActiveCombatTarget.PrimaryPart.Position
local stillInZone = true
if zoneEntry and workspace:GetAttribute("PlaceRole") ~= "Dungeon" then
stillInZone = (math.abs(mPos.Z - zPos.Z) <= maxZoneRadius and math.abs(mPos.X - zPos.X) <= 135)
end
if stillInZone then
if not specificMonsterId or specificMonsterId == "" or specificMonsterId == "any"
or (specificMonsterId == "leader" and ActiveCombatTarget:GetAttribute("IsLeader") == true)
or ( tostring(ActiveCombatTarget:GetAttribute("MonsterId") or "") == specificMonsterId ) then
return ActiveCombatTarget
end
end
end
end
local bestMonster: Model? = nil
local bestScore = math.huge
local priorityMode = Cfg.TargetPriority or "Smart Leveling (Normal First)"
local zPos = zoneEntry and zoneEntry.Pos or hrp.Position
local maxZoneRadius = (zoneEntry and zoneEntry.IsBossRoom) and 110 or 145
local candidates = CollectionService:GetTagged("Monster")
if #candidates == 0 and workspace:FindFirstChild("Monsters") then
candidates = workspace.Monsters:GetChildren()
end
for _, m in ipairs(candidates) do
if m:IsA("Model") and m.PrimaryPart and m:GetAttribute("IsDummy") ~= true then
local hp = tonumber(m:GetAttribute("HP")) or 0
local maxHp = tonumber(m:GetAttribute("MaxHP")) or hp
local dead = m:GetAttribute("AnimDead") == true
if hp > 0 and not dead then
updateMonsterHomeAnchor(m)
local mPos = m.PrimaryPart.Position
local mId = tostring(m:GetAttribute("MonsterId") or "")
local isBoss = (m:GetAttribute("IsBoss") == true)
local isMini = (m:GetAttribute("IsMiniBoss") == true)
local isLeader = (m:GetAttribute("IsLeader") == true)
local mRadius = tonumber(m:GetAttribute("Radius")) or 2.5
local inZone = true
if zoneEntry and workspace:GetAttribute("PlaceRole") ~= "Dungeon" then
local dz = math.abs(mPos.Z - zPos.Z)
local dx = math.abs(mPos.X - zPos.X)
inZone = (dz <= maxZoneRadius and dx <= 130)
end
local matchesFilter = true
if specificMonsterId and specificMonsterId ~= "" and specificMonsterId ~= "any" then
if specificMonsterId == "leader" then
matchesFilter = isLeader
else
matchesFilter = (mId == specificMonsterId)
end
elseif not (zoneEntry and zoneEntry.IsBossRoom) then
if priorityMode == "Normal Only" and (isBoss or isMini or isLeader) then
matchesFilter = false
end
end
if inZone and matchesFilter then
local dist = (mPos - hrp.Position).Magnitude
local score = dist
if m:GetAttribute("ThreatUserId") == LocalPlayer.UserId then
score -= 60
end
if priorityMode == "Smart Leveling (Normal First)" and not (zoneEntry and zoneEntry.IsBossRoom) then
if isBoss or isMini then
score += 600
elseif isLeader then
score += 400
elseif mRadius >= 3.5 or maxHp >= 3000 then
score += 200
end
elseif priorityMode == "Leader Priority" and isLeader then
score -= 250
elseif priorityMode == "Mini-Boss / Boss Priority" and (isBoss or isMini) then
score -= 350
end
if score < bestScore then
bestScore = score
bestMonster = m
end
end
end
end
end
return bestMonster
end
local function engageMonsterTarget(targetModel: Model)
if IsVisitingTownNpc then return end
local _, hum, hrp = getCharacterAndRoot()
if not hum or not hrp or hum.Health <= 0 then
return
end
if not targetModel or not targetModel.PrimaryPart then
return
end
updateMonsterHomeAnchor(targetModel)
if LocalPlayer:GetAttribute("AutoOn") == true then
if Remotes and Remotes:FindFirstChild("AutoHuntToggle") then
Remotes.AutoHuntToggle:FireServer(false)
end
LocalPlayer:SetAttribute("AutoOn", false)
end
if LocalPlayer:GetAttribute("Sitting") == true and Remotes:FindFirstChild("SitToggle") then
Remotes.SitToggle:FireServer(false)
end
local isNewTarget = (ActiveCombatTarget ~= targetModel)
ActiveCombatTarget = targetModel
local mPos = targetModel.PrimaryPart.Position
local flatVec = Vector3.new(mPos.X - hrp.Position.X, 0, mPos.Z - hrp.Position.Z)
if flatVec.Magnitude > 95 then
if Cfg.WalkOrTeleportMode == "Instant Teleport + Walk" then
local mRadius = tonumber(targetModel:GetAttribute("Radius")) or 2.5
local userDist = math.clamp(tonumber(Cfg.OrbitDistance) or 5.5, 3.5, 16.0)
local approachDir = (flatVec.Magnitude > 0.1) and flatVec.Unit or Vector3.new(0, 0, 1)
local safeLanding = mPos - approachDir * (mRadius + userDist)
OrbitKiteAngle = math.atan2(-approachDir.Z, -approachDir.X)
SmoothedTargetPos = mPos
SmoothedTargetModel = targetModel
hrp.CFrame = CFrame.new(Vector3.new(safeLanding.X, mPos.Y + 3.0, safeLanding.Z), Vector3.new(mPos.X, mPos.Y + 3.0, mPos.Z))
hrp.AssemblyLinearVelocity = Vector3.zero
else
hum:Move(flatVec.Unit, false)
return
end
elseif isNewTarget then
local fromMon = Vector3.new(hrp.Position.X - mPos.X, 0, hrp.Position.Z - mPos.Z)
if fromMon.Magnitude > 0.1 then
OrbitKiteAngle = math.atan2(fromMon.Z, fromMon.X)
end
end
local cTarget = LocalPlayer:FindFirstChild("CurrentTarget")
if cTarget and cTarget:IsA("ObjectValue") and cTarget.Value ~= targetModel then
cTarget.Value = targetModel
task.defer(function()
if ActiveCombatTarget == targetModel and Remotes:FindFirstChild("SetTarget") then
Remotes.SetTarget:FireServer(targetModel, false, true)
end
end)
end
local now = os.clock()
if LastAttackHoldTarget ~= targetModel or (now - LastTargetFireClock >= 0.40) then
LastAttackHoldTarget = targetModel
LastTargetFireClock = now
if Remotes:FindFirstChild("SetTarget") then
Remotes.SetTarget:FireServer(targetModel, false, true)
end
end
end
local LastSlotCastClock: { [number]: number } = {
[1] = 0, [2] = 0, [3] = 0, [4] = 0,
[5] = 0, [6] = 0, [7] = 0, [8] = 0,
}
local LastSkillTickClock = 0
local LastSkillSyncClock = 0
local NextSkillSlotCursor = 1
local SlotToggleLabelUpdaters: { [number]: (string) -> () } = {}
local SlotSliderLabelUpdaters: { [number]: (string) -> () } = {}
local function getHotbarSlotSkillInfo(slotIdx: number): (string?, string, boolean, number, boolean, number, boolean)
local hotbar = decodeAttrJson("HotbarJson")
local slotKey = tostring(slotIdx)
local rawVal = hotbar[slotKey] or hotbar[slotIdx]
local skillId: string? = nil
if type(rawVal) == "string" then
skillId = string.match(rawVal, "^skill:(.+)$")
end
if not skillId or skillId == "" then
local botJson = decodeAttrJson("BotJson")
local job = tostring(LocalPlayer:GetAttribute("Job") or "")
if type(botJson.Skills) == "table" and type(botJson.Skills[job]) == "table" then
local fallbackId = botJson.Skills[job][slotIdx]
if type(fallbackId) == "string" and fallbackId ~= "" then
local alreadyInHotbar = false
for k, v in pairs(hotbar) do
if tostring(k) ~= slotKey and v == ("skill:" .. fallbackId) then
alreadyInHotbar = true
break
end
end
if not alreadyInHotbar then
skillId = fallbackId
end
end
end
end
if not skillId or skillId == "" then
return nil, "Empty", false, 0, false, 0, false
end
local catalog = type(SkillData.Skills) == "table" and SkillData.Skills or {}
local def = catalog[skillId]
local displayName = (type(def) == "table" and tostring(def.Name or skillId)) or skillId
local isDash = isDashSuicideSkill(skillId)
local isPassive = (type(def) == "table" and def.Type == "passive") or false
local skillsJson = decodeAttrJson("SkillsJson")
local learnedLv = tonumber(skillsJson[skillId]) or 1
local spCost = 0
if type(def) == "table" then
if type(SkillData.Int) == "function" and def.SP ~= nil then
local okSp, valSp = pcall(SkillData.Int, def.SP, learnedLv)
if okSp and type(valSp) == "number" then
spCost = valSp
end
elseif type(def.SP) == "number" then
spCost = def.SP
elseif type(def.SP) == "table" and type(def.SP[1]) == "number" then
spCost = def.SP[1]
elseif type(def.SpCost) == "number" then
spCost = def.SpCost
end
end
local rangeStuds = 8.0
if type(def) == "table" then
if type(SkillData.Studs) == "function" and type(def.Range) == "number" and def.Range > 0 then
local okR, valR = pcall(SkillData.Studs, def.Range)
if okR and type(valR) == "number" and valR > 0 then
rangeStuds = valR
end
elseif type(def.Range) == "number" and def.Range > 0 then
rangeStuds = def.Range * 0.1111111111111111
end
end
local needsTarget = true
if type(def) == "table" then
if type(SkillData.NeedsTarget) == "function" then
local okN, valN = pcall(SkillData.NeedsTarget, def)
if okN and type(valN) == "boolean" then
needsTarget = valN
end
elseif def.Kind == "buff" or def.Kind == "heal" or def.Kind == "aoe_self" or def.Kind == "revive" then
needsTarget = false
end
end
return skillId, displayName, isDash, spCost, isPassive, rangeStuds, needsTarget
end
local function isHotbarSlotReady(slotIdx: number, skillId: string, spCost: number, smartCheck: boolean): boolean
local now = os.clock()
if (ServerSkillReadyAt[skillId] or 0) > now then
return false
end
local curSp = tonumber(LocalPlayer:GetAttribute("SP")) or 100
if spCost > 0 and curSp < spCost then
return false
end
if smartCheck then
local pg = LocalPlayer:FindFirstChild("PlayerGui")
local hbGui = pg and pg:FindFirstChild("LumiHotbar")
local pad = hbGui and hbGui:FindFirstChild("ActionPad")
local slotFrame = pad and pad:FindFirstChild("Slot" .. tostring(slotIdx))
local cdLbl = slotFrame and slotFrame:FindFirstChild("Cooldown")
if cdLbl and cdLbl:IsA("TextLabel") then
local txt = string.gsub(cdLbl.Text or "", "%s+", "")
if txt ~= "" and (tonumber(txt) or 0) > 0.05 then
return false
end
end
end
return true
end
local function refreshSkillSlotLabelsInUI()
for slotIdx = 1, 8 do
local skillId, dispName, isDash, _, isPassive = getHotbarSlotSkillInfo(slotIdx)
local tag = ""
if skillId then
local suffix = isPassive and " [Passive]" or (isDash and " [Dash]" or "")
tag = dispName .. suffix
else
tag = "Empty"
end
if SlotToggleLabelUpdaters[slotIdx] then
SlotToggleLabelUpdaters[slotIdx](string.format("Use Slot %d (%s)", slotIdx, tag))
end
if SlotSliderLabelUpdaters[slotIdx] then
SlotSliderLabelUpdaters[slotIdx](string.format("Slot %d Cooldown (%s)", slotIdx, skillId and dispName or "Empty"))
end
end
end
local function autoFillLearnedSkillsToHotbar()
pcall(function()
local setHotbar = Remotes:FindFirstChild("SetHotbar")
if not setHotbar then return end
local skillsJson = decodeAttrJson("SkillsJson")
local hotbar = decodeAttrJson("HotbarJson")
local catalog = type(SkillData.Skills) == "table" and SkillData.Skills or {}
local equippedSet = {}
for i = 1, 8 do
local v = hotbar[tostring(i)] or hotbar[i]
if type(v) == "string" then
local sid = string.match(v, "^skill:(.+)$")
if sid then equippedSet[sid] = true end
end
end
for skillId, lv in pairs(skillsJson) do
if (tonumber(lv) or 0) > 0 and not equippedSet[skillId] then
local def = catalog[skillId]
if type(def) == "table" and def.Type == "active" then
for slotIdx = 1, 8 do
local cur = hotbar[tostring(slotIdx)] or hotbar[slotIdx]
if not cur or cur == "" then
setHotbar:FireServer(slotIdx, "skill:" .. tostring(skillId))
hotbar[tostring(slotIdx)] = "skill:" .. tostring(skillId)
equippedSet[skillId] = true
task.wait(0.12)
break
end
end
end
end
end
task.delay(0.3, refreshSkillSlotLabelsInUI)
end)
end
local function stepAutoSkills()
local now = os.clock()
if Cfg.AutoUpgradeSkills and (now - LastSkillSyncClock >= 3.0) then
LastSkillSyncClock = now
pcall(function()
if LocalPlayer:GetAttribute("AutoSkill") ~= true and Remotes:FindFirstChild("SetAutoSkill") then
Remotes.SetAutoSkill:FireServer(true)
end
end)
end
if not Cfg.AutoCastSkills or (now - LastSkillTickClock < 0.08) then
return
end
local _, hum, hrp = getCharacterAndRoot()
if not hum or not hrp or hum.Health <= 0 then
return
end
local cTarget = LocalPlayer:FindFirstChild("CurrentTarget")
local targetObj = ActiveCombatTarget or (cTarget and cTarget:IsA("ObjectValue") and cTarget.Value)
if not targetObj or not targetObj.Parent or not targetObj.PrimaryPart or (tonumber(targetObj:GetAttribute("HP")) or 0) <= 0 then
return
end
local useSkillRemote = Remotes:FindFirstChild("UseSkill")
if not useSkillRemote then return end
local flatVec = Vector3.new(targetObj.PrimaryPart.Position.X - hrp.Position.X, 0, targetObj.PrimaryPart.Position.Z - hrp.Position.Z)
local mRadius = tonumber(targetObj:GetAttribute("Radius")) or 2.0
local edgeDist = math.max(0, flatVec.Magnitude - mRadius)
local smartCheck = (tostring(Cfg.SkillCastMode or ""):find("Smart") ~= nil)
for offset = 0, 7 do
local slotIdx = ((NextSkillSlotCursor - 1 + offset) % 8) + 1
local useKey = "UseSlot" .. tostring(slotIdx)
if Cfg[useKey] == true then
local delayKey = "Slot" .. tostring(slotIdx) .. "Delay"
local userDelay = math.clamp(tonumber(Cfg[delayKey]) or 0.2, 0.08, 30.0)
local lastCast = LastSlotCastClock[slotIdx] or 0
if (now - lastCast) >= userDelay then
local skillId, _, _, spCost, isPassive, skillRangeStuds, needsTarget = getHotbarSlotSkillInfo(slotIdx)
if skillId and skillId ~= "" and not isPassive then
local inSkillRange = (not needsTarget) or (edgeDist <= math.max(6.5, skillRangeStuds - 0.35))
if inSkillRange and isHotbarSlotReady(slotIdx, skillId, spCost, smartCheck) then
LastSkillTickClock = now
LastSlotCastClock[slotIdx] = now
NextSkillSlotCursor = (slotIdx % 8) + 1
pcall(function()
if cTarget and cTarget:IsA("ObjectValue") and cTarget.Value ~= targetObj then
cTarget.Value = targetObj
end
useSkillRemote:FireServer(skillId, targetObj)
end)
return
end
end
end
end
end
end
local SmoothedBehindDir = Vector3.new(0, 0, 1)
local WasBelowGroundMode = false
local LockedCombatPos: Vector3? = nil
table.insert(Connections, RunService.Stepped:Connect(function()
if not ScriptAlive or IsVisitingTownNpc then
return
end
if WasBelowGroundMode and isAnyCombatToggleActive() then
local char, _, hrp = getCharacterAndRoot()
if char then
for _, part in ipairs(char:GetDescendants()) do
if part:IsA("BasePart") and part.CanCollide then
part.CanCollide = false
end
end
end
if hrp and LastSafeCombatCFrame then
hrp.CFrame = LastSafeCombatCFrame
hrp.AssemblyLinearVelocity = Vector3.zero
end
end
end))
table.insert(Connections, RunService.Heartbeat:Connect(function(dt: number)
if not ScriptAlive or IsVisitingTownNpc or not isAnyCombatToggleActive() then
LockedCombatPos = nil
if WasBelowGroundMode then
WasBelowGroundMode = false
local _, _, hrpOut = getCharacterAndRoot()
if hrpOut then
hrpOut.CFrame = hrpOut.CFrame + Vector3.new(0, 9.0, 0)
hrpOut.AssemblyLinearVelocity = Vector3.zero
end
end
return
end
local char, hum, hrp = getCharacterAndRoot()
if not char or not hum or not hrp or hum.Health <= 0 then
LockedCombatPos = nil
return
end
stepAutoSkills()
local now = os.clock()
for i = #ActiveBossTelegraphs, 1, -1 do
if now > ActiveBossTelegraphs[i].expiresAt then
table.remove(ActiveBossTelegraphs, i)
end
end
local combatMode = tostring(Cfg.CombatMode or "Behind")
if combatMode ~= "Upper" and combatMode ~= "Behind" and combatMode ~= "Below" then
combatMode = "Behind"
Cfg.CombatMode = "Behind"
end
local targetModel = ActiveCombatTarget
if not targetModel or not targetModel.Parent or not targetModel.PrimaryPart
or (tonumber(targetModel:GetAttribute("HP")) or 0) <= 0
or targetModel:GetAttribute("AnimDead") == true then
ActiveCombatTarget = nil
SmoothedTargetModel = nil
SmoothedTargetPos = nil
if (combatMode == "Below" or combatMode == "Upper") and LastSafeCombatCFrame then
hrp.CFrame = LastSafeCombatCFrame
hrp.AssemblyLinearVelocity = Vector3.zero
end
return
end
updateMonsterHomeAnchor(targetModel)
local rawTargetPos = targetModel.PrimaryPart.Position
local flatToPlayer = Vector3.new(rawTargetPos.X - hrp.Position.X, 0, rawTargetPos.Z - hrp.Position.Z)
if flatToPlayer.Magnitude > 100 then
LockedCombatPos = nil
return
end
if SmoothedTargetModel ~= targetModel or not SmoothedTargetPos then
SmoothedTargetModel = targetModel
SmoothedTargetPos = rawTargetPos
local mLookInit = targetModel.PrimaryPart.CFrame.LookVector
local flatLookInit = Vector3.new(mLookInit.X, 0, mLookInit.Z)
SmoothedBehindDir = (flatLookInit.Magnitude > 0.05) and (-flatLookInit.Unit) or Vector3.new(0, 0, 1)
else
SmoothedTargetPos = SmoothedTargetPos:Lerp(rawTargetPos, math.clamp(dt * 12.0, 0, 1))
end
local centerPos = SmoothedTargetPos :: Vector3
local mRadius = tonumber(targetModel:GetAttribute("Radius")) or 2.0
local currentEdgeDist = math.max(0, flatToPlayer.Magnitude - mRadius)
local atkRange = tonumber(LocalPlayer:GetAttribute("AttackRange")) or 7.0
if ClassRange and type(ClassRange.Attack) == "function" then
local okR, rVal = pcall(ClassRange.Attack, LocalPlayer)
if okR and type(rVal) == "number" then
atkRange = rVal
end
end
if currentEdgeDist <= (atkRange + 1.5) and (now - LastTargetFireClock >= 0.35 or LastAttackHoldTarget ~= targetModel) then
LastAttackHoldTarget = targetModel
LastTargetFireClock = now
if Remotes:FindFirstChild("SetTarget") then
Remotes.SetTarget:FireServer(targetModel, false, true)
end
end
local userDist = math.clamp(tonumber(Cfg.OrbitDistance) or 5.5, 3.5, 16.0)
local userSpeed = math.clamp(tonumber(Cfg.OrbitSpeed) or 2.0, 0.5, 8.0)
local homePos = MonsterHomePosMap[targetModel] or rawTargetPos
local driftVec = Vector3.new(rawTargetPos.X - homePos.X, 0, rawTargetPos.Z - homePos.Z)
local driftDist = driftVec.Magnitude
local maxLeash = math.clamp(tonumber(Cfg.MaxLeashRadius) or 22, 10, 60)
local antiLeashOn = (Cfg.AntiLeashBoundary == true)
local mLook = targetModel.PrimaryPart.CFrame.LookVector
local flatLook = Vector3.new(mLook.X, 0, mLook.Z)
local forwardDir = (flatLook.Magnitude > 0.05) and flatLook.Unit or Vector3.new(0, 0, -1)
local targetBackDir = -forwardDir
if antiLeashOn and driftDist > (maxLeash * 0.55) and driftDist > 0.1 then
local toHomeDir = (-driftVec).Unit
targetBackDir = (targetBackDir * 0.35 + toHomeDir * 0.65).Unit
end
local desiredBackAng = math.atan2(targetBackDir.Z, targetBackDir.X)
local diffAng = math.atan2(math.sin(desiredBackAng - OrbitKiteAngle), math.cos(desiredBackAng - OrbitKiteAngle))
local maxAngStep = dt * (userSpeed * 1.6)
local clampedAngStep = math.clamp(diffAng, -maxAngStep, maxAngStep)
OrbitKiteAngle = (OrbitKiteAngle + clampedAngStep) % (math.pi * 2)
SmoothedBehindDir = Vector3.new(math.cos(OrbitKiteAngle), 0, math.sin(OrbitKiteAngle))
local goalPos: Vector3
if combatMode == "Upper" then
if WasBelowGroundMode then
WasBelowGroundMode = false
end
goalPos = Vector3.new(
centerPos.X,
rawTargetPos.Y + mRadius + userDist,
centerPos.Z
)
elseif combatMode == "Below" then
WasBelowGroundMode = true
for _, part in ipairs(char:GetDescendants()) do
if part:IsA("BasePart") and part.CanCollide then
part.CanCollide = false
end
end
local monsterFloorY = rawTargetPos.Y - math.max(mRadius, 2.6)
local submergeDepth = math.max(userDist, 6.5)
goalPos = Vector3.new(
centerPos.X,
monsterFloorY - submergeDepth,
centerPos.Z
)
else
if WasBelowGroundMode then
WasBelowGroundMode = false
end
local behindRadius = mRadius + userDist
goalPos = Vector3.new(
centerPos.X + SmoothedBehindDir.X * behindRadius,
rawTargetPos.Y + 2.8,
centerPos.Z + SmoothedBehindDir.Z * behindRadius
)
end
local isDodgingTelegraph = false
if Cfg.AutoDodgeBossSkills == true then
for _, entry in ipairs(ActiveBossTelegraphs) do
local z = entry.zone
if z.Safe == true and typeof(z.Center) == "Vector3" then
goalPos = Vector3.new(z.Center.X, goalPos.Y, z.Center.Z)
isDodgingTelegraph = true
break
elseif typeof(z.CFrame) == "CFrame" and type(z.Width) == "number" and type(z.Length) == "number" then
local localP = z.CFrame:PointToObjectSpace(goalPos)
local halfW = (z.Width * 0.5) + 6.0
local halfL = (z.Length * 0.5) + 4.5
if math.abs(localP.X) < halfW and math.abs(localP.Z) < halfL then
local sideSign = (localP.X >= 0) and 1 or -1
local safeWorld = z.CFrame:PointToWorldSpace(Vector3.new(sideSign * halfW, localP.Y, localP.Z))
goalPos = Vector3.new(safeWorld.X, goalPos.Y, safeWorld.Z)
isDodgingTelegraph = true
end
elseif z.Kind == "cone" and typeof(z.Center) == "Vector3" and typeof(z.Dir) == "Vector3" then
local flatDir = Vector3.new(z.Dir.X, 0, z.Dir.Z)
if flatDir.Magnitude > 0.05 then
local behind = z.Center - flatDir.Unit * 8.5
goalPos = Vector3.new(behind.X, goalPos.Y, behind.Z)
isDodgingTelegraph = true
end
elseif typeof(z.Center) == "Vector3" and type(z.Radius) == "number" then
local dangerR = z.Radius + 5.0
local diff = Vector3.new(goalPos.X - z.Center.X, 0, goalPos.Z - z.Center.Z)
if diff.Magnitude < dangerR then
local pushDir = (diff.Magnitude > 0.05) and diff.Unit or SmoothedBehindDir
goalPos = Vector3.new(z.Center.X + pushDir.X * dangerR, goalPos.Y, z.Center.Z + pushDir.Z * dangerR)
isDodgingTelegraph = true
end
end
end
end
hum:Move(Vector3.zero, false)
local curPos = (LockedCombatPos and (LockedCombatPos - hrp.Position).Magnitude < 30.0) and LockedCombatPos or hrp.Position
local delta3D = goalPos - curPos
local isApproachingTarget = (delta3D.Magnitude > userDist + 5.0)
local maxMoveSpeed = isDodgingTelegraph and 48.0 or (isApproachingTarget and 38.0 or math.max(24.0, userSpeed * 12.0))
local maxStep = maxMoveSpeed * dt
local nextPos: Vector3
if delta3D.Magnitude > maxStep then
nextPos = curPos + delta3D.Unit * maxStep
else
nextPos = curPos:Lerp(goalPos, math.clamp(dt * 16.0, 0, 1))
end
LockedCombatPos = nextPos
local flatLookAt = Vector3.new(centerPos.X, nextPos.Y, centerPos.Z)
if (flatLookAt - nextPos).Magnitude < 0.08 then
flatLookAt = nextPos + forwardDir
end
local desiredCF = CFrame.new(nextPos, flatLookAt)
LastSafeCombatCFrame = desiredCF
hrp.CFrame = desiredCF
hrp.AssemblyLinearVelocity = Vector3.zero
end))
local LastDropPickupClock = 0
local LastLootBoxClock = 0
local function stepPickupAndLootBoxes()
local now = os.clock()
local _, hum, hrp = getCharacterAndRoot()
if not hum or not hrp or hum.Health <= 0 then
return
end
if Cfg.AutoPickupDrops and (now - LastDropPickupClock >= 0.25) then
LastDropPickupClock = now
pcall(function()
local drops = CollectionService:GetTagged("Drop")
if #drops > 0 and Remotes:FindFirstChild("PickupDrop") then
Remotes.PickupDrop:FireServer(true)
end
end)
end
if Cfg.AutoOpenLootBoxes and (now - LastLootBoxClock >= 0.6) then
LastLootBoxClock = now
pcall(function()
local openRemote = Remotes:FindFirstChild("OpenLootBox")
for _, box in ipairs(CollectionService:GetTagged("LootBox")) do
if box and box.Parent then
if openRemote then
openRemote:FireServer(box)
end
local prompt = box:FindFirstChildWhichIsA("ProximityPrompt", true)
if prompt and typeof(fireproximityprompt) == "function" then
pcall(fireproximityprompt, prompt)
end
end
end
end)
end
end
local LastPotionClock = 0
local LastRespawnClock = 0
local LastPotionRestockClock = 0
local HP_POTION_TIER_LIST = {
"Red Potion (S) - 10% HP (20 Silver)",
"Red Potion (M) - 20% HP (100 Silver)",
"Red Potion (L) - 30% HP (600 Silver)",
"None (ไม่ซื้อยาเลือด)",
}
local HP_POTION_BY_LABEL: { [string]: { Id: string, Price: number, ShortName: string } } = {
["Red Potion (S) - 10% HP (20 Silver)"] = { Id = "red_potion", Price = 20, ShortName = "Red Potion (S)" },
["Red Potion (M) - 20% HP (100 Silver)"] = { Id = "red_potion_m", Price = 100, ShortName = "Red Potion (M)" },
["Red Potion (L) - 30% HP (600 Silver)"] = { Id = "white_potion", Price = 600, ShortName = "Red Potion (L)" },
}
local SP_POTION_TIER_LIST = {
"Blue Potion - 20% SP (200 Silver)",
"None (ไม่ซื้อยามานา)",
}
local SP_POTION_BY_LABEL: { [string]: { Id: string, Price: number, ShortName: string } } = {
["Blue Potion - 20% SP (200 Silver)"] = { Id = "blue_potion", Price = 200, ShortName = "Blue Potion" },
}
local function checkAndRestockBossPotions(forceNow: boolean?): boolean
if not forceNow and Cfg.AutoRestockBossPotions ~= true then
return false
end
if IsVisitingTownNpc then
return true
end
local now = os.clock()
if not forceNow and (now - LastPotionRestockClock < 4.5) then
return false
end
local _, hum, hrp = getCharacterAndRoot()
if not hum or not hrp or hum.Health <= 0 then
return false
end
local shopBuyRemote = Remotes and Remotes:FindFirstChild("ShopBuy")
if not shopBuyRemote then
return false
end
local items = decodeAttrJson("ItemsJson")
local silver = tonumber(LocalPlayer:GetAttribute("Silver")) or 0
local discountPct = tonumber(LocalPlayer:GetAttribute("BuyDiscountPct")) or 0
local minCheck = math.clamp(math.floor(tonumber(Cfg.MinPotionCheckCount) or 20), 1, 1000)
local buyQty = math.clamp(math.floor(tonumber(Cfg.BuyPotionQuantity) or 50), 1, 1000)
local hpEntry = HP_POTION_BY_LABEL[tostring(Cfg.SelectedHpPotionTier or "")]
local spEntry = SP_POTION_BY_LABEL[tostring(Cfg.SelectedSpPotionTier or "")]
local toBuyHp = 0
local toBuySp = 0
local remSilver = silver
if hpEntry then
local haveHp = tonumber(items[hpEntry.Id]) or 0
if forceNow or (haveHp < minCheck) then
local unitPriceHp = math.max(1, math.floor(hpEntry.Price * (100 - discountPct) / 100))
local affordableHp = math.floor(remSilver / unitPriceHp)
toBuyHp = math.min(buyQty, math.max(0, affordableHp))
remSilver = math.max(0, remSilver - (toBuyHp * unitPriceHp))
end
end
if spEntry then
local haveSp = tonumber(items[spEntry.Id]) or 0
if forceNow or (haveSp < minCheck) then
local unitPriceSp = math.max(1, math.floor(spEntry.Price * (100 - discountPct) / 100))
local affordableSp = math.floor(remSilver / unitPriceSp)
toBuySp = math.min(buyQty, math.max(0, affordableSp))
remSilver = math.max(0, remSilver - (toBuySp * unitPriceSp))
end
end
if toBuyHp <= 0 and toBuySp <= 0 then
if forceNow then
notify("Potion Shop", "เงิน Silver ไม่พอซื้อยา หรือตั้งค่าระดับยาเป็น None", 2.5)
end
LastPotionRestockClock = now
return false
end
LastPotionRestockClock = now
IsVisitingTownNpc = true
pcall(function()
local _, curHum, curHrp = getCharacterAndRoot()
if not curHum or not curHrp or curHum.Health <= 0 then
return
end
local prevCf = curHrp.CFrame
local mPos = NPC_POSITIONS["merchant"] or Vector3.new(-50.4, 4.7, 30.5)
local needStep = (LocalPlayer:GetAttribute("Premium") ~= true) and ((curHrp.Position - mPos).Magnitude > 11)
if needStep then
task.spawn(function()
pcall(function()
LocalPlayer:RequestStreamAroundAsync(mPos, 1)
end)
end)
curHrp.CFrame = CFrame.new(mPos + Vector3.new(0, 1.5, 3.5), mPos)
curHrp.AssemblyLinearVelocity = Vector3.zero
task.wait(0.38)
end
local setSlotRemote = Remotes:FindFirstChild("SetPotionSlot")
local boughtSummary = {}
if toBuyHp > 0 and hpEntry then
local remHp = toBuyHp
while remHp > 0 do
local chunk = math.min(99, remHp)
shopBuyRemote:FireServer(hpEntry.Id, chunk)
remHp -= chunk
task.wait(0.22)
end
if setSlotRemote then
setSlotRemote:FireServer("hp", hpEntry.Id)
end
table.insert(boughtSummary, string.format("%s x%d", hpEntry.ShortName, toBuyHp))
end
if toBuySp > 0 and spEntry then
local remSp = toBuySp
while remSp > 0 do
local chunk = math.min(99, remSp)
shopBuyRemote:FireServer(spEntry.Id, chunk)
remSp -= chunk
task.wait(0.22)
end
if setSlotRemote then
setSlotRemote:FireServer("sp", spEntry.Id)
end
table.insert(boughtSummary, string.format("%s x%d", spEntry.ShortName, toBuySp))
end
if needStep and curHrp and prevCf then
curHrp.CFrame = prevCf
curHrp.AssemblyLinearVelocity = Vector3.zero
end
if #boughtSummary > 0 then
notify("GateBoss Potion Restock", "วาร์ปไปซื้อยาสำเร็จ: " .. table.concat(boughtSummary, " + "), 3.0)
end
end)
IsVisitingTownNpc = false
return true
end
local function stepPotionsAndRespawn()
local now = os.clock()
local _, hum, _ = getCharacterAndRoot()
if Cfg.AutoRespawn and (now - LastRespawnClock >= 1.0) then
local waitingRespawn = (LocalPlayer:GetAttribute("HuntRespawnWaiting") == true)
or (hum and hum.Health <= 0)
if waitingRespawn then
LastRespawnClock = now
pcall(function()
if Remotes:FindFirstChild("RespawnChoice") then
Remotes.RespawnChoice:FireServer("town")
end
end)
end
end
if not Cfg.AutoPotion or not hum or hum.Health <= 0 or (now - LastPotionClock < 0.8) then
return
end
local maxHp = math.max(1, tonumber(LocalPlayer:GetAttribute("MaxHP")) or hum.MaxHealth or 100)
local curHp = hum.Health
local hpPct = (curHp / maxHp) * 100
local maxSp = math.max(1, tonumber(LocalPlayer:GetAttribute("MaxSP")) or 100)
local curSp = tonumber(LocalPlayer:GetAttribute("SP")) or maxSp
local spPct = (curSp / maxSp) * 100
local items = decodeAttrJson("ItemsJson")
local useItem = Remotes:FindFirstChild("UseItem")
if not useItem then return end
if hpPct <= (tonumber(Cfg.HpPotionThreshold) or 60) then
local prefHpEntry = HP_POTION_BY_LABEL[tostring(Cfg.SelectedHpPotionTier or "")]
local hpPot = (prefHpEntry and (tonumber(items[prefHpEntry.Id]) or 0) > 0) and prefHpEntry.Id
or tostring(LocalPlayer:GetAttribute("PotionHpNow") or "")
if hpPot == "" or (tonumber(items[hpPot]) or 0) <= 0 then
for _, candidate in ipairs({ "white_potion", "red_potion_m", "red_potion" }) do
if (tonumber(items[candidate]) or 0) > 0 then
hpPot = candidate
break
end
end
end
if hpPot ~= "" and (tonumber(items[hpPot]) or 0) > 0 then
LastPotionClock = now
useItem:FireServer(hpPot)
return
end
end
if spPct <= (tonumber(Cfg.SpPotionThreshold) or 35) then
local prefSpEntry = SP_POTION_BY_LABEL[tostring(Cfg.SelectedSpPotionTier or "")]
local spPot = (prefSpEntry and (tonumber(items[prefSpEntry.Id]) or 0) > 0) and prefSpEntry.Id
or tostring(LocalPlayer:GetAttribute("PotionSpNow") or "")
if spPot == "" or (tonumber(items[spPot]) or 0) <= 0 then
if (tonumber(items["blue_potion"]) or 0) > 0 then
spPot = "blue_potion"
end
end
if spPot ~= "" and (tonumber(items[spPot]) or 0) > 0 then
LastPotionClock = now
useItem:FireServer(spPot)
end
end
end
local LastQuestActionClock = 0
local function stepQuestAutomation(activeZone: { [string]: any }?, forceAll: boolean?)
local now = os.clock()
if not forceAll and (now - LastQuestActionClock < 1.2) then
return
end
LastQuestActionClock = now
local qAction = Remotes:FindFirstChild("QuestAction")
if not qAction then return end
local lv = tonumber(LocalPlayer:GetAttribute("Level")) or 1
local qJson = decodeAttrJson("QuestsJson")
local activeMap = type(qJson.Active) == "table" and qJson.Active or {}
local doneMap = type(qJson.Done) == "table" and qJson.Done or {}
local dailyMap = type(qJson.Daily) == "table" and qJson.Daily or {}
local qCatalog = type(QuestData.Quests) == "table" and QuestData.Quests or {}
for qId, progress in pairs(activeMap) do
local def = qCatalog[qId]
local need = def and tonumber(def.Count) or 1
local progNum = tonumber(progress) or 0
if def and def.Type == "check" then
if def.Target == "stat" and Remotes:FindFirstChild("SetAutoBuild") then
Remotes.SetAutoBuild:FireServer(Cfg.StatBuildMode or "balance")
qAction:FireServer("claim", qId)
elseif def.Target == "skill" and Remotes:FindFirstChild("SetAutoSkill") then
Remotes.SetAutoSkill:FireServer(true)
qAction:FireServer("claim", qId)
elseif def.Target == "equip" and Remotes:FindFirstChild("EquipItem") then
Remotes.EquipItem:FireServer("@best")
qAction:FireServer("claim", qId)
elseif def.Target == "card" and Remotes:FindFirstChild("CardAction") then
local cardsJson = decodeAttrJson("CardsJson")
local ownedCards = type(cardsJson.Owned) == "table" and cardsJson.Owned or cardsJson
if type(ownedCards) == "table" and next(ownedCards) ~= nil then
Remotes.CardAction:FireServer("auto")
qAction:FireServer("claim", qId)
end
else
qAction:FireServer("claim", qId)
end
elseif progNum >= need then
qAction:FireServer("claim", qId)
end
end
if forceAll or Cfg.AutoMainQuest == true then
for _, tId in ipairs({ "q01", "t01", "t02", "t03", "t04", "t05" }) do
local def = qCatalog[tId]
if def and lv >= (tonumber(def.ReqLevel) or 1) and not doneMap[tId] and activeMap[tId] == nil then
qAction:FireServer("accept", tId)
end
end
end
if forceAll or Cfg.AutoDailyRepeatQuest == true then
for _, dId in ipairs({ "d01", "d02", "d03" }) do
local def = qCatalog[dId]
if def and lv >= (tonumber(def.ReqLevel) or 1) and not dailyMap[dId] and activeMap[dId] == nil then
qAction:FireServer("accept", dId)
end
end
local z = activeZone
if not z then
z = resolveBestProgressionZone()
end
if z and type(z.RepeatQuests) == "table" then
for _, rq in ipairs(z.RepeatQuests) do
if lv >= rq.ReqLv and activeMap[rq.Id] == nil then
qAction:FireServer("accept", rq.Id)
end
end
end
end
end
local LastRewardClaimClock = 0
local IsClaimingRewardsBusy = false
local function claimAllFreeRewardsNow()
if IsClaimingRewardsBusy then return end
IsClaimingRewardsBusy = true
task.spawn(function()
pcall(function()
if Cfg.AutoClaimBetaPet or Cfg.AutoClaimAllRewards then
local evRemote = Remotes:FindFirstChild("EventNpcAction")
if evRemote then
local evJson = decodeAttrJson("EventJson")
local petJson = decodeAttrJson("PetJson")
local ownedPets = type(petJson.Owned) == "table" and petJson.Owned or {}
local petId = EventNpcData.PetId or "little_turtle"
local hasPet = (ownedPets[petId] == true)
local evReady = tonumber(LocalPlayer:GetAttribute("EventReady")) or 0
if not hasPet or evReady > 0 then
local _, hum, hrp = getCharacterAndRoot()
local prevCf = hrp and hrp.CFrame
local evNpc = CollectionService:GetTagged("EventNpc")[1]
local npcPos = (evNpc and evNpc:IsA("Model") and evNpc:GetPivot().Position) or Vector3.new(0, 6.0, 38.3)
IsVisitingTownNpc = true
pcall(function()
if hrp and hum and hum.Health > 0 and (hrp.Position - npcPos).Magnitude > 14 then
pcall(function() LocalPlayer:RequestStreamAroundAsync(npcPos, 2) end)
hrp.CFrame = CFrame.new(npcPos + Vector3.new(0, 2, 3.5))
hrp.AssemblyLinearVelocity = Vector3.zero
task.wait(0.55)
end
if evJson.Liked ~= true then
evRemote:FireServer("like")
task.wait(0.55)
end
if evJson.Group ~= true then
evRemote:FireServer("checkGroup", true)
task.wait(0.55)
end
if not hasPet then
evRemote:FireServer("claimPet")
task.wait(0.55)
end
if evReady > 0 then
evRemote:FireServer("claimAll")
task.wait(0.55)
end
if hrp and prevCf and (hrp.Position - prevCf.Position).Magnitude > 5 then
hrp.CFrame = prevCf
hrp.AssemblyLinearVelocity = Vector3.zero
end
end)
IsVisitingTownNpc = false
end
local petJsonAfter = decodeAttrJson("PetJson")
local ownedAfter = type(petJsonAfter.Owned) == "table" and petJsonAfter.Owned or {}
if ownedAfter[petId] == true and LocalPlayer:GetAttribute("PetActive") ~= petId and Remotes:FindFirstChild("PetAction") then
Remotes.PetAction:FireServer("summon", petId)
end
end
end
if not Cfg.AutoClaimAllRewards then
return
end
local dailyJson = decodeAttrJson("DailyJson")
if dailyJson.CanClaim == true and Remotes:FindFirstChild("DailyClaim") then
Remotes.DailyClaim:FireServer()
task.wait(0.35)
end
local rewRemote = Remotes:FindFirstChild("RewardAction")
if rewRemote and (tonumber(LocalPlayer:GetAttribute("RewardsReady")) or tonumber(LocalPlayer:GetAttribute("RewardReady")) or 0) > 0 then
local rewJson = decodeAttrJson("RewardsJson")
local online = type(rewJson.Online) == "table" and rewJson.Online or {}
local gotList = type(online.Got) == "table" and online.Got or {}
local gotMap = {}
for k, v in pairs(gotList) do
if type(v) == "number" then gotMap[v] = true end
if type(k) == "number" and v == true then gotMap[k] = true end
end
for idx = 1, 6 do
if not gotMap[idx] then
rewRemote:FireServer("online", idx)
task.wait(0.45)
end
end
local c8 = type(rewJson.C8) == "table" and rewJson.C8 or {}
if c8.Can == true then
rewRemote:FireServer("c8", nil)
task.wait(0.45)
end
rewRemote:FireServer("month", nil)
task.wait(0.35)
end
local bpRemote = Remotes:FindFirstChild("BattlePassAction")
if bpRemote and (tonumber(LocalPlayer:GetAttribute("BattlePassReady")) or 0) > 0 then
bpRemote:FireServer("missionAll")
task.wait(0.45)
bpRemote:FireServer("claimAll")
task.wait(0.45)
end
local achRemote = Remotes:FindFirstChild("AchieveAction")
if achRemote and (tonumber(LocalPlayer:GetAttribute("AchieveReady")) or 0) > 0 then
local achJson = decodeAttrJson("AchieveJson")
local got = type(achJson.Got) == "table" and achJson.Got or {}
local gotSet = {}
for k, v in pairs(got) do
if type(k) == "string" and v == true then gotSet[k] = true end
if type(v) == "string" then gotSet[v] = true end
end
for _, item in ipairs(AchievementData.List or {}) do
if item.Id and not gotSet[item.Id] then
achRemote:FireServer("claim", item.Id, false)
task.wait(0.35)
end
end
end
end)
IsClaimingRewardsBusy = false
end)
end
local LastGearShopClock = 0
local DEFAULT_JUNK_KEEP = {
refine_stone = true,
protection_stone = true,
lucky_stone = true,
colossus_core = true,
dungeon_key = true,
}
local function scanSellableJunkMaterials(): (number, number, number)
local junkKeep = (type(GameConfig.JunkKeep) == "table") and GameConfig.JunkKeep or DEFAULT_JUNK_KEEP
local locksJson = decodeAttrJson("LocksJson")
local itemsJson = decodeAttrJson("ItemsJson")
local sellBonusPct = tonumber(LocalPlayer:GetAttribute("SellBonusPct")) or 0
local totalItems = 0
local totalTypes = 0
local estSilver = 0
for itemId, count in pairs(itemsJson) do
local qty = tonumber(count) or 0
local def = ItemData[itemId]
if qty > 0
and type(def) == "table"
and def.Kind == "etc"
and (tonumber(def.Sell) or 0) > 0
and not junkKeep[itemId]
and not DEFAULT_JUNK_KEEP[itemId]
and not locksJson[itemId] then
totalItems += qty
totalTypes += 1
local unitPrice = math.floor((tonumber(def.Sell) or 0) * (100 + sellBonusPct) / 100)
estSilver += unitPrice * qty
end
end
return totalItems, totalTypes, estSilver
end
local function buildProtectedEquippedSet(): { [string]: number }
local protected: { [string]: number } = {}
local wepId = LocalPlayer:GetAttribute("WeaponId")
if type(wepId) == "string" and wepId ~= "" then
protected[wepId] = (protected[wepId] or 0) + 1
end
for _, eqRef in pairs(decodeAttrJson("EquipJson")) do
if type(eqRef) == "string" and eqRef ~= "" then
protected[eqRef] = (protected[eqRef] or 0) + 1
end
end
local function scanTableForRefs(tbl: { [any]: any })
for _, v in pairs(tbl) do
if type(v) == "string" and v ~= "" then
protected[v] = math.max(protected[v] or 0, 1)
elseif type(v) == "table" then
scanTableForRefs(v)
end
end
end
scanTableForRefs(decodeAttrJson("LoadoutJson"))
return protected
end
local function scanSellableEquipmentByRarity(): ({ { any } }, number, number, { string })
local sellBatch: { { any } } = {}
local bagSellRefs: { string } = {}
local totalPieces = 0
local estSilver = 0
local sellWeapons = (Cfg.SellWeapons == true)
local sellArmors = (Cfg.SellArmors == true)
if not sellWeapons and not sellArmors then
return sellBatch, 0, 0, bagSellRefs
end
local anyTierSelected = false
for t = 1, 6 do
if Cfg["SellRarityTier" .. tostring(t)] == true then
anyTierSelected = true
break
end
end
if not anyTierSelected then
return sellBatch, 0, 0, bagSellRefs
end
local protectedMap = buildProtectedEquippedSet()
local locksJson = decodeAttrJson("LocksJson")
local refineJson = decodeAttrJson("RefineJson")
local gearJson = decodeAttrJson("GearJson")
local itemsJson = decodeAttrJson("ItemsJson")
local keepRefined = (Cfg.KeepRefinedGear == true)
local sellBonusPct = tonumber(LocalPlayer:GetAttribute("SellBonusPct")) or 0
for gearRef, rawEntry in pairs(gearJson) do
if type(gearRef) == "string" and not protectedMap[gearRef] and not locksJson[gearRef] then
local refineLv = tonumber(refineJson[gearRef]) or 0
if not (keepRefined and refineLv > 0) then
local resolved = nil
if GearUtil and type(GearUtil.Resolve) == "function" then
local okR, resR = pcall(GearUtil.Resolve, gearRef, gearJson)
if okR then resolved = resR end
end
if not resolved and type(rawEntry) == "table" and type(rawEntry.Id) == "string" then
local baseDef = ItemData[rawEntry.Id]
if type(baseDef) == "table" then
resolved = {
Kind = baseDef.Kind,
Tier = tonumber(rawEntry.T) or tonumber(baseDef.Tier) or 1,
Sell = tonumber(baseDef.Sell) or 0,
Bound = baseDef.Bound,
}
end
end
if type(resolved) == "table" and resolved.Bound ~= true and (tonumber(resolved.Sell) or 0) > 0 then
local kind = tostring(resolved.Kind or "")
local categoryMatch = (kind == "weapon" and sellWeapons) or (kind == "armor" and sellArmors)
if categoryMatch then
local tierNum = math.clamp(
math.floor(tonumber(resolved.Tier) or ((tonumber(resolved.Rarity) or 0) + 1)),
1,
6
)
if Cfg["SellRarityTier" .. tostring(tierNum)] == true then
table.insert(sellBatch, { gearRef, 1 })
table.insert(bagSellRefs, gearRef)
totalPieces += 1
estSilver += math.floor((tonumber(resolved.Sell) or 0) * (100 + sellBonusPct) / 100)
end
end
end
end
end
end
for itemId, count in pairs(itemsJson) do
local isGearRef = (GearUtil and type(GearUtil.IsRef) == "function" and GearUtil.IsRef(itemId))
or (type(itemId) == "string" and string.match(itemId, "^g%d+$") ~= nil)
if not isGearRef and not locksJson[itemId] then
local def = ItemData[itemId]
if type(def) == "table" and def.Bound ~= true and (tonumber(def.Sell) or 0) > 0 then
local kind = tostring(def.Kind or "")
local categoryMatch = (kind == "weapon" and sellWeapons) or (kind == "armor" and sellArmors)
if categoryMatch then
local refineLv = tonumber(refineJson[itemId]) or 0
if not (keepRefined and refineLv > 0) then
local availQty = (tonumber(count) or 0) - (protectedMap[itemId] or 0)
if availQty > 0 then
local tierNum = math.clamp(
math.floor(tonumber(def.Tier) or ((tonumber(def.Rarity) or 0) + 1)),
1,
6
)
if Cfg["SellRarityTier" .. tostring(tierNum)] == true then
table.insert(sellBatch, { itemId, availQty })
totalPieces += availQty
local unitPrice = math.floor((tonumber(def.Sell) or 0) * (100 + sellBonusPct) / 100)
estSilver += unitPrice * availQty
end
end
end
end
end
end
end
table.sort(sellBatch, function(a, b)
return tostring(a[1]) < tostring(b[1])
end)
return sellBatch, totalPieces, estSilver, bagSellRefs
end
local function sellJunkMaterialsNow(silentIfEmpty: boolean?): (number, number)
local totalItems, _, estSilver = scanSellableJunkMaterials()
if totalItems <= 0 then
if not silentIfEmpty then
notify("Sell Junk Materials", "ไม่มีขยะมอนสเตอร์ในกระเป๋าให้ขายแล้ว!", 2.0)
end
return 0, 0
end
if IsVisitingTownNpc then
return 0, 0
end
task.spawn(function()
IsVisitingTownNpc = true
pcall(function()
local _, hum, hrp = getCharacterAndRoot()
local prevCf = hrp and hrp.CFrame
local mPos = NPC_POSITIONS["merchant"]
local needStep = (LocalPlayer:GetAttribute("Premium") ~= true)
and hrp and hum and hum.Health > 0
and ((hrp.Position - mPos).Magnitude > 11)
if needStep and hrp then
hrp.CFrame = CFrame.new(mPos + Vector3.new(0, 1, 3.5))
hrp.AssemblyLinearVelocity = Vector3.zero
task.wait(0.35)
end
if Remotes:FindFirstChild("ShopSellJunk") then
Remotes.ShopSellJunk:FireServer()
end
if needStep and hrp and prevCf then
task.wait(0.25)
hrp.CFrame = prevCf
hrp.AssemblyLinearVelocity = Vector3.zero
end
if not silentIfEmpty then
notify(
"Sold Junk Materials!",
string.format("ขายขยะมอนสเตอร์ %d ชิ้น (+%d Silver) เรียบร้อย!", totalItems, estSilver),
2.5
)
end
end)
IsVisitingTownNpc = false
end)
return totalItems, estSilver
end
local function sellSelectedEquipmentNow(silentIfEmpty: boolean?): (number, number)
local sellBatch, totalPieces, estSilver, bagSellRefs = scanSellableEquipmentByRarity()
if #sellBatch == 0 or totalPieces <= 0 then
if not silentIfEmpty then
notify(
"Sell Equipment by Rarity",
"ไม่พบอาวุธหรือชุดเกราะที่ตรงกับประเภทและ Rarity ที่ติ๊กเลือกในกระเป๋า",
2.5
)
end
return 0, 0
end
if IsVisitingTownNpc then
return 0, 0
end
task.spawn(function()
IsVisitingTownNpc = true
pcall(function()
local _, hum, hrp = getCharacterAndRoot()
local prevCf = hrp and hrp.CFrame
local mPos = NPC_POSITIONS["merchant"]
local isPrem = (LocalPlayer:GetAttribute("Premium") == true)
local needStep = (not isPrem)
and hrp and hum and hum.Health > 0
and ((hrp.Position - mPos).Magnitude > 11)
if needStep and hrp then
hrp.CFrame = CFrame.new(mPos + Vector3.new(0, 1, 3.5))
hrp.AssemblyLinearVelocity = Vector3.zero
task.wait(0.35)
end
local shopSellMany = Remotes:FindFirstChild("ShopSellMany")
local bagSell = Remotes:FindFirstChild("BagSell")
local shopSellSingle = Remotes:FindFirstChild("ShopSell")
if isPrem and bagSell and #bagSellRefs == #sellBatch then
bagSell:FireServer(bagSellRefs)
elseif shopSellMany then
local silverBefore = tonumber(LocalPlayer:GetAttribute("Silver")) or 0
shopSellMany:FireServer(sellBatch)
if isPrem and hrp and hum and hum.Health > 0 and ((hrp.Position - mPos).Magnitude > 11) then
task.wait(0.25)
if (tonumber(LocalPlayer:GetAttribute("Silver")) or 0) == silverBefore then
hrp.CFrame = CFrame.new(mPos + Vector3.new(0, 1, 3.5))
hrp.AssemblyLinearVelocity = Vector3.zero
task.wait(0.30)
shopSellMany:FireServer(sellBatch)
task.wait(0.20)
if prevCf then
hrp.CFrame = prevCf
hrp.AssemblyLinearVelocity = Vector3.zero
end
end
end
elseif shopSellSingle then
for _, pair in ipairs(sellBatch) do
shopSellSingle:FireServer(pair[1], pair[2])
task.wait(0.08)
end
end
if needStep and hrp and prevCf then
task.wait(0.25)
hrp.CFrame = prevCf
hrp.AssemblyLinearVelocity = Vector3.zero
end
if not silentIfEmpty then
notify(
"Sold Equipment by Rarity!",
string.format("ขายอาวุธ/ชุดเกราะ %d ชิ้น (+%d Silver) เรียบร้อย!", totalPieces, estSilver),
2.5
)
end
end)
IsVisitingTownNpc = false
end)
return totalPieces, estSilver
end
local REFINE_SLOT_DEFS = {
{ Key = "RefineSlotWeapon", Slot = "Weapon", Label = "Weapon (อาวุธ)" },
{ Key = "RefineSlotBody", Slot = "Body", Label = "Body (เสื้อเกราะ)" },
{ Key = "RefineSlotGarment", Slot = "Garment", Label = "Garment (ผ้าคลุม)" },
{ Key = "RefineSlotHeadTop", Slot = "HeadTop", Label = "HeadTop (หมวก)" },
{ Key = "RefineSlotHeadMid", Slot = "HeadMid", Label = "HeadMid (หน้ากาก)" },
{ Key = "RefineSlotShoes", Slot = "Shoes", Label = "Shoes (รองเท้า)" },
{ Key = "RefineSlotAcc1", Slot = "Acc1", Label = "Ring 1 (แหวนช่อง 1)" },
{ Key = "RefineSlotAcc2", Slot = "Acc2", Label = "Ring 2 (แหวนช่อง 2)" },
}
local RefineToggleLabelUpdaters: { [string]: (string) -> () } = {}
local function getEquippedSlotRefAndInfo(slotName: string): (string, string, number)
local eqJson = decodeAttrJson("EquipJson")
local gearJson = decodeAttrJson("GearJson")
local refineJson = decodeAttrJson("RefineJson")
local ref = ""
if slotName == "Weapon" then
ref = tostring(LocalPlayer:GetAttribute("WeaponId") or "")
else
ref = tostring(eqJson[slotName] or "")
end
if ref == "" or ref == "knife_wood" then
return "", "Empty", 0
end
local curPlus = tonumber(refineJson[ref]) or 0
local itemName = ref
if GearUtil and type(GearUtil.Resolve) == "function" then
local okR, resR = pcall(GearUtil.Resolve, ref, gearJson)
if okR and type(resR) == "table" and type(resR.Name) == "string" then
itemName = resR.Name
end
end
if itemName == ref then
local rawEntry = gearJson[ref]
if type(rawEntry) == "table" and type(rawEntry.Id) == "string" and type(ItemData[rawEntry.Id]) == "table" then
itemName = tostring(ItemData[rawEntry.Id].Name or rawEntry.Id)
elseif type(ItemData[ref]) == "table" then
itemName = tostring(ItemData[ref].Name or ref)
end
end
return ref, itemName, curPlus
end
local function refreshRefineSlotLabelsInUI()
for _, entry in ipairs(REFINE_SLOT_DEFS) do
local updater = RefineToggleLabelUpdaters[entry.Key]
if updater then
local ref, itemName, curPlus = getEquippedSlotRefAndInfo(entry.Slot)
if ref ~= "" then
updater(string.format("%s — %s [+%d]", entry.Label, itemName, curPlus))
else
updater(string.format("%s — [Empty]", entry.Label))
end
end
end
end
local function refineSelectedGearNow(manualToast: boolean?): boolean
if IsVisitingTownNpc then
return false
end
local items = decodeAttrJson("ItemsJson")
local stones = tonumber(items["refine_stone"]) or 0
local silver = tonumber(LocalPlayer:GetAttribute("Silver")) or 0
if stones <= 0 then
if manualToast then
notify("Auto Refine", "ไม่มี Refine Stone ในกระเป๋า!", 2.2)
end
return false
end
if silver < 500 or not Remotes:FindFirstChild("RefineWeapon") then
if manualToast then
notify("Auto Refine", "เงิน Silver ไม่พอสำหรับตีบวก!", 2.2)
end
return false
end
local targetPlus = tonumber(string.match(tostring(Cfg.MaxRefineTarget or "+5"), "%d+")) or 5
local candidateRef = ""
local candidateLabel = ""
local curPlus = 0
for _, entry in ipairs(REFINE_SLOT_DEFS) do
if Cfg[entry.Key] == true then
local ref, itemName, plusLv = getEquippedSlotRefAndInfo(entry.Slot)
if ref ~= "" and plusLv < targetPlus then
candidateRef = ref
candidateLabel = string.format("%s (%s +%d -> +%d)", entry.Label, itemName, plusLv, plusLv + 1)
curPlus = plusLv
break
end
end
end
if candidateRef == "" then
if manualToast then
notify("Auto Refine", "อุปกรณ์ที่ติ๊กเลือกไว้ตีบวกถึงเป้าหมาย (" .. tostring(Cfg.MaxRefineTarget) .. ") ครบแล้ว หรือยังไม่ได้ติ๊กเลือกชิ้น!", 2.5)
end
return false
end
local useProt = (curPlus >= 4) and ((tonumber(items["protection_stone"]) or 0) > 0)
local useLuck = (curPlus >= 4) and ((tonumber(items["lucky_stone"]) or 0) > 0)
task.spawn(function()
IsVisitingTownNpc = true
pcall(function()
local _, hum, hrp = getCharacterAndRoot()
local prevCf = hrp and hrp.CFrame
local bsPos = NPC_POSITIONS["blacksmith"]
local needStep = (LocalPlayer:GetAttribute("Premium") ~= true)
and hrp and hum and hum.Health > 0
and ((hrp.Position - bsPos).Magnitude > 11)
if needStep and hrp then
task.spawn(function()
pcall(function()
LocalPlayer:RequestStreamAroundAsync(bsPos, 1)
end)
end)
hrp.CFrame = CFrame.new(bsPos + Vector3.new(0, 1, 3.5), bsPos)
hrp.AssemblyLinearVelocity = Vector3.zero
task.wait(0.38)
end
Remotes.RefineWeapon:FireServer(candidateRef, useProt, useLuck, true)
task.wait(0.25)
if needStep and hrp and prevCf then
hrp.CFrame = prevCf
hrp.AssemblyLinearVelocity = Vector3.zero
end
refreshRefineSlotLabelsInUI()
if manualToast then
notify("Refine Gear", "สั่งตีบวก " .. candidateLabel .. " เรียบร้อย!", 2.5)
end
end)
IsVisitingTownNpc = false
end)
return true
end
local function stepCharacterGearRefineShop()
local now = os.clock()
if now - LastGearShopClock < 2.5 then
return
end
LastGearShopClock = now
pcall(function()
if Cfg.AutoEquipBest then
if LocalPlayer:GetAttribute("AutoEquip") ~= true and Remotes:FindFirstChild("SetAutoEquip") then
Remotes.SetAutoEquip:FireServer(true)
end
if Remotes:FindFirstChild("EquipItem") then
Remotes.EquipItem:FireServer("@best")
end
if Remotes:FindFirstChild("CardAction") then
local cardsJson = decodeAttrJson("CardsJson")
local ownedCards = type(cardsJson.Owned) == "table" and cardsJson.Owned or cardsJson
if type(ownedCards) == "table" and next(ownedCards) ~= nil then
Remotes.CardAction:FireServer("auto")
end
end
end
if Cfg.AutoAllocateStats then
local mode = Cfg.StatBuildMode or "balance"
if mode == "balance" then
if LocalPlayer:GetAttribute("AutoBuild") ~= "balance" and Remotes:FindFirstChild("SetAutoBuild") then
Remotes.SetAutoBuild:FireServer("balance")
end
else
local sp = tonumber(LocalPlayer:GetAttribute("StatPoints")) or 0
if sp > 0 and Remotes:FindFirstChild("StatPlan") then
task.spawn(function()
pcall(function()
Remotes.StatPlan:InvokeServer({ [mode] = 1 }, true)
end)
end)
end
end
end
if Cfg.AutoRefineGear then
refineSelectedGearNow(false)
end
if Cfg.AutoSellJunk and not IsVisitingTownNpc then
local used = tonumber(LocalPlayer:GetAttribute("BagSlotsUsed")) or 0
local maxSlots = tonumber(LocalPlayer:GetAttribute("BagSlotsMax")) or 120
local pct = math.clamp(tonumber(Cfg.SellJunkBagPct) or 65, 20, 95) / 100
if used >= math.max(5, math.floor(maxSlots * pct)) then
local junkCount = scanSellableJunkMaterials()
if junkCount > 0 then
sellJunkMaterialsNow(true)
end
end
end
if Cfg.AutoSellEquipment and not IsVisitingTownNpc then
local used = tonumber(LocalPlayer:GetAttribute("BagSlotsUsed")) or 0
local maxSlots = tonumber(LocalPlayer:GetAttribute("BagSlotsMax")) or 120
local pct = math.clamp(tonumber(Cfg.SellEquipBagPct) or 60, 10, 95) / 100
if used >= math.max(5, math.floor(maxSlots * pct)) then
local sellBatch, totalPieces = scanSellableEquipmentByRarity()
if #sellBatch > 0 and totalPieces > 0 then
sellSelectedEquipmentNow(true)
end
end
end
end)
end
local LastTrickTreatClock = 0
local function stepHalloweenTrickTreat(): boolean
if not Cfg.AutoTrickOrTreat then
return false
end
local items = decodeAttrJson("ItemsJson")
local candy = tonumber(items["halloween_candy"]) or 0
if candy < 100 then
return false
end
local _, hum, hrp = getCharacterAndRoot()
if not hum or not hrp or hum.Health <= 0 then
return false
end
local houses = CollectionService:GetTagged("TrickHouse")
if #houses == 0 and workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Halloween_TrickTreat") then
houses = workspace.Map.Halloween_TrickTreat:GetChildren()
end
local nearestHouse: Instance? = nil
local nearestPrompt: ProximityPrompt? = nil
local nearestDist = math.huge
for _, h in ipairs(houses) do
local prompt = h:FindFirstChild("KnockPrompt", true) or h:FindFirstChildWhichIsA("ProximityPrompt", true)
if prompt and prompt.Enabled then
local pPos = h:IsA("Model") and h:GetPivot().Position or (h:FindFirstChildWhichIsA("BasePart", true) and h:FindFirstChildWhichIsA("BasePart", true).Position)
if pPos then
local d = (pPos - hrp.Position).Magnitude
if d < nearestDist then
nearestDist = d
nearestHouse = h
nearestPrompt = prompt
end
end
end
end
if nearestHouse and nearestPrompt then
local hPos = nearestHouse:IsA("Model") and nearestHouse:GetPivot().Position or hrp.Position
if nearestDist > 10 then
movePlayerToPosition(hPos, 8)
else
local now = os.clock()
if now - LastTrickTreatClock >= 2.2 then
LastTrickTreatClock = now
if typeof(fireproximityprompt) == "function" then
pcall(fireproximityprompt, nearestPrompt)
end
end
end
return true
end
return false
end
local IsMobileDevice = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local ClientDeviceType = IsMobileDevice and "Mobile" or "PC"
local CurrentMapName = "Hunting Together"
local CurrentStatusText = "Idle (All Toggles OFF)"
local Theme = {
WindowBg = Color3.fromRGB(13, 18, 28),
SidebarBg = Color3.fromRGB(11, 16, 25),
CardBg = Color3.fromRGB(18, 25, 38),
ControlBg = Color3.fromRGB(12, 17, 26),
ActiveTabBg = Color3.fromRGB(26, 41, 66),
HoverTabBg = Color3.fromRGB(19, 30, 48),
BadgeBg = Color3.fromRGB(24, 40, 66),
Stroke = Color3.fromRGB(32, 46, 70),
ActiveStroke = Color3.fromRGB(58, 98, 160),
AccentBlue = Color3.fromRGB(101, 191, 255),
AccentDeep = Color3.fromRGB(52, 126, 232),
SliderThumb = Color3.fromRGB(122, 188, 255),
ToggleOffBg = Color3.fromRGB(32, 43, 60),
ToggleOffKnob = Color3.fromRGB(120, 138, 164),
ToggleOnKnob = Color3.fromRGB(12, 20, 34),
TextPrimary = Color3.fromRGB(240, 245, 255),
TextSecondary = Color3.fromRGB(214, 228, 248),
SidebarText = Color3.fromRGB(168, 184, 208),
TextMuted = Color3.fromRGB(127, 147, 174),
OnlineGreen = Color3.fromRGB(67, 181, 129),
}
local FontBold = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold)
local FontMedium = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Medium)
local CustomSvgDefinitions: { [string]: string } = {
main = [[
<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
<rect x="3.0" y="3.0" width="7.2" height="7.2" rx="2.0" />
<rect x="13.8" y="3.0" width="7.2" height="7.2" rx="2.0" />
<rect x="3.0" y="13.8" width="7.2" height="7.2" rx="2.0" />
<rect x="13.8" y="13.8" width="7.2" height="7.2" rx="2.0" />
</svg>]],
quests = [[
<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
<circle cx="12.0" cy="12.0" r="8.5" />
<path d="M 12.0 2.2 L 12.0 4.4 M 12.0 19.6 L 12.0 21.8 M 2.2 12.0 L 4.4 12.0 M 19.6 12.0 L 21.8 12.0" />
<path d="M 15.6 8.4 L 13.4 13.4 L 8.4 15.6 L 10.6 10.6 Z" />
</svg>]],
raid_swords = [[
<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
<path d="M 14.5 17.5 L 3.0 6.0 L 3.0 3.0 L 6.0 3.0 L 17.5 14.5 M 13.0 19.0 L 19.0 13.0 M 16.0 16.0 L 20.0 20.0 M 19.0 21.0 L 21.0 19.0" />
<path d="M 14.5 6.5 L 18.0 3.0 L 21.0 3.0 L 21.0 6.0 L 17.5 9.5 M 5.0 13.0 L 11.0 19.0 M 8.0 16.0 L 4.0 20.0 M 3.0 19.0 L 5.0 21.0" />
</svg>]],
dragon_crest = [[
<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
<path d="M 12.0 4.0 L 16.5 8.5 L 21.0 6.2 L 18.6 14.6 L 12.0 20.2 L 5.4 14.6 L 3.0 6.2 L 7.5 8.5 Z" />
<path d="M 12.0 9.2 L 14.6 13.0 L 12.0 16.4 L 9.4 13.0 Z" />
</svg>]],
daily_star = [[
<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
<path d="M 12.0 3.2 L 14.6 8.6 L 20.5 9.5 L 16.2 13.7 L 17.2 19.6 L 12.0 16.8 L 6.8 19.6 L 7.8 13.7 L 3.5 9.5 L 9.4 8.6 Z" />
</svg>]],
unit_crest = [[
<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
<path d="M 12.0 3.0 L 19.8 7.5 L 19.8 16.5 L 12.0 21.0 L 4.2 16.5 L 4.2 7.5 Z" />
<path d="M 12.0 8.2 L 15.8 12.0 L 12.0 15.8 L 8.2 12.0 Z" />
</svg>]],
settings = [[
<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
<circle cx="12.0" cy="12.0" r="3.2" />
<path d="M 10.1 5.5 L 10.2 2.8 L 13.8 2.8 L 13.9 5.5 L 16.7 7.1 L 19.1 5.8 L 20.9 8.9 L 18.6 10.4 L 18.6 13.6 L 20.9 15.1 L 19.1 18.2 L 16.7 16.9 L 13.9 18.5 L 13.8 21.2 L 10.2 21.2 L 10.1 18.5 L 7.3 16.9 L 4.9 18.2 L 3.1 15.1 L 5.4 13.6 L 5.4 10.4 L 3.1 8.9 L 4.9 5.8 L 7.3 7.1 Z" />
</svg>]],
search = [[
<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
<circle cx="10.5" cy="10.5" r="6.2" />
<path d="M 15.1 15.1 L 20.2 20.2" />
</svg>]],
collapse = [[
<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
<path d="M 14.5 4.0 L 20.0 4.0 L 20.0 9.5 M 20.0 4.0 L 13.8 10.2 M 9.5 20.0 L 4.0 20.0 L 4.0 14.5 M 4.0 20.0 L 10.2 13.8" />
</svg>]],
chevron_right = [[
<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
<path d="M 9.0 6.0 L 15.0 12.0 L 9.0 18.0" />
</svg>]],
keybind = [[
<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
<rect x="3.0" y="5.5" width="18.0" height="13.0" rx="2.5" />
<path d="M 7.0 9.5 L 8.5 9.5 M 11.2 9.5 L 12.8 9.5 M 15.5 9.5 L 17.0 9.5 M 7.0 13.2 L 8.5 13.2 M 15.5 13.2 L 17.0 13.2 M 9.5 15.0 L 14.5 15.0" />
</svg>]],
}
local function resolveSvgIconId(raw: string?): string
local key = string.lower(tostring(raw or "main"))
if CustomSvgDefinitions[key] then return key end
if string.find(key, "combat") or string.find(key, "sword") or string.find(key, "dungeon") then return "raid_swords" end
if string.find(key, "boss") or string.find(key, "dragon") then return "dragon_crest" end
if string.find(key, "quest") or string.find(key, "teleport") or string.find(key, "stage") then return "quests" end
if string.find(key, "event") or string.find(key, "reward") or string.find(key, "halloween") then return "daily_star" end
if string.find(key, "gear") or string.find(key, "char") or string.find(key, "refine") or string.find(key, "sell") then return "unit_crest" end
if string.find(key, "keybind") or string.find(key, "system") then return "keybind" end
if string.find(key, "setting") or string.find(key, "config") then return "settings" end
return "main"
end
local function createCustomSvgIcon(parent: Instance, iconName: string, iconSize: number?, initialColor: Color3?, position: UDim2?)
local sz = iconSize or 18
local curColor = initialColor or Theme.TextMuted
local strokePx = math.clamp(1.8 * (sz / 18), 1.4, 2.2)
local container = Instance.new("Frame")
container.Name = "SvgIcon_" .. tostring(iconName)
container.Size = UDim2.fromOffset(sz, sz)
container.Position = position or UDim2.new(0, 0, 0, 0)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.Parent = parent
local strokeTargets: { UIStroke } = {}
local fillTargets: { Frame } = {}
local function drawVectorSegment(x0: number, y0: number, x1: number, y1: number)
local px0, py0 = (x0 / 24) * sz, (y0 / 24) * sz
local px1, py1 = (x1 / 24) * sz, (y1 / 24) * sz
local dx, dy = px1 - px0, py1 - py0
local dist = math.sqrt(dx * dx + dy * dy)
if dist < 0.05 then return end
local seg = Instance.new("Frame")
seg.AnchorPoint = Vector2.new(0.5, 0.5)
seg.Position = UDim2.fromOffset((px0 + px1) * 0.5, (py0 + py1) * 0.5)
seg.Size = UDim2.fromOffset(dist + strokePx * 0.85, strokePx)
seg.Rotation = math.deg(math.atan2(dy, dx))
seg.BackgroundColor3 = curColor
seg.BorderSizePixel = 0
seg.Parent = container
local cap = Instance.new("UICorner")
cap.CornerRadius = UDim.new(1, 0)
cap.Parent = seg
table.insert(fillTargets, seg)
end
local function parseAndRenderSvgPath(d: string)
local cleanD = string.gsub(string.gsub(d, "([A-Za-z])", " %1 "), ",", " ")
local tokens = {}
for tok in string.gmatch(cleanD, "%S+") do table.insert(tokens, tok) end
local i, curX, curY, startX, startY, cmd = 1, 0, 0, 0, 0, "M"
while i <= #tokens do
local t = tokens[i]
if string.match(t, "^[A-Za-z]$") then cmd = t; i += 1 end
if cmd == "M" then
curX, curY = tonumber(tokens[i]) or 0, tonumber(tokens[i + 1]) or 0
startX, startY = curX, curY
i += 2; cmd = "L"
elseif cmd == "L" then
local nx, ny = tonumber(tokens[i]) or 0, tonumber(tokens[i + 1]) or 0
drawVectorSegment(curX, curY, nx, ny)
curX, curY = nx, ny; i += 2
elseif cmd == "Z" or cmd == "z" then
drawVectorSegment(curX, curY, startX, startY)
curX, curY = startX, startY
else
i += 1
end
end
end
local function buildIconGeometry(targetIconName: string)
for _, ch in ipairs(container:GetChildren()) do ch:Destroy() end
table.clear(strokeTargets); table.clear(fillTargets)
local resolved = resolveSvgIconId(targetIconName)
local svgMarkup = CustomSvgDefinitions[resolved] or CustomSvgDefinitions.main
for rectTag in string.gmatch(svgMarkup, "<rect[^/>]+/>") do
local x = tonumber(string.match(rectTag, "x=\"([^\"]+)\"")) or 0
local y = tonumber(string.match(rectTag, "y=\"([^\"]+)\"")) or 0
local w = tonumber(string.match(rectTag, "width=\"([^\"]+)\"")) or 0
local h = tonumber(string.match(rectTag, "height=\"([^\"]+)\"")) or 0
local rx = tonumber(string.match(rectTag, "rx=\"([^\"]+)\"")) or 0
local rf = Instance.new("Frame")
rf.Position = UDim2.fromOffset((x / 24) * sz, (y / 24) * sz)
rf.Size = UDim2.fromOffset((w / 24) * sz, (h / 24) * sz)
rf.BackgroundTransparency = 1
rf.BorderSizePixel = 0
rf.Parent = container
if rx > 0 then
local rc = Instance.new("UICorner")
rc.CornerRadius = UDim.new(0, math.max(1, math.floor((rx / 24) * sz + 0.5)))
rc.Parent = rf
end
local rs = Instance.new("UIStroke")
rs.Color = curColor; rs.Thickness = strokePx; rs.Parent = rf
table.insert(strokeTargets, rs)
end
for circleTag in string.gmatch(svgMarkup, "<circle[^/>]+/>") do
local cx = tonumber(string.match(circleTag, "cx=\"([^\"]+)\"")) or 12
local cy = tonumber(string.match(circleTag, "cy=\"([^\"]+)\"")) or 12
local r = tonumber(string.match(circleTag, "r=\"([^\"]+)\"")) or 4
local cf = Instance.new("Frame")
cf.Position = UDim2.fromOffset(((cx - r) / 24) * sz, ((cy - r) / 24) * sz)
cf.Size = UDim2.fromOffset(((r * 2) / 24) * sz, ((r * 2) / 24) * sz)
cf.BackgroundTransparency = 1; cf.BorderSizePixel = 0; cf.Parent = container
local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(1, 0); cc.Parent = cf
local cs = Instance.new("UIStroke"); cs.Color = curColor; cs.Thickness = strokePx; cs.Parent = cf
table.insert(strokeTargets, cs)
end
for pathD in string.gmatch(svgMarkup, "<path[^>]-d=\"([^\"]+)\"") do
parseAndRenderSvgPath(pathD)
end
end
buildIconGeometry(iconName)
local ctrl = { Frame = container }
function ctrl:SetColor(newColor: Color3, tweenSec: number?)
curColor = newColor
for _, st in ipairs(strokeTargets) do st.Color = newColor end
for _, fl in ipairs(fillTargets) do fl.BackgroundColor3 = newColor end
end
function ctrl:SetIcon(newIconName: string) buildIconGeometry(newIconName) end
function ctrl:SetRotation(deg: number, tweenSec: number?)
if tweenSec and tweenSec > 0 then
TweenService:Create(container, TweenInfo.new(tweenSec), { Rotation = deg }):Play()
else
container.Rotation = deg
end
end
return ctrl
end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SerennityHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 2147483647
ScreenGui.Parent = PlayerGui
local ToastContainer = Instance.new("Frame")
ToastContainer.Name = "ToastContainer"
ToastContainer.Size = UDim2.new(0, 270, 0, 260)
ToastContainer.Position = UDim2.new(1, -286, 1, -276)
ToastContainer.BackgroundTransparency = 1
ToastContainer.Parent = ScreenGui
do
local tl = Instance.new("UIListLayout")
tl.SortOrder = Enum.SortOrder.LayoutOrder
tl.VerticalAlignment = Enum.VerticalAlignment.Bottom
tl.Padding = UDim.new(0, 8)
tl.Parent = ToastContainer
end
local function notify(title: string, msg: string, duration: number?)
pcall(function()
local card = Instance.new("Frame")
card.Size = UDim2.new(1, 0, 0, 56)
card.BackgroundColor3 = Theme.CardBg
card.BorderSizePixel = 0
card.Parent = ToastContainer
local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = card
local s = Instance.new("UIStroke"); s.Color = Theme.AccentBlue; s.Thickness = 1.2; s.Parent = card
local tLbl = Instance.new("TextLabel")
tLbl.Size = UDim2.new(1, -20, 0, 20); tLbl.Position = UDim2.new(0, 10, 0, 6)
tLbl.BackgroundTransparency = 1; tLbl.FontFace = FontBold; tLbl.TextSize = 13
tLbl.TextColor3 = Theme.AccentBlue; tLbl.TextXAlignment = Enum.TextXAlignment.Left
tLbl.TextTruncate = Enum.TextTruncate.AtEnd; tLbl.Text = title; tLbl.Parent = card
local mLbl = Instance.new("TextLabel")
mLbl.Size = UDim2.new(1, -20, 0, 22); mLbl.Position = UDim2.new(0, 10, 0, 26)
mLbl.BackgroundTransparency = 1; mLbl.FontFace = FontMedium; mLbl.TextSize = 12
mLbl.TextColor3 = Theme.TextSecondary; mLbl.TextXAlignment = Enum.TextXAlignment.Left
mLbl.TextTruncate = Enum.TextTruncate.AtEnd; mLbl.Text = msg; mLbl.Parent = card
task.delay(duration or 3, function()
if card and card.Parent then card:Destroy() end
end)
end)
end
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "SerennityFloatBtn"
FloatingBtn.Size = UDim2.new(0, 52, 0, 52)
FloatingBtn.Position = UDim2.new(0, 24, 0, 24)
FloatingBtn.BackgroundColor3 = Theme.WindowBg
FloatingBtn.BorderSizePixel = 0
FloatingBtn.Text = ""
FloatingBtn.AutoButtonColor = false
FloatingBtn.Visible = IsMobileDevice or false
FloatingBtn.Parent = ScreenGui
do
local fbCorner = Instance.new("UICorner"); fbCorner.CornerRadius = UDim.new(0, 12); fbCorner.Parent = FloatingBtn
local fbStroke = Instance.new("UIStroke"); fbStroke.Color = Theme.AccentBlue; fbStroke.Transparency = 0.25; fbStroke.Thickness = 1.4; fbStroke.Parent = FloatingBtn
end
local CustomLogoAsset = ""
local CustomLogoContent = nil
local applyCrossPlatformLogo = nil
;(function()
local rgbaB64File = "serennity_logo_96x96.b64"
local b64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local b64Lut = {}
for i = 1, #b64Chars do b64Lut[string.byte(b64Chars, i)] = i - 1 end
local function buildEditableLogoContent(rawRgbaB64: string)
local clean = string.gsub(rawRgbaB64, "[^%w%+%/%=]", "")
local totalBytes = 96 * 96 * 4
local buf = buffer.create(totalBytes)
local outOffset = 0
for i = 1, #clean, 4 do
local c1, c2, c3, c4 = string.byte(clean, i, i + 3)
local n = bit32.bor(
bit32.lshift(b64Lut[c1] or 0, 18),
bit32.lshift(b64Lut[c2] or 0, 12),
bit32.lshift(b64Lut[c3] or 0, 6),
b64Lut[c4] or 0
)
if outOffset < totalBytes then buffer.writeu8(buf, outOffset, bit32.band(bit32.rshift(n, 16), 0xFF)); outOffset += 1 end
if c3 and c3 ~= 61 and outOffset < totalBytes then buffer.writeu8(buf, outOffset, bit32.band(bit32.rshift(n, 8), 0xFF)); outOffset += 1 end
if c4 and c4 ~= 61 and outOffset < totalBytes then buffer.writeu8(buf, outOffset, bit32.band(n, 0xFF)); outOffset += 1 end
end
if outOffset < totalBytes then return nil end
local ei = game:GetService("AssetService"):CreateEditableImage({ Size = Vector2.new(96, 96) })
ei:WritePixelsBuffer(Vector2.zero, Vector2.new(96, 96), buf)
return Content.fromObject(ei)
end
pcall(function()
if typeof(isfile) == "function" and typeof(readfile) == "function" and isfile(rgbaB64File) then
local cachedB64 = readfile(rgbaB64File)
if type(cachedB64) == "string" and #cachedB64 >= 48000 then
CustomLogoContent = buildEditableLogoContent(cachedB64)
end
end
end)
applyCrossPlatformLogo = function(fbImg: ImageLabel, sideImg: ImageLabel)
if CustomLogoContent then
pcall(function()
fbImg.ImageContent = CustomLogoContent
sideImg.ImageContent = CustomLogoContent
end)
return
end
task.spawn(function()
local applied = false
pcall(function()
local rawRgbaB64 = game:HttpGet("https://pastefy.app/cM3JgxLc/raw")
if type(rawRgbaB64) == "string" and #rawRgbaB64 >= 48000 then
if typeof(writefile) == "function" then pcall(writefile, rgbaB64File, rawRgbaB64) end
local contentObj = buildEditableLogoContent(rawRgbaB64)
if contentObj then
CustomLogoContent = contentObj
fbImg.ImageContent = contentObj
sideImg.ImageContent = contentObj
applied = true
end
end
end)
if not applied then
createCustomSvgIcon(FloatingBtn, "raid_swords", 24, Theme.AccentBlue, UDim2.new(0.5, -12, 0.5, -12))
createCustomSvgIcon(sideImg.Parent, "raid_swords", 28, Theme.AccentBlue, UDim2.new(0, 22, 0, 24))
end
end)
end
end)()
local fbLogo = Instance.new("ImageLabel")
fbLogo.Name = "FloatLogo"
fbLogo.Size = UDim2.new(1, -8, 1, -8)
fbLogo.Position = UDim2.new(0, 4, 0, 4)
fbLogo.BackgroundTransparency = 1
fbLogo.ScaleType = Enum.ScaleType.Fit
fbLogo.Image = CustomLogoAsset
fbLogo.Parent = FloatingBtn
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 880, 0, 556)
MainWindow.Position = UDim2.new(0.5, -440, 0.5, -278)
MainWindow.BackgroundColor3 = Theme.WindowBg
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = true
MainWindow.Parent = ScreenGui
do
local mwCorner = Instance.new("UICorner"); mwCorner.CornerRadius = UDim.new(0, 12); mwCorner.Parent = MainWindow
local mwStroke = Instance.new("UIStroke"); mwStroke.Color = Theme.Stroke; mwStroke.Thickness = 1.2; mwStroke.Parent = MainWindow
end
local function makeDraggable(dragHandle: GuiObject, targetFrame: GuiObject)
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
table.insert(Connections, dragHandle.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true; dragStart = input.Position; startPos = targetFrame.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then dragging = false end
end)
end
end))
table.insert(Connections, dragHandle.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end))
table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging and dragStart and startPos then
local delta = input.Position - dragStart
if delta.Magnitude > 8 then dragHandle:SetAttribute("_WasDragged", true) end
targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end))
end
makeDraggable(FloatingBtn, FloatingBtn)
;(function()
local mwScale = Instance.new("UIScale")
mwScale.Name = "ResponsiveScale"
mwScale.Scale = 1
mwScale.Parent = MainWindow
local lastScale = 1
local function updateScale()
local cam = workspace.CurrentCamera
if not cam then return end
local vp = cam.ViewportSize
if vp.X <= 0 or vp.Y <= 0 then return end
local newScale = 1
if vp.X < 910 or vp.Y < 580 then
newScale = math.clamp(math.min((vp.X - 20) / 880, (vp.Y - 20) / 556), 0.45, 1)
end
if math.abs(newScale - lastScale) > 0.01 then
lastScale = newScale
mwScale.Scale = newScale
MainWindow.Position = UDim2.new(0.5, -math.floor(440 * newScale), 0.5, -math.floor(278 * newScale))
end
end
updateScale()
if workspace.CurrentCamera then
table.insert(Connections, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale))
end
end)()
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 240, 1, 0)
Sidebar.BackgroundColor3 = Theme.SidebarBg
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainWindow
do
local sbCorner = Instance.new("UICorner"); sbCorner.CornerRadius = UDim.new(0, 12); sbCorner.Parent = Sidebar
local sbDiv = Instance.new("Frame")
sbDiv.Size = UDim2.new(0, 1, 1, 0); sbDiv.Position = UDim2.new(1, -1, 0, 0)
sbDiv.BackgroundColor3 = Theme.Stroke; sbDiv.BorderSizePixel = 0; sbDiv.Parent = Sidebar
local BrandHeader = Instance.new("Frame")
BrandHeader.Name = "BrandHeader"
BrandHeader.Size = UDim2.new(1, 0, 0, 76)
BrandHeader.BackgroundTransparency = 1
BrandHeader.Parent = Sidebar
makeDraggable(BrandHeader, MainWindow)
local LogoImage = Instance.new("ImageLabel")
LogoImage.Name = "SerennityLogo"
LogoImage.Size = UDim2.new(0, 48, 0, 48)
LogoImage.Position = UDim2.new(0, 12, 0, 14)
LogoImage.BackgroundTransparency = 1
LogoImage.ScaleType = Enum.ScaleType.Fit
LogoImage.Image = CustomLogoAsset
LogoImage.Parent = BrandHeader
if type(applyCrossPlatformLogo) == "function" then
applyCrossPlatformLogo(fbLogo, LogoImage)
end
local MapTitleLabel = Instance.new("TextLabel")
MapTitleLabel.Name = "MapTitleLabel"
MapTitleLabel.Size = UDim2.new(1, -74, 0, 22)
MapTitleLabel.Position = UDim2.new(0, 66, 0, 15)
MapTitleLabel.BackgroundTransparency = 1
MapTitleLabel.FontFace = FontBold
MapTitleLabel.TextSize = 14
MapTitleLabel.TextColor3 = Theme.TextPrimary
MapTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
MapTitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
MapTitleLabel.Text = CurrentMapName
MapTitleLabel.Parent = BrandHeader
local HubSubLabel = Instance.new("TextLabel")
HubSubLabel.Name = "HubSubLabel"
HubSubLabel.Size = UDim2.new(1, -72, 0, 20)
HubSubLabel.Position = UDim2.new(0, 66, 0, 39)
HubSubLabel.BackgroundTransparency = 1
HubSubLabel.FontFace = FontMedium
HubSubLabel.TextSize = 13
HubSubLabel.TextColor3 = Theme.AccentBlue
HubSubLabel.TextXAlignment = Enum.TextXAlignment.Left
HubSubLabel.Text = "Serennity Hub • " .. SCRIPT_VERSION .. " (FREE)"
HubSubLabel.Parent = BrandHeader
end
local NavListFrame = Instance.new("ScrollingFrame")
NavListFrame.Name = "NavList"
NavListFrame.Size = UDim2.new(1, -24, 1, -162)
NavListFrame.Position = UDim2.new(0, 12, 0, 80)
NavListFrame.BackgroundTransparency = 1
NavListFrame.BorderSizePixel = 0
NavListFrame.ScrollBarThickness = 0
NavListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
NavListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
NavListFrame.Parent = Sidebar
do
local nl = Instance.new("UIListLayout")
nl.SortOrder = Enum.SortOrder.LayoutOrder
nl.Padding = UDim.new(0, 6)
nl.Parent = NavListFrame
end
do
local UserCard = Instance.new("Frame")
UserCard.Name = "UserCard"
UserCard.Size = UDim2.new(1, -24, 0, 62)
UserCard.Position = UDim2.new(0, 12, 1, -74)
UserCard.BackgroundColor3 = Theme.CardBg
UserCard.BorderSizePixel = 0
UserCard.Parent = Sidebar
local ucC = Instance.new("UICorner"); ucC.CornerRadius = UDim.new(0, 10); ucC.Parent = UserCard
local ucS = Instance.new("UIStroke"); ucS.Color = Theme.Stroke; ucS.Thickness = 1; ucS.Parent = UserCard
local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Name = "AvatarImg"
AvatarImg.Size = UDim2.new(0, 38, 0, 38)
AvatarImg.Position = UDim2.new(0, 10, 0.5, -19)
AvatarImg.BackgroundColor3 = Theme.ControlBg
AvatarImg.BorderSizePixel = 0
AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
AvatarImg.Parent = UserCard
local avC = Instance.new("UICorner"); avC.CornerRadius = UDim.new(1, 0); avC.Parent = AvatarImg
local OnlineDot = Instance.new("Frame")
OnlineDot.Size = UDim2.new(0, 10, 0, 10)
OnlineDot.Position = UDim2.new(0, 38, 0.5, 9)
OnlineDot.BackgroundColor3 = Theme.OnlineGreen
OnlineDot.BorderSizePixel = 0
OnlineDot.Parent = UserCard
local odC = Instance.new("UICorner"); odC.CornerRadius = UDim.new(1, 0); odC.Parent = OnlineDot
local odS = Instance.new("UIStroke"); odS.Color = Theme.CardBg; odS.Thickness = 1.5; odS.Parent = OnlineDot
local UcTitle = Instance.new("TextLabel")
UcTitle.Size = UDim2.new(1, -78, 0, 20); UcTitle.Position = UDim2.new(0, 56, 0, 10)
UcTitle.BackgroundTransparency = 1; UcTitle.FontFace = FontBold; UcTitle.TextSize = 15
UcTitle.TextColor3 = Theme.TextPrimary; UcTitle.TextXAlignment = Enum.TextXAlignment.Left
UcTitle.TextTruncate = Enum.TextTruncate.AtEnd; UcTitle.Text = LocalPlayer.DisplayName
UcTitle.Parent = UserCard
local UcSub = Instance.new("TextLabel")
UcSub.Size = UDim2.new(1, -78, 0, 18); UcSub.Position = UDim2.new(0, 56, 0, 33)
UcSub.BackgroundTransparency = 1; UcSub.FontFace = FontMedium; UcSub.TextSize = 13
UcSub.TextColor3 = Theme.AccentBlue; UcSub.TextXAlignment = Enum.TextXAlignment.Left
UcSub.TextTruncate = Enum.TextTruncate.AtEnd
UcSub.Text = "@" .. LocalPlayer.Name .. " • " .. ClientDeviceType
UcSub.Parent = UserCard
createCustomSvgIcon(UserCard, "chevron_right", 16, Theme.TextMuted, UDim2.new(1, -24, 0.5, -8))
end
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -240, 1, 0)
ContentArea.Position = UDim2.new(0, 240, 0, 0)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainWindow
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 58)
TopBar.BackgroundTransparency = 1
TopBar.Parent = ContentArea
makeDraggable(TopBar, MainWindow)
local TopBarDivider = Instance.new("Frame")
TopBarDivider.Size = UDim2.new(1, 0, 0, 1)
TopBarDivider.Position = UDim2.new(0, 0, 1, -1)
TopBarDivider.BackgroundColor3 = Theme.Stroke
TopBarDivider.BorderSizePixel = 0
TopBarDivider.Parent = TopBar
local ActiveTabIconCtrl = createCustomSvgIcon(TopBar, "main", 18, Theme.AccentBlue, UDim2.new(0, 24, 0.5, -9))
local ActiveTabTitleLabel = Instance.new("TextLabel")
ActiveTabTitleLabel.Size = UDim2.new(0, 240, 0, 26)
ActiveTabTitleLabel.Position = UDim2.new(0, 50, 0.5, -13)
ActiveTabTitleLabel.BackgroundTransparency = 1
ActiveTabTitleLabel.FontFace = FontBold
ActiveTabTitleLabel.TextSize = 19
ActiveTabTitleLabel.TextColor3 = Theme.TextPrimary
ActiveTabTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
ActiveTabTitleLabel.Text = "Main & Stage"
ActiveTabTitleLabel.Parent = TopBar
local SearchFrame = Instance.new("Frame")
SearchFrame.Name = "SearchFrame"
SearchFrame.Size = UDim2.new(0, 210, 0, 34)
SearchFrame.Position = UDim2.new(1, -264, 0.5, -17)
SearchFrame.BackgroundColor3 = Theme.SidebarBg
SearchFrame.BorderSizePixel = 0
SearchFrame.Parent = TopBar
local sfCorner = Instance.new("UICorner")
sfCorner.CornerRadius = UDim.new(0, 7)
sfCorner.Parent = SearchFrame
local sfStroke = Instance.new("UIStroke")
sfStroke.Color = Theme.Stroke
sfStroke.Thickness = 1
sfStroke.Parent = SearchFrame
local SearchIconCtrl = createCustomSvgIcon(SearchFrame, "search", 16, Theme.TextMuted, UDim2.new(0, 10, 0.5, -8))
local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, -38, 1, 0)
SearchBox.Position = UDim2.new(0, 32, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.FontFace = FontMedium
SearchBox.TextSize = 13
SearchBox.TextColor3 = Theme.TextPrimary
SearchBox.PlaceholderText = "Search"
SearchBox.PlaceholderColor3 = Theme.TextMuted
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Text = ""
SearchBox.Parent = SearchFrame
SearchBox.Focused:Connect(function()
sfStroke.Color = Theme.AccentBlue
SearchIconCtrl:SetColor(Theme.AccentBlue, 0.14)
end)
SearchBox.FocusLost:Connect(function()
sfStroke.Color = Theme.Stroke
SearchIconCtrl:SetColor(Theme.TextMuted, 0.14)
end)
local CollapseBtn = Instance.new("TextButton")
CollapseBtn.Name = "CollapseBtn"
CollapseBtn.Size = UDim2.new(0, 30, 0, 30)
CollapseBtn.Position = UDim2.new(1, -42, 0.5, -15)
CollapseBtn.BackgroundTransparency = 1
CollapseBtn.Text = ""
CollapseBtn.AutoButtonColor = false
CollapseBtn.Parent = TopBar
local CollapseIconCtrl = createCustomSvgIcon(CollapseBtn, "collapse", 18, Theme.TextMuted, UDim2.new(0.5, -9, 0.5, -9))
CollapseBtn.MouseEnter:Connect(function()
CollapseIconCtrl:SetColor(Theme.TextPrimary, 0.12)
end)
CollapseBtn.MouseLeave:Connect(function()
CollapseIconCtrl:SetColor(Theme.TextMuted, 0.12)
end)
local function setWindowVisible(vis: boolean)
MainWindow.Visible = vis
FloatingBtn.Visible = (not vis) or IsMobileDevice
end
CollapseBtn.MouseButton1Click:Connect(function()
setWindowVisible(false)
end)
FloatingBtn.MouseButton1Click:Connect(function()
if FloatingBtn:GetAttribute("_WasDragged") then
FloatingBtn:SetAttribute("_WasDragged", false)
return
end
if IsMobileDevice then
setWindowVisible(not MainWindow.Visible)
else
setWindowVisible(true)
end
end)
local IsBindingKey = false
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gp)
if IsBindingKey or IsMobileDevice or gp then return end
if input.UserInputType == Enum.UserInputType.Keyboard then
local keyName = input.KeyCode.Name
if keyName == (Cfg.MenuKeybind or "RightControl") then
setWindowVisible(not MainWindow.Visible)
end
end
end))
local TabsRegistry = {}
local AllSearchableCards = {}
local CurrentSelectedTab = nil
local function createTab(tabName: string, iconId: string)
local resolvedIcon = resolveSvgIconId(iconId ~= "" and iconId or tabName)
local navBtn = Instance.new("TextButton")
navBtn.Name = "Tab_" .. tabName
navBtn.Size = UDim2.new(1, 0, 0, 42)
navBtn.BackgroundColor3 = Theme.ActiveTabBg
navBtn.BackgroundTransparency = 1
navBtn.BorderSizePixel = 0
navBtn.AutoButtonColor = false
navBtn.Text = ""
navBtn.Parent = NavListFrame
local nbC = Instance.new("UICorner"); nbC.CornerRadius = UDim.new(0, 8); nbC.Parent = navBtn
local nbS = Instance.new("UIStroke"); nbS.Color = Theme.ActiveStroke; nbS.Thickness = 1; nbS.Transparency = 1; nbS.Parent = navBtn
local nbIcon = createCustomSvgIcon(navBtn, resolvedIcon, 18, Theme.TextMuted, UDim2.new(0, 14, 0.5, -9))
local nbTitle = Instance.new("TextLabel")
nbTitle.Size = UDim2.new(1, -48, 1, 0); nbTitle.Position = UDim2.new(0, 42, 0, 0)
nbTitle.BackgroundTransparency = 1; nbTitle.FontFace = FontMedium; nbTitle.TextSize = 15
nbTitle.TextColor3 = Theme.SidebarText; nbTitle.TextXAlignment = Enum.TextXAlignment.Left
nbTitle.TextTruncate = Enum.TextTruncate.AtEnd; nbTitle.Text = tabName; nbTitle.Parent = navBtn
local page = Instance.new("Frame")
page.Name = "Page_" .. tabName
page.Size = UDim2.new(1, 0, 1, -58); page.Position = UDim2.new(0, 0, 0, 58)
page.BackgroundTransparency = 1; page.Visible = false; page.Parent = ContentArea
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "ColumnsScroll"
scroll.Size = UDim2.new(1, -44, 1, -28); scroll.Position = UDim2.new(0, 22, 0, 14)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = Theme.AccentBlue; scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = page
local leftCol = Instance.new("Frame")
leftCol.Name = "LeftColumn"; leftCol.Size = UDim2.new(0.5, -8, 0, 0)
leftCol.BackgroundTransparency = 1; leftCol.AutomaticSize = Enum.AutomaticSize.Y; leftCol.Parent = scroll
local lLay = Instance.new("UIListLayout"); lLay.SortOrder = Enum.SortOrder.LayoutOrder; lLay.Padding = UDim.new(0, 14); lLay.Parent = leftCol
local rightCol = Instance.new("Frame")
rightCol.Name = "RightColumn"; rightCol.Size = UDim2.new(0.5, -8, 0, 0); rightCol.Position = UDim2.new(0.5, 8, 0, 0)
rightCol.BackgroundTransparency = 1; rightCol.AutomaticSize = Enum.AutomaticSize.Y; rightCol.Parent = scroll
local rLay = Instance.new("UIListLayout"); rLay.SortOrder = Enum.SortOrder.LayoutOrder; rLay.Padding = UDim.new(0, 14); rLay.Parent = rightCol
local entry = { Name = tabName, Page = page, Left = leftCol, Right = rightCol, NavBtn = navBtn, NavStroke = nbS, NavIcon = nbIcon, NavTitle = nbTitle, Icon = resolvedIcon }
function entry:Select()
CurrentSelectedTab = entry
ActiveTabIconCtrl:SetIcon(resolvedIcon)
ActiveTabIconCtrl:SetColor(Theme.AccentBlue)
ActiveTabTitleLabel.Text = tabName
for _, other in ipairs(TabsRegistry) do
local isMe = (other == entry)
other.Page.Visible = isMe
other.NavBtn.BackgroundColor3 = Theme.ActiveTabBg
other.NavBtn.BackgroundTransparency = isMe and 0 or 1
other.NavStroke.Transparency = isMe and 0 or 1
other.NavIcon:SetColor(isMe and Theme.TextPrimary or Theme.TextMuted, 0.14)
other.NavTitle.TextColor3 = isMe and Theme.TextPrimary or Theme.SidebarText
other.NavTitle.FontFace = isMe and FontBold or FontMedium
end
end
navBtn.MouseEnter:Connect(function()
if CurrentSelectedTab ~= entry then
TweenService:Create(navBtn, TweenInfo.new(0.12), {
BackgroundColor3 = Theme.HoverTabBg,
BackgroundTransparency = 0.35,
}):Play()
nbIcon:SetColor(Theme.AccentBlue, 0.12)
TweenService:Create(nbTitle, TweenInfo.new(0.12), { TextColor3 = Theme.TextPrimary }):Play()
end
end)
navBtn.MouseLeave:Connect(function()
if CurrentSelectedTab ~= entry then
TweenService:Create(navBtn, TweenInfo.new(0.12), {
BackgroundColor3 = Theme.ActiveTabBg,
BackgroundTransparency = 1,
}):Play()
nbIcon:SetColor(Theme.TextMuted, 0.12)
TweenService:Create(nbTitle, TweenInfo.new(0.12), { TextColor3 = Theme.SidebarText }):Play()
end
end)
navBtn.MouseButton1Click:Connect(function() entry:Select() end)
table.insert(TabsRegistry, entry)
return entry
end
local AllTogglesRegistry = {}
local AllSlidersRegistry = {}
local AllDropdownsRegistry = {}
local function createSectionCard(parentColumn: Frame, cardTitle: string, cardIcon: string, defaultExpanded: boolean?)
local isExpanded = (defaultExpanded ~= false)
local resolvedCardIcon = resolveSvgIconId(cardIcon ~= "" and cardIcon or cardTitle)
local card = Instance.new("Frame")
card.Name = "Card_" .. cardTitle
card.Size = UDim2.new(1, 0, 0, 0)
card.AutomaticSize = Enum.AutomaticSize.Y
card.BackgroundColor3 = Theme.CardBg
card.BorderSizePixel = 0
card.Parent = parentColumn
local cC = Instance.new("UICorner"); cC.CornerRadius = UDim.new(0, 10); cC.Parent = card
local cS = Instance.new("UIStroke"); cS.Color = Theme.Stroke; cS.Thickness = 1; cS.Parent = card
local headerBtn = Instance.new("TextButton")
headerBtn.Name = "Header"
headerBtn.Size = UDim2.new(1, 0, 0, 46)
headerBtn.BackgroundTransparency = 1
headerBtn.Text = ""
headerBtn.AutoButtonColor = false
headerBtn.Parent = card
local hIconCtrl = createCustomSvgIcon(headerBtn, resolvedCardIcon, 18, Theme.AccentBlue, UDim2.new(0, 16, 0.5, -9))
local hTitle = Instance.new("TextLabel")
hTitle.Name = "CardTitle"
hTitle.Size = UDim2.new(1, -96, 1, 0)
hTitle.Position = UDim2.new(0, 42, 0, 0)
hTitle.BackgroundTransparency = 1
hTitle.FontFace = FontBold
hTitle.TextSize = 15
hTitle.TextColor3 = Theme.TextPrimary
hTitle.TextXAlignment = Enum.TextXAlignment.Left
hTitle.TextTruncate = Enum.TextTruncate.AtEnd
hTitle.Text = cardTitle
hTitle.Parent = headerBtn
local popHolder = Instance.new("Frame")
popHolder.Size = UDim2.new(0, 14, 0, 12)
popHolder.Position = UDim2.new(1, -48, 0.5, -6)
popHolder.BackgroundTransparency = 1
popHolder.Parent = headerBtn
local popOuter = Instance.new("Frame")
popOuter.Size = UDim2.new(0, 11, 0, 9)
popOuter.Position = UDim2.new(0, 0, 0, 1)
popOuter.BackgroundTransparency = 1
popOuter.Parent = popHolder
local poCorner = Instance.new("UICorner"); poCorner.CornerRadius = UDim.new(0, 2); poCorner.Parent = popOuter
local poStroke = Instance.new("UIStroke"); poStroke.Color = Theme.TextMuted; poStroke.Thickness = 1.1; poStroke.Parent = popOuter
local popInner = Instance.new("Frame")
popInner.Size = UDim2.new(0, 5, 0, 4)
popInner.Position = UDim2.new(0, 7, 0, 6)
popInner.BackgroundColor3 = Theme.CardBg
popInner.Parent = popHolder
local piCorner = Instance.new("UICorner"); piCorner.CornerRadius = UDim.new(0, 1); piCorner.Parent = popInner
local piStroke = Instance.new("UIStroke"); piStroke.Color = Theme.TextMuted; piStroke.Thickness = 1.1; piStroke.Parent = popInner
local chevronCtrl = createCustomSvgIcon(headerBtn, "chevron_right", 16, Theme.TextMuted, UDim2.new(1, -27, 0.5, -8))
chevronCtrl:SetRotation(isExpanded and 90 or 0)
local body = Instance.new("Frame")
body.Name = "Body"
body.Size = UDim2.new(1, 0, 0, 0)
body.Position = UDim2.new(0, 0, 0, 46)
body.AutomaticSize = Enum.AutomaticSize.Y
body.BackgroundTransparency = 1
body.Visible = isExpanded
body.Parent = card
local div = Instance.new("Frame")
div.Size = UDim2.new(1, -28, 0, 1)
div.Position = UDim2.new(0, 14, 0, 0)
div.BackgroundColor3 = Theme.Stroke
div.BorderSizePixel = 0
div.Parent = body
local items = Instance.new("Frame")
items.Name = "Items"
items.Size = UDim2.new(1, 0, 0, 0)
items.AutomaticSize = Enum.AutomaticSize.Y
items.BackgroundTransparency = 1
items.Parent = body
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 10)
pad.PaddingBottom = UDim.new(0, 14)
pad.PaddingLeft = UDim.new(0, 16)
pad.PaddingRight = UDim.new(0, 16)
pad.Parent = items
local lay = Instance.new("UIListLayout")
lay.SortOrder = Enum.SortOrder.LayoutOrder
lay.Padding = UDim.new(0, 10)
lay.Parent = items
headerBtn.MouseEnter:Connect(function()
hIconCtrl:SetColor(Theme.TextPrimary, 0.12)
chevronCtrl:SetColor(Theme.TextPrimary, 0.12)
end)
headerBtn.MouseLeave:Connect(function()
hIconCtrl:SetColor(Theme.AccentBlue, 0.12)
chevronCtrl:SetColor(Theme.TextMuted, 0.12)
end)
headerBtn.MouseButton1Click:Connect(function()
isExpanded = not isExpanded
body.Visible = isExpanded
chevronCtrl:SetRotation(isExpanded and 90 or 0, 0.15)
end)
local searchKeywords = { string.lower(cardTitle) }
table.insert(AllSearchableCards, {
Card = card,
Keywords = searchKeywords,
})
local api = {}
function api:AddToggle(configKey: string, labelText: string, defaultVal: boolean, callback: ((boolean) -> ())?)
table.insert(searchKeywords, string.lower(labelText))
local state = (defaultVal == true)
local row = Instance.new("Frame")
row.Size = UDim2.new(1, 0, 0, 28); row.BackgroundTransparency = 1; row.Parent = items
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(1, -54, 1, 0); lbl.BackgroundTransparency = 1
lbl.FontFace = FontMedium; lbl.TextSize = 14; lbl.TextColor3 = Theme.TextSecondary
lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextTruncate = Enum.TextTruncate.AtEnd
lbl.Text = labelText; lbl.Parent = row
local switchBtn = Instance.new("TextButton")
switchBtn.Name = "Toggle_" .. configKey
switchBtn.Size = UDim2.new(0, 42, 0, 22); switchBtn.Position = UDim2.new(1, -42, 0.5, -11)
switchBtn.BackgroundColor3 = state and Theme.AccentBlue or Theme.ToggleOffBg
switchBtn.BorderSizePixel = 0; switchBtn.Text = ""; switchBtn.AutoButtonColor = false; switchBtn.Parent = row
local swC = Instance.new("UICorner"); swC.CornerRadius = UDim.new(1, 0); swC.Parent = switchBtn
local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 16, 0, 16)
knob.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
knob.BackgroundColor3 = state and Theme.ToggleOnKnob or Theme.ToggleOffKnob
knob.BorderSizePixel = 0; knob.Parent = switchBtn
local knC = Instance.new("UICorner"); knC.CornerRadius = UDim.new(1, 0); knC.Parent = knob
local tObj = {}
function tObj:UpdateState(newVal: boolean, fireCb: boolean?)
state = (newVal == true)
Cfg[configKey] = state
TweenService:Create(switchBtn, TweenInfo.new(0.16), {
BackgroundColor3 = state and Theme.AccentBlue or Theme.ToggleOffBg,
}):Play()
TweenService:Create(knob, TweenInfo.new(0.16), {
Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
BackgroundColor3 = state and Theme.ToggleOnKnob or Theme.ToggleOffKnob,
}):Play()
if fireCb and callback then
task.spawn(callback, state)
end
end
function tObj:SetLabel(newText: string)
lbl.Text = newText
end
switchBtn.MouseButton1Click:Connect(function()
tObj:UpdateState(not state, true)
end)
AllTogglesRegistry[configKey] = tObj
return tObj
end
function api:AddSlider(
configKey: string,
labelText: string,
minVal: number,
maxVal: number,
defaultVal: number,
step: number?,
suffix: string?,
callback: ((number) -> ())?
)
table.insert(searchKeywords, string.lower(labelText))
local stepVal = step or 1
local unitSuffix = suffix or ""
local curVal = math.clamp(tonumber(defaultVal) or minVal, minVal, maxVal)
Cfg[configKey] = curVal
local function formatVal(v: number): string
if stepVal < 1 then
return string.format("%.1f%s", v, unitSuffix)
end
return string.format("%d%s", math.floor(v + 0.5), unitSuffix)
end
local box = Instance.new("Frame")
box.Name = "Slider_" .. configKey
box.Size = UDim2.new(1, 0, 0, 42)
box.BackgroundTransparency = 1
box.Parent = items
local topRow = Instance.new("Frame")
topRow.Size = UDim2.new(1, 0, 0, 20)
topRow.BackgroundTransparency = 1
topRow.Parent = box
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(1, -68, 1, 0)
lbl.BackgroundTransparency = 1
lbl.FontFace = FontMedium
lbl.TextSize = 14
lbl.TextColor3 = Theme.TextSecondary
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.TextTruncate = Enum.TextTruncate.AtEnd
lbl.Text = labelText
lbl.Parent = topRow
local valLbl = Instance.new("TextLabel")
valLbl.Name = "ValueLabel"
valLbl.Size = UDim2.new(0, 64, 1, 0)
valLbl.Position = UDim2.new(1, -64, 0, 0)
valLbl.BackgroundTransparency = 1
valLbl.FontFace = FontBold
valLbl.TextSize = 13
valLbl.TextColor3 = Theme.AccentBlue
valLbl.TextXAlignment = Enum.TextXAlignment.Right
valLbl.Text = formatVal(curVal)
valLbl.Parent = topRow
local trackBtn = Instance.new("TextButton")
trackBtn.Name = "Track_" .. configKey
trackBtn.Size = UDim2.new(1, 0, 0, 14)
trackBtn.Position = UDim2.new(0, 0, 0, 24)
trackBtn.BackgroundTransparency = 1
trackBtn.Text = ""
trackBtn.AutoButtonColor = false
trackBtn.Parent = box
local trackBg = Instance.new("Frame")
trackBg.Size = UDim2.new(1, 0, 0, 6)
trackBg.Position = UDim2.new(0, 0, 0.5, -3)
trackBg.BackgroundColor3 = Theme.ControlBg
trackBg.BorderSizePixel = 0
trackBg.Parent = trackBtn
local tbC = Instance.new("UICorner"); tbC.CornerRadius = UDim.new(1, 0); tbC.Parent = trackBg
local tbS = Instance.new("UIStroke"); tbS.Color = Theme.Stroke; tbS.Thickness = 1; tbS.Parent = trackBg
local initAlpha = math.clamp((curVal - minVal) / math.max(0.0001, maxVal - minVal), 0, 1)
local fill = Instance.new("Frame")
fill.Size = UDim2.new(initAlpha, 0, 1, 0)
fill.BackgroundColor3 = Theme.AccentBlue
fill.BorderSizePixel = 0
fill.Parent = trackBg
local flC = Instance.new("UICorner"); flC.CornerRadius = UDim.new(1, 0); flC.Parent = fill
local thumb = Instance.new("Frame")
thumb.Size = UDim2.new(0, 12, 0, 12)
thumb.AnchorPoint = Vector2.new(0.5, 0.5)
thumb.Position = UDim2.new(initAlpha, 0, 0.5, 0)
thumb.BackgroundColor3 = Theme.TextPrimary
thumb.BorderSizePixel = 0
thumb.Parent = trackBg
local thC = Instance.new("UICorner"); thC.CornerRadius = UDim.new(1, 0); thC.Parent = thumb
local sObj = {}
function sObj:SetValue(newVal: number, fireCb: boolean?)
local snapped = minVal + math.floor(((newVal - minVal) / stepVal) + 0.5) * stepVal
if stepVal < 1 then
snapped = tonumber(string.format("%.2f", snapped)) or snapped
end
curVal = math.clamp(snapped, minVal, maxVal)
Cfg[configKey] = curVal
local alpha = math.clamp((curVal - minVal) / math.max(0.0001, maxVal - minVal), 0, 1)
fill.Size = UDim2.new(alpha, 0, 1, 0)
thumb.Position = UDim2.new(alpha, 0, 0.5, 0)
valLbl.Text = formatVal(curVal)
if fireCb and callback then
task.spawn(callback, curVal)
end
end
function sObj:SetLabel(newText: string)
lbl.Text = newText
end
local dragging = false
local function updateFromX(screenX: number)
local absPos = trackBg.AbsolutePosition.X
local absSize = math.max(1, trackBg.AbsoluteSize.X)
local alpha = math.clamp((screenX - absPos) / absSize, 0, 1)
local raw = minVal + alpha * (maxVal - minVal)
sObj:SetValue(raw, true)
end
trackBtn.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
updateFromX(input.Position.X)
end
end)
table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
updateFromX(input.Position.X)
end
end))
table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = false
end
end))
AllSlidersRegistry[configKey] = sObj
return sObj
end
function api:AddSingleDropdown(configKey: string, labelText: string, options: { string }, defaultSelected: string, callback: ((string) -> ())?)
table.insert(searchKeywords, string.lower(labelText))
local currentVal = defaultSelected or options[1] or ""
local isOpen = false
local wrapper = Instance.new("Frame")
wrapper.Size = UDim2.new(1, 0, 0, 32); wrapper.AutomaticSize = Enum.AutomaticSize.Y
wrapper.BackgroundTransparency = 1; wrapper.Parent = items
local topRow = Instance.new("Frame")
topRow.Size = UDim2.new(1, 0, 0, 32); topRow.BackgroundTransparency = 1; topRow.Parent = wrapper
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(0.42, -6, 1, 0); lbl.BackgroundTransparency = 1
lbl.FontFace = FontMedium; lbl.TextSize = 14; lbl.TextColor3 = Theme.TextSecondary
lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextTruncate = Enum.TextTruncate.AtEnd
lbl.Text = labelText; lbl.Parent = topRow
local dropBtn = Instance.new("TextButton")
dropBtn.Size = UDim2.new(0.58, 0, 0, 30); dropBtn.Position = UDim2.new(0.42, 0, 0.5, -15)
dropBtn.BackgroundColor3 = Theme.ControlBg; dropBtn.BorderSizePixel = 0
dropBtn.Text = ""; dropBtn.AutoButtonColor = false; dropBtn.Parent = topRow
local dbC = Instance.new("UICorner"); dbC.CornerRadius = UDim.new(0, 6); dbC.Parent = dropBtn
local dbS = Instance.new("UIStroke"); dbS.Color = Theme.Stroke; dbS.Thickness = 1; dbS.Parent = dropBtn
local sumText = Instance.new("TextLabel")
sumText.Size = UDim2.new(1, -26, 1, 0); sumText.Position = UDim2.new(0, 10, 0, 0)
sumText.BackgroundTransparency = 1; sumText.FontFace = FontMedium; sumText.TextSize = 12
sumText.TextColor3 = Theme.TextPrimary; sumText.TextXAlignment = Enum.TextXAlignment.Left
sumText.TextTruncate = Enum.TextTruncate.AtEnd; sumText.Text = currentVal; sumText.Parent = dropBtn
local arrowCtrl = createCustomSvgIcon(dropBtn, "chevron_right", 14, Theme.TextMuted, UDim2.new(1, -21, 0.5, -7))
arrowCtrl:SetRotation(90)
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, 0, 0, math.min(#options * 29 + 10, 175))
listFrame.Position = UDim2.new(0, 0, 0, 36)
listFrame.BackgroundColor3 = Theme.ControlBg; listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 3; listFrame.ScrollBarImageColor3 = Theme.AccentBlue
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0); listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.Visible = false; listFrame.Parent = wrapper
local lfC = Instance.new("UICorner"); lfC.CornerRadius = UDim.new(0, 6); lfC.Parent = listFrame
local lfS = Instance.new("UIStroke"); lfS.Color = Theme.Stroke; lfS.Thickness = 1; lfS.Parent = listFrame
local lfP = Instance.new("UIPadding")
lfP.PaddingTop = UDim.new(0, 5); lfP.PaddingBottom = UDim.new(0, 5)
lfP.PaddingLeft = UDim.new(0, 6); lfP.PaddingRight = UDim.new(0, 6); lfP.Parent = listFrame
local lfL = Instance.new("UIListLayout"); lfL.SortOrder = Enum.SortOrder.LayoutOrder; lfL.Padding = UDim.new(0, 3); lfL.Parent = listFrame
local function rebuild(optsList: { string }?, selOverride: string?)
if type(optsList) == "table" then
options = optsList
end
if type(selOverride) == "string" and #selOverride > 0 then
currentVal = selOverride
elseif #options > 0 then
local found = false
for _, o in ipairs(options) do
if o == currentVal then found = true; break end
end
if not found then
currentVal = options[1]
end
end
sumText.Text = currentVal
listFrame.Size = UDim2.new(1, 0, 0, math.min(#options * 29 + 10, 175))
for _, ch in ipairs(listFrame:GetChildren()) do
if ch:IsA("TextButton") then ch:Destroy() end
end
for idx, opt in ipairs(options) do
local isMe = (opt == currentVal)
local ob = Instance.new("TextButton")
ob.LayoutOrder = idx; ob.Size = UDim2.new(1, -4, 0, 26)
ob.BackgroundColor3 = Theme.ActiveTabBg; ob.BackgroundTransparency = isMe and 0.2 or 1
ob.BorderSizePixel = 0; ob.AutoButtonColor = false; ob.Text = ""; ob.Parent = listFrame
local obC = Instance.new("UICorner"); obC.CornerRadius = UDim.new(0, 5); obC.Parent = ob
local ot = Instance.new("TextLabel")
ot.Size = UDim2.new(1, -28, 1, 0); ot.Position = UDim2.new(0, 10, 0, 0)
ot.BackgroundTransparency = 1; ot.FontFace = FontMedium; ot.TextSize = 13
ot.TextColor3 = isMe and Theme.AccentBlue or Theme.TextSecondary
ot.TextXAlignment = Enum.TextXAlignment.Left; ot.TextTruncate = Enum.TextTruncate.AtEnd
ot.Text = opt; ot.Parent = ob
local checkDot = Instance.new("Frame")
checkDot.Size = UDim2.new(0, 7, 0, 7)
checkDot.Position = UDim2.new(1, -16, 0.5, -3)
checkDot.BackgroundColor3 = Theme.AccentBlue
checkDot.BorderSizePixel = 0
checkDot.Visible = isMe
checkDot.Parent = ob
local cdCorner = Instance.new("UICorner")
cdCorner.CornerRadius = UDim.new(1, 0)
cdCorner.Parent = checkDot
ob.MouseButton1Click:Connect(function()
currentVal = opt
if configKey ~= "" then
Cfg[configKey] = currentVal
end
sumText.Text = currentVal
isOpen = false
listFrame.Visible = false
arrowCtrl:SetRotation(90, 0.14)
rebuild()
if callback then callback(currentVal) end
end)
end
end
rebuild()
dropBtn.MouseButton1Click:Connect(function()
isOpen = not isOpen
listFrame.Visible = isOpen
arrowCtrl:SetRotation(isOpen and -90 or 90, 0.14)
end)
local dObj = {
SetSelected = function(_, val: string)
currentVal = val
if configKey ~= "" then
Cfg[configKey] = val
end
sumText.Text = val
rebuild(nil, val)
end,
SetOptions = function(_, newOptions: { string }, newSelected: string?)
rebuild(newOptions, newSelected)
end,
GetSelected = function(): string
return currentVal
end,
}
if configKey ~= "" then
AllDropdownsRegistry[configKey] = dObj
end
return dObj
end
function api:AddTextBox(labelText: string, placeholderText: string, defaultText: string?, callback: ((string) -> ())?)
table.insert(searchKeywords, string.lower(labelText))
local row = Instance.new("Frame")
row.Size = UDim2.new(1, 0, 0, 32)
row.BackgroundTransparency = 1
row.Parent = items
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(0.42, -6, 1, 0)
lbl.BackgroundTransparency = 1
lbl.FontFace = FontMedium
lbl.TextSize = 14
lbl.TextColor3 = Theme.TextSecondary
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.TextTruncate = Enum.TextTruncate.AtEnd
lbl.Text = labelText
lbl.Parent = row
local boxBg = Instance.new("Frame")
boxBg.Size = UDim2.new(0.58, 0, 0, 30)
boxBg.Position = UDim2.new(0.42, 0, 0.5, -15)
boxBg.BackgroundColor3 = Theme.ControlBg
boxBg.BorderSizePixel = 0
boxBg.Parent = row
local bbCorner = Instance.new("UICorner"); bbCorner.CornerRadius = UDim.new(0, 6); bbCorner.Parent = boxBg
local bbStroke = Instance.new("UIStroke"); bbStroke.Color = Theme.Stroke; bbStroke.Thickness = 1; bbStroke.Parent = boxBg
local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -20, 1, 0)
inputBox.Position = UDim2.new(0, 10, 0, 0)
inputBox.BackgroundTransparency = 1
inputBox.FontFace = FontMedium
inputBox.TextSize = 13
inputBox.TextColor3 = Theme.TextPrimary
inputBox.PlaceholderText = placeholderText
inputBox.PlaceholderColor3 = Theme.TextMuted
inputBox.TextXAlignment = Enum.TextXAlignment.Left
inputBox.ClearTextOnFocus = false
inputBox.Text = defaultText or ""
inputBox.Parent = boxBg
inputBox.Focused:Connect(function()
bbStroke.Color = Theme.AccentBlue
end)
inputBox.FocusLost:Connect(function()
bbStroke.Color = Theme.Stroke
if callback then
callback(inputBox.Text)
end
end)
local tbObj = {}
function tbObj:GetText(): string
return inputBox.Text
end
function tbObj:SetText(txt: string)
inputBox.Text = txt
end
return tbObj
end
function api:AddKeybind(labelText: string, defaultKeyName: string, callback: ((string) -> ())?)
table.insert(searchKeywords, string.lower(labelText))
local currentKey = defaultKeyName or "RightControl"
local row = Instance.new("Frame")
row.Size = UDim2.new(1, 0, 0, 32)
row.BackgroundTransparency = 1
row.Parent = items
local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(0.52, 0, 1, 0)
lbl.BackgroundTransparency = 1
lbl.FontFace = FontMedium
lbl.TextSize = 14
lbl.TextColor3 = Theme.TextSecondary
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.TextTruncate = Enum.TextTruncate.AtEnd
lbl.Text = labelText
lbl.Parent = row
local keyBtn = Instance.new("TextButton")
keyBtn.Size = UDim2.new(0.48, 0, 0, 30)
keyBtn.Position = UDim2.new(0.52, 0, 0.5, -15)
keyBtn.BackgroundColor3 = Theme.ControlBg
keyBtn.BorderSizePixel = 0
keyBtn.FontFace = FontBold
keyBtn.TextSize = 13
keyBtn.TextColor3 = Theme.AccentBlue
keyBtn.Text = "[" .. currentKey .. "]"
keyBtn.AutoButtonColor = false
keyBtn.Parent = row
local kbCorner = Instance.new("UICorner"); kbCorner.CornerRadius = UDim.new(0, 6); kbCorner.Parent = keyBtn
local kbStroke = Instance.new("UIStroke"); kbStroke.Color = Theme.Stroke; kbStroke.Thickness = 1; kbStroke.Parent = keyBtn
keyBtn.MouseButton1Click:Connect(function()
if IsBindingKey then return end
IsBindingKey = true
keyBtn.Text = "[Press Key...]"
keyBtn.TextColor3 = Theme.TextPrimary
kbStroke.Color = Theme.AccentBlue
local bindConn
bindConn = UserInputService.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
bindConn:Disconnect()
if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
currentKey = "None"
elseif input.KeyCode ~= Enum.KeyCode.Escape then
currentKey = input.KeyCode.Name
end
keyBtn.Text = "[" .. currentKey .. "]"
keyBtn.TextColor3 = Theme.AccentBlue
kbStroke.Color = Theme.Stroke
task.delay(0.15, function()
IsBindingKey = false
end)
if callback then
callback(currentKey)
end
end
end)
end)
return {
SetKey = function(_, newKey: string)
currentKey = newKey
keyBtn.Text = "[" .. currentKey .. "]"
end,
}
end
function api:AddButton(btnText: string, callback: () -> ())
table.insert(searchKeywords, string.lower(btnText))
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, 0, 0, 34)
btn.BackgroundColor3 = Theme.ActiveTabBg; btn.BorderSizePixel = 0
btn.FontFace = FontBold; btn.TextSize = 13; btn.TextColor3 = Theme.TextPrimary
btn.TextTruncate = Enum.TextTruncate.AtEnd; btn.Text = btnText
btn.AutoButtonColor = false; btn.Parent = items
local bC = Instance.new("UICorner"); bC.CornerRadius = UDim.new(0, 7); bC.Parent = btn
local bS = Instance.new("UIStroke"); bS.Color = Theme.ActiveStroke; bS.Thickness = 1; bS.Parent = btn
btn.MouseEnter:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(34, 54, 88) }):Play()
end)
btn.MouseLeave:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Theme.ActiveTabBg }):Play()
end)
btn.MouseButton1Click:Connect(function()
if callback then task.spawn(callback) end
end)
return btn
end
function api:AddButtonRow(leftText: string, leftCb: () -> (), rightText: string, rightCb: () -> ())
table.insert(searchKeywords, string.lower(leftText))
table.insert(searchKeywords, string.lower(rightText))
local row = Instance.new("Frame")
row.Size = UDim2.new(1, 0, 0, 32)
row.BackgroundTransparency = 1
row.Parent = items
local function makeHalfBtn(txt: string, posScale: number, posOff: number, cb: () -> ())
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.5, -4, 1, 0)
btn.Position = UDim2.new(posScale, posOff, 0, 0)
btn.BackgroundColor3 = Theme.ActiveTabBg
btn.BorderSizePixel = 0
btn.FontFace = FontBold
btn.TextSize = 13
btn.TextColor3 = Theme.TextPrimary
btn.TextTruncate = Enum.TextTruncate.AtEnd
btn.Text = txt
btn.AutoButtonColor = false
btn.Parent = row
local bC = Instance.new("UICorner"); bC.CornerRadius = UDim.new(0, 7); bC.Parent = btn
local bS = Instance.new("UIStroke"); bS.Color = Theme.ActiveStroke; bS.Thickness = 1; bS.Parent = btn
btn.MouseEnter:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(34, 54, 88) }):Play()
end)
btn.MouseLeave:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Theme.ActiveTabBg }):Play()
end)
btn.MouseButton1Click:Connect(function()
if cb then task.spawn(cb) end
end)
end
makeHalfBtn(leftText, 0, 0, leftCb)
makeHalfBtn(rightText, 0.5, 4, rightCb)
end
function api:AddInfoParagraph(headerText: string, bodyText: string)
table.insert(searchKeywords, string.lower(headerText))
local box = Instance.new("Frame")
box.Size = UDim2.new(1, 0, 0, 0); box.AutomaticSize = Enum.AutomaticSize.Y
box.BackgroundColor3 = Theme.ControlBg; box.BorderSizePixel = 0; box.Parent = items
local bxC = Instance.new("UICorner"); bxC.CornerRadius = UDim.new(0, 7); bxC.Parent = box
local bxS = Instance.new("UIStroke"); bxS.Color = Theme.Stroke; bxS.Thickness = 1; bxS.Parent = box
local pad2 = Instance.new("UIPadding")
pad2.PaddingTop = UDim.new(0, 10); pad2.PaddingBottom = UDim.new(0, 12)
pad2.PaddingLeft = UDim.new(0, 12); pad2.PaddingRight = UDim.new(0, 12); pad2.Parent = box
local lay2 = Instance.new("UIListLayout"); lay2.SortOrder = Enum.SortOrder.LayoutOrder; lay2.Padding = UDim.new(0, 6); lay2.Parent = box
local hLbl = Instance.new("TextLabel")
hLbl.Size = UDim2.new(1, 0, 0, 0); hLbl.AutomaticSize = Enum.AutomaticSize.Y
hLbl.BackgroundTransparency = 1; hLbl.FontFace = FontBold; hLbl.TextSize = 14; hLbl.LineHeight = 1.35
hLbl.TextColor3 = Theme.AccentBlue; hLbl.TextXAlignment = Enum.TextXAlignment.Left
hLbl.TextWrapped = true; hLbl.Text = headerText; hLbl.Parent = box
local bLbl = Instance.new("TextLabel")
bLbl.Size = UDim2.new(1, 0, 0, 0); bLbl.AutomaticSize = Enum.AutomaticSize.Y
bLbl.BackgroundTransparency = 1; bLbl.FontFace = FontMedium; bLbl.TextSize = 13; bLbl.LineHeight = 1.45
bLbl.TextColor3 = Theme.TextSecondary; bLbl.TextXAlignment = Enum.TextXAlignment.Left
bLbl.TextWrapped = true; bLbl.Text = bodyText; bLbl.Parent = box
return hLbl, bLbl
end
return api
end
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
local q = string.lower(string.gsub(SearchBox.Text or "", "^%s*(.-)%s*$", "%1"))
for _, entry in ipairs(AllSearchableCards) do
if q == "" then
entry.Card.Visible = true
else
local matched = false
for _, kw in ipairs(entry.Keywords) do
if string.find(kw, q, 1, true) then
matched = true
break
end
end
entry.Card.Visible = matched
end
end
end)
local TabMain = createTab("Main & Quests", "main")
local TabCombat = createTab("Combat & Skills", "raid_swords")
local TabBoss = createTab("Boss & Restock", "dragon_crest")
local TabChar = createTab("Char, Refine & Sell", "unit_crest")
local TabEvent = createTab("Event & Teleports", "daily_star")
local TabSettings = createTab("Settings", "settings")
local StatusTitleLbl, StatusBodyLbl = nil, nil
do
local ProgCard = createSectionCard(TabMain.Left, "Auto Progression & Stage (Lv.1–99)", "main")
StatusTitleLbl, StatusBodyLbl = ProgCard:AddInfoParagraph(
"Status: Idle (All Toggles OFF)",
"ลูกค้าสามารถเลือกเปิด/ปิดแต่ละฟังก์ชันได้เองอย่างอิสระ 100% (ไม่มีการแอบเปิดพ่วงอัตโนมัติ)"
)
ProgCard:AddToggle("AutoProgression", "Auto Stage Progression (Lv.1-99)", false, function(val)
if val then
notify("Auto Progression [ON]", "เปิดระบบพาเดินเปลี่ยนด่าน Lv.1–99 แล้ว!", 2.2)
else
if not isAnyCombatToggleActive() then
stopAllActiveMovementAndCombat()
end
notify("Auto Progression [OFF]", "หยุดระบบเดินเปลี่ยนด่านทันที", 2.0)
end
end)
ProgCard:AddToggle("AutoUnlockBossGates", "Auto Unlock Boss Gates (Lv.25/50/75/99)", false, function(val)
if val then
notify("Auto Unlock Boss Gates [ON]", "เปิดระบบปลดล็อกด่านบอสเมื่อเลเวลถึงกำหนดแล้ว!", 2.2)
else
if not isAnyCombatToggleActive() then
stopAllActiveMovementAndCombat()
end
notify("Auto Unlock Boss Gates [OFF]", "ปิดระบบปลดล็อกด่านบอสแล้ว", 2.0)
end
end)
ProgCard:AddSingleDropdown(
"WalkOrTeleportMode",
"Move Mode",
{ "Instant Teleport + Walk", "Walk Only (Legit)" },
Cfg.WalkOrTeleportMode
)
local QuestCard = createSectionCard(TabMain.Right, "Auto Quests (Tutorial / Main / Daily / Repeat)", "quests")
QuestCard:AddToggle("AutoMainQuest", "Auto Tutorial & Main Quests", false, function(val)
if not val and not isAnyCombatToggleActive() then
stopAllActiveMovementAndCombat()
end
end)
QuestCard:AddToggle("AutoDailyRepeatQuest", "Auto Daily & Repeatable Quests", false)
QuestCard:AddButton("Accept & Claim All Quests Now", function()
LastQuestActionClock = 0
stepQuestAutomation(nil, true)
notify("Quests Synced", "รับและส่งเควสที่สำเร็จทั้งหมดแล้ว!", 2.0)
end)
local SurvCard = createSectionCard(TabMain.Right, "Survival, Potions & Loot Drops", "unit_crest")
SurvCard:AddToggle("AutoPotion", "Auto Use HP / SP Potions", false)
SurvCard:AddSlider("HpPotionThreshold", "Use HP Potion At (%)", 10, 95, Cfg.HpPotionThreshold or 60, 5, "%")
SurvCard:AddSlider("SpPotionThreshold", "Use Mana Potion At (%)", 10, 95, Cfg.SpPotionThreshold or 35, 5, "%")
SurvCard:AddToggle("AutoRespawn", "Auto Free Town Respawn (0 Robux)", false)
SurvCard:AddToggle("AutoPickupDrops", "Auto Pickup Ground Drops", false)
SurvCard:AddToggle("AutoOpenLootBoxes", "Auto Open LootBoxes & Boss Eggs", false)
end
do
local FarmCard = createSectionCard(TabCombat.Left, "Zone, Combat Logic & Anti-Leash", "raid_swords")
FarmCard:AddToggle("AutoFarmZone", "Auto Farm Selected Zone", false, function(val)
if val then
notify("Auto Farm Zone [ON]", "เริ่มฟาร์มโซน: " .. tostring(Cfg.SelectedZone), 2.2)
else
if not isAnyCombatToggleActive() then
stopAllActiveMovementAndCombat()
end
notify("Auto Farm Zone [OFF]", "หยุดฟาร์มโซนทันที", 2.0)
end
end)
FarmCard:AddSingleDropdown("SelectedZone", "Target Zone", ZONE_DROPDOWN_LIST, Cfg.SelectedZone)
FarmCard:AddSingleDropdown(
"TargetPriority",
"Target Priority",
{
"Smart Leveling (Normal First)",
"All Monsters",
"Normal Only",
"Leader Priority",
"Mini-Boss / Boss Priority",
},
Cfg.TargetPriority
)
FarmCard:AddSingleDropdown(
"CombatMode",
"Combat Logic",
{
"Upper",
"Behind",
"Below",
},
Cfg.CombatMode
)
FarmCard:AddSlider("OrbitDistance", "Distance (ระยะห่างมอน)", 3.5, 16.0, Cfg.OrbitDistance or 5.5, 0.5, " studs")
FarmCard:AddSlider("OrbitSpeed", "Follow Speed (ความเร็วตามมอน)", 0.5, 8.0, Cfg.OrbitSpeed or 2.0, 0.5, "x")
FarmCard:AddToggle("AntiLeashBoundary", "Anti-Leash Boundary (กันมอนหลุดโซนรีเลือด)", false)
FarmCard:AddSlider("MaxLeashRadius", "Max Leash Radius (รัศมีคุมมอนจากจุดเกิด)", 12, 50, Cfg.MaxLeashRadius or 22, 1, " studs")
local SkillCard = createSectionCard(TabCombat.Right, "Auto Skill Manager (Slots 1–8)", "raid_swords")
SkillCard:AddToggle("AutoCastSkills", "Auto Cast Selected Skills (Master)", false, function(val)
if val then
refreshSkillSlotLabelsInUI()
notify("Auto Skill [ON]", "เปิดระบบกดสกิลเฉพาะช่อง (Slot 1–8) ที่ลูกค้าติ๊กเลือกไว้แล้ว!", 2.0)
else
notify("Auto Skill [OFF]", "ปิดระบบกดสกิลอัตโนมัติแล้ว", 2.0)
end
end)
SkillCard:AddToggle("AutoUpgradeSkills", "Auto Upgrade Skills", false)
SkillCard:AddSingleDropdown(
"SkillCastMode",
"Cast Mode",
{
"Spam Mode (รัวตามเวลาที่ตั้ง)",
"Smart Mode (เช็คคูลดาวน์เกม + SP)",
},
Cfg.SkillCastMode
)
SkillCard:AddButtonRow("Enable All Slots (1-8)", function()
for i = 1, 8 do
local k = "UseSlot" .. tostring(i)
if AllTogglesRegistry[k] then
AllTogglesRegistry[k]:UpdateState(true, false)
end
end
refreshSkillSlotLabelsInUI()
notify("All 8 Slots Enabled", "เปิดใช้งานสกิลครบทุกช่อง (Slot 1 ถึง Slot 8) แล้ว!", 2.0)
end, "Disable All Slots (1-8)", function()
for i = 1, 8 do
local k = "UseSlot" .. tostring(i)
if AllTogglesRegistry[k] then
AllTogglesRegistry[k]:UpdateState(false, false)
end
end
refreshSkillSlotLabelsInUI()
notify("All Slots Disabled", "ปิดสกิลทุกช่องแล้ว (เลือกติ๊กเปิดเฉพาะช่องที่ต้องการได้เลย)!", 2.0)
end)
SkillCard:AddButton("Auto Fill Learned Skills to Hotbar (Slots 1-8)", function()
autoFillLearnedSkillsToHotbar()
notify("Hotbar Synced", "ดึงสกิลที่เรียนแล้วลงช่องสกิลว่าง (Slot 1–8) เรียบร้อย!", 2.0)
end)
local defaultSlotDelays = { [1] = 0.1, [2] = 0.2, [3] = 0.2, [4] = 0.5, [5] = 0.2, [6] = 0.2, [7] = 0.2, [8] = 0.2 }
for slotIdx = 1, 8 do
local useKey = "UseSlot" .. tostring(slotIdx)
local delayKey = "Slot" .. tostring(slotIdx) .. "Delay"
local defDelay = tonumber(Cfg[delayKey]) or defaultSlotDelays[slotIdx] or 0.2
local tCtrl = SkillCard:AddToggle(useKey, string.format("Use Slot %d", slotIdx), false)
local sCtrl = SkillCard:AddSlider(delayKey, string.format("Slot %d Cooldown", slotIdx), 0.1, 20.0, defDelay, 0.1, "s")
SlotToggleLabelUpdaters[slotIdx] = function(txt: string)
tCtrl:SetLabel(txt)
end
SlotSliderLabelUpdaters[slotIdx] = function(txt: string)
sCtrl:SetLabel(txt)
end
end
refreshSkillSlotLabelsInUI()
table.insert(Connections, LocalPlayer:GetAttributeChangedSignal("HotbarJson"):Connect(refreshSkillSlotLabelsInUI))
table.insert(Connections, LocalPlayer:GetAttributeChangedSignal("SkillsJson"):Connect(refreshSkillSlotLabelsInUI))
table.insert(Connections, LocalPlayer:GetAttributeChangedSignal("Job"):Connect(refreshSkillSlotLabelsInUI))
end
do
local LootBossCard = createSectionCard(TabBoss.Left, "Major Boss Hunter & Telegraph Evasion", "dragon_crest")
LootBossCard:AddToggle("AutoDodgeBossSkills", "Auto Dodge Boss & Leader Skills (100%)", false)
LootBossCard:AddToggle("AutoBossHunter", "Auto Hunt Selected Major Bosses", false, function(val)
if val then
notify("Major Boss Hunter [ON]", "เปิดระบบล่าบอสใหญ่เฉพาะตัวที่ลูกค้าติ๊กเลือกไว้แล้ว!", 2.0)
else
if not isAnyCombatToggleActive() then
stopAllActiveMovementAndCombat()
end
notify("Major Boss Hunter [OFF]", "ปิดระบบล่าบอสใหญ่แล้ว", 2.0)
end
end)
LootBossCard:AddButtonRow("Select All Bosses (1-5)", function()
for i = 1, 5 do
local k = "HuntBoss0" .. tostring(i)
if AllTogglesRegistry[k] then
AllTogglesRegistry[k]:UpdateState(true, false)
end
end
notify("All Bosses Selected", "เลือกบอสใหญ่ครบทั้ง 5 ตัว (Boss01–Boss05) แล้ว!", 2.0)
end, "Deselect All Bosses", function()
for i = 1, 5 do
local k = "HuntBoss0" .. tostring(i)
if AllTogglesRegistry[k] then
AllTogglesRegistry[k]:UpdateState(false, false)
end
end
notify("All Bosses Cleared", "ยกเลิกการเลือกบอสใหญ่ทั้งหมดแล้ว", 2.0)
end)
LootBossCard:AddToggle("HuntBoss01", "Hunt Boss01: Gorilla King (Lv.25)", false)
LootBossCard:AddToggle("HuntBoss02", "Hunt Boss02: Whitefang Sabertooth (Lv.50)", false)
LootBossCard:AddToggle("HuntBoss03", "Hunt Boss03: Obsidian Pharaoh (Lv.75)", false)
LootBossCard:AddToggle("HuntBoss04", "Hunt Boss04: Tempest Dragon King (Lv.99)", false)
LootBossCard:AddToggle("HuntBoss05", "Hunt Boss05: Volcano Turtle King (Lv.99)", false)
local BossPotCard = createSectionCard(TabBoss.Right, "GateBoss Potion Restock (เช็คและซื้อยาก่อนตีบอส)", "unit_crest")
BossPotCard:AddToggle("AutoRestockBossPotions", "Check & Buy Potions at GateBoss (เช็คยาก่อนตีบอส)", false)
BossPotCard:AddSingleDropdown(
"SelectedHpPotionTier",
"HP Potion Tier (ระดับยาเลือด)",
HP_POTION_TIER_LIST,
Cfg.SelectedHpPotionTier
)
BossPotCard:AddSingleDropdown(
"SelectedSpPotionTier",
"Mana Potion Tier (ระดับยามานา)",
SP_POTION_TIER_LIST,
Cfg.SelectedSpPotionTier
)
BossPotCard:AddSlider(
"MinPotionCheckCount",
"Buy When Below (ถ้ายามีไม่ถึงกี่ขวดให้วาร์ปไปซื้อ)",
1,
300,
Cfg.MinPotionCheckCount or 20,
1,
" ขวด"
)
BossPotCard:AddSlider(
"BuyPotionQuantity",
"Buy Quantity (จำนวนขวดที่จะซื้อ)",
1,
500,
Cfg.BuyPotionQuantity or 50,
5,
" ขวด"
)
BossPotCard:AddButton("Buy Selected Potions Now (วาร์ปไปซื้อยาทันที)", function()
checkAndRestockBossPotions(true)
end)
end
do
local CharCard = createSectionCard(TabChar.Left, "Auto Equipment, Cards & Stats", "unit_crest")
CharCard:AddToggle("AutoEquipBest", "Auto Equip Best Gear & Cards", false, function(val)
if val then
LastGearShopClock = 0
stepCharacterGearRefineShop()
end
end)
CharCard:AddToggle("AutoAllocateStats", "Auto Allocate Stat Points", false, function(val)
if val then
LastGearShopClock = 0
stepCharacterGearRefineShop()
end
end)
CharCard:AddSingleDropdown(
"StatBuildMode",
"Stat Build",
{ "balance", "STR", "AGI", "VIT", "INT", "DEX", "LUK" },
Cfg.StatBuildMode
)
CharCard:AddButton("Equip Best Gear & Cards Now", function()
pcall(function()
if Remotes:FindFirstChild("EquipItem") then Remotes.EquipItem:FireServer("@best") end
if Remotes:FindFirstChild("CardAction") then Remotes.CardAction:FireServer("auto") end
end)
notify("Equipped Best", "สวมใส่อุปกรณ์และการ์ดที่ดีที่สุดแล้ว!", 2.0)
end)
local RefineCard = createSectionCard(TabChar.Left, "Auto Refine Weapon & Gear (เลือกชิ้นตีบวก)", "unit_crest")
RefineCard:AddToggle("AutoRefineGear", "Auto Refine Selected Gear (ตีบวกชิ้นที่เลือก)", false, function(val)
if val then
refreshRefineSlotLabelsInUI()
LastGearShopClock = 0
stepCharacterGearRefineShop()
notify("Auto Refine [ON]", "เปิดระบบตีบวกเฉพาะชิ้นอุปกรณ์ที่ลูกค้าติ๊กเลือกไว้แล้ว!", 2.2)
else
notify("Auto Refine [OFF]", "ปิดระบบตีบวกอุปกรณ์แล้ว", 2.0)
end
end)
RefineCard:AddSingleDropdown(
"MaxRefineTarget",
"Target Refine (บวกถึงระดับ)",
{ "+1", "+2", "+3", "+4", "+5", "+6", "+7", "+8", "+9", "+10" },
Cfg.MaxRefineTarget
)
RefineCard:AddButtonRow("Select All 8 Gear Slots", function()
for _, entry in ipairs(REFINE_SLOT_DEFS) do
if AllTogglesRegistry[entry.Key] then
AllTogglesRegistry[entry.Key]:UpdateState(true, false)
else
Cfg[entry.Key] = true
end
end
refreshRefineSlotLabelsInUI()
notify("All Gear Slots Selected", "เลือกตีบวกครบทั้ง 8 ชิ้นที่สวมใส่แล้ว!", 2.0)
end, "Deselect All Slots", function()
for _, entry in ipairs(REFINE_SLOT_DEFS) do
if AllTogglesRegistry[entry.Key] then
AllTogglesRegistry[entry.Key]:UpdateState(false, false)
else
Cfg[entry.Key] = false
end
end
refreshRefineSlotLabelsInUI()
notify("Gear Slots Cleared", "ยกเลิกการเลือกชิ้นตีบวกทั้งหมดแล้ว", 2.0)
end)
for _, entry in ipairs(REFINE_SLOT_DEFS) do
local tCtrl = RefineCard:AddToggle(entry.Key, entry.Label, false)
RefineToggleLabelUpdaters[entry.Key] = function(txt: string)
tCtrl:SetLabel(txt)
end
end
RefineCard:AddButton("Refine Selected Gear Now (ตีบวกชิ้นที่เลือกทันที)", function()
refineSelectedGearNow(true)
end)
refreshRefineSlotLabelsInUI()
table.insert(Connections, LocalPlayer:GetAttributeChangedSignal("WeaponId"):Connect(refreshRefineSlotLabelsInUI))
table.insert(Connections, LocalPlayer:GetAttributeChangedSignal("EquipJson"):Connect(refreshRefineSlotLabelsInUI))
table.insert(Connections, LocalPlayer:GetAttributeChangedSignal("RefineJson"):Connect(refreshRefineSlotLabelsInUI))
table.insert(Connections, LocalPlayer:GetAttributeChangedSignal("GearJson"):Connect(refreshRefineSlotLabelsInUI))
local JunkSellCard = createSectionCard(TabChar.Left, "Auto Sell Junk (Monster Materials Only)", "unit_crest")
JunkSellCard:AddInfoParagraph(
"Separated Junk Seller (ขายเฉพาะขยะมอนสเตอร์)",
"ขายเฉพาะชิ้นส่วนมอนสเตอร์ทั่วไป (ไม่ยุ่งกับอาวุธ ชุดเกราะ หินตีบวก หรือของที่กดล็อกไว้)"
)
JunkSellCard:AddToggle("AutoSellJunk", "Auto Sell Junk Materials", false, function(val)
if val then
LastGearShopClock = 0
stepCharacterGearRefineShop()
notify("Auto Sell Junk [ON]", "เปิดระบบขายขยะมอนสเตอร์อัตโนมัติแล้ว!", 2.0)
else
notify("Auto Sell Junk [OFF]", "ปิดระบบขายขยะมอนสเตอร์อัตโนมัติแล้ว", 2.0)
end
end)
JunkSellCard:AddSlider("SellJunkBagPct", "Sell Junk When Bag At (%)", 20, 95, Cfg.SellJunkBagPct or 65, 5, "%")
JunkSellCard:AddButton("Sell All Junk Materials Now", function()
sellJunkMaterialsNow(false)
end)
local EquipSellCard = createSectionCard(TabChar.Right, "Auto Sell Equipment by Rarity (Weapons & Armor)", "unit_crest")
EquipSellCard:AddInfoParagraph(
"Separated Equipment Seller (เลือกประเภทและ Rarity เอง)",
"ขายเฉพาะอาวุธ/ชุดเกราะตามประเภทและระดับ Rarity ที่ลูกค้าติ๊กเลือกเอง (ข้ามของที่สวมใส่และของที่ล็อกเสมอ)"
)
EquipSellCard:AddToggle("AutoSellEquipment", "Auto Sell Equipment by Rarity", false, function(val)
if val then
LastGearShopClock = 0
stepCharacterGearRefineShop()
notify("Auto Sell Equipment [ON]", "เปิดระบบขายอาวุธ/ชุดเกราะเฉพาะที่ลูกค้าติ๊กเลือกไว้แล้ว!", 2.2)
else
notify("Auto Sell Equipment [OFF]", "ปิดระบบขายอาวุธ/ชุดเกราะอัตโนมัติแล้ว", 2.0)
end
end)
EquipSellCard:AddSlider("SellEquipBagPct", "Sell Equipment When Bag At (%)", 10, 95, Cfg.SellEquipBagPct or 60, 5, "%")
EquipSellCard:AddToggle("SellWeapons", "Sell Weapons (อาวุธทุกชนิด)", false)
EquipSellCard:AddToggle("SellArmors", "Sell Armors & Rings (ชุดเกราะ/หมวก/ประดับ)", false)
EquipSellCard:AddToggle("KeepRefinedGear", "Protect Refined Gear (ไม่ขายของตีบวก +1 ขึ้นไป)", false)
EquipSellCard:AddButtonRow("Select Low Tiers (Tier I-II)", function()
for t = 1, 6 do
local k = "SellRarityTier" .. tostring(t)
local shouldOn = (t <= 2)
if AllTogglesRegistry[k] then
AllTogglesRegistry[k]:UpdateState(shouldOn, false)
else
Cfg[k] = shouldOn
end
end
notify("Low Rarity Selected", "เลือกขายเฉพาะ Tier I (สีเทา) และ Tier II (สีเขียว) แล้ว!", 2.0)
end, "Clear All Rarity", function()
for t = 1, 6 do
local k = "SellRarityTier" .. tostring(t)
if AllTogglesRegistry[k] then
AllTogglesRegistry[k]:UpdateState(false, false)
else
Cfg[k] = false
end
end
notify("Rarity Cleared", "ยกเลิกการเลือก Rarity ทั้งหมดแล้ว", 2.0)
end)
EquipSellCard:AddToggle("SellRarityTier1", "Rarity Tier I — Common (สีเทา / Grey)", false)
EquipSellCard:AddToggle("SellRarityTier2", "Rarity Tier II — Uncommon (สีเขียว / Green)", false)
EquipSellCard:AddToggle("SellRarityTier3", "Rarity Tier III — Rare (สีฟ้า / Blue)", false)
EquipSellCard:AddToggle("SellRarityTier4", "Rarity Tier IV — Epic (สีม่วง / Purple)", false)
EquipSellCard:AddToggle("SellRarityTier5", "Rarity Tier V — Legendary (สีส้ม / Orange)", false)
EquipSellCard:AddToggle("SellRarityTier6", "Rarity Tier VI — Mythic (สีแดง / Red)", false)
EquipSellCard:AddButton("Sell Selected Rarity Equipment Now", function()
sellSelectedEquipmentNow(false)
end)
end
do
local EventCard = createSectionCard(TabEvent.Left, "Halloween Event & Dungeon", "daily_star")
EventCard:AddToggle("AutoTrickOrTreat", "Auto Trick-or-Treat (100 Candy)", false, function(val)
if not val and not isAnyCombatToggleActive() then
stopAllActiveMovementAndCombat()
end
end)
EventCard:AddToggle("AutoHalloweenDungeon", "Auto Halloween Dungeon (Ready + Farm)", false, function(val)
if not val and not isAnyCombatToggleActive() then
stopAllActiveMovementAndCombat()
end
end)
local RewCard = createSectionCard(TabEvent.Left, "Free Pet, Beta Rewards & Codes", "daily_star")
RewCard:AddToggle("AutoClaimBetaPet", "Auto Claim & Summon Free Pet (Turtle)", false, function(val)
if val then claimAllFreeRewardsNow() end
end)
RewCard:AddToggle("AutoClaimAllRewards", "Auto Claim All Rewards (Daily/Pass/Achieve)", false, function(val)
if val then claimAllFreeRewardsNow() end
end)
RewCard:AddButton("Claim All Free Rewards & Pet Now", function()
local prev1, prev2 = Cfg.AutoClaimBetaPet, Cfg.AutoClaimAllRewards
Cfg.AutoClaimBetaPet = true
Cfg.AutoClaimAllRewards = true
claimAllFreeRewardsNow()
Cfg.AutoClaimBetaPet = prev1
Cfg.AutoClaimAllRewards = prev2
notify("Rewards Claimed", "กดรับสัตว์เลี้ยงฟรี รางวัลเลเวล และเช็คอินทั้งหมดแล้ว!", 2.5)
end)
RewCard:AddButton("Redeem All Active Codes", function()
local redeemRemote = Remotes:FindFirstChild("RedeemCode")
if not redeemRemote then return end
local candidateCodes = {
"WELCOME", "BETA", "HUNTING", "HALLOWEEN", "RELEASE",
"HUNTINGTOGETHER", "FREE", "THANKYOU", "UPDATE1", "LUMI",
}
local okCount = 0
for _, code in ipairs(candidateCodes) do
local ok, res = pcall(function()
return redeemRemote:InvokeServer(code)
end)
if ok and type(res) == "table" and res.Ok then
okCount += 1
end
end
notify("Redeem Codes", string.format("ตรวจสอบโค้ดทั้งหมดเรียบร้อย (%d โค้ดใหม่)", okCount), 2.5)
end)
local TpCard = createSectionCard(TabEvent.Right, "Instant Teleports (Zones & Town NPCs)", "quests")
TpCard:AddSingleDropdown("SelectedTeleportZone", "Select Zone", TELEPORT_ZONE_LIST, Cfg.SelectedTeleportZone)
TpCard:AddButton("Teleport to Selected Zone", function()
local sel = tostring(Cfg.SelectedTeleportZone or "")
local targetPos = Vector3.new(0, 4.7, 45)
if sel ~= "Town (Main Village)" then
local z = ZONE_BY_LABEL[sel]
if z and z.Pos then
targetPos = z.Pos
end
end
local _, _, hrp = getCharacterAndRoot()
if hrp then
task.spawn(function()
pcall(function() LocalPlayer:RequestStreamAroundAsync(targetPos, 1) end)
end)
hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3.5, 0))
hrp.AssemblyLinearVelocity = Vector3.zero
notify("Teleported", "วาร์ปไปยัง " .. sel .. " แล้ว!", 2.0)
end
end)
TpCard:AddSingleDropdown(
"SelectedTeleportNpc",
"Select Town NPC",
{ "blacksmith", "merchant", "masterclass", "craftsmith", "statmaster", "storage" },
Cfg.SelectedTeleportNpc
)
TpCard:AddButton("Teleport to Selected NPC", function()
local npcKey = tostring(Cfg.SelectedTeleportNpc or "blacksmith")
local pos = NPC_POSITIONS[npcKey] or Vector3.new(0, 4.7, 45)
local _, _, hrp = getCharacterAndRoot()
if hrp then
hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3.0, 3.0), pos)
hrp.AssemblyLinearVelocity = Vector3.zero
notify("Teleported to NPC", "วาร์ปไปหา NPC: " .. npcKey .. " แล้ว!", 2.0)
end
end)
end
local ConfigRootFolder = "SerennityHub"
local ConfigSubFolder = "SerennityHub/HuntingConfigs_v1"
local SystemSettingsPath = "SerennityHub/hunting_settings_v1.json"
local SystemSettings = {
AutoLoadConfig = false,
SelectedConfig = "default",
AutoExecute = false,
MenuKeybind = "RightControl",
}
local MenuKeybindPickerAPI = nil
local ConfigDropdownAPI = nil
local SettingsHeaderLbl, SettingsBodyLbl = nil, nil
local function ensureConfigFolders()
pcall(function()
if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
if not isfolder(ConfigRootFolder) then
makefolder(ConfigRootFolder)
end
if not isfolder(ConfigSubFolder) then
makefolder(ConfigSubFolder)
end
end
end)
end
local function saveSystemSettings()
ensureConfigFolders()
pcall(function()
if typeof(writefile) == "function" then
writefile(SystemSettingsPath, HttpService:JSONEncode(SystemSettings))
end
end)
end
local function loadSystemSettings()
ensureConfigFolders()
pcall(function()
if typeof(isfile) == "function" and typeof(readfile) == "function" and isfile(SystemSettingsPath) then
local decoded = HttpService:JSONDecode(readfile(SystemSettingsPath))
if type(decoded) == "table" then
if type(decoded.AutoLoadConfig) == "boolean" then
SystemSettings.AutoLoadConfig = decoded.AutoLoadConfig
end
if type(decoded.SelectedConfig) == "string" and #decoded.SelectedConfig > 0 then
SystemSettings.SelectedConfig = decoded.SelectedConfig
end
if type(decoded.AutoExecute) == "boolean" then
SystemSettings.AutoExecute = decoded.AutoExecute
end
if type(decoded.MenuKeybind) == "string" and #decoded.MenuKeybind > 0 then
SystemSettings.MenuKeybind = decoded.MenuKeybind
Cfg.MenuKeybind = decoded.MenuKeybind
end
end
end
end)
end
local function sanitizeConfigName(raw: string): string
local clean = string.gsub(raw or "", "[<>:\"/\\|%?%*%c]", "")
clean = string.gsub(clean, "^%s*(.-)%s*$", "%1")
return clean
end
local function getSavedConfigNames(): { string }
ensureConfigFolders()
local names = {}
pcall(function()
if typeof(listfiles) == "function" then
for _, fpath in ipairs(listfiles(ConfigSubFolder)) do
local fname = string.match(fpath, "([^/\\]+)%.json$")
if fname and #fname > 0 then
table.insert(names, fname)
end
end
end
end)
table.sort(names)
if #names == 0 then
table.insert(names, "default")
end
return names
end
local function applyBoostFPS(enabled: boolean, showToast: boolean?)
pcall(function()
local Lighting = game:GetService("Lighting")
Lighting.GlobalShadows = not enabled
LocalPlayer:SetAttribute("OptShadows", not enabled)
LocalPlayer:SetAttribute("OptFastMode", enabled)
if enabled then
Lighting.FogEnd = 9e9
end
for _, eff in ipairs(Lighting:GetChildren()) do
if eff:IsA("PostEffect") then
eff.Enabled = not enabled
end
end
if enabled then
task.spawn(function()
for i, inst in ipairs(workspace:GetDescendants()) do
if inst:IsA("BasePart") then
inst.CastShadow = false
elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") then
inst.Enabled = false
end
if i % 1500 == 0 then
task.wait()
end
end
end)
end
end)
if showToast then
notify("Boost FPS", enabled and "เปิดโหมด Boost FPS (ลดแลค/ปิดเงา/ลดเอฟเฟกต์) แล้ว!" or "ปิดโหมด Boost FPS แล้ว", 2.5)
end
end
local function refreshSettingsStatusBox()
if SettingsHeaderLbl and SettingsBodyLbl then
SettingsHeaderLbl.Text = "Active Config: " .. tostring(SystemSettings.SelectedConfig) .. "  •  Device: " .. tostring(ClientDeviceType)
if not IsMobileDevice then
SettingsBodyLbl.Text = string.format(
"Auto Load: %s  •  Auto Execute: %s\nAnti AFK: %s  •  Boost FPS: %s\nUI Toggle Key: [%s]  •  Version: %s",
SystemSettings.AutoLoadConfig and "ON" or "OFF",
SystemSettings.AutoExecute and "ON" or "OFF",
(Cfg.AntiAFK == true) and "ON" or "OFF",
(Cfg.BoostFPS == true) and "ON" or "OFF",
tostring(Cfg.MenuKeybind or "RightControl"),
SCRIPT_VERSION
)
else
SettingsBodyLbl.Text = string.format(
"Auto Load: %s  •  Auto Execute: %s\nAnti AFK: %s  •  Boost FPS: %s\nMode: Mobile Touch UI  •  Version: %s",
SystemSettings.AutoLoadConfig and "ON" or "OFF",
SystemSettings.AutoExecute and "ON" or "OFF",
(Cfg.AntiAFK == true) and "ON" or "OFF",
(Cfg.BoostFPS == true) and "ON" or "OFF",
SCRIPT_VERSION
)
end
end
end
local function writeConfigToFile(cfgName: string): boolean
local clean = sanitizeConfigName(cfgName)
if #clean == 0 then
return false
end
ensureConfigFolders()
local payload = {}
for k, defaultVal in pairs(DefaultConfig) do
local curVal = Cfg[k]
if type(defaultVal) == "boolean" then
payload[k] = (curVal == true)
elseif type(defaultVal) == "number" then
payload[k] = tonumber(curVal) or defaultVal
elseif type(defaultVal) == "string" then
payload[k] = type(curVal) == "string" and curVal or defaultVal
elseif type(defaultVal) == "table" then
payload[k] = type(curVal) == "table" and table.clone(curVal) or table.clone(defaultVal)
end
end
local ok = pcall(function()
if typeof(writefile) == "function" then
writefile(ConfigSubFolder .. "/" .. clean .. ".json", HttpService:JSONEncode(payload))
end
end)
return ok
end
local function syncAllUIFromConfig()
for k, tObj in pairs(AllTogglesRegistry) do
if k == "AutoLoadConfig" then
tObj:UpdateState(SystemSettings.AutoLoadConfig == true, false)
elseif k == "AutoExecute" then
tObj:UpdateState(SystemSettings.AutoExecute == true, false)
elseif DefaultConfig[k] ~= nil then
tObj:UpdateState(Cfg[k] == true, false)
end
end
for k, sObj in pairs(AllSlidersRegistry) do
if type(Cfg[k]) == "number" then
sObj:SetValue(Cfg[k], false)
end
end
for k, dObj in pairs(AllDropdownsRegistry) do
if type(Cfg[k]) == "string" then
dObj:SetSelected(Cfg[k])
end
end
if MenuKeybindPickerAPI and type(Cfg.MenuKeybind) == "string" then
MenuKeybindPickerAPI:SetKey(Cfg.MenuKeybind)
end
if Cfg.BoostFPS == true then
applyBoostFPS(true, false)
end
if not isAnyCombatToggleActive() then
stopAllActiveMovementAndCombat()
end
refreshSkillSlotLabelsInUI()
refreshRefineSlotLabelsInUI()
refreshSettingsStatusBox()
end
local function loadConfigFromFile(cfgName: string, silent: boolean?): boolean
local clean = sanitizeConfigName(cfgName)
if #clean == 0 then
return false
end
ensureConfigFolders()
local path = ConfigSubFolder .. "/" .. clean .. ".json"
if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" or not isfile(path) then
return false
end
local ok, decoded = pcall(function()
return HttpService:JSONDecode(readfile(path))
end)
if not ok or type(decoded) ~= "table" then
return false
end
for k, defaultVal in pairs(DefaultConfig) do
local loadedVal = decoded[k]
if type(defaultVal) == "boolean" and type(loadedVal) == "boolean" then
Cfg[k] = loadedVal
elseif type(defaultVal) == "number" and type(loadedVal) == "number" then
Cfg[k] = loadedVal
elseif type(defaultVal) == "string" and type(loadedVal) == "string" and #loadedVal > 0 then
Cfg[k] = loadedVal
elseif type(defaultVal) == "table" and type(loadedVal) == "table" then
Cfg[k] = table.clone(loadedVal)
end
end
if type(Cfg.MenuKeybind) == "string" and #Cfg.MenuKeybind > 0 then
SystemSettings.MenuKeybind = Cfg.MenuKeybind
end
syncAllUIFromConfig()
if not silent then
notify("Config Loaded", "โหลดตั้งค่า '" .. clean .. "' เรียบร้อยแล้ว!", 2.5)
end
return true
end
local function deleteConfigFile(cfgName: string, silent: boolean?): boolean
local clean = sanitizeConfigName(cfgName)
if #clean == 0 then
return false
end
local path = ConfigSubFolder .. "/" .. clean .. ".json"
local deleted = false
pcall(function()
if typeof(isfile) == "function" and typeof(delfile) == "function" and isfile(path) then
delfile(path)
deleted = true
end
end)
if deleted then
local list = getSavedConfigNames()
if typeof(isfile) == "function" and not isfile(ConfigSubFolder .. "/" .. list[1] .. ".json") then
writeConfigToFile("default")
list = getSavedConfigNames()
end
SystemSettings.SelectedConfig = list[1] or "default"
saveSystemSettings()
if ConfigDropdownAPI then
ConfigDropdownAPI:SetOptions(list, SystemSettings.SelectedConfig)
end
refreshSettingsStatusBox()
if not silent then
notify("Config Deleted", "ลบไฟล์ Config '" .. clean .. "' เรียบร้อยแล้ว!", 2.5)
end
end
return deleted
end
loadSystemSettings()
local existingConfigList = getSavedConfigNames()
if typeof(isfile) == "function" and not isfile(ConfigSubFolder .. "/default.json") then
writeConfigToFile("default")
existingConfigList = getSavedConfigNames()
end
do
local ConfigCard = createSectionCard(TabSettings.Left, "Configuration", "settings", true)
local ConfigNameBoxAPI = ConfigCard:AddTextBox("Config Name", "Enter config name...", "")
ConfigDropdownAPI = ConfigCard:AddSingleDropdown("", "Config List", existingConfigList, SystemSettings.SelectedConfig, function(sel)
SystemSettings.SelectedConfig = sel
saveSystemSettings()
refreshSettingsStatusBox()
end)
ConfigCard:AddButton("Create Config", function()
local rawName = ConfigNameBoxAPI:GetText()
local clean = sanitizeConfigName(rawName)
if #clean == 0 then
notify("Create Config", "กรุณาพิมพ์ชื่อ Config ก่อนกดสร้าง!", 2.5)
return
end
if writeConfigToFile(clean) then
SystemSettings.SelectedConfig = clean
saveSystemSettings()
ConfigDropdownAPI:SetOptions(getSavedConfigNames(), clean)
ConfigNameBoxAPI:SetText("")
refreshSettingsStatusBox()
notify("Config Created", "สร้างและบันทึก Config '" .. clean .. "' เรียบร้อยแล้ว!", 2.5)
end
end)
ConfigCard:AddButton("Load Config", function()
local target = ConfigDropdownAPI:GetSelected()
if loadConfigFromFile(target, false) then
SystemSettings.SelectedConfig = target
saveSystemSettings()
refreshSettingsStatusBox()
else
notify("Load Failed", "ไม่พบไฟล์ Config '" .. tostring(target) .. "'", 2.5)
end
end)
ConfigCard:AddButton("Overwrite Config", function()
local target = ConfigDropdownAPI:GetSelected()
if writeConfigToFile(target) then
refreshSettingsStatusBox()
notify("Config Overwritten", "บันทึกทับ Config '" .. tostring(target) .. "' เรียบร้อยแล้ว!", 2.5)
end
end)
ConfigCard:AddButton("Delete Config", function()
local target = ConfigDropdownAPI:GetSelected()
deleteConfigFile(target, false)
end)
ConfigCard:AddButton("Refresh Configs", function()
local list = getSavedConfigNames()
ConfigDropdownAPI:SetOptions(list, SystemSettings.SelectedConfig)
refreshSettingsStatusBox()
notify("Configs Refreshed", "อัปเดตรายชื่อ Config ทั้งหมด (" .. tostring(#list) .. " ไฟล์)", 2.5)
end)
ConfigCard:AddToggle("AutoLoadConfig", "Auto Load Config", SystemSettings.AutoLoadConfig, function(val)
SystemSettings.AutoLoadConfig = val
saveSystemSettings()
refreshSettingsStatusBox()
notify("Auto Load Config", val and ("เปิด Auto Load: '" .. tostring(SystemSettings.SelectedConfig) .. "'") or "ปิด Auto Load Config แล้ว", 2.5)
end)
local SystemCard = createSectionCard(TabSettings.Right, "System & Keybind", "keybind", true)
if not IsMobileDevice then
MenuKeybindPickerAPI = SystemCard:AddKeybind("UI Toggle Keybind", Cfg.MenuKeybind or "RightControl", function(newKey)
Cfg.MenuKeybind = newKey
SystemSettings.MenuKeybind = newKey
saveSystemSettings()
refreshSettingsStatusBox()
notify("Keybind Updated", "เปลี่ยนปุ่มเปิด/ปิด UI เป็น [" .. tostring(newKey) .. "] แล้ว!", 2.5)
end)
end
SystemCard:AddToggle("AntiAFK", "Anti AFK (20m Kick Protection)", false, function(val)
Cfg.AntiAFK = val
if val and typeof(getconnections) == "function" then
pcall(function()
for _, conn in ipairs(getconnections(LocalPlayer.Idled)) do
if conn.Disable then
conn:Disable()
end
end
end)
end
refreshSettingsStatusBox()
notify("Anti AFK", val and "เปิดระบบป้องกันหลุด AFK 20 นาทีแล้ว!" or "ปิดระบบ Anti AFK แล้ว", 2.0)
end)
SystemCard:AddToggle("AutoExecute", "Auto Execute", SystemSettings.AutoExecute, function(val)
SystemSettings.AutoExecute = val
saveSystemSettings()
refreshSettingsStatusBox()
notify("Auto Execute", val and "เปิดระบบรันสคริปต์อัตโนมัติเมื่อย้ายเซิร์ฟ/เข้าดันเจี้ยนแล้ว!" or "ปิดระบบ Auto Execute แล้ว", 2.5)
end)
SystemCard:AddToggle("BoostFPS", "Boost FPS (Ultra Low Lag)", false, function(val)
Cfg.BoostFPS = val
refreshSettingsStatusBox()
applyBoostFPS(val, true)
end)
SystemCard:AddButton("Clean Map VFX & Lag Now", function()
applyBoostFPS(true, true)
end)
SystemCard:AddButton("Copy Serennity Hub Discord Link", function()
if typeof(setclipboard) == "function" then
pcall(setclipboard, DISCORD_INVITE)
end
notify("Copied Discord Link!", "คัดลอกลิงก์ " .. DISCORD_INVITE .. " แล้ว!", 2.5)
end)
SettingsHeaderLbl, SettingsBodyLbl = SystemCard:AddInfoParagraph(
"Active Config: " .. tostring(SystemSettings.SelectedConfig),
"Loading settings..."
)
refreshSettingsStatusBox()
end
if TabsRegistry[1] then
TabsRegistry[1]:Select()
end
table.insert(Connections, LocalPlayer.OnTeleport:Connect(function()
if SystemSettings.AutoExecute and typeof(queue_on_teleport) == "function" then
pcall(function()
queue_on_teleport([[
if isfile and isfile("SerennityHub/loader.luau") then
loadfile("SerennityHub/loader.luau")()
elseif isfile and isfile("serennity_hunting.luau") then
loadfile("serennity_hunting.luau")()
end
]])
end)
end
end))
if SystemSettings.AutoLoadConfig and SystemSettings.SelectedConfig then
pcall(loadConfigFromFile, SystemSettings.SelectedConfig, true)
end
if Remotes and Remotes:FindFirstChild("DungeonPrompt") then
local dp = Remotes.DungeonPrompt
if dp:IsA("RemoteEvent") then
table.insert(Connections, dp.OnClientEvent:Connect(function(action, payload)
if Cfg.AutoHalloweenDungeon and action == "ready" and type(payload) == "table" and payload.Id then
task.delay(0.4, function()
if Cfg.AutoHalloweenDungeon and Remotes:FindFirstChild("DungeonAction") then
Remotes.DungeonAction:FireServer("ready", payload.Id, true)
end
end)
end
end))
end
end
table.insert(Connections, LocalPlayer.Idled:Connect(function()
if Cfg.AntiAFK == true then
pcall(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.zero)
end)
end
end))
local LastRewardLoopClock = 0
local LastStatusUpdateClock = 0
task.spawn(function()
while ScriptAlive do
task.wait(0.20)
if not ScriptAlive then break end
local now = os.clock()
stepPotionsAndRespawn()
stepPickupAndLootBoxes()
stepAutoSkills()
stepCharacterGearRefineShop()
if (Cfg.AutoClaimBetaPet or Cfg.AutoClaimAllRewards) and (now - LastRewardLoopClock >= 5.0) then
LastRewardLoopClock = now
claimAllFreeRewardsNow()
end
local activeZone: { [string]: any }? = nil
local statusReason = "Idle (All Toggles OFF)"
if workspace:GetAttribute("PlaceRole") == "Dungeon" and Cfg.AutoHalloweenDungeon then
statusReason = "Halloween Dungeon: Clearing Waves & Boss"
local dTarget = findTargetInZone(nil, nil)
if dTarget then
engageMonsterTarget(dTarget)
end
elseif stepHalloweenTrickTreat() then
statusReason = "Halloween Event: Knocking WitchHouse (100 Candy)"
else
local huntedBossZone: { [string]: any }? = nil
if Cfg.AutoBossHunter then
for _, z in ipairs(ZONE_ORDER) do
if z.IsBossRoom and z.BossId and (Cfg["Hunt" .. tostring(z.Id)] == true) and isGateUnlocked(z.GateReq) then
streamBossRoomInBackground(z)
local aliveBoss = isBossMonsterAlive(z.BossId)
if aliveBoss then
huntedBossZone = z
break
end
end
end
end
if huntedBossZone then
activeZone = huntedBossZone
statusReason = "Boss Hunter: Fighting " .. huntedBossZone.Label
elseif Cfg.AutoProgression then
activeZone, statusReason = resolveBestProgressionZone()
elseif Cfg.AutoFarmZone then
local sel = tostring(Cfg.SelectedZone or "Auto Best Zone (Lv.1-99)")
if sel == "Auto Best Zone (Lv.1-99)" then
activeZone, statusReason = resolveBestProgressionZone()
else
activeZone = ZONE_BY_LABEL[sel] or ZONE_BY_ID["Field01"]
statusReason = "Farming Zone: " .. tostring(activeZone.Label)
end
elseif Cfg.AutoUnlockBossGates then
local bz, bReason = resolveBestProgressionZone()
if bz and bz.IsBossRoom then
activeZone = bz
statusReason = bReason
end
elseif Cfg.AutoMainQuest then
activeZone = ZONE_BY_ID["Field01"]
statusReason = "Main Quest: Farming Field01"
end
if Cfg.AutoMainQuest or Cfg.AutoDailyRepeatQuest then
stepQuestAutomation(activeZone, false)
end
if activeZone then
if activeZone.IsBossRoom and Cfg.AutoRestockBossPotions == true then
checkAndRestockBossPotions(false)
end
local specificMon = activeZone.IsBossRoom and activeZone.BossId or nil
local targetMon = findTargetInZone(activeZone, specificMon)
if not targetMon and activeZone.IsBossRoom then
local _, _, hrp = getCharacterAndRoot()
if hrp and (hrp.Position - activeZone.Pos).Magnitude > 30 then
movePlayerToPosition(activeZone.Pos, 15)
else
local fallbackField = ZONE_BY_ID["Field03"]
if activeZone.Id == "Boss02" then fallbackField = ZONE_BY_ID["Field06"]
elseif activeZone.Id == "Boss03" then fallbackField = ZONE_BY_ID["Field09"]
elseif activeZone.Id == "Boss04" or activeZone.Id == "Boss05" then fallbackField = ZONE_BY_ID["Field12"]
end
if fallbackField then
statusReason = string.format("Waiting %s Respawn -> Farming %s", activeZone.Id, fallbackField.Id)
local fbTarget = findTargetInZone(fallbackField, nil)
if fbTarget then
engageMonsterTarget(fbTarget)
else
movePlayerToPosition(fallbackField.Pos, 15)
end
end
end
elseif targetMon then
engageMonsterTarget(targetMon)
else
movePlayerToPosition(activeZone.Pos, 16)
end
end
end
CurrentStatusText = statusReason
if now - LastStatusUpdateClock >= 0.6 then
LastStatusUpdateClock = now
if StatusTitleLbl and StatusBodyLbl then
local lv = tonumber(LocalPlayer:GetAttribute("Level")) or 1
local job = tostring(LocalPlayer:GetAttribute("Job") or "Novice")
local silver = tonumber(LocalPlayer:GetAttribute("Silver")) or 0
StatusTitleLbl.Text = "Status: " .. CurrentStatusText
StatusBodyLbl.Text = string.format("Lv.%d (%s) • Silver: %d • Map: %s", lv, job, silver, CurrentMapName)
end
end
end
end)
_G.SerennityHuntingAPI = {
Config = Cfg,
SystemSettings = SystemSettings,
Toggles = AllTogglesRegistry,
Sliders = AllSlidersRegistry,
Dropdowns = AllDropdownsRegistry,
Tabs = TabsRegistry,
WriteConfigToFile = writeConfigToFile,
LoadConfigFromFile = loadConfigFromFile,
DeleteConfigFile = deleteConfigFile,
GetSavedConfigNames = getSavedConfigNames,
SyncAllUIFromConfig = syncAllUIFromConfig,
SaveSystemSettings = saveSystemSettings,
SkillCastCounts = SkillCastCountMap,
ServerSkillReadyAt = ServerSkillReadyAt,
ResolveBestProgressionZone = resolveBestProgressionZone,
CheckAndRestockBossPotions = checkAndRestockBossPotions,
RefineSelectedGearNow = refineSelectedGearNow,
GetEquippedSlotRefAndInfo = getEquippedSlotRefAndInfo,
ClaimAllFreeRewardsNow = claimAllFreeRewardsNow,
StepQuestAutomation = stepQuestAutomation,
ScanSellableJunkMaterials = scanSellableJunkMaterials,
ScanSellableEquipmentByRarity = scanSellableEquipmentByRarity,
SellJunkMaterialsNow = sellJunkMaterialsNow,
SellSelectedEquipmentNow = sellSelectedEquipmentNow,
StopAll = stopAllActiveMovementAndCombat,
}
_G.SerennityHuntingCleanup = function()
ScriptAlive = false
stopAllActiveMovementAndCombat()
for _, conn in ipairs(Connections) do
pcall(function() conn:Disconnect() end)
end
table.clear(Connections)
if ScreenGui and ScreenGui.Parent then
ScreenGui:Destroy()
end
end
notify("Serennity Hub • " .. SCRIPT_VERSION, "โหลดสคริปต์ Hunting Together (FREE Edition) สำเร็จ!", 3.5)
