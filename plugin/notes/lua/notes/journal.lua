local M = {}

local function today_date()
  return os.date("%Y-%m-%d")
end

--- Offset a YYYY-MM-DD date by a number of days
local function add_days(date_str, days)
  local y, m, d = date_str:match("^(%d+)-(%d+)-(%d+)$")
  if not y then return nil end
  local t = os.time({ year = y, month = m, day = d })
  t = t + days * 86400
  return os.date("%Y-%m-%d", t)
end

--- Offset a YYYY-MM-DD date by a number of months (handles year rollover)
local function add_months(date_str, months)
  local y, m, d = date_str:match("^(%d+)-(%d+)-(%d+)$")
  if not y then return nil end
  y, m = tonumber(y), tonumber(m) + months
  -- Roll months into years
  local whole_years = math.floor(m / 12)
  m = m - whole_years * 12
  if m <= 0 then m = m + 12; whole_years = whole_years - 1 end
  y = y + whole_years
  -- os.time normalizes overflowed days (e.g. Jan 31 + 1 month -> Mar 3)
  local t = os.time({ year = y, month = m, day = tonumber(d) })
  return os.date("%Y-%m-%d", t)
end

--- Parse a flexible user date input and return YYYY-MM-DD, or nil on failure.
-- Accepts:
--   YYYY-MM-DD, YYYY/MM/DD, YYYYMMDD
--   today, yesterday, tomorrow (and yest/tom/tomorrow)
--   +Nd, -Nd, +Nw, -Nw  (days / weeks from today)
--   +Nm, -Nm, +Ny, -Ny  (months / years from today)
local function parse_date(input)
  if not input then return nil end
  input = vim.trim(input)
  if input == "" then return nil end

  local today = today_date()
  local lower = input:lower()

  -- Friendly words
  local words = {
    today = today, now = today, t = today,
    yesterday = add_days(today, -1), yest = add_days(today, -1),
    tomorrow = add_days(today, 1), tom = add_days(today, 1), tmrw = add_days(today, 1),
  }
  if words[lower] then return words[lower] end

  -- Relative offsets from today: +2d, -3w, +1m, -1y (sign optional)
  local sign, n, unit = lower:match("^([%+%-]?)(%d+)([dwmy])$")
  if n and unit then
    local count = tonumber(n)
    if sign == "-" then count = -count end
    if unit == "d" then return add_days(today, count) end
    if unit == "w" then return add_days(today, count * 7) end
    if unit == "m" then return add_months(today, count) end
    if unit == "y" then return add_months(today, count * 12) end
  end

  -- YYYY-MM-DD or YYYY/MM/DD
  local y, m, d = input:match("^(%d%d%d%d)[-/](%d%d)[-/](%d%d)$")
  if y then
    -- Validate by round-tripping through os.time
    local t = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d) })
    if t then return os.date("%Y-%m-%d", t) end
  end

  -- YYYYMMDD (8 digits)
  local c8 = input:match("^(%d%d%d%d%d%d%d%d)$")
  if c8 then
    local cy, cm, cd = c8:match("^(%d%d%d%d)(%d%d)(%d%d)$")
    local t = os.time({ year = tonumber(cy), month = tonumber(cm), day = tonumber(cd) })
    if t then return os.date("%Y-%m-%d", t) end
  end

  return nil
end
M.parse_date = parse_date

--- Open (or create) the journal entry for the given YYYY-MM-DD date
function M.open_date(config, date)
  if not date or not date:match("^%d%d%d%d%-%d%d%-%d%d$") then
    vim.notify("Invalid journal date: " .. tostring(date), vim.log.levels.ERROR)
    return
  end

  local path = config.journal_dir .. "/" .. date .. ".md"

  -- Create from journal template if it doesn't exist
  if vim.fn.filereadable(path) == 0 and config.journal_template then
    -- Compute weekday for the requested date (not necessarily today)
    local y, m, d = date:match("^(%d+)-(%d+)-(%d+)$")
    local weekday = os.date("%A", os.time({ year = y, month = m, day = d }))
    local content = require("notes.templates").load_and_apply(config, config.journal_template, {
      title = date,
      page = date,
      date = date,
      weekday = weekday,
    })
    if content then
      vim.fn.writefile(vim.split(content, "\n"), path)
    end
  end

  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

function M.open_today(config)
  M.open_date(config, today_date())
end

--- Open a journal entry, optionally prompting for a date.
-- `arg` may be nil/"" (prompt), or a date expression (see parse_date).
function M.open(config, arg)
  if arg and arg ~= "" then
    local date = parse_date(arg)
    if not date then
      vim.notify("Could not parse date: " .. arg, vim.log.levels.ERROR)
      return
    end
    M.open_date(config, date)
    return
  end

  -- No argument: prompt, defaulting to today
  vim.ui.input({ prompt = "Journal date (YYYY-MM-DD, today, yesterday, +2d, ...): ", default = today_date() }, function(answer)
    if not answer or vim.trim(answer) == "" then return end
    local date = parse_date(answer)
    if not date then
      vim.notify("Could not parse date: " .. answer, vim.log.levels.ERROR)
      return
    end
    M.open_date(config, date)
  end)
end

return M