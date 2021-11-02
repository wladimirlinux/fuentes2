require'package_path'
require'get_redis_client'
require'get_port_status'
require'get_redisip'
require'common_tools'
require'logging.file'
local logger = logging.file("/data/record_ussd_report_url.txt")
local redis = require'redis'
local cjson = require'cjson'
local ussdresultstohttp_list = "app.ussd.resulttohttp.list"

local client = get_redis_client("127.0.0.1","6379")
--local wget_cmd = "wget \"http://172.16.6.23:80/receiveussd.php?phonenumber=10086&port=3&message=Just20%Do%20IT&time=2017/08/22%2016:23:26&\""
--os.execute(wget_cmd)

function get_ussdresults_url_info(ussd_conf)
	local readfile = io.open(ussd_conf, "r")
	assert(readfile)
	local url_ussdresults_t = {}
	for str in readfile:lines() do
		if string.find(str, "ussd_to_http_enable=") then
			local value = string.gsub(str, "ussd_to_http_enable=", "")
			--table.insert(url_ussdresults_t["ussdresults_to_http_enable"], value)
			url_ussdresults_t["ussdresults_to_http_enable"] = value
		elseif string.find(str, "url_http=") then
			local value = string.gsub(str, "url_http=", "")
			--table.insert(url_ussdresults_t["ussdresults_url_http"], value)
			url_ussdresults_t["ussdresults_url_http"] = value
		elseif string.find(str, "url_host=") then
			local value = string.gsub(str, "url_host=", "")
			--table.insert(url_ussdresults_t["ussdresults_url_host"], value)
			url_ussdresults_t["ussdresults_url_host"] = value
		elseif string.find(str, "url_port=") then
			local value = string.gsub(str, "url_port=", "")
			--table.insert(url_ussdresults_t[ussdresults_url_port], value)
			url_ussdresults_t["ussdresults_url_port"] = value
		elseif string.find(str, "url_path=") then
			local value = string.gsub(str, "url_path=", "")
			--table.insert(url_ussdresults_t["ussdresults_url_service"], value)
			url_ussdresults_t["ussdresults_url_service"] = value
		elseif string.find(str, "url_to_num=") then
			local value = string.gsub(str, "url_to_num=", "")
			url_ussdresults_t["ussdresults_url_to_num"] = value
		elseif string.find(str, "url_message=") then
			local value = string.gsub(str, "url_message=", "")
			url_ussdresults_t["ussdresults_url_message"] = value
		elseif string.find(str, "url_time=") then
			local value = string.gsub(str, "url_time=", "")
			url_ussdresults_t["ussdresults_url_time"] = value
		elseif string.find(str, "url_status=") then
			local value = string.gsub(str, "url_status=", "")
			url_ussdresults_t["ussdresults_url_status"] = value
		elseif string.find(str, "url_code") then
			local value = string.gsub(str, "url_code=", "")
			url_ussdresults_t["ussdresults_url_code"] = value
		elseif string.find(str, "url_id") then
			local value = string.gsub(str, "url_id=", "")
			url_ussdresults_t["ussdresults_url_id"] = value
		elseif string.find(str, "url_user_defined=") then
			local value = string.gsub(str, "url_user_defined=", "")
			url_ussdresults_t["ussdresults_url_user_defined"] = value
		end
	end
	readfile:close()
	return url_ussdresults_t
end

local url_info = get_ussdresults_url_info("/etc/asterisk/gw/ussd.conf")
local ussdresults_sw = url_info.ussdresults_to_http_enable
local url_head = url_info.ussdresults_url_http
local server_host = url_info.ussdresults_url_host
local server_port = url_info.ussdresults_url_port
local service_file =  url_info.ussdresults_url_service
local var_phonenumber = url_info.ussdresults_url_from_num
local var_port = url_info.ussdresults_url_to_num
local var_message = url_info.ussdresults_url_message
local var_time = url_info.ussdresults_url_time
local var_status = url_info.ussdresults_url_status
local var_code = url_info.ussdresults_url_code
local var_id = url_info.ussdresults_url_id
local var_user_defined = url_info.ussdresults_url_user_defined
	--print(var_phonenumber .. "-" .. var_port .. "-" .. var_time .. "-" .. var_status .. "-" .. var_user_defined)
while true do
	ussdresults_str = client:blpop(ussdresultstohttp_list,0)
	if ussdresults_sw == "on" then
		if ussdresults_str ~= nil then
			local send_date = os.date("%Y-%m-%d %H:%M:%S")
			local ussdresults_table = cjson.decode(ussdresults_str[2])
			local port_name = ussdresults_table.port
			url = "\"" .. url_head .. "://" .. server_host .. ":" .. server_port .. service_file .. "?" .. 
			var_port .. "=" .. ussdresults_table.port .. "&" .. -- ussdresults_table.port
			var_message .. "=" .. ussdresults_table.content .. "&" ..
			var_time .. "=" .. send_date .. "&" ..
			var_code .. "=" .. ussdresults_table.coding .."&" ..
			var_status .. "=" .. ussdresults_table.status .. "&" ..
			var_id .. "=" .. ussdresults_table.id .. "&\""
			
			wget_cmd = "/my_tools/op_wget " .. string.gsub(url," ","%%20") .. " -O - > /dev/null 2>&1 &"
			--print(wget_cmd)
			-- logger:info("url = %s",url)
			-- logger:info("cmd = %s", wget_cmd)
			os.execute(wget_cmd)
		end
		--print(ussdresults_table.port .. ussdresults_table.phonenumber .. ussdresults_table.time)
	end
end
