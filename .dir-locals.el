((nil
  (eval . (dante-mode 1))
  (eval . (flycheck-mode 1))
  (dante-repl-command-line . ("ghci"))
  (haskell-process-type . ghci)
  (format-all-formatters
   ("Haskell" fourmolu)
   ("Literate Haskell" fourmolu)
   )))
