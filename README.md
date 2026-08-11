<!-- foundation:identity -->
# Emberline Chat

ChatGPT-style chat app: users sign in, start conversations, send messages, and see assistant replies stream back through a pluggable AI provider adapter.

- Site: https://emberline-chat.api.holode.xyz
- Support: support@emberline-chat.api.holode.xyz
<!-- /foundation:identity -->

## What this is

ChatGPT-style chat app: users sign in, start conversations, send messages, and see assistant replies stream back through a pluggable AI provider adapter.

## Who it is for

- User (signed-in account owner)
- Admin (viewer of app health, no per-user data access)

## Main features

- **Sign in and start a conversation** — Authenticate (password + optional OAuth), then create a new conversation with an auto title.
- **Send a message and stream a reply** — User posts a message; the app appends it, calls the provider adapter, and streams the assistant reply back chunk by chunk; the full reply is persisted.
- **Browse past conversations** — Sidebar lists the user's conversations; opening one shows the full message history.
- **Delete a conversation** — Owner removes a conversation and all its messages.

## AI provider

The app talks to the model through a single adapter (`app/services/ai/provider.rb`).
Two implementations ship:

- **Demo** (default) — canned replies, zero keys, works offline. Replies stream
  in word-sized chunks so the UI is exercised for real.
- **OpenAI-compatible** — streams from any OpenAI-compatible chat completions
  endpoint (OpenAI, DeepSeek, OpenRouter, Together, local vLLM/Ollama, …).

Switching is one config change plus one environment variable:

```bash
# config/foundation.yml
ai:
  provider: "openai_compatible"
  openai_compatible:
    base_url: "https://api.openai.com/v1"
    model: "gpt-4o-mini"

# environment (never commit the key)
export AI_API_KEY=sk-...
```

`AI_BASE_URL` and `AI_MODEL` env vars override the foundation.yml block if set.
Without a key the live provider fails loudly with a clear message — it never
silently falls back to canned text.

## Core entities

- User
- Conversation
- Message

## Run locally

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed   # optional: demo account + sample conversations
bin/dev
```

Requires Ruby, PostgreSQL, and the usual Rails toolchain. See `bin/setup` if present.

Demo login (seeded): `demo@emberline.chat` / `demo-password-123`.

## Deploy notes

Production `config.hosts` is derived from `domain` in `config/foundation.yml`. Keep that value aligned with the real host or every request will 403.
