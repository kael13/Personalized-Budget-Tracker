import React from "react";
import { AnimatePresence } from "motion/react";
import { Sparkles } from "lucide-react";
import { useBudgetTracker } from "./hooks/useBudgetTracker";
import Header from "./components/Header";
import MobileDashboard from "./components/MobileDashboard";
import OverviewStats from "./components/OverviewStats";
import GlobalAnalytics from "./components/GlobalAnalytics";
import NewProfileCard from "./components/NewProfileCard";
import AIRecommendations from "./components/AIRecommendations";
import BudgetModal from "./components/BudgetModal";
import DetailSheet from "./components/DetailSheet";

const CHART_COLORS = ["#EC7063", "#FFB6C1", "#F1948A", "#FADADD", "#F5B7B1"];

export default function App() {
  const {
    budgets,
    config,
    activeTab,
    setActiveTab,
    showNewModal,
    setShowNewModal,
    selectedBudget,
    setSelectedBudget,
    editingBudget,
    setEditingBudget,
    sortBy,
    handleCreateBudget,
    handleUpdateBudget,
    handleDeleteBudget,
    handleDeleteMultipleBudgets,
    handleBudgetClick,
    toggleDarkMode,
    filteredBudgets,
    totalBudgetAmount,
    maxDaysToConsume,
    globalCategoryData,
  } = useBudgetTracker();

  return (
    <div className={`${config.darkMode ? "dark" : ""} h-screen flex flex-col overflow-hidden bg-background-soft dark:bg-slate-950 transition-colors duration-500`}>
      {/* Header Navigation */}
      <Header darkMode={config.darkMode} toggleDarkMode={toggleDarkMode} />

      <main className="flex-grow flex p-0 xl:p-6 gap-0 xl:gap-8 overflow-hidden bg-background-soft dark:bg-slate-950 transition-colors">
        {/* Mobile Mock iPhone Simulator Panel */}
        <MobileDashboard
          activeTab={activeTab}
          setActiveTab={setActiveTab}
          budgets={budgets}
          filteredBudgets={filteredBudgets}
          globalCategoryData={globalCategoryData}
          onBudgetClick={handleBudgetClick}
          onDeleteBudget={handleDeleteBudget}
          onDeleteMultipleBudgets={handleDeleteMultipleBudgets}
          onUpdateBudget={handleUpdateBudget}
          onShowNewModal={() => {
            setEditingBudget(null);
            setShowNewModal(true);
          }}
          toggleDarkMode={toggleDarkMode}
          darkMode={config.darkMode}
          chartColors={CHART_COLORS}
        />

        {/* Right Panel / Desktop Dashboard Screen */}
        <section className="hidden xl:flex flex-grow flex-col gap-8 overflow-hidden">
          {/* Top Metric Cards */}
          <OverviewStats
            totalBudget={totalBudgetAmount}
            activeProfilesCount={budgets.length}
            maxDaysLeft={budgets.length > 0 ? maxDaysToConsume : "--"}
          />

          {/* Interactive Recharts Global Breakdown */}
          <GlobalAnalytics
            globalCategoryData={globalCategoryData}
            chartColors={CHART_COLORS}
          />

          {/* AI recommendations & Launcher Card */}
          <div className="flex-grow grid grid-cols-1 lg:grid-cols-2 gap-6 overflow-hidden">
            <div className="bg-white dark:bg-slate-900 rounded-[40px] border border-pastel-pink/20 shadow-sm p-8 flex flex-col overflow-hidden transition-colors">
              <div className="flex items-center gap-2 mb-6 shrink-0">
                <Sparkles className="text-pastel-pink-dark" />
                <h3 className="text-xl font-black text-slate-800 dark:text-white">AI Financial Analysis</h3>
              </div>
              <div className="flex-grow overflow-y-auto pr-4">
                <AIRecommendations budgets={budgets} />
              </div>
            </div>

            <NewProfileCard
              budgets={budgets}
              onBudgetClick={handleBudgetClick}
              onCreateNew={() => {
                setEditingBudget(null);
                setShowNewModal(true);
              }}
            />
          </div>
        </section>
      </main>

      {/* Global Status Footer */}
      <footer className="hidden xl:flex h-12 bg-white dark:bg-slate-900 border-t border-pastel-pink flex items-center justify-between px-8 text-[9px] font-black uppercase tracking-[0.2em] text-slate-400 shrink-0 transition-colors">
        <div>Active Profiles: {budgets.length}</div>
        <div className="flex gap-8">
          <span className="text-pastel-pink-dark">Syncing to Cloud... Sparkle Active ✨</span>
          <span className="hidden sm:inline">Sorted by: {sortBy === "date" ? "Date Created ↓" : "Budget Amount ↓"}</span>
        </div>
      </footer>

      {/* Full Screen Overlays */}
      <AnimatePresence>
        {showNewModal && (
          <BudgetModal
            initialData={editingBudget}
            onClose={() => {
              setShowNewModal(false);
              setEditingBudget(null);
            }}
            onSave={handleCreateBudget}
          />
        )}

        {selectedBudget && (
          <DetailSheet
            budget={selectedBudget}
            onClose={() => setSelectedBudget(null)}
            onEdit={() => {
              setEditingBudget(selectedBudget);
              setSelectedBudget(null);
              setShowNewModal(true);
            }}
            onDelete={() => handleDeleteBudget(selectedBudget.id)}
            onUpdate={handleUpdateBudget}
          />
        )}
      </AnimatePresence>
    </div>
  );
}
