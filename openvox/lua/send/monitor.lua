require'package_path'
local socket = require'socket'

function sleep_linux(n)
	socket.select(nil,nil,n)
end
local i = 0
local kill_cmd = "kill -9 `ps -ef | grep insert_port_redis.lua | grep -v grep | awk '{print $1}'`"
while true do
	i = i + 1
	local j = i % 5
	os.execute("cd /my_tools/lua/send && lua monitor_send.lua &")
	if j == 1 then
		os.execute(kill_cmd)
		os.execute("cd /my_tools/lua/my_lua_tools && lua insert_port_redis.lua &")
		if i >= 30 then
			i = 0
		end
	end
	sleep_linux(5)
end

