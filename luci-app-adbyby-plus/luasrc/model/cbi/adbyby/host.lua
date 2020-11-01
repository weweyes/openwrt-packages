local fs = require "nixio.fs"
local conffile = "/etc/adbyby_conf/adhost.conf"

f=SimpleForm("custom")
t=f:field(TextValue,"conf")
t.rmempty=true
t.rows=13
t.description=translate("These Domain will be filtered in Plus+ mode")
function t.cfgvalue()
	return fs.readfile(conffile) or ""
end

function f.handle(self,state,data)
	if state == FORM_VALID then
		if data.conf then
			fs.writefile(conffile,data.conf:gsub("\r\n","\n"))
			luci.sys.exec("/etc/init.d/adbyby restart")
		end
	end
	return true
end

return f