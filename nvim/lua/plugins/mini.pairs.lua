return {
  {
    "echasnovski/mini.pairs",
    opts = function(_, opts)
      -- Extend the existing opts table
      opts.pairs = opts.pairs or {}

      -- Add $$ pair for Markdown files
      local add_dollar_pairs = function()
        if vim.bo.filetype == "md" then
          return { { "$", "$" } }
        end
        return {}
      end

      opts.custom_pairs = add_dollar_pairs

      return opts
    end,
  },
}