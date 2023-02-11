((nil
  (eval . (dante-mode 0))
  (eval . (flycheck-mode 0))
  (dante-repl-command-line . ("ghci"))
  (haskell-process-type . ghci)
  (format-all-formatters
   ("Haskell" ormolu)
   ("Literate Haskell" ormolu)
   )))
