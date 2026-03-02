# ai-commit

AI-powered git commit message generator using Claude. Analyzes your staged changes and generates a conventional commit message via the Anthropic Claude API.

## Requirements

- `bash`, `git`, `curl`, `jq`
- Anthropic API key → [console.anthropic.com](https://console.anthropic.com)

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/byrmff/ai-commit/refs/heads/main/install.sh | sudo bash
```

Then add your API key:

```bash
# system-wide
sudo nano /etc/ai-commit/config

# or per-user (overrides system config)
mkdir -p ~/.config/ai-commit
echo 'ANTHROPIC_API_KEY="sk-ant-..."' > ~/.config/ai-commit/config
```

## Usage

```bash
git add .
ai-commit
```

You'll see a suggested commit message and can confirm, edit, or abort.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `ANTHROPIC_API_KEY` | *(required)* | Your Anthropic API key |
| `CLAUDE_MODEL` | `claude-haiku-4-5-20251001` | Claude model to use |
| `MAX_TOKENS` | `256` | Max tokens in response |

Config is loaded from `/etc/ai-commit/config`, overridden by `~/.config/ai-commit/config`.

## Install specific version

```bash
curl -fsSL https://raw.githubusercontent.com/byrmff/ai-commit/refs/heads/main/install.sh | sudo bash -s v1.0.0
```

## Uninstall

```bash
sudo rm /usr/local/bin/ai-commit
sudo rm -rf /etc/ai-commit
```

## License

MIT
