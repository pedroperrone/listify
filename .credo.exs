%{
  configs: [
    %{
      name: "default",
      files: %{
        included: [
          "lib/",
          "test/"
        ],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      plugins: [],
      requires: [],
      strict: false,
      parse_timeout: 5000,
      color: true,
      checks: [
        {Credo.Check.Consistency.ExceptionNames, []},
        {Credo.Check.Consistency.LineEndings, []},
        {Credo.Check.Consistency.MultiAliasImportRequireUse, false},
        {Credo.Check.Consistency.ParameterPatternMatching, []},
        {Credo.Check.Consistency.SpaceAroundOperators, []},
        {Credo.Check.Consistency.SpaceInParentheses, []},
        {Credo.Check.Consistency.TabsOrSpaces, []},
        {Credo.Check.Consistency.UnusedVariableNames, false},
        {Credo.Check.Design.AliasUsage,
         [priority: :low, if_nested_deeper_than: 2, if_called_more_often_than: 0]},
        {Credo.Check.Design.DuplicatedCode, []},
        {Credo.Check.Design.TagFIXME, []},
        {Credo.Check.Design.TagTODO, [exit_status: 2]},
        {Credo.Check.Readability.AliasAs, false},
        {Credo.Check.Readability.AliasOrder, []},
        {Credo.Check.Readability.FunctionNames, []},
        {Credo.Check.Readability.LargeNumbers, []},
        {Credo.Check.Readability.MaxLineLength, [priority: :low, max_length: 120]},
        {Credo.Check.Readability.ModuleAttributeNames, []},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Readability.ModuleNames, []},
        {Credo.Check.Readability.MultiAlias, false},
        {Credo.Check.Readability.ParenthesesInCondition, []},
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs, []},
        {Credo.Check.Readability.PredicateFunctionNames, []},
        {Credo.Check.Readability.PreferImplicitTry, []},
        {Credo.Check.Readability.RedundantBlankLines, []},
        {Credo.Check.Readability.Semicolons, []},
        {Credo.Check.Readability.SinglePipe, false},
        {Credo.Check.Readability.SpaceAfterCommas, []},
        {Credo.Check.Readability.Specs, false},
        {Credo.Check.Readability.StrictModuleLayout, false},
        {Credo.Check.Readability.StringSigils, []},
        {Credo.Check.Readability.TrailingBlankLine, []},
        {Credo.Check.Readability.TrailingWhiteSpace, []},
        {Credo.Check.Readability.UnnecessaryAliasExpansion, []},
        {Credo.Check.Readability.VariableNames, []},
        {Credo.Check.Readability.WithCustomTaggedTuple, false},
        {Credo.Check.Refactor.ABCSize, false},
        {Credo.Check.Refactor.AppendSingleItem, []},
        {Credo.Check.Refactor.CondStatements, []},
        {Credo.Check.Refactor.CyclomaticComplexity, []},
        {Credo.Check.Refactor.DoubleBooleanNegation, []},
        {Credo.Check.Refactor.FunctionArity, []},
        {Credo.Check.Refactor.LongQuoteBlocks, []},
        {Credo.Check.Refactor.MapInto, false},
        {Credo.Check.Refactor.MatchInCondition, []},
        {Credo.Check.Refactor.ModuleDependencies, false},
        {Credo.Check.Refactor.NegatedConditionsInUnless, []},
        {Credo.Check.Refactor.NegatedConditionsWithElse, []},
        {Credo.Check.Refactor.NegatedIsNil, false},
        {Credo.Check.Refactor.Nesting, []},
        {Credo.Check.Refactor.PipeChainStart, []},
        {Credo.Check.Refactor.UnlessWithElse, false},
        {Credo.Check.Refactor.VariableRebinding, []},
        {Credo.Check.Refactor.WithClauses, false},
        {Credo.Check.Warning.BoolOperationOnSameValues, []},
        {Credo.Check.Warning.ExpensiveEmptyEnumCheck, []},
        {Credo.Check.Warning.IExPry, []},
        {Credo.Check.Warning.IoInspect, []},
        {Credo.Check.Warning.LazyLogging, false},
        {Credo.Check.Warning.LeakyEnvironment, false},
        {Credo.Check.Warning.MapGetUnsafePass, []},
        {Credo.Check.Warning.OperationOnSameValues, []},
        {Credo.Check.Warning.OperationWithConstantResult, []},
        {Credo.Check.Warning.RaiseInsideRescue, []},
        {Credo.Check.Warning.UnsafeExec, []},
        {Credo.Check.Warning.UnsafeToAtom, []},
        {Credo.Check.Warning.UnusedEnumOperation, []},
        {Credo.Check.Warning.UnusedFileOperation, []},
        {Credo.Check.Warning.UnusedKeywordOperation, []},
        {Credo.Check.Warning.UnusedListOperation, []},
        {Credo.Check.Warning.UnusedPathOperation, []},
        {Credo.Check.Warning.UnusedRegexOperation, []},
        {Credo.Check.Warning.UnusedStringOperation, []},
        {Credo.Check.Warning.UnusedTupleOperation, []}
      ]
    }
  ]
}
