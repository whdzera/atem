## Ruby Discord & Telegram Bot Boilerplate

A boilerplate project for running Discord and Telegram bots together in a single Ruby application.
Perfect starting point if you want a clean structure, environment setup, and testing out of the box.

## Structure

<pre>
├── app/ # Bot logic (Discord, Telegram, controllers)
├── bin/ # Executable entry point scripts
├── config/ # Configuration, including example .env
├── spec/ # RSpec test suite
├── Gemfile # Project dependencies
├── Rakefile # Build/test/automation tasks
├── .rubocop.yml # Code linting rules
</pre>

## Setup

#### 1. Clone the repo

```
git clone https://github.com/spellbooks/ruby-discord-telegram-bot-boilerplate.git
cd ruby-discord-telegram-bot-boilerplate
```

#### 2. Install dependencies

```
bundle install
```

#### 3. Copy .env file

```
cp config/.env.example .env
```

#### 4. Configure environment variables

Edit .env and set your credentials:

`TOKEN_DISCORD`, `CLIENT_ID_DISCORD`

`TOKEN_TELEGRAM`

`SERVER_ID_DISCORD` (optional, for Discord dev testing)

#### 5. Run Bot

```
./bin/START
```

#### 6. Single Run Bot

```
rake discord
```

or

```
rake telegram
```

## Unit Test

RSpec is preconfigured in the spec/ directory. Run tests with:

```
bundle exec rspec
```

## Summary

| Purpose            | Details                                          |
| ------------------ | ------------------------------------------------ |
| Quick start        | Ready-to-use project structure with `.env` setup |
| Modular & testable | Commands separated, testable with RSpec          |
| Scalable           | Easy to add new commands and integrations        |
