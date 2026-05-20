<div align="center">
  # 🌸 Bloom Budget ✨
  
  **Bloom Budget** is a personalized, highly aesthetic personal finance app designed for anyone who wants to manage their savings in style. Styled with a premium, modern "girly pop" theme, the project offers a gorgeous responsive **TypeScript React Web App** side-by-side with a **Native iOS Flutter Application**.
  
  With intelligent **Google Gemini AI spending analysis** and a secure **6-digit Privacy Vault**, managing money has never been this fun, supportive, and chic! 🎀
</div>

---

## 🌟 Key Features

*   🌸 **Vibrant "Girly Pop" UI Design**: Curated, warm pastel palettes, rounded premium curves, and micro-animations that deliver an immersive, delightful user experience. Full support for **Light** and **Dark** modes.
*   🧠 **Gemini AI Royal Financial Advisor**: A built-in generative AI interface powered by the `gemini-3-flash-preview` model that analyzes active budgets and dispenses three supportive, helpful, and fun money-saving tips!
*   🔒 **Royal Privacy Vault**: Lock sensitive or private budget profiles with a 6-digit numeric keypad screen (`PinLock`), keeping your financial data secure from prying eyes.
*   📊 **Double-Pane Live Simulation**: A gorgeous desktop layout containing a fully interactive, responsive **iPhone notch simulator frame** alongside massive **Recharts desktop breakdowns** and top category summaries.
*   📱 **Native iOS App (Flutter)**: A robust, native implementation featuring true local **SQLite database persistence** (`sqflite`), Material 3 styling, and fluid motion transitions (`flutter_animate`).

---

## 🏗️ Project Architecture & Tech Stack

Bloom Budget is engineered with a modular, decoupling strategy for ultimate maintainability:

### 🌐 Web Application (React & Express Node.js)
*   **Frontend**: React 19, TypeScript, Tailwind CSS v4, Motion (fluid animations), Recharts (category visualization), Lucide React (premium icons).
*   **Backend Server**: Express API proxy (`server.ts`) hosting the `@google/genai` interface.
*   **Data Strategy**: Persisted via standard, lightning-fast Web LocalStorage (`src/services/db.ts`) simulating the SQLite database schema.
*   **Component Strategy**: Decoupled UI components orchestrating with a custom hook state manager:
    *   `src/hooks/useBudgetTracker.ts`: Core state machine handling CRUD, filtering, sorting, and aggregate analytics.
    *   `src/components/Header.tsx`: Responsive navigation header.
    *   `src/components/MobileDashboard.tsx`: Simulated notched iPhone mockup frame.
    *   `src/components/OverviewStats.tsx`: Total monthly budget, active profiles, and countdown meters.
    *   `src/components/GlobalAnalytics.tsx`: Interactive Recharts Category Breakdown.
    *   `src/components/NewProfileCard.tsx`: Quick select budget profiles and creation portal.

### 📱 Native Mobile Application (Flutter)
*   **Language & SDK**: Dart / Flutter SDK (optimized for iOS).
*   **Persistence**: SQLite database integration via the `sqflite` plugin for robust local storage.
*   **Animation & UI**: Material 3 pastel styling (`GoogleFonts.outfitTextTheme`) and `flutter_animate` transitions.

---

## 🚀 How to Run the Web App Locally

### Prerequisites
*   [Node.js](https://nodejs.org/) (v18 or higher recommended)

### Step 1: Install Dependencies
From the project root directory, run:
```bash
npm install
```

### Step 2: Configure Environment Variables
1. Create a copy of `.env.example` and name it `.env` (or `.env.local`):
   ```bash
   cp .env.example .env
   ```
2. Open the file and replace `"MY_GEMINI_API_KEY"` with your active Gemini API key:
   ```env
   GEMINI_API_KEY="AIzaSyYourKeyHere..."
   ```

### Step 3: Run the Server
Launch the development server:
```bash
npm run dev
```
Open **[http://localhost:3000](http://localhost:3000)** in your browser to view the app!

---

## 📱 How to Simulate on an iOS Phone

### 1. Previewing the Web App on Your Physical iPhone
The development server is pre-configured to bind to `0.0.0.0`, enabling you to access the web app from any device on your Wi-Fi network:
1. Find your Mac's local IP address:
   ```bash
   ipconfig getifaddr en0
   ```
2. Open **Safari** on your iPhone (ensure it's connected to the same Wi-Fi network).
3. Navigate to `http://<your-mac-ip>:3000` (e.g. `http://192.168.1.15:3000`).
4. *Tip*: Tap **Share** > **Add to Home Screen** in Safari to test it as a standalone, native-feeling Web App!

### 2. Running the Native iOS App (Xcode Simulator)
1. Navigate to the mobile source directory:
   ```bash
   cd flutter
   ```
2. Install package dependencies:
   ```bash
   flutter pub get
   ```
3. Open the Apple iOS Simulator:
   ```bash
   open -a Simulator
   ```
4. Compile and launch the native code:
   ```bash
   flutter run
   ```

---

## 🛡️ Database Schema Reference (SQLite / iOS)

If you modify or expand the models, refer to the established three-table design:

```sql
-- Table: budgets
CREATE TABLE budgets (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  total_budget REAL NOT NULL,
  currency TEXT NOT NULL,
  days_to_consume INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  pin TEXT
);

-- Table: categories
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  budget_id TEXT NOT NULL,
  name TEXT NOT NULL,
  allocated_amount REAL NOT NULL,
  spent_amount REAL NOT NULL,
  FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE
);

-- Table: sub_categories
CREATE TABLE sub_categories (
  id TEXT PRIMARY KEY,
  category_id TEXT NOT NULL,
  name TEXT NOT NULL,
  allocated_amount REAL NOT NULL,
  spent_amount REAL NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
);
```

---
<div align="center">
  *Made with 💖 and a touch of sparkle. Keep glowing and growing your savings! ✨*
</div>
