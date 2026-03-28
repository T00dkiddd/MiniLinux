local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.IgnoreGuiInset = true

local bg = Instance.new("Frame", gui)
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
bg.BorderSizePixel = 0

local textColor = Color3.fromRGB(180,180,180)

local logLabel = Instance.new("TextLabel", bg)
logLabel.Size = UDim2.new(1,-20,0.6,0)
logLabel.Position = UDim2.new(0,10,0,10)
logLabel.BackgroundTransparency = 1
logLabel.TextColor3 = textColor
logLabel.Font = Enum.Font.Code
logLabel.TextSize = 14
logLabel.TextXAlignment = Enum.TextXAlignment.Left
logLabel.TextYAlignment = Enum.TextYAlignment.Top
logLabel.Text = ""

local logs = {
"[0.000000] Linux version 4.1.0",
"[0.100000] Booting MiniLinux",
"[0.300000] Initializing CPU",
"[0.500000] Memory detected: 2048MB",
"[0.800000] Mounting filesystems",
"[1.200000] Starting services",
"[1.600000] Network ready",
"[2.000000] System initialized"
}

for _,v in ipairs(logs) do
	logLabel.Text = logLabel.Text .. v .. "\n"
	wait(0.25)
end

wait(9)
logLabel.Visible = false

local terminal = Instance.new("TextBox", bg)
terminal.Size = UDim2.new(1,-20,1,-20)
terminal.Position = UDim2.new(0,10,0,10)
terminal.BackgroundTransparency = 1
terminal.TextColor3 = textColor
terminal.Font = Enum.Font.Code
terminal.TextSize = 16
terminal.TextXAlignment = Enum.TextXAlignment.Left
terminal.TextYAlignment = Enum.TextYAlignment.Top
terminal.ClearTextOnFocus = false

local user = "user"
local host = "minilinux"
local currentDir = "/home/user"

local function getPrompt()
	return user.."@"..host..":"..currentDir.."$ "
end

terminal.Text = getPrompt()

local fs = {
	["/home/user"] = {"file.txt","notes.log"},
	["/"] = {"home","bin","etc"}
}

local commands = {}

commands.help = function()
	return "ls cd pwd cat echo clear uname whoami date neofetch"
end

commands.ls = function()
	return table.concat(fs[currentDir] or {}, "  ")
end

commands.pwd = function()
	return currentDir
end

commands.cd = function(args)
	if args[1] == ".." then
		currentDir = "/"
	end
	return ""
end

commands.echo = function(args)
	return table.concat(args," ")
end

commands.uname = function()
	return "Linux 4.1.0"
end

commands.whoami = function()
	return user
end

commands.date = function()
	return os.date()
end

commands.clear = function()
	terminal.Text = getPrompt()
	return ""
end

commands.cat = function(args)
	return args[1] or ""
end

commands.neofetch = function()
	return [[
      .--.
     |o_o |
     |:_/ |
MiniLinux
Kernel 4.1
]]
end

terminal.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local text = terminal.Text
		local lines = string.split(text, "\n")
		local lastLine = lines[#lines]

		local cmdLine = lastLine:gsub("^"..getPrompt(), "")

		local args = string.split(cmdLine, " ")
		local cmd = args[1]
		table.remove(args,1)

		if cmd and commands[cmd] then
			local result = commands[cmd](args)
			terminal.Text = terminal.Text .. "\n" .. (result or "") .. "\n" .. getPrompt()
		else
			terminal.Text = terminal.Text .. "\ncommand not found\n" .. getPrompt()
		end
	end
end)
