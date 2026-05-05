# kbot
A simple Telegram bot built with Go, Cobra CLI, and Telebot library. Handles user messages and commands.

## Bot Link
https://t.me/SanaHappyMiBot

## Features 

- Handles text messages
- Supports basic commands (/start)
- Built with CLI interface using Cobra
- Uses Telegram Bot API via Telebot
- Cross-platform build support
- Dockerized deployment ready


## Project Structure
```text
.
├── cmd/                  # the main command implementations
│   ├── kbot.go           # bot logic implementation 
│   ├── root.go           # root command configuration
│   ├── version.go        # version command 
├── main.go               # entry point
├── Makefile              # build automation
├── Dockerfile            # container build
├── .env.example          # environment template
└── .gitignore

```

## Prerequisites

- Go >=1.16 
- A Telegram bot token (from [@BotFather](https://t.me/BotFather) set as TELE_TOKEN environment variable
- Required Go packages:
  - github.com/spf13/cobra
  - gopkg.in/telebot.v4



## Setup

### 1. Clone the repository:
```bash
git clone https://github.com/lutska/kbot.git
cd kbot
```

### 2. Install dependencies
```bash
go mod tidy
```

### 3. Set up your Telegram Bot Token:
```bash
read -s TELE_TOKEN
```
paste your bot token 
```
export TELE_TOKEN
```

### 4. Build the application and set the appVersion value (ex. v1.0.0):
```bash
go build -ldflags "-X="github.com/lutska/kbot/cmd.appVersion=<VERSION>
```

## Usage

### Start the bot:

```bash
./kbot start
```
### Telegram interaction

**User:**
```text
/start hello
```
**Bot:**
```text
Hi there I'm Kbot v 1.0.1
```
---
**User:**
```text
any other message
```
**Bot:**
```text
I am still learning, please get back later
```

### Available Commands

- `/start hello` - Get a greeting from the bot with current version number


## License

This project is licensed under the MIT License - see the LICENSE file for details.
