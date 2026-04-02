# Copilot Instructions for dominion-ai-auralift

## Project Overview

**Dominion AI** is an all-in-one viral ad empire for **AuraLift Essentials** skincare. It integrates Shopify sync, Omega brain, HeyGen videos, ElevenLabs voices, and autonomous social posting. The frontend is built with Lovable (React + Supabase) and kept in sync via GitHub 2-way sync.

## Repository Structure

```
.github/
  workflows/
    vercel-deploy.yml   # CI/CD: deploys to Vercel and runs the trading bot
scripts/
  trading/
    auto_trading.py     # Autonomous Alpaca trading bot (paper trading)
    requirements.txt    # Python dependencies for the trading bot
  setup-org.ps1         # PowerShell script for org setup
package.json            # Node.js project manifest (Vercel deployment)
README.md
```

## Tech Stack

- **Frontend**: React + Supabase (managed via Lovable, synced to this repo)
- **Deployment**: Vercel (deployed via `npm run deploy` using `VERCEL_TOKEN`)
- **Trading bot**: Python 3, Alpaca Trade API (paper trading at `https://paper-api.alpaca.markets`)
- **CI/CD**: GitHub Actions (`.github/workflows/vercel-deploy.yml`)

## Key Workflows

### Deployment
- Triggered on every push to `main`
- Runs `npm install` then `npm run deploy` (Vercel)
- Requires the `VERCEL_TOKEN` secret in the repository

### Trading Bot
- Runs after a successful deploy
- Uses Python 3 and the packages in `scripts/trading/requirements.txt`
- Requires `ALPACA_API_KEY` and `ALPACA_API_SECRET` secrets; falls back to dry-run if absent

## Required Secrets

| Secret | Purpose |
|---|---|
| `VERCEL_TOKEN` | Vercel deployment authentication |
| `ALPACA_API_KEY` | Alpaca trading API key |
| `ALPACA_API_SECRET` | Alpaca trading API secret |

## Development Guidelines

- **Python**: Follow PEP 8. Use `logging` (not `print`) for all output in scripts.
- **Dependencies**: Pin Python package versions with both lower and upper bounds (e.g., `>=x.y,<z.0`).
- **Secrets**: Never hard-code credentials. Always read from environment variables via `os.environ.get(...)`.
- **Error handling**: Wrap external API calls in try/except and re-raise after logging.
- **Workflow actions**: Prefer pinning GitHub Actions to a specific major version (e.g., `@v4`).

## Testing

There is no automated test suite currently in this repository. When adding tests, place them under a `tests/` directory and follow the conventions of the language being tested (pytest for Python, Jest/Vitest for JavaScript/TypeScript).
