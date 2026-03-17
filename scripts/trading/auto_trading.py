"""
Dominion AI - Autonomous Trading Bot
AuraLift Essentials automated trading script.
"""

import logging
import os

import alpaca_trade_api as tradeapi

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)


def main():
    logger.info("Dominion AI trading bot started.")

    api_key = os.environ.get("ALPACA_API_KEY")
    api_secret = os.environ.get("ALPACA_API_SECRET")

    if not api_key or not api_secret:
        logger.warning("ALPACA_API_KEY and ALPACA_API_SECRET are not set. Running in dry-run mode.")
        return

    try:
        api = tradeapi.REST(api_key, api_secret, base_url="https://paper-api.alpaca.markets")
        account = api.get_account()
        logger.info("Account status: %s", account.status)
        logger.info("Portfolio value: %s", account.portfolio_value)
    except Exception as exc:
        logger.error("Trading bot error: %s", exc)
        raise


if __name__ == "__main__":
    main()
