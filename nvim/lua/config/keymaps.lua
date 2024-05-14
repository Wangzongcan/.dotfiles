local map = vim.keymap.set

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

map({ "i" }, "<C-f>", "<Right>")
map({ "i" }, "<C-b>", "<Left>")
map({ "i" }, "<C-p>", "<Up>")
map({ "i" }, "<C-n>", "<Down>")
map({ "i" }, "<C-a>", "<Home>")
map({ "i" }, "<C-e>", "<End>")
