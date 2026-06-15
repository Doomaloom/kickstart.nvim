local function angular_root(path)
  return vim.fs.root(path, { 'angular.json', 'nx.json' })
end

vim.filetype.add {
  extension = {
    html = function(path)
      return angular_root(path) and 'htmlangular' or 'html'
    end,
  },
}

local function vtsls_command(name)
  return function()
    require('vtsls').commands[name]()
  end
end

local function eslint_fix_all()
  local commands = vim.api.nvim_buf_get_commands(0, {})
  if commands.LspEslintFixAll then
    vim.cmd.LspEslintFixAll()
  else
    vim.notify('ESLint is not attached to this buffer', vim.log.levels.WARN)
  end
end

local angular_component_suffixes = {
  '.ts',
  '.html',
  '.scss',
  '.css',
  '.sass',
  '.less',
  '.spec.ts',
}

local function alternate_angular_component_file()
  local current = vim.api.nvim_buf_get_name(0)
  local suffix_start
  local current_index

  for index, suffix in ipairs(angular_component_suffixes) do
    local start = #current - #suffix + 1
    if start > 0 and current:sub(start) == suffix then
      if not suffix_start or start < suffix_start then
        suffix_start = start
        current_index = index
      end
    end
  end

  if not suffix_start then
    vim.notify('Current file is not an Angular component file', vim.log.levels.WARN)
    return
  end

  local stem = current:sub(1, suffix_start - 1)
  for offset = 1, #angular_component_suffixes - 1 do
    local index = ((current_index + offset - 1) % #angular_component_suffixes) + 1
    local candidate = stem .. angular_component_suffixes[index]
    if vim.fn.filereadable(candidate) == 1 then
      vim.cmd.edit(vim.fn.fnameescape(candidate))
      return
    end
  end

  vim.notify('No related Angular component files found', vim.log.levels.WARN)
end

local function run_angular_test(command)
  local root = angular_root(vim.api.nvim_buf_get_name(0))
  if not root then
    vim.notify('Current buffer is not inside an Angular workspace', vim.log.levels.WARN)
    return
  end

  local runner_key = 'test#javascript#runner'
  local options_key = 'test#javascript#ngtest#options'
  local previous_runner = vim.g[runner_key]
  local previous_options = vim.g[options_key]

  vim.g[runner_key] = 'ngtest'
  vim.g[options_key] = '--watch=false'
  local ok, err = pcall(vim.cmd, command)
  vim.g[runner_key] = previous_runner
  vim.g[options_key] = previous_options
  if not ok then
    error(err)
  end
end

local function restart_last_task()
  local overseer = require 'overseer'
  local task_list = require 'overseer.task_list'
  local tasks = overseer.list_tasks {
    status = {
      overseer.STATUS.FAILURE,
      overseer.STATUS.CANCELED,
      overseer.STATUS.SUCCESS,
    },
    sort = task_list.sort_finished_recently,
  }

  if vim.tbl_isempty(tasks) then
    vim.notify('No completed tasks found', vim.log.levels.WARN)
    return
  end

  overseer.run_action(tasks[1], 'restart')
end

return {
  {
    'uga-rosa/ccc.nvim',
    event = 'BufReadPre',
    cmd = { 'CccPick', 'CccHighlighterToggle' },
    keys = {
      { '<leader>cp', '<cmd>CccPick<cr>', desc = '[C]olor [P]icker' },
      { '<leader>ct', '<cmd>CccHighlighterToggle<cr>', desc = '[C]olor preview [T]oggle' },
    },
    config = function()
      local ccc = require 'ccc'
      local input = ccc.input
      local output = ccc.output
      local picker = ccc.picker

      ccc.setup {
        inputs = {
          input.rgb,
          input.hsl,
          input.oklch,
        },
        outputs = {
          output.hex,
          output.css_rgb,
          output.css_hsl,
          output.css_oklch,
        },
        pickers = {
          picker.hex,
          picker.css_rgb,
          picker.css_hsl,
          picker.css_hwb,
          picker.css_lab,
          picker.css_lch,
          picker.css_oklab,
          picker.css_oklch,
          picker.css_name,
        },
        recognize = {
          input = true,
          output = true,
        },
        highlighter = {
          auto_enable = true,
          filetypes = { 'css', 'html', 'htmlangular', 'less', 'sass', 'scss' },
          lsp = true,
          update_insert = true,
        },
      }
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
      aliases = {
        angular = 'html',
      },
    },
  },
  {
    'L3MON4D3/LuaSnip',
    optional = true,
    opts = function(_, opts)
      local luasnip = require 'luasnip'
      luasnip.filetype_extend('htmlangular', { 'html', 'angular' })

      local snippet = luasnip.snippet
      local text = luasnip.text_node
      local insert = luasnip.insert_node

      luasnip.add_snippets('htmlangular', {
        snippet('a-if', {
          text '@if (',
          insert(1, 'condition'),
          text { ') {', '  ' },
          insert(2),
          text { '', '}' },
        }),
        snippet('a-ifelse', {
          text '@if (',
          insert(1, 'condition'),
          text { ') {', '  ' },
          insert(2),
          text { '', '} @else {', '  ' },
          insert(3),
          text { '', '}' },
        }),
        snippet('a-for', {
          text '@for (',
          insert(1, 'item'),
          text ' of ',
          insert(2, 'items'),
          text '; track ',
          insert(3, 'item.id'),
          text { ') {', '  ' },
          insert(4),
          text { '', '} @empty {', '  ' },
          insert(5),
          text { '', '}' },
        }),
        snippet('a-switch', {
          text '@switch (',
          insert(1, 'value'),
          text { ') {', '  @case (' },
          insert(2, 'caseValue'),
          text { ') {', '    ' },
          insert(3),
          text { '', '  }', '  @default {', '    ' },
          insert(4),
          text { '', '  }', '}' },
        }),
        snippet('a-defer', {
          text { '@defer {', '  ' },
          insert(1),
          text { '', '} @placeholder {', '  ' },
          insert(2),
          text { '', '}' },
        }),
      })

      return opts
    end,
  },
  {
    'yioneko/nvim-vtsls',
    lazy = false,
    config = function()
      require('vtsls').config {
        refactor_auto_rename = true,
      }
    end,
    keys = {
      { '<leader>co', vtsls_command 'organize_imports', desc = '[C]ode [O]rganize imports' },
      { '<leader>cm', vtsls_command 'add_missing_imports', desc = '[C]ode add [M]issing imports' },
      { '<leader>cu', vtsls_command 'remove_unused_imports', desc = '[C]ode remove [U]nused imports' },
      { '<leader>cR', vtsls_command 'rename_file', desc = '[C]ode [R]ename file' },
      { '<leader>cs', vtsls_command 'goto_source_definition', desc = '[C]ode goto [S]ource definition' },
      { '<leader>cf', eslint_fix_all, desc = '[C]ode ESLint [F]ix all' },
      { '<leader>ca', alternate_angular_component_file, desc = '[C]omponent [A]lternate file' },
    },
  },
  {
    'vim-test/vim-test',
    cmd = { 'TestNearest', 'TestFile', 'TestSuite', 'TestLast', 'TestVisit' },
    init = function()
      vim.g['test#strategy'] = 'neovim_sticky'
      vim.g['test#neovim_sticky#kill_previous'] = 1
      vim.g['test#neovim_sticky#reopen_window'] = 1
      vim.g['test#neovim_sticky#use_existing'] = 1
    end,
    keys = {
      {
        '<leader>rn',
        function()
          run_angular_test 'TestNearest'
        end,
        desc = '[R]un [N]earest Angular test',
      },
      {
        '<leader>rf',
        function()
          run_angular_test 'TestFile'
        end,
        desc = '[R]un Angular test [F]ile',
      },
      {
        '<leader>rs',
        function()
          run_angular_test 'TestSuite'
        end,
        desc = '[R]un Angular test [S]uite',
      },
      {
        '<leader>rl',
        function()
          run_angular_test 'TestLast'
        end,
        desc = '[R]un [L]ast Angular test',
      },
      { '<leader>rv', '<cmd>TestVisit<cr>', desc = '[R]un: [V]isit last test file' },
    },
  },
  {
    'stevearc/overseer.nvim',
    cmd = { 'OverseerRun', 'OverseerToggle' },
    opts = {
      templates = { 'builtin' },
    },
    keys = {
      { '<leader>or', '<cmd>OverseerRun<cr>', desc = '[O]verseer [R]un task' },
      { '<leader>ot', '<cmd>OverseerToggle<cr>', desc = '[O]verseer [T]oggle task list' },
      { '<leader>oa', restart_last_task, desc = '[O]verseer restart l[A]st task' },
    },
  },
}
