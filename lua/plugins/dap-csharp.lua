return {
  -- Configure nvim-dap for C# debugging
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")

      -- Configure C# adapter
      dap.adapters.coreclr = {
        type = "executable",
        command = vim.fn.expand("~/.local/bin/netcoredbg/netcoredbg"),
        args = { "--interpreter=vscode" },
      }

      -- Configure C# debugging configurations
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch - netcoredbg",
          request = "launch",
          program = function()
            -- Look for dll in bin/Debug or bin/Release
            local cwd = vim.fn.getcwd()
            local dll_path = vim.fn.input("Path to dll (or press Enter for auto-detect): ", cwd .. "/bin/Debug/", "file")
            
            if dll_path == "" or dll_path == cwd .. "/bin/Debug/" then
              -- Auto-detect: find the first .csproj and use its name
              local csproj = vim.fn.glob(cwd .. "/**/*.csproj")
              if csproj ~= "" then
                local project_name = vim.fn.fnamemodify(csproj, ":t:r")
                -- Try to find the dll
                local patterns = {
                  cwd .. "/bin/Debug/**/" .. project_name .. ".dll",
                  cwd .. "/bin/Release/**/" .. project_name .. ".dll",
                }
                for _, pattern in ipairs(patterns) do
                  local found = vim.fn.glob(pattern)
                  if found ~= "" then
                    return found
                  end
                end
              end
              return vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/", "file")
            end
            
            return dll_path
          end,
        },
        {
          type = "coreclr",
          name = "Attach - netcoredbg",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }
    end,
  },

  -- Optional: Configure nvim-dap-ui for better debugging experience
  {
    "rcarriga/nvim-dap-ui",
    optional = true,
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          position = "left",
          size = 40,
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          position = "bottom",
          size = 10,
        },
      },
    },
  },
}
