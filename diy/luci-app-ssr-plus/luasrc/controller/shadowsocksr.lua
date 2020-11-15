module("luci.controller.shadowsocksr",package.seeall)
function index()
	if not nixio.fs.access("/etc/config/shadowsocksr") then
		return
	end
	entry({"admin","services","shadowsocksr"},alias("admin","services","shadowsocksr","base"),_("ShadowSocksR Plus+"),10).dependent=true
	entry({"admin","services","shadowsocksr","base"},cbi("shadowsocksr/base"),_("Base Setting"),1).leaf=true
	entry({"admin","services","shadowsocksr","servers"},arcombine(cbi("shadowsocksr/servers",{autoapply=true}),cbi("shadowsocksr/client-config")),_("Severs Nodes"),2).leaf=true
	entry({"admin","services","shadowsocksr","control"},cbi("shadowsocksr/control"),_("Access Control"),3).leaf=true
	entry({"admin","services","shadowsocksr","domain"},form("shadowsocksr/domain"),_("Domain List"),4).leaf=true
	entry({"admin","services","shadowsocksr","advanced"},cbi("shadowsocksr/advanced"),_("Advanced Settings"),5).leaf=true
	if nixio.fs.access("/usr/bin/ssr-server") then
	      entry({"admin","services","shadowsocksr","server"},arcombine(cbi("shadowsocksr/server"),cbi("shadowsocksr/server-config")),_("SSR Server"),6).leaf=true
	end
	entry({"admin","services","shadowsocksr","status"},form("shadowsocksr/status"),_("Status"),7).leaf=true
	entry({"admin","services","shadowsocksr","log"},form("shadowsocksr/log"),_("Log"),8).leaf=true
	entry({"admin","services","shadowsocksr","check"},call("check_status"))
	entry({"admin","services","shadowsocksr","refresh"},call("refresh_data"))
	entry({"admin","services","shadowsocksr","subscribe"},call("subscribe"))
	entry({"admin","services","shadowsocksr","checkport"},call("check_port"))
	entry({"admin","services","shadowsocksr","run"},call("act_status"))
	entry({"admin","services","shadowsocksr","ping"},call("act_ping"))
end

function subscribe()
	luci.sys.call("/usr/share/ssrplus/subscribe >> /tmp/ssrplus.log 2>&1")
	luci.http.prepare_content("application/json")
	luci.http.write_json({ret=1})
end

function act_status()
	local e={}
	e.running=luci.sys.call("ps -w | grep ssr-retcp | grep -v grep >/dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function act_ping()
	local e={}
	local domain=luci.http.formvalue("domain")
	local port=luci.http.formvalue("port")
	e.index=luci.http.formvalue("index")
	local iret=luci.sys.call("ipset add ss_spec_wan_ac "..domain.." 2>/dev/null")
	local socket=nixio.socket("inet","stream")
	socket:setopt("socket","rcvtimeo",3)
	socket:setopt("socket","sndtimeo",3)
	e.socket=socket:connect(domain,port)
	socket:close()
	e.ping=luci.sys.exec(string.format("tcping -q -c 1 -i 1 -t 2 -p %s %s 2>&1 | grep -o 'time=[0-9]*' | awk -F '=' '{print $2}'",port,domain))
	if (iret==0) then
		luci.sys.call("ipset del ss_spec_wan_ac "..domain)
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function check_status()
	sret=luci.sys.call("curl -so /dev/null -m 3 www."..luci.http.formvalue("set")..".com")
	if sret==0 then
		retstring="0"
	else
		retstring="1"
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json({ret=retstring})
end

function refresh_data()
	local set=luci.http.formvalue("set")
	local icount=0
	if set=="gfw_data" then
		sret=luci.sys.call("curl -Lfso /tmp/gfw.b64 https://cdn.jsdelivr.net/gh/gfwlist/gfwlist/gfwlist.txt")
		if sret==0 then
			luci.sys.call("/usr/share/ssrplus/ssr-gfw")
			icount=luci.sys.exec("cat /tmp/gfwnew.txt | wc -l")
			if tonumber(icount)>1000 then
				oldcount=luci.sys.exec("cat /tmp/ssrplus/gfw.list | wc -l")
				if tonumber(icount)~=tonumber(oldcount) then
					luci.sys.exec("cp -f /tmp/gfwnew.txt /tmp/ssrplus/gfw.list && /etc/init.d/shadowsocksr restart >/dev/null 2>&1")
					retstring=tostring(tonumber(icount))
				else
					retstring="0"
				end
			else
				retstring="-1"
			end
			luci.sys.exec("rm -f /tmp/gfwnew.txt ")
		else
			retstring="-1"
		end
	elseif set=="ip_data" then
		refresh_cmd="A=`curl -Lfs https://small_5.coding.net/p/adbyby/d/adbyby/git/raw/master/delegated-apnic-latest` && echo \"$A\" | awk -F\\| '/CN\\|ipv4/{printf\"%s/%d\\n\",$4,32-log($5)/log(2)}' > /tmp/china.txt"
		sret=luci.sys.call(refresh_cmd)
		icount=luci.sys.exec("cat /tmp/china.txt | wc -l")
		if sret==0 and tonumber(icount)>1000 then
			oldcount=luci.sys.exec("cat /tmp/ssrplus/china.txt | wc -l")
			if tonumber(icount)~=tonumber(oldcount) then
				luci.sys.exec("cp -f /tmp/china.txt /tmp/ssrplus/china.txt && ipset list china_v4 >/dev/null 2>&1 && /usr/share/ssrplus/chinaipset")
				retstring=tostring(tonumber(icount))
			else
				retstring="0"
			end
		else
			retstring="-1"
		end
		luci.sys.exec("rm -f /tmp/china.txt ")
	elseif set=="ip6_data" then
		refresh_cmd="A=`curl -Lfs https://small_5.coding.net/p/adbyby/d/adbyby/git/raw/master/delegated-apnic-latest` && echo \"$A\" | awk -F\\| '/CN\\|ipv6/{printf\"%s/%d\\n\",$4,$5}' > /tmp/china_v6.txt"
		sret=luci.sys.call(refresh_cmd)
		icount=luci.sys.exec("cat /tmp/china_v6.txt | wc -l")
		if sret==0 and tonumber(icount)>1000 then
			oldcount=luci.sys.exec("cat /tmp/ssrplus/china_v6.txt | wc -l")
			if tonumber(icount)~=tonumber(oldcount) then
				luci.sys.exec("cp -f /tmp/china_v6.txt /tmp/ssrplus/china_v6.txt && ipset list china_v6 >/dev/null 2>&1 && /usr/share/ssrplus/chinaipset v6")
				retstring=tostring(tonumber(icount))
			else
				retstring="0"
			end
		else
			retstring="-1"
		end
		luci.sys.exec("rm -f /tmp/china_v6.txt ")
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json({ret=retstring,retcount=icount})
end

function check_port()
	local set=""
	local retstring="<br/><br/>"
	local s
	local server_name=""
	local iret=1
	luci.model.uci.cursor():foreach("shadowsocksr","servers",function(s)
		if s.alias then
			server_name=s.alias
		elseif s.server and s.server_port then
			server_name="%s:%s"%{s.server,s.server_port}
		end
		iret=luci.sys.call("ipset add ss_spec_wan_ac "..s.server.." 2>/dev/null")
		socket=nixio.socket("inet","stream")
		socket:setopt("socket","rcvtimeo",3)
		socket:setopt("socket","sndtimeo",3)
		ret=socket:connect(s.server,s.server_port)
		socket:close()
		if tostring(ret)=="true" then
			retstring=retstring.."<font color='green'>["..server_name.."] OK.</font><br/>"
		else
			retstring=retstring.."<font color='red'>["..server_name.."] Error.</font><br/>"
		end
		if  iret==0 then
			luci.sys.call("ipset del ss_spec_wan_ac "..s.server)
		end
	end)
	luci.http.prepare_content("application/json")
	luci.http.write_json({ret=retstring})
end