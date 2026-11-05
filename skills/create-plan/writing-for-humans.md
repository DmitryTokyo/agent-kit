# Writing plan.md for the developer

The developer reads `plan.md` once and approves it. Each item describes observable behaviour: what an actor does and
sees, what the system sends, stores or refuses. One or two sentences per item, two or three items per section; the
whole plan fits one screen.

One fact lives in one section. `Result` carries before → after only; a behaviour that stays as it is gets no item. A
fact repeated in `Boundaries` or `Checks` is cut there.

Each `Result` item carries:

1. **Before → after.** A new thing is "none → X".
2. **Effect.** What the actor sees, or what the system sends, stores, refuses.
3. **Fact behind it.** Only when the effect alone looks arbitrary: one clause inside the same sentence.

Each `Criteria` item is a `- [ ]` condition a reviewer confirms in the diff or a run: "the checkout screen shows the
pickup point", not "the code is clean".

Each `Checks` item is a consequence the change can break and how it is checked: `condition → expected result ·
test: new`. A behaviour that stays as it is gets a check only when the change shares its code path.

A code name is a label beside its meaning: "`pickup_point_id` — the field the order already stores".

Domain words come from `CONTEXT.md`. Rejected alternatives stay out of the plan; they belong in `research.md`.

## Example

- Result: pickup point at checkout: none → the buyer picks one on the map before paying.
- Checks: no pickup point chosen → the pay button stays disabled · test: new.

## Check

Each item passes when:

- it still reads with every code name removed;
- before → after is stated (`Result`), or condition → expected result and how it is checked (`Checks`);
- it fits in two sentences;
- its fact appears in no other section;
- it names no rejected alternative.

Done when every item passes.
