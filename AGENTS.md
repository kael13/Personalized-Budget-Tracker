# Project Context

## Architecture
- **Flutter app (iOS/mobile)** — calls OpenRouter API directly from device. No server dependency.
- **React web app** — calls Express server proxy (`server.ts`) which forwards to OpenRouter.
- **Database** — SQLite via `sqflite`, managed by `DatabaseHelper`.

## LLM / OpenRouter

### Models
- Primary: `openai/gpt-oss-120b:free`
- Fallback: `google/gemma-4-31b-it:free`

### API Keys
- Flutter: hardcoded in `flutter/lib/services/api_config.dart`
- Server: `process.env.OPENROUTER_API_KEY` (loaded via `dotenv`)

### Prompt
- Asks for a short budget summary in Taglish (Tagalog + English)
- Fun, supportive, "girly pop" tone
- Returns plain text (no JSON, no markdown, no lists)

### Response Format
- Flutter `openrouter_service.dart`: returns raw string → `ai_recommendations.dart` stores as `_summary` (single `String?`)
- Server `server.ts`: returns `{ summary: "..." }` → React `AIRecommendations.tsx` stores as `summary` (single `string | null`)

## Fallback Logic
- Flutter `openrouter_service.dart`: `getRecommendations` tries primary model, on exception tries fallback, on second exception rethrows
- Server `server.ts`: same pattern in `/api/analyze-spending`

## Data Flow (Save)
`BudgetModal (_handleSave)` → `widget.onSave(budget)` → `home_screen: appState.saveBudget(budget)` → `app_state: DatabaseHelper.instance.saveBudget(budget)` → SQLite

## Animations
- Library: `flutter_animate` (^4.5.0)
- No Lottie/Rive — all visual flair is emoji-based
- Sticker packs: use PNG/WebP assets under `assets/stickers/`, animated with `flutter_animate` (fadeIn, fadeOut, slideX, slideY, scale, etc.)

## Key Files
| Path | Purpose |
|------|---------|
| `flutter/lib/services/api_config.dart` | API key, base URL, model constants |
| `flutter/lib/services/openrouter_service.dart` | LLM client (primary + fallback) |
| `flutter/lib/widgets/ai_recommendations.dart` | Flutter UI for LLM summary + rule-based fallback |
| `flutter/lib/dialogs/budget_modal.dart` | Create/edit budget modal (3-step) |
| `flutter/lib/screens/home_screen.dart` | Main screen with dashboard/analytics/calculator tabs |
| `flutter/lib/providers/app_state.dart` | State management + DB operations |
| `server.ts` | Express proxy for React web app |
| `src/components/AIRecommendations.tsx` | React UI for LLM summary |
