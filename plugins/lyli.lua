local captured_URL_table
function lyliit(targ)
  -- Properly escape the input
  targ = string.gsub(targ, '(["|\'|\\{|\\}])', '\\%1')
  local handle = io.popen("curl -H 'Content-Type: application/json' -X POST -d '{\"url\": \""..targ.."\"}' api.lyli.fi")
  print("Check escaping://BEGIN//"..targ.."//END//")
  local result = handle:read("*a")
  handle:close()
  return result
end

function piliit(from)
	from = string.gsub(from, "'", "\\'")
	local handle = io.popen("curl 'api.lyli.fi/"..from.."'")
  	local result = handle:read("*a")
  	handle:close()
  	return result
end


function run(msg, matches)
  local results = "lyli plugin is confused."
  if(string.match(msg.text, "^!lyli (.*)$")) then
  	results = lyliit(matches[1])
  elseif string.match(msg.text, "^!pili (.*)$") then
  	results = piliit(matches[1])
  elseif string.match(msg.text, "^!lyli$") then
    local to_id = msg.to.id
    local onfail = "I have no previous link stored in my database 😞. You can also use !lyli [URL] to shorten a URL."
    if captured_URL_table ~= nil then
      if captured_URL_table[to_id] ~= nil then
        results = lyliit(captured_URL_table[to_id])
      else results = onfail.." (Debug: cUt[to_id] is nil)" end
    else results = onfail end
  elseif string.match(msg.text, "(https?://[%w-_%.%?%.:/%+=&]+)") and string.match(msg.text, "^❱") == nil then
    results = catch_url(msg)
  end
  return results
  
end

function catch_url(msg)
  local to_id = tostring(msg.to.id)

  print("Found URL!")
  if captured_URL_table == nil then
    captured_URL_table = {}
    print("cUt was nil!")
  end
  
  captured_URL_table[to_id] = matches[1]
  print("cUt[t/i] == "..captured_URL_table[to_id]..", and to_id == "..to_id)
  
  return "Use !lyli to shorten that link!"
end

return {
  description = "Creates a lyli link (using api.lyli.fi)",
  usage =  {
    "!lyli [url]: Shortens a long URL using lyli.fi.",
    "!pili [text]: Gets the target of link lyli.fi/text",
    "!lyli: Shortens the last URL sent to this chat"
  },
  patterns = {
    "^!lyli (.*)$",
    "^!pili (.*)$",
    "(https?://[%w-_%.%?%.:/%+=&]+)",
    "^!lyli$"
  },
  run = run
}
