-- Licensed to the public under the Apache License 2.0.

module("luci.controller.cifsd", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/ksmbd") then
		return
	end
	

	local page

	page = entry({"admin", "services", "cifsd"}, cbi("cifsd"), _("Network Shares"))
	page.dependent = true
end

