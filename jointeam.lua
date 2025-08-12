
local function setTeam(teamName)
	local args = {
		"SetTeam",
		teamName
	}
	game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
end

spawn(function()
	while wait() do
		local repStorage = game:GetService("ReplicatedStorage")
		if repStorage:FindFirstChild("Remotes") and repStorage.Remotes:FindFirstChild("CommF_") then
			if getgenv().Config.AutoChooseTeam then
				setTeam(getgenv().Config.Team)
			end
			break
		end
	end
end)