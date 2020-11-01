local SYS = require "luci.sys"

m=Map("adbyby")
s=m:section(TypedSection,"adbyby")
s.anonymous=true

o=s:option(Flag,"block_ios")
o.title = translate("Block Apple iOS OTA update")
o.default=0
o.rmempty=false

o=s:option(Flag,"block_cnshort")
o.title=translate("Block CNshort APP and Website")
o.default=0
o.rmempty=false

o=s:option(Flag,"cron_mode")
o.title=translate("Enable automatic update rules")
o.default=0
o.rmempty=false

o=s:option(ListValue,"time_update")
o.title=translate("Update time")
for s=0,23 do
o:value(s)
end
o.default=6
o:depends("cron_mode","1")

if nixio.fs.access("/tmp/adbyby/dnsmasq/dnsmasq.adblock") then
ad_count=tonumber(SYS.exec("cat /tmp/adbyby/dnsmasq/dnsmasq.adblock | wc -l"))
o=s:option(DummyValue,"0",translate("Adblock Plus Data"))
o.rawhtml=true
o.template="adbyby/refresh"
o.value=ad_count .. " " .. translate("Records")
end

local tmp_rule=0
if nixio.fs.access("/tmp/adbyby/rules/3rd.conf") or nixio.fs.access("/tmp/adbyby/rules/3rd.host") then
tmp_rule=1
rule_count=tonumber(SYS.exec("find /tmp/adbyby/rules -name 3* -exec cat {} \\; 2>/dev/null | wc -l"))
o=s:option(DummyValue,"1",translate("Subscribe 3rd Rules Data"))
o.rawhtml=true
o.template="adbyby/refresh"
o.value=rule_count .. " " .. translate("Records")
o.description=translate("AdGuardHome / Host / DNSMASQ rules auto-convert<br/>Automatically remove duplicate rules(including Adblock Plus Rules)")
end

o=s:option(Flag,"flash")
o.title=translate("Save 3rd rules to flash")
o.description=translate("Should be enabled when 3rd rules addresses are slow to download")
o.default=0
o.rmempty=false

if tmp_rule==1 then
o=s:option(Button,"delete",translate("Delete All Subscribe Rules"))
o.inputstyle="reset"
o.description=translate("Delete 3rd rules files and delete the subscription link<br/>There is no need to click for modify the subscription link,The script will automatically replace the old rule file")
o.write=function()
	SYS.exec("[ -d /etc/adbyby_conf/rules ] && rm -rf /etc/adbyby_conf/rules")
	SYS.exec("grep -wq 'list url' /etc/config/adbyby && sed -i '/list url/d' /etc/config/adbyby && /etc/init.d/adbyby restart 2>&1 &")
	luci.http.redirect(luci.dispatcher.build_url("admin","services","adbyby","advanced"))
end
end

sret=luci.sys.call("[ -h /tmp/adbyby/rules/url ] || exit 9")
if sret==9 then
	if nixio.fs.access("/etc/adbyby_conf/rules/3rd.conf") or nixio.fs.access("/etc/adbyby_conf/rules/3rd.host") then
		o=s:option(Button,"delete_1",translate("Delete Subscribe Rules On The Flash"))
		o.inputstyle="reset"
		o.write=function()
			SYS.exec("rm -rf /etc/adbyby_conf/rules")
			luci.http.redirect(luci.dispatcher.build_url("admin","services","adbyby","advanced"))
		end
	end
end

o=s:option(DynamicList,"url",translate("Anti-AD Rules Subscribe"))
o.rmempty=true

return m
