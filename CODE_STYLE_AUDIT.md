# QBot Code Style Audit & Improvement Plan

## Current Code Style

QBot is a ~4,600-line Ruby Discord bot (74 `.rb` files) built on `discordrb`, using
ActiveRecord for persistence and a modular command architecture. The codebase has a
distinctive style that combines some strong patterns with areas that have grown
organically.

### What works well

- **Consistent `frozen_string_literal` pragmas** across all files.
- **Good use of modern Ruby idioms**: `Data.define` for value objects (`ColorLib`),
  pattern matching (`pkg => {repo:, name:, ...}`), endless methods, anonymous block
  forwarding (`&`), argument forwarding (`...`).
- **Clean DSL for config schema**: The `Configurable` concern with `extend_schema`,
  `SchemaBuilder`, typed `Option`/`ColumnOption` classes, and `OptionTypes` is
  well-designed and extensible.
- **I18n throughout**: All user-facing strings use the `t()` helper with locale files.
- **Separation of event containers**: Modules like `Colors`/`ColorsEvents` and
  `Polls`/`PollsEvents` correctly separate command definitions from event handlers.
- **Well-structured domain objects**: `ColorLib` has clean colorspace conversion chains
  (`SRGBColor → SRGBLinearColor → XYZTristimulus → CIELABColor`) with proper
  mathematical implementations.
- **RuboCop configured** with sensible settings (80-char lines, semantic block
  delimiters, consistent indentation).

### What needs attention

- **Global namespace pollution**: 16+ methods defined at the Kernel level (`embed`,
  `log`, `t`, `find_prefix`, `cmd_prefix`, `parse_int`, `to_emoji`, `after_nth_word`,
  `load_by_glob`, etc.). These are callable from everywhere, making dependencies
  invisible and testing difficult.
- **Monkey-patching**: `patches.rb` reopens `Discordrb::Commands::CommandBot`,
  `Discordrb::Events::Respondable`, `Discordrb::Commands::Command`, and even stubs
  `Rails.env`. `hooks.rb` aliases and overrides `execute_command`. These create
  invisible coupling.
- **Top-level `Modules` constant**: Not namespaced under `QBot`, risks collision.
- **God-object pattern**: `QBot` module accumulates class-level mutable state (`bot`,
  `log`, `config`, `options`, `version`, `worker`, `worker_thread`, `scheduler`) via
  `attr_accessor` on the singleton class, all set by side effects during boot.
- **116 RuboCop offenses** (72 autocorrectable), many in actively maintained code.
- **Zero test coverage**: No test framework configured, no tests exist.
- **Load-order coupling**: Files rely on being required in a specific order
  (`lib/qbot.rb` is a carefully ordered manifest). The `SchemaBuilder#build` method
  temporarily monkey-patches `Object.const_missing` during schema definition blocks.
- **Mixed abstraction levels**: `colors.rb` (353 lines) mixes UI embed formatting,
  Discord API calls, role management logic, and event handlers in one file.

---

## Target Code Style

The ideal style retains the bot's current strengths—clean Ruby idioms, good i18n,
typed config DSL—while adding clear boundaries, testability, and maintainability.
The goal is **not** to turn this into a Rails app or to over-abstract a ~5k-line bot,
but to make each piece independently understandable and testable.

### Guiding principles

1. **No Kernel-level methods.** All helpers live in modules, included/extended where
   needed.
2. **Explicit dependencies.** Each file can be understood (and tested) by reading its
   `require` / `include` lines.
3. **Single responsibility per file.** Command modules define commands; business logic
   lives in service/domain objects; embeds are formatting concerns.
4. **Testable pure functions.** Anything that doesn't touch Discord or the database
   should be testable in isolation with no boot process.
5. **Minimal monkey-patching.** Where upstream APIs are insufficient, prefer wrapper
   objects or `prepend` with clear documentation.
6. **Consistent RuboCop compliance.** Zero offenses on `bundle exec rubocop`.

---

## Improvement Tasks

Ordered roughly from quickest/lowest-risk to most architectural.

### Tier 1 — Trivial (minimal risk, immediate value)

- [ ] **Auto-fix RuboCop offenses.** Run `rubocop -A` to resolve the 72
  autocorrectable offenses (redundant line continuations, trailing whitespace, block
  style, `each_value`, frozen string literals). Review the diff, commit.
- [ ] **Add a test framework.** Add `minitest` (stdlib, zero deps) or `rspec` to the
  Gemfile `:development` group. Create `test/test_helper.rb`. Add a `rake test` task.
  Write initial tests for pure functions: `parse_int`, `to_emoji`, `to_word`,
  `after_nth_word`, `ColorLib` roundtrips, `XSConverter.convert`.
- [ ] **Add missing doc comments.** RuboCop flags ~10 undocumented modules/classes
  (`ARConfig`, migration classes, `TestJob`, `PollsEvents`, `TioEvents`,
  `ColorsEvents`, `QBot::Database` reopenings). Add brief `##` comments.
- [ ] **Delete dead code.** `lib/qbot/aur.rb` is a single orphaned string literal.
  `fun.rb` is an empty module. Remove or mark as stubs explicitly.
- [ ] **CI: add a test step.** Extend `.github/workflows/lint.yml` (or add
  `test.yml`) to run the test suite on PRs.

### Tier 2 — Low-risk structural cleanup

- [ ] **Move Kernel helpers into a `QBot::Helpers` module.** Create
  `lib/qbot/helpers.rb` as a module with `module_function` or `extend self`. Include
  it into `Discordrb::Commands::CommandContainer` so command blocks still have access.
  This makes `embed`, `log`, `t`, `parse_int`, `to_emoji`, etc. explicit dependencies.
- [ ] **Namespace `Modules` under `QBot`.** Rename to `QBot::Modules` to avoid
  polluting the top-level namespace.
- [ ] **Move `find_prefix`/`cmd_prefix` into `QBot`.** These are only used during bot
  init and the hook override.
- [ ] **Move `load_by_glob` into `QBot::Database`.** Only used for loading
  concerns/models.
- [ ] **Extract embed formatting.** In modules like `arch.rb`, `colors.rb`,
  `queries.rb`, the embed-building logic (field layout, truncation, formatting) is
  mixed with business logic. Extract `*_embed` methods into companion modules or a
  simple presenter pattern (e.g., `ArchEmbed.package(pkg)` → returns embed hash).
- [ ] **Reduce `colors.rb` size.** It's 353 lines mixing command definitions, embed
  classes (`RCEmbed`, `CCREmbed`), role management (`ColorRole`—already extracted),
  and event handlers. Split into `colors/commands.rb`, `colors/embeds.rb`,
  `colors/events.rb`.

### Tier 3 — Moderate refactors

- [ ] **Replace `QBot` god-object state with an application container.** Instead of
  `QBot.bot`, `QBot.log`, `QBot.config` as mutable singleton attrs, create a
  `QBot::Application` instance that holds these. Pass it through initialization. This
  removes hidden global state and makes testing possible without boot.
  ```ruby
  class QBot::Application
    attr_reader :bot, :log, :config, :scheduler
    def initialize(config_path:, state_dir:, ...)
      @config = GlobalConfig.read_from_file(config_path)
      @log = Discordrb::Logger.new(true)
      # ...
    end
  end
  ```
- [ ] **Replace monkey-patches with explicit wrappers.** Instead of reopening
  `CommandBot#execute_command` in `hooks.rb`, use `prepend` with a named module (or
  better, register hooks via discordrb's built-in event system). Instead of the
  `Rails.env` stub, use `ActiveRecord` configuration directly.
- [ ] **Typed configuration with dry-struct or Data classes.** Replace the JSI-based
  `GlobalConfig` with `Data.define` or `dry-struct` value objects for type safety and
  pattern matching. The current JSI approach works but is opaque.
- [ ] **Extract service objects for complex operations.** `Colors.create_color_roles`
  does role deletion, cache invalidation, color generation, role creation, and
  progress reporting in one method. Extract a `ColorRoleGenerator` service.
- [ ] **Formalize the module loading contract.** Currently modules are loaded via
  `load` + `constantize` + `include!`, with side effects at file scope (e.g.,
  `ServerConfig.extend_schema` in `admin.rb`). Consider a registration DSL or
  manifest that makes module dependencies explicit.

### Tier 4 — Architectural (higher effort, higher reward)

- [ ] **Adopt `dry-rb` for dependency injection.** Use `dry-container` +
  `dry-auto_inject` to wire dependencies. This eliminates the need for global state
  and makes every component testable in isolation.
  ```ruby
  # Container registration
  QBot::Container.register(:config) { GlobalConfig.read_from_file(...) }
  QBot::Container.register(:logger) { Discordrb::Logger.new(true) }

  # Auto-injection
  class ArchRepos::DBCache
    include QBot::Import[:config, :logger]
  end
  ```
- [ ] **Event-driven architecture.** Replace the current "hooks" (monkey-patching
  `execute_command`) with a proper event bus. `dry-events` or `wisper` would allow
  decoupled before/after command hooks, logging, locale setting, etc.
- [ ] **Database migrations via ActiveRecord proper.** The current `schema.rb` uses
  `define_schema` as a seed, and migrations exist but aren't integrated into a
  standard workflow. Adopt `standalone_migrations` or a lightweight migration runner
  for a standard `db:migrate` flow.
- [ ] **Comprehensive test suite with mocked Discord.** Use a test double for
  `Discordrb::Commands::CommandBot` to test command handlers end-to-end. Test the
  config DSL, the Configurable concern, the full module loading lifecycle.
- [ ] **Consider slash commands.** The `discordrb` text-command API is deprecated
  upstream in favor of Discord's interaction/slash command API. Plan a migration path.

---

## Priorities

If time is limited, the highest-impact changes are:

1. **RuboCop autofix + test framework** (Tier 1) — immediate quality baseline.
2. **Move Kernel helpers into a module** (Tier 2) — biggest single structural win.
3. **Split `colors.rb`** (Tier 2) — demonstrates the target file size/responsibility.
4. **Application container** (Tier 3) — unlocks testability for everything else.
