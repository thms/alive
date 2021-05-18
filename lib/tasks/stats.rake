 task stats: 'statsetup'

 task :statsetup do
      require 'rails/code_statistics'

      custom_directories = [
        %w[Abilities app/abilities],
        %w[Ability\ tests test/abilities],
        %w[Modifiers app/abilities/modifiers],
        %w[Modifier\ tests test/abilities/modifiers],
        %w[Strategies app/strategies],
        %w[Strategy\ tests test/strategies],
      ]
      STATS_DIRECTORIES.concat(custom_directories)

      custom_test_types = %w[Ability\ tests Modifer\ tests Strategy\ tests]
      CodeStatistics::TEST_TYPES.concat(custom_test_types)
  end
