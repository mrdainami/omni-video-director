# Costs (billed actuals — update as you run)

kie bills on **submit** (a failed job is refunded). The exact number always prints as
`creditsConsumed`; these are real values we've measured.

| Model | Setting | Billed | Notes |
|---|---|---|---|
| `gemini-omni-video` | 720p · 4s window | **168 credits** | measured 2026-07-08 (probe). 1080p/4k cost more. |
| `gpt-image-2` | 2K still | ~6–10 credits | from the Dainami still recipe |

Rule: on a new model/resolution, run ONE cheapest probe (Omni: 720p/4s) and read
`creditsConsumed` before batching. Convert credits→$ from https://kie.ai/pricing.
