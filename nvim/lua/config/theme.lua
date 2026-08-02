-- Palette-driven colorscheme builder.
--
-- Each rice supplies ~18 colours; this turns them into a complete highlight
-- set. Doing it this way rather than pulling in nine upstream colorscheme
-- plugins means no network dependency, no nine different option APIs to
-- learn, and identical coverage across every profile — if a group is themed
-- for one rice it is themed for all of them.
--
-- kib-custom is the exception and still uses the catppuccin plugin; see
-- lua/plugins/colorscheme.lua for the branch.
--
-- Required palette keys:
--   bg bg1 bg2 bg3 fg fg1 dim sel accent accent2
--   red green yellow blue purple cyan orange
-- Optional:
--   none (set to "NONE" for transparency), border

local M = {}

function M.apply(p)
  local bg = p.transparent and "NONE" or p.bg
  local bgf = p.transparent and "NONE" or p.bg1   -- floats
  local hl = vim.api.nvim_set_hl

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
  vim.o.background = p.light and "light" or "dark"
  vim.g.colors_name = p.name or "rice"

  local groups = {
    -- ── core ──
    Normal        = { fg = p.fg, bg = bg },
    NormalNC      = { fg = p.fg, bg = bg },
    NormalFloat   = { fg = p.fg, bg = bgf },
    FloatBorder   = { fg = p.border or p.accent, bg = bgf },
    FloatTitle    = { fg = p.accent, bg = bgf, bold = true },
    Cursor        = { fg = p.bg, bg = p.accent },
    CursorLine    = { bg = p.bg1 },
    CursorLineNr  = { fg = p.accent, bold = true },
    LineNr        = { fg = p.dim },
    SignColumn    = { bg = bg },
    ColorColumn   = { bg = p.bg1 },
    Visual        = { bg = p.sel },
    VisualNOS     = { bg = p.sel },
    Search        = { fg = p.bg, bg = p.yellow },
    IncSearch     = { fg = p.bg, bg = p.accent },
    CurSearch     = { fg = p.bg, bg = p.accent },
    MatchParen    = { fg = p.accent, bold = true },
    NonText       = { fg = p.bg3 },
    Whitespace    = { fg = p.bg3 },
    EndOfBuffer   = { fg = bg == "NONE" and p.bg2 or bg },
    Folded        = { fg = p.fg1, bg = p.bg1 },
    FoldColumn    = { fg = p.dim, bg = bg },
    Conceal       = { fg = p.dim },
    Directory     = { fg = p.blue },
    Title         = { fg = p.accent, bold = true },
    ErrorMsg      = { fg = p.red },
    WarningMsg    = { fg = p.yellow },
    ModeMsg       = { fg = p.fg1 },
    MoreMsg       = { fg = p.green },
    Question      = { fg = p.green },
    SpecialKey    = { fg = p.bg3 },
    WinSeparator  = { fg = p.bg2, bg = bg },
    VertSplit     = { fg = p.bg2, bg = bg },

    -- ── statusline / tabline ──
    StatusLine    = { fg = p.fg1, bg = p.bg2 },
    StatusLineNC  = { fg = p.dim, bg = p.bg1 },
    TabLine       = { fg = p.dim, bg = p.bg1 },
    TabLineFill   = { bg = bg },
    TabLineSel    = { fg = p.accent, bg = p.bg2, bold = true },
    WinBar        = { fg = p.fg1, bg = bg },
    WinBarNC      = { fg = p.dim, bg = bg },

    -- ── popup menu ──
    Pmenu         = { fg = p.fg1, bg = p.bg1 },
    PmenuSel      = { fg = p.bg, bg = p.accent, bold = true },
    PmenuSbar     = { bg = p.bg2 },
    PmenuThumb    = { bg = p.accent },
    WildMenu      = { fg = p.bg, bg = p.accent },

    -- ── syntax ──
    Comment       = { fg = p.dim, italic = p.italic_comments ~= false },
    Constant      = { fg = p.orange },
    String        = { fg = p.green },
    Character     = { fg = p.green },
    Number        = { fg = p.orange },
    Boolean       = { fg = p.orange },
    Float         = { fg = p.orange },
    Identifier    = { fg = p.fg },
    Function      = { fg = p.blue },
    Statement     = { fg = p.purple },
    Conditional   = { fg = p.purple },
    Repeat        = { fg = p.purple },
    Label         = { fg = p.purple },
    Operator      = { fg = p.cyan },
    Keyword       = { fg = p.purple },
    Exception     = { fg = p.red },
    PreProc       = { fg = p.cyan },
    Include       = { fg = p.purple },
    Define        = { fg = p.purple },
    Macro         = { fg = p.cyan },
    Type          = { fg = p.yellow },
    StorageClass  = { fg = p.yellow },
    Structure     = { fg = p.yellow },
    Typedef       = { fg = p.yellow },
    Special       = { fg = p.accent2 },
    SpecialChar   = { fg = p.accent2 },
    Delimiter     = { fg = p.fg1 },
    Tag           = { fg = p.accent2 },
    Underlined    = { fg = p.blue, underline = true },
    Todo          = { fg = p.bg, bg = p.yellow, bold = true },
    Error         = { fg = p.red },

    -- ── diagnostics ──
    DiagnosticError            = { fg = p.red },
    DiagnosticWarn             = { fg = p.yellow },
    DiagnosticInfo             = { fg = p.blue },
    DiagnosticHint             = { fg = p.cyan },
    DiagnosticOk               = { fg = p.green },
    DiagnosticUnderlineError   = { sp = p.red,    undercurl = true },
    DiagnosticUnderlineWarn    = { sp = p.yellow, undercurl = true },
    DiagnosticUnderlineInfo    = { sp = p.blue,   undercurl = true },
    DiagnosticUnderlineHint    = { sp = p.cyan,   undercurl = true },
    DiagnosticVirtualTextError = { fg = p.red },
    DiagnosticVirtualTextWarn  = { fg = p.yellow },
    DiagnosticVirtualTextInfo  = { fg = p.blue },
    DiagnosticVirtualTextHint  = { fg = p.cyan },

    -- ── lsp ──
    LspReferenceText  = { bg = p.sel },
    LspReferenceRead  = { bg = p.sel },
    LspReferenceWrite = { bg = p.sel, underline = true },
    LspInlayHint      = { fg = p.dim, bg = p.bg1, italic = true },
    LspSignatureActiveParameter = { fg = p.accent, bold = true },

    -- ── diff / git ──
    DiffAdd     = { fg = p.green,  bg = p.bg1 },
    DiffChange  = { fg = p.yellow, bg = p.bg1 },
    DiffDelete  = { fg = p.red,    bg = p.bg1 },
    DiffText    = { fg = p.bg,     bg = p.yellow },
    Added       = { fg = p.green },
    Changed     = { fg = p.yellow },
    Removed     = { fg = p.red },

    -- ── treesitter ──
    ["@variable"]              = { fg = p.fg },
    ["@variable.builtin"]      = { fg = p.red },
    ["@variable.parameter"]    = { fg = p.orange },
    ["@variable.member"]       = { fg = p.accent2 },
    ["@constant"]              = { fg = p.orange },
    ["@constant.builtin"]      = { fg = p.orange },
    ["@module"]                = { fg = p.yellow },
    ["@string"]                = { fg = p.green },
    ["@string.escape"]         = { fg = p.cyan },
    ["@character"]             = { fg = p.green },
    ["@number"]                = { fg = p.orange },
    ["@boolean"]               = { fg = p.orange },
    ["@function"]              = { fg = p.blue },
    ["@function.builtin"]      = { fg = p.cyan },
    ["@function.method"]       = { fg = p.blue },
    ["@constructor"]           = { fg = p.yellow },
    ["@operator"]              = { fg = p.cyan },
    ["@keyword"]               = { fg = p.purple },
    ["@keyword.function"]      = { fg = p.purple },
    ["@keyword.return"]        = { fg = p.purple },
    ["@type"]                  = { fg = p.yellow },
    ["@type.builtin"]          = { fg = p.yellow },
    ["@attribute"]             = { fg = p.cyan },
    ["@property"]              = { fg = p.accent2 },
    ["@punctuation.delimiter"] = { fg = p.fg1 },
    ["@punctuation.bracket"]   = { fg = p.fg1 },
    ["@punctuation.special"]   = { fg = p.accent2 },
    ["@comment"]               = { fg = p.dim, italic = p.italic_comments ~= false },
    ["@tag"]                   = { fg = p.purple },
    ["@tag.attribute"]         = { fg = p.yellow },
    ["@tag.delimiter"]         = { fg = p.fg1 },
    ["@markup.heading"]        = { fg = p.accent, bold = true },
    ["@markup.link"]           = { fg = p.blue, underline = true },
    ["@markup.raw"]            = { fg = p.green },
    ["@markup.list"]           = { fg = p.accent2 },
    ["@markup.strong"]         = { bold = true },
    ["@markup.italic"]         = { italic = true },

    -- ── nvim-cmp ──
    CmpItemAbbr           = { fg = p.fg1 },
    CmpItemAbbrMatch      = { fg = p.accent, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = p.accent },
    CmpItemKind           = { fg = p.purple },
    CmpItemMenu           = { fg = p.dim },
  }

  for group, spec in pairs(groups) do
    hl(0, group, spec)
  end

  -- Per-rice escape hatch, applied last so a theme can always win.
  for group, spec in pairs(p.overrides or {}) do
    hl(0, group, spec)
  end

  -- Terminal colours inside :terminal, so a shell in nvim matches alacritty.
  local t = {
    p.bg2, p.red, p.green, p.yellow, p.blue, p.purple, p.cyan, p.fg1,
    p.bg3, p.red, p.green, p.yellow, p.blue, p.purple, p.cyan, p.fg,
  }
  for i, c in ipairs(t) do
    vim.g["terminal_color_" .. (i - 1)] = c
  end
end

return M
