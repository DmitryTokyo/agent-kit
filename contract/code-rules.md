# Code rules

How code is written in this project. `/{{p}}-develop`, the TDD subagents and `/{{p}}-code-review` read this file in
full. Pack sections sit between `<!-- pack:NAME -->` markers and come from `agent-kit/packs/`; edit them there and
pull through `sync`. Everything else is the project's own.

## Layers

<!-- fill: the layers and what each may and may not do, with the forbidden placements and where the code goes
instead. Name the layer a plan uses for «where new code lives». -->

## Where code goes

<!-- fill: the layout inside a module or app, as a tree, and what is created only on first need. -->

## Ticket slicing

<!-- fill: how this architecture splits into commit-sized tickets, e.g. «a domain service and the screen that uses it
are separate tickets». «none» when the defaults of `/{{p}}-to-tickets` are enough. -->

## Code quality

<!-- fill: project rules on top of the packs. -->
