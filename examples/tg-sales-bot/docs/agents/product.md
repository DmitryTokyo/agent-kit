# Product

What the product does for whom, and where behaviour is checked.

## Behaviour spec

`docs/bot-design.md` — bot screens, buttons and texts. It is changed before the handlers.

## Actors

- Покупатель (`Buyer`, `Customer` in the models) — picks a Product, pays in Telegram, gets the Order at a Pickup Point.
- продавец (seller) — runs the catalog and Orders in the Django admin.

The skills say «an actor» and mean these.

## Checks

- A check is written as `<screen> → <action> → <expected result>`.
- Only a manual check shows what the real Telegram chat renders (struck-through text, a changed photo), the real age of
  a message, a real payment, the Django admin.
- E2E: the `buyer` fixture plays the Покупатель through the real aiogram dispatcher; only Telegram is replaced.
