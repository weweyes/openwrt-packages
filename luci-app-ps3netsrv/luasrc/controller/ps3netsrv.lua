module("luci.controller.ps3netsrv",package.seeall)

function index()
if not nixio.fs.access("/etc/config/ps3netsrv")then
  return
end

	
local page

entry({"admin", "services","ps3netsrv"},cbi("ps3netsrv"),_("PS3 NET Server"),40).dependent=true
entry({"admin", "services","ps3netsrv","status"},call("act_status")).leaf=true
end

function act_status()
  local e={}
  e.running=luci.sys.call("ps | grep ps3netsrv |grep -v grep >/dev/null") == 0
  luci.http.prepare_content("application/json")
  luci.http.write_json(e)
end
