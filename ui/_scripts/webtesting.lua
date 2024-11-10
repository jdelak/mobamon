
--serverAddress = '192.168.1.240'
--serverAddress = '127.0.0.1'
local serverAddress = '205.204.53.150:8080'
--serverAddress = '205.204.53.150:1337'
-- USE port 1337 FOR THE ON-BOX DEV ENVIRONMENT
--serverAddress = '192.168.1.102'

--disableDebugOutput = false;

local testClient = testClient or {}
local testGameServer = testGameServer or {}
local testChatServer = testChatServer or {}

function gameServerLogin(serverid, password, slave)

	slave = slave or 1
	
	testGameServer = {}
	testGameServer.serverid = serverid

	local srp = SRPClient.Create()
	local success
	
	local A
	success, A = srp:Begin(serverid, password)
	if not success then return end
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('s')
	request1:SetRequestMethod('POST')
	request1:SetResource('/gameServerSession/serverid/' .. URLEncode(serverid))
	request1:AddVariable('A', A)
	request1:AddVariable('slave', slave)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return end
	
	local response1SRP = response1Body.srp
	if response1SRP == nil then return end
	
	local M
	success, M = srp:Middle(response1SRP.salt, response1SRP.B, response1SRP.salt2)
	if not success then return end
	
	local request2 = Master.SpawnRequest()
	
	request2:SetServerAddress(serverAddress)
	request2:SetRequestService('strife')
	request2:SetRequestClientType('s')
	request2:SetRequestMethod('POST')
	request2:SetResource('/gameServerSession/serverid/' .. URLEncode(serverid))
	request2:AddVariable('proof', M)
	request2:AddVariable('slave', slave)
	request2:SendRequest(true)
	request2:Wait()
	
	local response2Body = request2:GetBody()
	if response2Body == nil then return end
	
	local response2SRP = response2Body.srp
	if response2SRP == nil then return end
	
	success = srp:Finish(response2SRP.serverProof)
	if not success then return end
	
	testGameServer.sessionKey = srp:GetSessionKey()
	testGameServer.server_id = response2Body.server_id
	testGameServer.shard = response2Body.shard
	
	return srp:GetSessionKey()
end

function chatServerAuthClient(chatserverid, account_id)
	
	local challenge = CryptRandHex(64)
	local hash = HMAC('sha256', challenge, testClient.sessionKey)
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetAuthService('igames')
	request1:SetAuthClientType('cs')
	request1:SetAuthID(chatserverid)
	request1:SetAuthSessionKey(testChatServer.sessionKey)
	request1:SetRequestService('igames')
	request1:SetRequestClientType('cs')
	request1:SetRequestMethod('GET')
	request1:SetResource('/session/accountid/' .. URLEncode(account_id))
	request1:AddVariable('hash', hash)
	request1:AddVariable('challenge', challenge)
	request1:AddVariable('friends','1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')
	
	if response1Body == nil then return 'it did not work' end
	
	return true
end

function testGameServerAuthClient(username, password, gameserverid, gameserverpassword, slot, account_id, identid)
	flushMemcached()
	iGamesLogin(username, password)
	gameServerLogin(gameserverid, gameserverpassword, slot)
	gameServerAuthClient(gameserverid, slot, account_id, identid)
end

function strifeChatServerAuthClient(chatserverid, slot, identid)
	local challenge = CryptRandHex(64)
	local hash = HMAC('sha256', challenge, testClient.sessionKey)
	local request1 = Master.SpawnRequest()
	printd(testClient.sessionKey)
	request1:SetServerAddress(serverAddress)
	request1:SetAuthService('strife')
	request1:SetAuthClientType('cs')
	request1:SetAuthID(chatserverid .. ':' .. slot)
	request1:SetAuthSessionKey(testChatServer.sessionKey)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('cs')
	request1:SetRequestMethod('GET')
	request1:SetResource('/verify/identid/' .. URLEncode(identid))
	request1:AddVariable('hash', hash)
	request1:AddVariable('challenge', challenge)
	request1:AddVariable('friends','1')
	request1:AddVariable('commodities','1')
	request1:AddVariable('identities', '1')
	request1:SendRequest(true)
	request1:Wait()
	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')
	if response1Body == nil then return 'it did not work' end
	return true
end

function gameServerAuthClient(gameserverid, slot, identid)
	local challenge = CryptRandHex(64)
	local hash = HMAC('sha256', challenge, testClient.sessionKey)
	local request1 = Master.SpawnRequest()

	request1:SetServerAddress(serverAddress)
	request1:SetAuthService('strife')
	request1:SetAuthClientType('s')
	request1:SetAuthID(gameserverid .. ':' .. slot)
	request1:SetAuthSessionKey(testGameServer.sessionKey)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('s')
	request1:SetRequestMethod('GET')
	request1:SetResource('/verify/identid/' .. URLEncode(identid))
	request1:AddVariable('hash', hash)
	request1:AddVariable('challenge', challenge)
	request1:AddVariable('friends','1')
	request1:AddVariable('commodities','1')
	request1:AddVariable('identities', '1')
	request1:SendRequest(true)
	request1:Wait()
	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')
	if response1Body == nil then return 'it did not work' end
	return true
end
function gameServerAuthClient2(gameserverid, slot, account_id)
	local challenge = CryptRandHex(64)
	local hash = HMAC('sha256', challenge, testClient.sessionKey)
	local request1 = Master.SpawnRequest()
	request1:SetServerAddress(serverAddress)
	request1:SetAuthService('strife')
	request1:SetAuthClientType('s')
	request1:SetAuthID(gameserverid .. ':' .. slot)
	request1:SetAuthSessionKey(testGameServer.sessionKey)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('s')
	request1:SetRequestMethod('GET')
	request1:SetResource('/verify/accountid/' .. URLEncode(account_id))
	request1:AddVariable('identities', 'strife')
	request1:AddVariable('hash', hash)
	request1:AddVariable('challenge', challenge)
	request1:AddVariable('friends','1')
	request1:SendRequest(true)
	request1:Wait()
	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')
	if response1Body == nil then return 'it did not work' end
	return true
end
function gameServerAuthClient3(gameserverid, slot, account_id)
	local challenge = CryptRandHex(64)
	local hash = HMAC('sha256', challenge, testClient.sessionKey)
	local request1 = Master.SpawnRequest()
	request1:SetServerAddress(serverAddress)
	request1:SetAuthService('strife')
	request1:SetAuthClientType('s')
	request1:SetAuthID(gameserverid .. ':' .. slot)
	request1:SetAuthSessionKey(testGameServer.sessionKey)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('s')
	request1:SetRequestMethod('GET')
	request1:SetResource('/verify/accountid/' .. URLEncode(account_id))
	request1:AddVariable('identities', '1')
	request1:AddVariable('hash', hash)
	request1:AddVariable('challenge', challenge)
	request1:AddVariable('friends','1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')

	if response1Body == nil then return 'it did not work' end
	
	return true
end

function chatServerAuthGameServer(chatserverid, gameserverid)
	
	local challenge = CryptRandHex(64)
	local hash = HMAC('sha256', challenge, testGameServer.sessionKey)
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetAuthService('igames')
	request1:SetAuthClientType('cs')
	request1:SetAuthID(chatserverid)
	request1:SetAuthSessionKey(testChatServer.sessionKey)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('cs')
	request1:SetRequestMethod('GET')
	request1:SetResource('/gameServerSession/serverid/' .. URLEncode(gameserverid))
	request1:AddVariable('hash', hash)
	request1:AddVariable('challenge', challenge)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')
	
	if response1Body == nil then return 'it did not work' end
	
	return true
end

function createMatch(serverid, slave, map, mapVersion, version)
	
	map = map or '1'
	mapVersion = mapVersion or '1.0.0.0'
	version = version or '1.0.0.0'
	
	local challenge = CryptRandHex(64)
	local hash = SHA256(challenge .. testGameServer.sessionKey)
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetAuthService('strife')
	request1:SetAuthClientType('s')
	request1:SetAuthID(serverid .. ':' .. slave)
	request1:SetAuthSessionKey(testGameServer.sessionKey)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('s')
	request1:SetRequestMethod('POST')
	request1:SetResource('/match')
	request1:AddVariable('serverid', serverid)
	request1:AddVariable('slave', slave)
	request1:AddVariable('map', map)
	request1:AddVariable('mapVersion', mapVersion)
	request1:AddVariable('version', version)
	request1:AddVariable('challenge', challenge)
	request1:AddVariable('hash', hash)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	testGameServer.matchIdentity = {}
	testGameServer.matchIdentity = response1Body
	testGameServer.matchIdentity.serverid = serverid
	testGameServer.matchIdentity.match_id = response1Body.match_id
	printd(TableToMultiLineString(response1Body) .. '\n')
	
	if response1Body == nil then return 'it did not work' end
	
	return true
	
end

function magicWord()
	println([[]])
	println([[_   _ ____ _  _    ___  _ ___  _  _ . ___     ]])
	println([[ \_/  |  | |  |    |  \ | |  \ |\ | '  |      ]])
	println([[  |   |__| |__|    |__/ | |__/ | \|    |      ]])
	println([[                                              ]])
	println([[____ ____ _   _    ___ _  _ ____              ]])
	println([[[__  |__|  \_/      |  |__| |___              ]])
	println([[___] |  |   |       |  |  | |___              ]])
	println([[                                              ]])
	println([[_  _ ____ ____ _ ____    _ _ _ ____ ____ ___  ]])
	println([[|\/| |__| | __ | |       | | | |  | |__/ |  \ ]])
	println([[|  | |  | |__] | |___    |_|_| |__| |  \ |__/ ]])
	println([[                                              ]])
end

function submitTestStats(matchid)
	
	if not testGameServer.sessionKey then return 'Game server session not set' end
	
	local challenge = CryptRandHex(64)
	local hash = SHA256(challenge .. testGameServer.sessionKey)
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('s')
	request1:SetRequestMethod('PUT')
	request1:SetResource('/match/matchid/' .. URLEncode(matchid))
	request1:AddVariable('matchStats[0][match_id]', matchid)
	request1:AddVariable('matchStats[0][ident_id]', '1.008')
	request1:AddVariable('matchStats[0][slot]', '1')
	request1:AddVariable('matchStats[0][winner]', '1')
	request1:AddVariable('matchStats[0][hero]', 'Hero_Accursed')
	request1:AddVariable('matchStats[0][gpm]', '230')
	request1:AddVariable('matchStats[0][kills]', '14')
	request1:AddVariable('matchStats[0][creepKills]', '114')
	request1:AddVariable('matchStats[0][deaths]', '30')
	request1:AddVariable('matchStats[0][item_1]', 'Item_Spellblade')
	request1:AddVariable('matchStats[0][item_2]', 'Item_Kingsmail')
	request1:AddVariable('matchStats[0][item_3]', 'Item_Shieldbreaker')
	request1:AddVariable('matchStats[0][item_4]', 'Item_Momentus')
	request1:AddVariable('matchStats[0][item_5]', 'Item_Malevolence')
	request1:AddVariable('matchStats[0][item_6]', 'Item_MaxManaPower')
	request1:AddVariable('matchStats[1][match_id]', matchid)
	request1:AddVariable('matchStats[1][ident_id]', '2.000')
	request1:AddVariable('matchStats[1][slot]', '2')
	request1:AddVariable('matchStats[1][winner]', '0')
	request1:AddVariable('matchStats[1][hero]', 'Hero_Rook')
	request1:AddVariable('matchStats[1][gpm]', '400')
	request1:AddVariable('matchStats[1][kills]', '30')
	request1:AddVariable('matchStats[1][creepKills]', '230')
	request1:AddVariable('matchStats[1][deaths]', '14')
	request1:AddVariable('matchStats[1][item_1]', 'Item_Malevolence')
	request1:AddVariable('matchStats[1][item_2]', 'Item_Tome_Health')
	request1:AddVariable('matchStats[1][item_3]', 'Rare_Siphoning')
	request1:AddVariable('matchStats[1][item_4]', 'Rare_Vampirism')
	request1:AddVariable('challenge', challenge)
	request1:AddVariable('hash', hash)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')
	
	if response1Body == nil then return 'it did not work' end
	
	return true
	
end

function testPut()

	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('igames')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('PUT')
	request1:SetResource('/account/accountid/1.000')
	request1:AddVariable('matchStats[0][match_id]', '1.009')
	request1:AddVariable('matchStats[0][ident_id]', '1.000')
	request1:AddVariable('matchStats[0][stat1]', '512')
	request1:AddVariable('matchStats[1][match_id]', '1.009')
	request1:AddVariable('matchStats[1][ident_id]', '2.000')
	request1:AddVariable('matchStats[1][stat1]', '512')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return end
	return true
	
end

function iGamesLogin(username, password)
	testClient = {}
	testClient.username = username

	local srp = SRPClient.Create()
	local success
	
	local A
	success, A = srp:Begin(username, password)
	if not success then return end
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('igames')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('POST')
	request1:SetResource('/session/email/' .. URLEncode(username))
	request1:AddVariable('A', A)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	
	Master.ReleaseRequest(request1)
	
	if response1Body == nil then return end
	
	local response1SRP = response1Body.srp
	if response1SRP == nil then return end
	
	local M
	success, M = srp:Middle(response1SRP.salt, response1SRP.B, response1SRP.salt2)
	if not success then return end
	
	local request2 = Master.SpawnRequest()
	
	request2:SetServerAddress(serverAddress)
	request2:SetRequestService('igames')
	request2:SetRequestClientType('c')
	request2:SetRequestMethod('POST')
	request2:SetResource('/session/email/' .. URLEncode(username))
	request2:AddVariable('proof', M)
	request2:SendRequest(true)
	request2:Wait()
	
	local response2Body = request2:GetBody()
	
	Master.ReleaseRequest(request2)
	
	if response2Body == nil then return end
	
	local response2SRP = response2Body.srp
	if response2SRP == nil then return end
	
	success = srp:Finish(response2SRP.serverProof)
	if not success then return end
	
	testClient.sessionKey = srp:GetSessionKey()
	testClient.account_id = response2Body.account_id
	
	return true
end

function strifeChatServerLogin(serverid, password, slave)

	slave = slave or 1
	testChatServer = {}
	testChatServer.serverid = serverid
	
	local srp = SRPClient.Create()
	local success
	
	local A
	success, A = srp:Begin(serverid, password)
	if not success then return end
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('cs')
	request1:SetRequestMethod('POST')
	request1:SetResource('/chatServerSession/serverid/' .. URLEncode(serverid))
	request1:AddVariable('A', A)
	request1:AddVariable('slave', slave)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return end
	
	local response1SRP = response1Body.srp
	if response1SRP == nil then return end
	
	local M
	success, M = srp:Middle(response1SRP.salt, response1SRP.B, response1SRP.salt2)
	if not success then return end
	
	local request2 = Master.SpawnRequest()
	
	request2:SetServerAddress(serverAddress)
	request2:SetRequestService('strife')
	request2:SetRequestClientType('cs')
	request2:SetRequestMethod('POST')
	request2:SetResource('/chatServerSession/serverid/' .. URLEncode(serverid))
	request2:AddVariable('proof', M)
	request2:AddVariable('slave', slave)
	request2:SendRequest(true)
	request2:Wait()
	
	local response2Body = request2:GetBody()
	if response2Body == nil then return end
	
	local response2SRP = response2Body.srp
	if response2SRP == nil then return end
	
	success = srp:Finish(response2SRP.serverProof)
	if not success then return end
	
	testChatServer.sessionKey = srp:GetSessionKey()
	testChatServer.server_id = response2Body.server_id
	testChatServer.shard = response2Body.shard
	
	return srp:GetSessionKey()
end

function igamesChatServerLogin(serverid, password, slave)

	slave = slave or 1
	testChatServer = {}
	testChatServer.serverid = serverid
	
	local srp = SRPClient.Create()
	local success
	
	local A
	success, A = srp:Begin(serverid, password)
	if not success then return end
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('igames')
	request1:SetRequestClientType('cs')
	request1:SetRequestMethod('POST')
	request1:SetResource('/chatServerSession/serverid/' .. URLEncode(serverid))
	request1:AddVariable('A', A)
	request1:AddVariable('slave', slave)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return end
	
	local response1SRP = response1Body.srp
	if response1SRP == nil then return end
	
	local M
	success, M = srp:Middle(response1SRP.salt, response1SRP.B, response1SRP.salt2)
	if not success then return end
	
	local request2 = Master.SpawnRequest()
	
	request2:SetServerAddress(serverAddress)
	request2:SetRequestService('igames')
	request2:SetRequestClientType('cs')
	request2:SetRequestMethod('POST')
	request2:SetResource('/chatServerSession/serverid/' .. URLEncode(serverid))
	request2:AddVariable('proof', M)
	request2:AddVariable('slave', slave)
	request2:SendRequest(true)
	request2:Wait()
	
	local response2Body = request2:GetBody()
	if response2Body == nil then return end
	
	local response2SRP = response2Body.srp
	if response2SRP == nil then return end
	
	success = srp:Finish(response2SRP.serverProof)
	if not success then return end
	
	testChatServer.sessionKey = srp:GetSessionKey()
	testChatServer.server_id = response2Body.server_id
	testChatServer.shard = response2Body.shard
	
	return srp:GetSessionKey()
end

function CreateAccount(email, password, display, firstName, lastName)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('igames')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('POST')
	request1:SetResource('/account')
	request1:AddVariable('email', email)
	request1:AddVariable('password', password)
	request1:AddVariable('display', display)
	request1:AddVariable('firstName', firstName)
	request1:AddVariable('lastName', lastName)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function AddFriend(account_id, friend_account_id, list)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('igames')
	request1:SetRequestClientType('cs')
	request1:SetRequestMethod('POST')
	request1:SetResource('/friend/accountid/' .. URLEncode(account_id))
	request1:AddVariable('account_id', friend_account_id)
	request1:AddVariable('list', list)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function AddFriendStrife(ident_id, friend_ident_id, list)
	
	println('^yAddFriendStrife')
	println('ident_id ' .. tostring(ident_id) )
	println('friend_ident_id ' .. tostring(friend_ident_id) )
	println('list ' .. tostring(list) )
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('cs')
	request1:SetRequestMethod('POST')
	request1:SetResource('/friend/identid/' .. URLEncode(ident_id))
	request1:AddVariable('ident_id', friend_ident_id)
	request1:AddVariable('list', list)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function GetFriends(account_id)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('igames')
	request1:SetRequestClientType('cs')
	request1:SetRequestMethod('GET')
	request1:SetResource('/friend/accountid/' .. URLEncode(account_id))
	request1:AddVariable('friends', '1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function RemoveFriend(account_id, friend_account_id)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('igames')
	request1:SetRequestClientType('cs')
	request1:SetRequestMethod('DELETE')
	request1:SetResource('/friend/accountid/' .. URLEncode(account_id))
	request1:AddVariable('account_id', friend_account_id)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function SetFriendsList(account_id, friend_account_id, list)

	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('igames')
	request1:SetRequestClientType('cs')
	request1:SetRequestMethod('PUT')
	request1:SetResource('/friend/accountid/' .. URLEncode(account_id))
	request1:AddVariable('account_id', friend_account_id)
	request1:AddVariable('list', list)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	

end

function getIdentStats(identid)

	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('GET')
	request1:SetResource('/ident/identid/' .. URLEncode(identid))
	request1:AddVariable('identStats', '1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function getMatchStats(matchid)

	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('GET')
	request1:SetResource('/match/matchid/' .. URLEncode(matchid))
	request1:AddVariable('matchStats', '1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function CreateStrifeChatServer(password, ip, slaves, region)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('cs')
	request1:SetRequestMethod('POST')
	request1:SetResource('/chatServer')
	request1:AddVariable('password', password)
	request1:AddVariable('ip', ip)
	request1:AddVariable('slaves', slaves)
	request1:AddVariable('region', region)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	
	testGameServer.ipLong = response1Body.chatServerIdentity.ipLong
	testGameServer.slaves = slaves
	testGameServer.region = region
	testGameServer.chatServerIncrement = response1Body.chatServerIdentity.chatServerIncrement
	testGameServer.shard = response1Body.chatServerIdentity.shard
	testGameServer.chatServerId = response1Body.chatServerIdentity.chatServerIncrement .. '.' .. response1Body.chatServerIdentity.shard
	
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function CreateIgamesChatServer(password, ip, slaves, region)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('igames')
	request1:SetRequestClientType('cs')
	request1:SetRequestMethod('POST')
	request1:SetResource('/chatServer')
	request1:AddVariable('password', password)
	request1:AddVariable('ip', ip)
	request1:AddVariable('slaves', slaves)
	request1:AddVariable('region', region)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	
	testGameServer.ipLong = response1Body.chatServerIdentity.ipLong
	testGameServer.slaves = slaves
	testGameServer.region = region
	testGameServer.chatServerIncrement = response1Body.chatServerIdentity.chatServerIncrement
	testGameServer.shard = response1Body.chatServerIdentity.shard
	testGameServer.chatServerId = response1Body.chatServerIdentity.chatServerIncrement .. '.' .. response1Body.chatServerIdentity.shard
	
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function CreateGameServer(password, ip, slaves, region)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('s')
	request1:SetRequestMethod('POST')
	request1:SetResource('/gameServer')
	request1:AddVariable('password', password)
	request1:AddVariable('ip', ip)
	request1:AddVariable('slaves', slaves)
	request1:AddVariable('region', region)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	
	testGameServer.ipLong = response1Body.ipLong
	testGameServer.slaves = slaves
	testGameServer.region = region
	testGameServer.gameServerIncrement = response1Body.gameServerIncrement
	testGameServer.shard = response1Body.shard
	testGameServer.gameServerId = response1Body.gameServer_id
	
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function CreatePet(identid, petType, slot)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('POST')
	request1:SetResource('/pet/identid/' .. URLEncode(identid))
	request1:AddVariable('petType', petType)
	request1:AddVariable('slot', slot)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function FeedPet(identid, petIncrement, amount)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('PUT')
	request1:SetResource('/pet/identid/' .. URLEncode(identid) .. '/petIncrement/' .. URLEncode(petIncrement))
	request1:AddVariable('feed', amount)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function NamePet(identid, petIncrement, name)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('PUT')
	request1:SetResource('/pet/identid/' .. URLEncode(identid) .. '/petIncrement/' .. URLEncode(petIncrement))
	request1:AddVariable('name', name)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function GetPet(identid, petIncrement)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('GET')
	request1:SetResource('/pet/identid/' .. URLEncode(identid) .. '/petIncrement/' .. URLEncode(petIncrement))
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function GetPets(identid)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('GET')
	request1:SetResource('/pet/identid/' .. URLEncode(identid))
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function getRewards(identid)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('GET')
	request1:SetResource('/reward/identid/' .. URLEncode(identid))
	request1:AddVariable('rewards', '1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function claimReward(identid, matchid)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('PUT')
	request1:SetResource('/reward/identid/' .. URLEncode(identid) .. '/matchid/' .. URLEncode(matchid))
	request1:AddVariable('claim', '1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function getReward(identid, matchid)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('GET')
	request1:SetResource('/reward/identid/' .. URLEncode(identid) .. '/matchid/' .. URLEncode(matchid))
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function getIdentCommodities(identid)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('GET')
	request1:SetResource('/ident/identid/' .. URLEncode(identid))
	request1:AddVariable('commodities', '1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function getIdent(identid)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('GET')
	request1:SetResource('/ident/identid/' .. URLEncode(identid))
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function getIdentByName(nickname)

	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('GET')
	request1:SetResource('/ident/nickname/' .. URLEncode(nickname))
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function getIdentitiesByAccount(accountid)

	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('igames')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('GET')
	request1:SetResource('/account/accountid/' .. URLEncode(accountid))
	request1:AddVariable('identities','strife')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	if response1Body == nil then return false end
	printd(TableToMultiLineString(response1Body) .. '\n')
	return true
	
end

function CreateIdent(accountid, nickname, uniqid)
	
	if not uniqid
	then
		math.randomseed(tonumber(CryptRandHex(8),16))
		uniqid = math.random(0, 9999)
	end
	
	local challenge = CryptRandHex(64)
	local hash = HMAC('sha256', challenge, testClient.sessionKey)
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('POST')
	request1:SetResource('/ident/accountid/' .. URLEncode(accountid))
	request1:AddVariable('nickname', nickname)
	request1:AddVariable('uniqid', uniqid)
	request1:AddVariable('challenge', challenge)
	request1:AddVariable('hash', hash)
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	testClient.clientIdentity = {}
	testClient.clientIdentity.nickname = nickname
	testClient.clientIdentity.shard = response1Body.clientIdentity.shard
	testClient.clientIdentity.identIncrement = response1Body.clientIdentity.identIncrement
	testClient.clientIdentity.ident_id = response1Body.clientIdentity.identIncrement .. '.' .. response1Body.clientIdentity.shard
	testClient.clientIdentity.uniqid = response1Body.clientIdentity.uniqid
	testClient.clientIdentity.game = response1Body.clientIdentity.game
	
	printd(TableToMultiLineString(response1Body) .. '\n')
	
	if response1Body == nil then return 'it did not work' end
	
	return true
	
end

function flushMemcached()
	local request = HTTP.SpawnRequest()
	request:SetTargetURL(serverAddress .. '/flushMemcached.php')
	request:SendRequest('GET')
	request:Wait()
	local response = request:GetResponse()
	if response == nil then return 'it did not work' end
	return 'Success!'
	
end

function getSettings(settings, environment)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService(environment)
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('GET')
	request1:SetResource('/settings')
	request1:AddVariable(settings, '1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')
	
end

function getRewardSettings()
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('GET')
	request1:SetResource('/settings')
	request1:AddVariable('reward', '1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')
	
end

function createCraftedItem(identid)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('POST')
	request1:SetResource('/craft/identid/' .. URLEncode(identid))
	request1:AddVariable('entityName', 'Item_FellBlade')
	request1:AddVariable('component1', 'Item_Blade')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')
	
end

function enchantCraft(identid, craftid)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('PUT')
	request1:SetResource('/craft/identid/' .. URLEncode(identid) .. '/craftid/' .. URLEncode(craftid))
	request1:AddVariable('use', 'essence')
	request1:AddVariable('enchant', '1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')
	
end

function temperCraft(identid, craftid)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('PUT')
	request1:SetResource('/craft/identid/' .. URLEncode(identid) .. '/craftid/' .. URLEncode(craftid))
	request1:AddVariable('use', 'gems')
	request1:AddVariable('temper', '1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')
	
end

function getCrafts(identid)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('GET')
	request1:SetResource('/craft/identid/' .. URLEncode(identid))
	request1:AddVariable('crafts', '1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')
	
end

function getCraft(identid, craftid)
	
	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('GET')
	request1:SetResource('/craft/identid/' .. URLEncode(identid) .. '/craftid/' .. URLEncode(craftid))
	request1:AddVariable('craft', '1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')
	
end

function salvageCraft(identid, craftid)

	local request1 = Master.SpawnRequest()
	
	request1:SetServerAddress(serverAddress)
	request1:SetRequestService('strife')
	request1:SetRequestClientType('c')
	request1:SetRequestMethod('PUT')
	request1:SetResource('/craft/identid/' .. URLEncode(identid) .. '/craftid/' .. URLEncode(craftid))
	request1:AddVariable('salvage', '1')
	request1:SendRequest(true)
	request1:Wait()

	local response1Body = request1:GetBody()
	printd(TableToMultiLineString(response1Body) .. '\n')
	
end

function DumpTestClient()
	printd(TableToMultiLineString(testClient) .. '\n')
end

