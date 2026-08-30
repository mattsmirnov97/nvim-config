-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.tabstop = 4
opt.shiftwidth = 4

-- Layout-agnostic Normal/Visual mode: every Cyrillic (ЙЦУКЕН) key maps to
-- whatever Latin letter sits in the *same physical position* on a US
-- keyboard, so commands/motions/leader sequences work identically no matter
-- which OS input source is active — no switching, no background process,
-- no polling. This is what 'langmap' exists for.
--
-- Deliberately does NOT touch Insert mode (typed text is unaffected) or
-- Command-line/search (`:`, `/`, `?`) — that's not an oversight, it's
-- 'langmap''s own documented scope (:help langmap). Cmdline input is
-- ambiguous by nature: the same keystroke stream is used both for issuing
-- Latin commands (`:w`) and for typing free text users may want to stay
-- Cyrillic (`/русский_текст`, `:s/фыв/.../`), so there's no single correct
-- translation to apply there — that's a real, permanent limitation of this
-- approach, not something worth working around with OS-level hacks again.
opt.langmap = [[йq,цw,уe,кr,еt,нy,гu,шi,щo,зp,х[,ъ],фa,ыs,вd,аf,пg,рh,оj,лk,дl,ж\;,э',яz,чx,сc,мv,иb,тn,ьm,б\,,ю.,ё`,ЙQ,ЦW,УE,КR,ЕT,НY,ГU,ШI,ЩO,ЗP,Х{,Ъ},ФA,ЫS,ВD,АF,ПG,РH,ОJ,ЛK,ДL,Ж:,Э\",ЯZ,ЧX,СC,МV,ИB,ТN,ЬM,Б<,Ю>,Ё~]]
