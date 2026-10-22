# Hygiene checklist

What `/ag-hygiene-review` scans for in changed files: what the linters and the type checker miss. One rule per
heading: the condition, then the line to report. Pack sections sit between `<!-- pack:NAME -->` markers.

## Channel leak into domain apps (ADR-0007)
Domain apps: tg_sales_bot/{catalog,customers,orders,payments,delivery,core}/.
- An `aiogram` import, or a button text / keyboard built in a domain app → report:
  "CHANNEL LEAK: <file>:<line> — domain code must not know the Channel; move to tg_sales_bot/bot/"
- A business rule (a decision about Cart, Order, Consent, prices, availability) inside
  tg_sales_bot/bot/handlers/ or tg_sales_bot/bot/services/ → report:
  "RULE IN ADAPTER: <file>:<line> — move the decision into a domain service, keep screen building in bot/"

<!-- pack:python -->
<!-- /pack:python -->

<!-- pack:django -->
<!-- /pack:django -->
