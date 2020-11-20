module("luci.controller.adblock-plus",package.seeall)
function index()
	if not nixio.fs.access("/etc/config/adblock-plus") then
		return
	end
	entry({"admin","services","adblock-plus"},alias("admin","services","adblock-plus","base"),_("Adblock Plus+"),9).dependent=true
	entry({"admin","services","adblock-plus","base"},cbi("adblock-plus/base"),_("Base Setting"),1).leaf=true
	entry({"admin","services","adblock-plus","white"},form("adblock-plus/white"),_("White Domain List"),2).leaf=true
	entry({"admin","services","adblock-plus","black"},form("adblock-plus/black"),_("Block Domain List"),3).leaf=true
	entry({"admin","services","adblock-plus","ip"},form("adblock-plus/ip"),_("Block IP List"),4).leaf=true
	entry({"admin","services","adblock-plus","log"},form("adblock-plus/log"),_("Update Log"),5).leaf=true
	entry({"admin","services","adblock-plus","run"},call("act_status"))
	entry({"admin","services","adblock-plus","refresh"},call("refresh_data"))
end

function act_status()
	local e={}
	e.running=luci.sys.call("[ -s /tmp/dnsmasq.adblock-plus/3rd.conf ]")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function refresh_data()
local set=luci.http.formvalue("set")
local icount=0

	luci.sys.exec("/usr/share/adblock-plus/adblock-plus down")
	icount=luci.sys.exec("find /tmp/ad_tmp/3rd -name 3* -exec cat {} \\; 2>/dev/null | wc -l")
	if tonumber(icount)>0 then
		oldcount=luci.sys.exec("find /tmp/adblock-plus/3rd -name 3* -exec cat {} \\; 2>/dev/null | wc -l")
		if tonumber(icount) ~= tonumber(oldcount) then
			luci.sys.exec("[ -h /tmp/adblock-plus/3rd/url ] && (rm -f /etc/adblock-plus/3rd/*;cp -a /tmp/ad_tmp/3rd /etc/adblock-plus) || (rm -f /tmp/adblock-plus/3rd/*;cp -a /tmp/ad_tmp/3rd /tmp/adblock-plus)")
			luci.sys.exec("/etc/init.d/adblock-plus restart &")
			retstring=tostring(math.ceil(tonumber(icount)))
		else
			retstring=0
		end
		luci.sys.call("echo `date +'%Y-%m-%d %H:%M:%S'` > /tmp/adblock-plus/adblock-plus.updated")
	else
		retstring="-1"
	end
	luci.sys.exec("rm -rf /tmp/ad_tmp")

	luci.http.prepare_content("application/json")
	luci.http.write_json({ret=retstring,retcount=icount})
end
