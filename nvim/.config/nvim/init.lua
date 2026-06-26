vim.loader.enable()

local opt = vim.opt

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.mouse = 'a'
opt.ignorecase = true
opt.smartcase = true
opt.clipboard = 'unnamedplus'
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.signcolumn = 'yes'
opt.updatetime = 250
opt.timeoutlen = 500

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      vim.cmd('TSUpdate')
    end
  end,
})

vim.pack.add({
  'https://github.com/echasnovski/mini.nvim',
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/folke/snacks.nvim',
  'https://github.com/MagicDuck/grug-far.nvim',
  'https://github.com/nvim-lualine/lualine.nvim',
})

vim.cmd.colorscheme('tokyonight')

require('mini.basics').setup()
require('mini.surround').setup({
  mappings = {
    add         = '',
    add_curly   = '',
    add_line    = '',
    delete      = '',
    delete_line = '',
    replace     = '',
    replace_line= '',
    find        = '',
    find_left   = '',
    highlight   = '',
  },
})
require('mini.icons').setup()
require('lualine').setup({
  options = {
    theme = 'tokyonight',
    globalstatus = true,
    icons_enabled = false,
    component_separators = { left = '|', right = '|' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = { 'snacks_dashboard' },
    },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = {
      {
        'filename',
        path = 1,
      },
    },
    lualine_x = { 'filetype', 'encoding', 'fileformat' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },
})
require('which-key').setup({
  preset = 'helix',
  spec = {
    { '<leader>f', group = 'file/find' },
    { '<leader>p', group = 'project' },
    { '<leader>s', group = 'search' },
  },
})



local global_lsp = vim.lsp.enable
vim.lsp.enable({ 'lua_ls', 'ts_ls' })

-- snacks.nvim (dashboard, picker, notifier, etc.)
require('snacks').setup({
  dashboard = {
    enabled = true,
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
    },
  },
  picker = {
    enabled = true,
    win = {
      input = {
        keys = {
          ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
        },
      },
    },
  },
  notifier = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  words = { enabled = true },
  bigfile = { enabled = true },
  quickfile = { enabled = true },
})

local map = vim.keymap.set
local opts = { silent = true }

local proj_root = function()
  return vim.fs.root(0, { '.git', 'Makefile', 'package.json', 'Cargo.toml', 'pyproject.toml', 'go.mod', 'CMakeLists.txt', 'composer.json' })
end

-- emacs-style cursor movement in insert mode
map('i', '<C-a>', '<Home>', { silent = true, desc = 'cursor line start' })
map('i', '<C-b>', '<Left>', { silent = true, desc = 'cursor left' })
map('i', '<C-e>', '<End>', { silent = true, desc = 'cursor line end' })
map('i', '<C-f>', '<Right>', { silent = true, desc = 'cursor right' })
map('i', '<C-p>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-p>'
  end
  return '<Up>'
end, { expr = true, silent = true, desc = 'cursor up' })
map('i', '<C-n>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-n>'
  end
  return '<Down>'
end, { expr = true, silent = true, desc = 'cursor down' })

-- snacks picker keymaps
map('n', '<leader>ff', function() Snacks.picker.files() end, { silent = true, desc = 'Find files' })
map('n', '<leader>fg', function() Snacks.picker.grep() end, { silent = true, desc = 'Grep files' })
map('n', '<leader>fr', function() Snacks.picker.recent() end, { silent = true, desc = 'Recent files' })
map('n', '<leader>fb', function() Snacks.picker.buffers() end, { silent = true, desc = 'Find buffers' })
map('n', '<leader>f/', function() Snacks.picker.grep_buffers() end, { silent = true, desc = 'Grep open buffers' })
map('n', '<leader>:', function() Snacks.picker.commands() end, { silent = true, desc = 'Command palette' })
map('n', '<leader>fk', function() Snacks.picker.keymaps() end, { silent = true, desc = 'Find keymaps' })

-- project keymaps (p prefix)
map('n', '<leader>pp', function() Snacks.picker.projects() end, { silent = true, desc = 'Switch project' })
map('n', '<leader>pf', function() Snacks.picker.files({ cwd = proj_root() }) end, { silent = true, desc = 'Project files' })
map('n', '<leader>pg', function() Snacks.picker.grep({ cwd = proj_root() }) end, { silent = true, desc = 'Project grep' })
map('n', '<leader>pb', function() Snacks.picker.buffers({ cwd = proj_root() }) end, { silent = true, desc = 'Project buffers' })
map('n', '<leader>pr', function() Snacks.picker.recent({ cwd = proj_root() }) end, { silent = true, desc = 'Project recent files' })

-- grug-far.nvim (search & replace across files)
map({'n', 'x'}, '<leader>sr', function()
  require('grug-far').open({ transient = true })
end, { silent = true, desc = 'Search and replace' })

map('n', '<leader>?', function()
  require('which-key').show({ global = false })
end, { silent = true, desc = 'Buffer keymaps' })

-- vim-surround style bindings (powered by mini.surround)
local get_char = function()
  local c = vim.fn.getcharstr()
  if c == '' or c == '\27' then return nil end
  return c
end

map('n', 'ys', function()
  vim.o.operatorfunc = 'v:lua.MiniSurround.add'
  return 'g@'
end, { expr = true, desc = 'surround: add' })

map('n', 'yss', function()
  vim.o.operatorfunc = 'v:lua.MiniSurround.add'
  return 'g@_'
end, { expr = true, desc = 'surround: add line' })

map('n', 'ds', function()
  local c = get_char()
  if c then MiniSurround.delete(c) end
end, { desc = 'surround: delete' })

map('n', 'cs', function()
  local old = get_char()
  if not old then return end
  local new = get_char()
  if not new then return end
  MiniSurround.replace(old, new)
end, { desc = 'surround: change' })

map('x', 'S', function()
  vim.o.operatorfunc = 'v:lua.MiniSurround.add'
  return 'g@'
end, { expr = true, desc = 'surround: add (visual)' })
