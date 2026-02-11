# QBot Code Style Audit & Improvement Plan

## Current Code Style

QBot is a ~4,600-line Ruby Discord bot (74 `.rb` files) built on `discordrb`,
using ActiveRecord/SQLite for persistence and a modular command architecture.
The codebase has a distinctive style—modern Ruby with FP leanings—combined with
areas that have grown organically and now conflict with the project's
modernization goals (see `.github/copilot-instructions.md`).

### Strengths

- **Modern Ruby idioms used well.** `Data.define` for value objects
  (`ColorLib::SRGBColor`, `ArchWiki::PageInfo`), pattern matching
  (`pkg => {repo:, name:, ...}`), endless methods (`def self.comic_url(info) =`),
  anonymous block forwarding (`&`), and argument forwarding (`...`) are used
  naturally throughout.
- **Elegant, functional domain objects.** `ColorLib` is a standout: clean
  colorspace conversion chains (`SRGBColor → SRGBLinearColor → XYZTristimulus →
  CIELABColor`) with `to_ary` destructuring, `Data.define` immutability, and
  mathematically correct implementations. This is a good model for the rest of
  the codebase.
- **Well-designed config DSL.** The `Configurable` concern with
  `extend_schema`, `SchemaBuilder`, typed `Option`/`ColumnOption` classes, and
  `OptionTypes` (with `TString`, `TInteger`, `TEnum`, `TSnowflake`, etc.) is
  extensible and cleanly separated. The `build` DSL block, abbreviation-based
  lookups, and hook system (`on_load`, `on_save`) show good design instincts.
- **Thorough i18n.** All user-facing strings use the `t()` helper with
  locale files in `share/locales/`. Multiple locales are supported, including
  a Toki Pona translation.
- **Event container separation.** Modules like `Colors`/`ColorsEvents` and
  `Polls`/`PollsEvents` correctly separate command definitions from Discord
  event handlers.
- **Clean external API wrappers.** `TIO`, `XKCD`, `ArchWiki` each wrap their
  respective APIs with concise, stateless interfaces. `ArchWiki` uses
  `Data.define` for `PageInfo`; `TIO` cleanly encapsulates the binary protocol.
- **RuboCop configured** with sensible, opinionated settings (80-char lines,
  semantic block delimiters, `with_fixed_indentation` alignment).

### Weaknesses

- **Pervasive global namespace pollution.** 16+ methods defined at the Kernel
  level: `embed`, `log`, `t`, `find_prefix`, `cmd_prefix`, `parse_int`,
  `to_emoji`, `to_word`, `after_nth_word`, `load_by_glob`, `unescape`,
  `cmd_target`, `user_response`, `prefixed`, `console_log`, `log_embed`. These
  are callable from anywhere with no visible dependency chain. Testing any of
  them in isolation requires booting or stubbing the entire `QBot` module.
- **Mutable god-object.** `QBot` accumulates eight mutable singleton attrs
  (`bot`, `log`, `config`, `options`, `version`, `worker`, `worker_thread`,
  `scheduler`) set by side effects during boot. Every library file reaches into
  `QBot.config` or `QBot.bot` at will, creating invisible coupling throughout.
- **Monkey-patching as architecture.** `hooks.rb` aliases and overrides
  `Discordrb::Commands::CommandBot#execute_command` to inject locale, logging,
  embed target, and prefix resolution—four orthogonal concerns in one override.
  `patches.rb` reopens `Respondable`, stubs `Rails.logger`/`Rails.env`, and
  prepends `CommandEventIntercept`. These create action-at-a-distance bugs.
- **Top-level constants.** `Modules` (module loader), `XKCD`, `TIO`,
  `ArchWiki`, `XSConverter`, `TPDict`, `SPGen`, `NamedStringIO`,
  `CommandEventIntercept` are all defined outside any namespace.
- **Load-order fragility.** `lib/qbot.rb` is a carefully ordered manifest of
  34 `require_relative` calls. `SchemaBuilder#build` temporarily monkey-patches
  `Object.const_missing` so that schema blocks can reference `TString`,
  `TBoolean`, etc. unqualified. Module files execute `ServerConfig.extend_schema`
  at load time as a side effect.
- **Mixed abstraction levels.** `colors.rb` (353 lines) mixes command
  definitions, two embed presenter classes (`RCEmbed`, `CCREmbed`), role
  management logic, and event handlers. Other modules embed formatting and
  business logic in the same command block.
- **ActiveRecord as infrastructure lock-in.** Database models (`ServerConfig`,
  `UserConfig`, `Note`, `Snippet`, `Query`, etc.) use ActiveRecord with
  `ActiveSupport::Concern` for concerns. The schema is defined both in
  `schema.rb` (used as a seed) and in migrations, with no standard migration
  runner integrated.
- **116 RuboCop offenses** (72 autocorrectable) in actively maintained code.
- **Zero test coverage.** No test framework, no tests, no CI test step.

---

## Target Code Style

The target retains and extends the codebase's existing strengths—modern Ruby,
FP-leaning design, elegant personal style—while introducing the structure
needed for testability, maintainability, and the planned `dry-rb`/`rom-rb`
migration.

### Guiding principles

1. **Functional where possible.** Prefer immutable data (`Data.define`,
   `dry-struct`), pure functions, and value objects. Minimize mutable state.
   When mutation is necessary, contain it behind clear interfaces.
2. **Explicit dependencies everywhere.** Every component declares what it
   needs (via `include`, injection, or constructor args). No reaching into
   global singletons. Each file should be understandable from its own
   `require`/`include` lines.
3. **No Kernel-level methods.** All helpers live in modules,
   included/extended where needed. Global `def` at the top-level is never
   appropriate.
4. **Single responsibility per file.** Command modules define commands;
   business logic lives in service/domain objects; embeds are formatting
   concerns. A file that needs a `Metrics/ModuleLength` disable comment is
   too large.
5. **Testable in isolation.** Anything that doesn't directly touch Discord
   should be testable with no boot process. Domain objects, config parsing,
   color math, embed formatting—all should have unit tests that run in
   milliseconds.
6. **Minimal monkey-patching.** Where upstream APIs are insufficient, prefer
   `prepend` with a named, documented module. Never reopen a class just to
   inject unrelated concerns.
7. **Consistent RuboCop compliance.** Zero offenses on
   `bundle exec rubocop --parallel`. Disable cops only with justification.
8. **Elegant, not over-engineered.** This is a ~5k-line bot, not a Rails
   monolith. Abstractions should earn their keep. A well-named module with
   three methods is often better than a class hierarchy.

### Target architecture (from copilot-instructions.md)

- **Dependency injection** via `dry-system` / `dry-auto_inject` for component
  management.
- **Database** via `rom-rb` replacing ActiveRecord.
- **Slash commands** replacing text-prefix commands.
- **Discord Components v2** replacing embeds for interactive UI.
- Other `dry-rb` / `rom-rb` ecosystem libraries adopted where appropriate.

---

## Improvement Tasks

Ordered from quickest/lowest-risk to most architectural. Each tier builds on
the previous; earlier tiers should generally be completed first.

### Tier 1 — Quick wins (minimal risk, immediate value)

- [ ] **Auto-fix RuboCop offenses.** `rubocop -A` resolves 72 of the 116
  current offenses (redundant line continuations, trailing whitespace, block
  style, `each_value`, frozen string literals). Review the diff and commit.
- [ ] **Add a test framework.** Add `minitest` (stdlib, zero deps) to the
  Gemfile `:development` group. Create `test/test_helper.rb` and a `rake test`
  task. Write initial tests for pure functions: `parse_int`, `to_emoji`,
  `to_word`, `after_nth_word`, `ColorLib` conversion roundtrips,
  `XSConverter.convert`.
- [ ] **Add missing doc comments.** RuboCop flags ~10 undocumented
  modules/classes (`ARConfig`, migration classes, `TestJob`, `PollsEvents`,
  `TioEvents`, `ColorsEvents`, `QBot::Database` reopenings). Add brief `##`
  comments.
- [ ] **Remove dead code.** `lib/qbot/aur.rb` is a single orphaned URL
  string with no consumers. `modules/fun.rb` is an empty module stub (`# :(`).
  Remove both (or replace with explicit TODOs if they represent planned work).
- [ ] **CI: add a test step.** Extend `.github/workflows/lint.yml` or add a
  `test.yml` to run the test suite on PRs.

### Tier 2 — Structural cleanup (low risk, high readability impact)

- [ ] **Move Kernel helpers into a `QBot::Helpers` module.** Collect `embed`,
  `log`, `t`, `parse_int`, `to_emoji`, `to_word`, `after_nth_word`,
  `prefixed`, `cmd_target`, `unescape`, `user_response`, `console_log`,
  `log_embed` into a module. Use `module_function` or `extend self` so they
  can also be called as `QBot::Helpers.parse_int(...)`. Include the module
  into `Discordrb::Commands::CommandContainer` so command blocks retain
  implicit access.
- [ ] **Namespace all top-level constants under `QBot`.** `Modules` →
  `QBot::Modules`, `XKCD` → `QBot::XKCD`, `TIO` → `QBot::TIO`, etc. This
  eliminates collision risk and makes the codebase grep-friendly.
- [ ] **Move `find_prefix`/`cmd_prefix` into `QBot`.** These are only used
  by `init.rb` and `hooks.rb`.
- [ ] **Move `load_by_glob` into `QBot::Database`.** Only used for loading
  concerns and models.
- [ ] **Split `colors.rb`.** It's 353 lines mixing command definitions, two
  embed classes (`RCEmbed`, `CCREmbed`), and event handlers. Split into
  `colors/commands.rb`, `colors/embeds.rb`, `colors/events.rb`. The existing
  `colors/wrapped_color_role.rb` is a good model for this split.
- [ ] **Extract embed formatting.** In `arch.rb`, `colors.rb`, `queries.rb`,
  embed-building logic (field layout, truncation, color) is mixed with
  business logic. Extract presenter methods/modules (e.g.,
  `ArchPresenter.package_embed(pkg)`) that return embed hashes. Command
  blocks call the presenter and pass the result to `embed`.

### Tier 3 — Moderate refactors (prerequisite for Tier 4)

- [ ] **Replace the `QBot` god-object with a `dry-system` container.** This
  is the keystone change. Instead of `QBot.bot`, `QBot.log`,
  `QBot.config`, etc. as mutable singleton attrs, register components in a
  `dry-system` container. Dependencies are resolved via `dry-auto_inject`.
  This directly aligns with the target architecture in
  `copilot-instructions.md`.

  ```ruby
  # lib/qbot/container.rb
  class QBot::Container < Dry::System::Container
    configure do |config|
      config.root = Pathname(__dir__).join('../..')
    end

    register(:config) { QBot::GlobalConfig.read_from_file(...) }
    register(:logger) { Discordrb::Logger.new(true) }
  end

  QBot::Import = QBot::Container.injector
  ```

- [ ] **Replace monkey-patches with explicit wrappers.** Factor the four
  concerns in `hooks.rb`'s `execute_command` override (locale, logging,
  embed target, prefix) into a named `prepend` module or, better, a
  middleware chain. Replace the `Rails.logger`/`Rails.env` stubs with
  direct `ActiveRecord` configuration.
- [ ] **Adopt `dry-struct` or `Data.define` for typed configuration.**
  Replace the JSI-based `GlobalConfig` with value objects. The current JSI
  approach works but is opaque to tooling and pattern matching. `Data.define`
  is already used well elsewhere in the codebase (`ColorLib`, `ArchWiki`);
  extend that pattern to config.
- [ ] **Extract service objects for complex operations.**
  `Colors.create_color_roles` does role deletion, cache invalidation, color
  ring generation, role creation, and progress reporting in one method.
  Extract a `ColorRoleGenerator` service that takes dependencies explicitly.
- [ ] **Formalize module loading.** The current `load` + `constantize` +
  `include!` pipeline with file-scope side effects
  (`ServerConfig.extend_schema`) is fragile. Consider a registration DSL or
  module manifest that declares dependencies and config extensions explicitly.

### Tier 4 — Architectural (high effort, high reward)

- [ ] **Migrate to `rom-rb` for persistence.** Replace ActiveRecord models
  with `rom-rb` repositories/relations/changesets. This aligns with the
  target architecture and naturally separates persistence from domain logic.
  Start with a single model (e.g., `Note`) as a proof of concept.
- [ ] **Event-driven hook architecture.** Replace the monkey-patched
  `execute_command` override with a proper event bus (`dry-events` or
  `wisper`). Locale setting, logging, embed targeting, and prefix resolution
  become independent subscribers. New cross-cutting concerns can be added
  without touching the hook.
- [ ] **Migrate to slash commands.** The `discordrb` text-command API is
  deprecated upstream. Plan and execute a migration to Discord's interaction
  API (slash commands, autocomplete, modals). This is a large effort but
  necessary for long-term viability.
- [ ] **Adopt Discord Components v2.** Where interactive UI is needed
  (polls, color selection, config), use Components v2 (buttons, selects,
  modals) instead of reaction-based interactions and plain embeds.
- [ ] **Comprehensive test suite with mocked Discord.** Test command handlers
  end-to-end using a test double for `CommandBot`. Test the config DSL, the
  `Configurable` concern, the module loading lifecycle, and `rom-rb`
  repositories.
- [ ] **Standardize database migrations.** The current `schema.rb` is used
  as a seed (`define_schema`), and migrations exist but aren't integrated
  into a standard workflow. With `rom-rb`, adopt its migration system; or
  if staying with ActiveRecord temporarily, integrate
  `standalone_migrations` for a proper `db:migrate` flow.

---

## Priorities

If time is limited, the highest-leverage changes in order:

1. **RuboCop autofix + test framework** (Tier 1) — establishes a quality
   baseline and makes future changes verifiable.
2. **Move Kernel helpers into `QBot::Helpers`** (Tier 2) — single biggest
   structural improvement. Eliminates global namespace pollution, makes
   dependencies visible, enables testing helpers in isolation.
3. **`dry-system` container** (Tier 3) — the keystone. Replaces the mutable
   god-object with explicit dependency injection, directly enabling the
   `rom-rb` migration and unlocking testability for everything else.
4. **`rom-rb` proof of concept** (Tier 4) — validates the target
   architecture with a single model before committing to a full migration.
