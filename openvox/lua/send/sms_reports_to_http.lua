require'package_path'
require'get_redis_client'
require'get_port_status'
require'get_redisip'
require'common_tools'
require'logging.file'
local logger = logging.file("/data/record_sms_report_url.txt")
local redis = require'redis'
local cjson = require'cjson'
local smsreportstohttp_list = "app.sms.reportstohttp.list"

local client = get_redis_client("127.0.0.1","6379")
--local wget_cmd = "wget \"http://172.16.6.23:80/receivesms.php?phonenumber=10086&port=3&message=Just20%Do%20IT&time=2017/08/22%2016:23:26&\""
--os.execute(wget_cmd)

function get_smsreports_url_info(sms_conf)
	local readfile = io.open(sms_conf, "r")
	assert(readfile)
	local url_smsreports_t = {}
	for str in readfile:lines() do
		if string.find(str, "smsreports_to_http_enable=") then
			local value = string.gsub(str, "smsreports_to_http_enable=", "")
			--table.insert(url_smsreports_t["smsreports_to_http_enable"], value)
			url_smsreports_t["smsreports_to_http_enable"] = value
		elseif string.find(str, "url_http=") then
			local value = string.gsub(str, "url_http=", "")
			--table.insert(url_smsreports_t["smsreports_url_http"], value)
			url_smsreports_t["smsreports_url_http"] = value
		elseif string.find(str, "url_host=") then
			local value = string.gsub(str, "url_host=", "")
			--table.insert(url_smsreports_t["smsreports_url_host"], value)
			url_smsreports_t["smsreports_url_host"] = value
		elseif string.find(str, "url_port=") then
			local value = string.gsub(str, "url_port=", "")
			--table.insert(url_smsreports_t[smsreports_url_port], value)
			url_smsreports_t["smsreports_url_port"] = value
		elseif string.find(str, "url_path=") then
			local value = string.gsub(str, "url_path=", "")
			--table.insert(url_smsreports_t["smsreports_url_service"], value)
			url_smsreports_t["smsreports_url_service"] = value
		elseif string.find(str, "url_from_num=") then
			local value = string.gsub(str, "url_from_num=", "")
			url_smsreports_t["smsreports_url_from_num"] = value
		elseif string.find(str, "url_to_num=") then
			local value = string.gsub(str, "url_to_num=", "")
			url_smsreports_t["smsreports_url_to_num"] = value
		elseif string.find(str, "url_message=") then
			local value = string.gsub(str, "url_message=", "")
			url_smsreports_t["smsreports_url_message"] = value
		elseif string.find(str, "url_time=") then
			local value = string.gsub(str, "url_time=", "")
			url_smsreports_t["smsreports_url_time"] = value
		elseif string.find(str, "url_status=") then
			local value = string.gsub(str, "url_status=", "")
			url_smsreports_t["smsreports_url_status"] = value
		elseif string.find(str, "url_user_defined=") then
			local value = string.gsub(str, "url_user_defined=", "")
			url_smsreports_t["smsreports_url_user_defined"] = value
		end
	end
	readfile:close()
	return url_smsreports_t
end

local url_info = get_smsreports_url_info("/etc/asterisk/gw/sms.conf")
local smsreports_sw = url_info.smsreports_to_http_enable
local url_head = url_info.smsreports_url_http
local server_host = url_info.smsreports_url_host
local server_port = url_info.smsreports_url_port
local service_file =  url_info.smsreports_url_service
local var_phonenumber = url_info.smsreports_url_from_num
local var_port = url_info.smsreports_url_to_num
local var_message = url_info.smsreports_url_message
local var_time = url_info.smsreports_url_time
local var_status = url_info.smsreports_url_status
local var_user_defined = url_info.smsreports_url_user_defined
	--print(var_phonenumber .. "-" .. var_port .. "-" .. var_time .. "-" .. var_status .. "-" .. var_user_defined)
while true do
	smsreports_str = client:blpop(smsreportstohttp_list,0)
	if smsreports_sw == "on" then
		if smsreports_str ~= nil then
			local smsreports_table = cjson.decode(smsreports_str[2])
			local port_name = smsreports_table.port
			url = "\"" .. url_head .. "://" .. server_host .. ":" .. server_port .. service_file .. "?" .. 
			var_phonenumber .. "=" .. smsreports_table.phonenumber .."&" .. 
			var_port .. "=" .. port_name .. "&" .. -- smsreports_table.port
			var_message .. "=" .. smsreports_table.message .. "&" ..
			var_time .. "=" .. smsreports_table.time .."&type=" .. smsreports_table.type .."&" ..
			var_status .. "=" .. smsreports_table.status .. "&\""

			wget_cmd = "/my_tools/op_wget " .. string.gsub(url," ","") .. " -O - > /dev/null 2>&1 &"
			-- print(wget_cmd)
			-- logger:info("url = %s",url)
			-- logger:info("cmd = %s", wget_cmd)
			os.execute(wget_cmd)
		end
		--print(smsreports_table.port .. smsreports_table.phonenumber .. smsreports_table.time)
	end
end
