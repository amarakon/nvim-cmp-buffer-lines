nvim-cmp Buffer Lines
================

## Contents

- <a href="#preview" id="toc-preview">Preview</a>
- <a href="#introduction" id="toc-introduction">Introduction</a>
- <a href="#installation" id="toc-installation">Installation</a>
  - <a href="#packernvim" id="toc-packernvim">packer.nvim</a>
- <a href="#setup" id="toc-setup">Setup</a>
  - <a href="#options" id="toc-options">Options</a>
  - <a href="#command-line" id="toc-command-line">Command-line</a>
  - <a href="#only-for-certain-file-types"
    id="toc-only-for-certain-file-types">Only for certain file types</a>
- <a href="#todo" id="toc-todo">TODO</a>

## Preview

![](preview.gif)

## Introduction

nvim-cmp Buffer Lines is a completion source for
[nvim-cmp](https://github.com/hrsh7th/nvim-cmp) that provides a source
for all the lines in the current buffer. This is especially useful for
[C programmers](#only-for-certain-file-types).

## Installation

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

``` lua
require "packer".startup(function(use)
    use "amarakon/nvim-cmp-buffer-lines"
end)
```

## Setup

``` lua
require "cmp".setup {
    sources = {
        {
            name = "buffer-lines",
            option = { … }
        }
    }
}
```

### Options

| Option               | Type    | Default | Description                                                                                  |
|:---------------------|:--------|:--------|:---------------------------------------------------------------------------------------------|
| `words`              | Boolean | `false` | Include words                                                                                |
| `comments`           | Boolean | `false` | Include comments                                                                             |
| `leading_whitespace` | Boolean | `true`  | Include leading whitespace in the completion menu (does not apply on selection/confirmation) |

### Command-line

You can use this source for searching for patterns in the command-line.
I recommend using it in conjunction with
[cmp-buffer](https://github.com/hrsh7th/cmp-buffer) for a
bread-and-butter combination. The following code block is the
configuration I use and recommend.

``` lua
-- Enable `buffer` and `buffer-lines` for `/` and `?` in the command-line
require "cmp".setup.cmdline({ "/", "?" }, {
    mapping = require "cmp".mapping.preset.cmdline(),
    sources = {
        {
            name = "buffer",
            option = { keyword_pattern = [[\k\+]] }
        },
        { name = "buffer-lines" }
    }
})
```

### Only for certain file types

``` lua
-- Only enable `buffer-lines` for C and C++
require "cmp".setup.filetype({ "c", "cpp" }, {
    sources = {
        { name = "buffer-lines" }
    }
})
```

## TODO

- [x] Automatically update the source
- [x] Cut comments from lines
  - [x] Test it to prove it works in all use cases
  - [ ] Find a more efficient implementation with
    [tree-sitter](https://github.com/nvim-treesitter/nvim-treesitter) or
    LSP (Language Server Protocol)
- [x] Omit duplicate lines
- [x] Show indentation level in the completion menu, but not when
  selecting or confirming
- [ ] Add an option to choose the maximum indentation level lines will
  be shown
- [ ] Make the plugin more efficient for editing large files
- [ ] Add an option to set a file size limit
- [x] Add configuration options
- [ ] Add syntax highlighting
