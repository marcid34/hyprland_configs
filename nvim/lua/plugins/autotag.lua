return {
  -- nvim-autopairs only does bracket/quote pairs; tags need this
  "windwp/nvim-ts-autotag",
  event = "InsertEnter",
  opts = {
    opts = {
      enable_close = true,          -- <div> -> </div>
      enable_rename = true,         -- rename one tag, the pair follows
      enable_close_on_slash = true, -- </ closes the nearest open tag
    },
  },
}
