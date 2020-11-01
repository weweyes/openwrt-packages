module("luci.controller.adbyby",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/adbyby") then
		return
	end
	entry({"admin","services","adbyby"},alias("admin","services","adbyby","base"),_("ADBYBY Plus +"),9).dependent=true
	entry({"admin","services","adbyby","base"},cbi("adbyby/base"),_("Base Setting"),10).leaf=true
	entry({"admin","services","adbyby","advanced"},cbi("adbyby/advanced"),_("Advance Setting"),20).leaf=true
	entry({"admin","services","adbyby","host"},form("adbyby/host"),_("Plus+ Domain List"),30).leaf=true
	entry({"admin","services","adbyby","esc"},form("adbyby/esc"),_("Bypass Domain List"),40).leaf=true
	entry({"admin","services","adbyby","black"},form("adbyby/black"),_("Block Domain List"),50).leaf=true
	entry({"admin","services","adbyby","block"},form("adbyby/block"),_("Block IP List"),60).leaf=true
	entry({"admin","services","adbyby","user"},form("adbyby/user"),_("User-defined Rule"),70).leaf=true
	entry({"admin","services","adbyby","log"},form("adbyby/log"),_("Update Log"),80).leaf=true
	entry({"admin","services","adbyby","refresh"},call("refresh_data"))
	entry({"admin","services","adbyby","run"},call("act_status")).leaf=true
end

function act_status()
	local e={}
	e.running=luci.sys.call("pgrep /tmp/adbyby/adbyby >/dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function refresh_data()
local set=luci.http.formvalue("set")
local icount=0

if set=="0" then
	sret=luci.sys.call("curl -Lfso /tmp/adnew.conf https://small_5.coding.net/p/adbyby/d/adbyby/git/raw/master/easylistchina%2Beasylist.txt || curl -Lfso /tmp/adnew.conf https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt")
	if sret==0 then
		luci.sys.call("/tmp/adbyby/adblock.sh gen")
		icount=luci.sys.exec("cat /tmp/ad.conf | wc -l")
		if tonumber(icount)>0 then
			oldcount=luci.sys.exec("cat /tmp/adbyby/dnsmasq/dnsmasq.adblock | wc -l")
			if tonumber(icount) ~= tonumber(oldcount) then
				luci.sys.exec("cp -f /tmp/ad.conf /tmp/adbyby/dnsmasq/dnsmasq.adblock")
				luci.sys.exec("/etc/init.d/dnsmasq restart &")
				retstring=tostring(math.ceil(tonumber(icount)))
			else
				retstring=0
			end
		else
			retstring="-1"
		end
		luci.sys.exec("rm -f /tmp/ad.conf")
	else
		retstring="-1"
	end
else
	luci.sys.exec("/tmp/adbyby/adblock.sh down")
	icount=luci.sys.exec("find /tmp/ad_tmp/rules -name 3* -exec cat {} \\; 2>/dev/null | wc -l")
	if tonumber(icount)>0 then
		oldcount=luci.sys.exec("find /tmp/adbyby/rules -name 3* -exec cat {} \\; 2>/dev/null | wc -l")
		if tonumber(icount) ~= tonumber(oldcount) then
			luci.sys.exec("[ -h /tmp/adbyby/rules/url ] && (rm -f /etc/adbyby_conf/rules/*;cp -a /tmp/ad_tmp/rules /etc/adbyby_conf) || (rm -f /tmp/adbyby/rules/*;cp -a /tmp/ad_tmp/rules /tmp/adbyby)")
			luci.sys.exec("/etc/init.d/adbyby restart &")
			retstring=tostring(math.ceil(tonumber(icount)))
		else
			retstring=0
		end
	else
		retstring="-1"
	end
	luci.sys.exec("rm -rf /tmp/ad_tmp")
end
	luci.http.prepare_content("application/json")
	luci.http.write_json({ret=retstring,retcount=icount})
end
