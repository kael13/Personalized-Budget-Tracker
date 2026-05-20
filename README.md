# 🌸 Budgetarian

> **A beautifully crafted, pastel-themed personal budget tracker built with Flutter.**
> Designed to feel premium, intuitive, and delightful — because managing your money should spark joy, not stress.

---

## ✨ Features

### 💰 Budget Management
- **Create Budget Profiles** — A guided 3-step wizard walks you through naming your budget, setting a total amount, choosing your currency, and defining the consumption timeline.
- **Category & Subcategory Allocations** — Granularly distribute your total budget across custom categories (e.g., Food, Transport, Savings), each with their own nested subcategories.
- **Real-time Validation** — The wizard dynamically tracks remaining unallocated funds as you distribute, preventing over-allocation.

### 🔐 PIN Security
- **Optional PIN Lock** — Protect sensitive budget profiles with a numeric PIN code set during creation.
- **Custom Keypad UI** — A beautifully designed numerical keypad with pastel aesthetics for PIN entry.

### 📊 Visual Analytics
- **Donut Charts** — Interactive `fl_chart` pie/donut visualizations showing category-level breakdowns for each budget.
- **Global Statistics** — Aggregate insights across all budgets: weekly, monthly, quarterly, and yearly summaries.
- **Top Categories Breakdown** — See which spending categories dominate across your entire portfolio.

### 🤖 AI Recommendations
- **Smart Insights Engine** — Analyzes your budget distributions and generates tailored advice:
  - Warns if Food allocations exceed 35% of total budget.
  - Nudges you if Savings fall below 15%.
  - Flags short-timeline budgets that may deplete too quickly.
- **Refresh on Demand** — Tap to regenerate fresh insights with a simulated processing animation.

### 🧮 Calculator Tools
- **Standard Calculator** — Full arithmetic expression parser supporting MDAS (Multiply, Divide, Add, Subtract) order of operations.
- **Royal Ratio Splitter** — Preset budget allocation ratios for quick planning:
  - `50/30/20` — Needs / Wants / Savings
  - `70/20/10` — Essentials / Lifestyle / Savings
  - `80/20` — Living / Savings

### 🎨 Design & UX
- **Pastel Pink Aesthetic** — A cohesive, premium color palette built around soft pinks, corals, and slate tones.
- **Dark Mode** — Full dark theme with carefully tuned slate backgrounds and soft pink accents.
- **Micro-Animations** — Smooth transitions, animated progress bars, and responsive touch feedback powered by `flutter_animate`.
- **Google Fonts** — Typography uses `Outfit` for UI text and `JetBrains Mono` for numerical displays.

### 🗂️ Bulk Operations
- **Multi-Select Mode** — Toggle edit mode to select multiple budget cards for batch deletion.
- **Search & Sort** — Filter budgets by name with real-time search, and toggle sort order between date and amount.

---

## 🏗️ Architecture

```
lib/
├── main.dart                          # App entry point & Material theme config
├── theme/
│   └── app_colors.dart                # Centralized color palette (light + dark)
├── models/
│   └── budget_models.dart             # Data classes: BudgetAllocation, Category, SubCategory
├── services/
│   └── database_helper.dart           # SQLite database (sqflite) with FK cascades
├── providers/
│   └── app_state.dart                 # Global state management via ChangeNotifier
├── screens/
│   ├── home_screen.dart               # Main dashboard with tab navigation
│   ├── analytics_screen.dart          # Global stats, charts, and AI insights
│   └── calculator_screen.dart         # Standard calc + ratio split tools
├── dialogs/
│   ├── budget_modal.dart              # 3-step budget creation wizard
│   ├── detail_sheet.dart              # Bottom sheet with category editor & donut chart
│   └── pin_lock_dialog.dart           # PIN verification keypad
└── widgets/
    ├── budget_card_widget.dart         # Individual budget card with progress bar
    └── ai_recommendations.dart        # Smart insights analysis widget
```

---

## 💾 Database Design

Budgetarian uses **SQLite** via `sqflite` for robust, offline-first data persistence with a normalized relational schema:

| Table | Description | Foreign Key |
|-------|-------------|-------------|
| `budgets` | Top-level budget profiles (name, total, currency, pin, days) | — |
| `categories` | Budget categories with allocated/spent amounts | `budget_id` → `budgets.id` |
| `sub_categories` | Granular subcategory breakdowns | `category_id` → `categories.id` |

- **Foreign Key Cascading**: `ON DELETE CASCADE` ensures deleting a budget automatically removes all associated categories and subcategories.
- **Transaction-Based Saves**: All nested writes use `db.transaction()` for atomic, rollback-safe operations.

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | Reactive state management |
| `sqflite` | Local SQLite database |
| `fl_chart` | Donut/pie chart visualizations |
| `google_fonts` | Outfit & JetBrains Mono typography |
| `flutter_animate` | Smooth micro-animations |
| `intl` | Date/number formatting |
| `shared_preferences` | Lightweight key-value settings |
| `google_generative_ai` | Gemini AI integration (future) |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0+)
- Xcode (for iOS builds)
- iOS Simulator or physical device

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/Personalized-Budget-Tracker.git

# Navigate to the Flutter project
cd Personalized-Budget-Tracker/flutter

# Install dependencies
flutter pub get

# Run on iOS Simulator
flutter run

# Build for iOS device (without codesigning)
flutter build ios --no-codesign
```

---

## 🎯 Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter (Dart) |
| **State Management** | Provider (ChangeNotifier) |
| **Database** | SQLite via sqflite |
| **Charts** | fl_chart |
| **Typography** | Google Fonts (Outfit, JetBrains Mono) |
| **Animations** | flutter_animate |
| **Platform** | iOS (primary), Android (compatible) |

---

## 📄 License

This project is part of a personal portfolio. All rights reserved.

---

<p align="center">
  <i>Built with 💖 and Flutter</i>
</p>
