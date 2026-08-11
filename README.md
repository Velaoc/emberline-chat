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
- **Send a message and stream a reply** — User posts a message; the app appends it, calls the provider adapter, and streams the assistant reply back chunk by chunk; full reply is persisted.
- **Browse past conversations** — Sidebar lists the user's conversations; opening one shows the full message history.
- **Rename or delete a conversation** — Owner edits the title or removes the conversation and its messages.

## Core entities

- User
- Conversation
- Message

## Run locally

```bash
bundle install
bin/rails db:prepare
bin/dev
```

Requires Ruby, PostgreSQL, and the usual Rails toolchain. See `bin/setup` if present.

## Demo

Demo user with two sample conversations: one greeting exchange with a canned assistant reply, one with a longer multi-paragraph reply demonstrating streaming and formatting.

## Deploy notes

Production `config.hosts` is derived from `domain` in `config/foundation.yml`. Keep that value aligned with the real host or every request will 403.
