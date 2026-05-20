import React, { useState } from "react";
import { Sun, Moon, Plus, Layers, Sparkles, Shield, Calculator as CalculatorIcon, Edit2 } from "lucide-react";
import { 
  PieChart, 
  Pie, 
  Cell, 
  ResponsiveContainer, 
  Tooltip as RechartsTooltip 
} from "recharts";
import type { BudgetAllocation } from "../types";
import BudgetCard from "./BudgetCard";
import AIRecommendations from "./AIRecommendations";
import Calculator from "./Calculator";

interface PeriodStat {
  amount: number;
  count: number;
}

interface CategoryData {
  name: string;
  value: number;
}

interface MobileDashboardProps {
  activeTab: "dashboard" | "analytics" | "calculator";
  setActiveTab: (tab: "dashboard" | "analytics" | "calculator") => void;
  budgets: BudgetAllocation[];
  filteredBudgets: BudgetAllocation[];
  globalCategoryData: CategoryData[];
  onBudgetClick: (budget: BudgetAllocation) => void;
  onDeleteBudget: (id: string) => Promise<void>;
  onDeleteMultipleBudgets: (ids: string[]) => Promise<void>;
  onUpdateBudget: (budget: BudgetAllocation) => Promise<void>;
  onShowNewModal: () => void;
  toggleDarkMode: () => void;
  darkMode: boolean;
  chartColors: string[];
  periodStats: {
    weekly: PeriodStat;
    monthly: PeriodStat;
    quarterly: PeriodStat;
    yearly: PeriodStat;
  };
}

export default function MobileDashboard({
  activeTab,
  setActiveTab,
  budgets,
  filteredBudgets,
  globalCategoryData,
  onBudgetClick,
  onDeleteBudget,
  onDeleteMultipleBudgets,
  onUpdateBudget,
  onShowNewModal,
  toggleDarkMode,
  darkMode,
  chartColors,
  periodStats,
}: MobileDashboardProps) {
  const [selectedBudgetIds, setSelectedBudgetIds] = useState<string[]>([]);
  const [isEditMode, setIsEditMode] = useState(false);

  const toggleSelectBudget = (id: string) => {
    if (selectedBudgetIds.includes(id)) {
      setSelectedBudgetIds(selectedBudgetIds.filter(x => x !== id));
    } else {
      setSelectedBudgetIds([...selectedBudgetIds, id]);
    }
  };

  const handleBulkDelete = async () => {
    if (selectedBudgetIds.length === 0) return;
    await onDeleteMultipleBudgets(selectedBudgetIds);
    setSelectedBudgetIds([]);
    setIsEditMode(false);
  };

  const toggleSelectAll = () => {
    if (selectedBudgetIds.length === filteredBudgets.length) {
      setSelectedBudgetIds([]);
    } else {
      setSelectedBudgetIds(filteredBudgets.map(b => b.id));
    }
  };

  const handleBulkPinToggle = async () => {
    if (selectedBudgetIds.length === 0) return;
    
    // Check if at least one selected budget is not pinned
    const anyUnpinned = budgets.some(b => selectedBudgetIds.includes(b.id) && !b.pin);
    const newPinState = anyUnpinned ? "true" : null;
    
    // Update all selected plans
    for (const budget of budgets) {
      if (selectedBudgetIds.includes(budget.id)) {
        const updated = { ...budget, pin: newPinState };
        await onUpdateBudget(updated);
      }
    }
    alert(`Successfully ${anyUnpinned ? "pinned" : "unpinned"} ${selectedBudgetIds.length} budget plans! 📌`);
    setSelectedBudgetIds([]);
    setIsEditMode(false);
  };
  return (
    <section className="flex xl:w-[400px] w-full shrink-0 items-center justify-center relative">
      <div className="iphone-xs-container bg-white dark:bg-slate-900 flex flex-col shadow-2xl relative transition-colors duration-300">
        {/* Mock iPhone Notch - Hidden on real mobile screens */}
        <div className="hidden xl:flex h-10 items-center justify-center shrink-0">
          <div className="w-32 h-6 bg-slate-900 rounded-b-3xl" />
        </div>

        {/* Mobile App Content */}
        <div className="flex-grow flex flex-col overflow-hidden">
          <div className="px-6 pt-8 pb-4 flex justify-between items-center">
            <div>
              <span className="text-[10px] font-black text-pastel-pink-dark uppercase tracking-[0.2em]">
                {new Date().toLocaleDateString("en-US", { month: "long", day: "numeric" })}
              </span>
              <h2 className="text-2xl font-black text-slate-800 dark:text-white">
                {activeTab === "dashboard" ? "My Budgets" : activeTab === "analytics" ? "Spending Stats" : "Royal Calculator"}
              </h2>
            </div>
            <div className="flex gap-2">
              <button 
                onClick={toggleDarkMode}
                className="w-12 h-12 bg-white dark:bg-slate-800 text-pastel-pink rounded-2xl flex items-center justify-center shadow-lg shadow-black/5 active:scale-90 transition-transform border border-pastel-pink/10 cursor-pointer"
              >
                {darkMode ? <Sun size={20} /> : <Moon size={20} />}
              </button>
              {activeTab === "dashboard" && (
                <>
                  <button 
                    onClick={() => {
                      setIsEditMode(!isEditMode);
                      if (isEditMode) setSelectedBudgetIds([]); // Clear selection when exiting edit mode
                    }}
                    className={`w-12 h-12 rounded-2xl flex items-center justify-center shadow-lg active:scale-90 transition-transform cursor-pointer border ${
                      isEditMode
                        ? "bg-pastel-pink text-white border-pastel-pink shadow-pastel-pink/20"
                        : "bg-white dark:bg-slate-800 text-pastel-pink border-pastel-pink/10 shadow-black/5"
                    }`}
                    title="Edit/Bulk Actions"
                  >
                    <Edit2 size={18} strokeWidth={2.5} />
                  </button>
                  <button 
                    onClick={onShowNewModal}
                    className="w-12 h-12 bg-pastel-pink text-white rounded-2xl flex items-center justify-center shadow-lg shadow-pastel-pink/20 active:scale-90 transition-transform cursor-pointer"
                  >
                    <Plus size={24} strokeWidth={3} />
                  </button>
                </>
              )}
            </div>
          </div>

          <div className="flex-grow overflow-y-auto px-6 pt-2 pb-28 space-y-4">
            {activeTab === "dashboard" ? (
              filteredBudgets.length === 0 ? (
                <div className="py-20 text-center flex flex-col items-center">
                  <div className="w-20 h-20 bg-pastel-pink-light dark:bg-slate-800 rounded-full flex items-center justify-center mb-6">
                    <Plus className="text-pastel-pink" size={32} />
                  </div>
                  <p className="text-xs font-bold text-slate-400 px-8">No sparkle plans yet! Start your journey. ✨</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {/* Bulk Actions Header Bar */}
                  {isEditMode && (
                    <div className="flex flex-col gap-2 bg-[#FFF8FA] dark:bg-slate-800/80 p-3.5 rounded-[24px] border border-pastel-pink/15 shadow-sm transition-all duration-300">
                      <div className="flex justify-between items-center">
                        <button
                          onClick={toggleSelectAll}
                          className="text-[10px] font-black text-pastel-pink-dark hover:underline flex items-center gap-1.5 uppercase tracking-widest cursor-pointer select-none"
                        >
                          {selectedBudgetIds.length === filteredBudgets.length ? "Deselect All 🌸" : "Select All 🎀"}
                        </button>
                        <span className="text-[9px] font-bold text-slate-400 dark:text-slate-500 uppercase tracking-wider font-mono">
                          {selectedBudgetIds.length} Selected
                        </span>
                      </div>
                      
                      {selectedBudgetIds.length > 0 && (
                        <div className="flex gap-2 pt-2 border-t border-dashed border-pastel-pink/15">
                          <button
                            onClick={handleBulkPinToggle}
                            className="flex-1 py-2 bg-white dark:bg-slate-700 text-pastel-pink-dark border border-pastel-pink/20 hover:bg-pastel-pink-light/35 rounded-xl text-[9px] font-black uppercase tracking-widest flex items-center justify-center gap-1 cursor-pointer select-none shadow-sm"
                          >
                            Pin/Unpin 📌
                          </button>
                          <button
                            onClick={handleBulkDelete}
                            className="flex-1 py-2 bg-red-50 dark:bg-red-950/20 text-red-500 hover:bg-red-100 dark:hover:bg-red-900/30 rounded-xl text-[9px] font-black uppercase tracking-widest flex items-center justify-center gap-1 cursor-pointer select-none"
                          >
                            Remove Selected 🗑️
                          </button>
                        </div>
                      )}
                    </div>
                  )}

                  {filteredBudgets.map((budget) => (
                    <BudgetCard
                      key={budget.id}
                      allocation={budget}
                      onClick={() => onBudgetClick(budget)}
                      isSelected={isEditMode && selectedBudgetIds.includes(budget.id)}
                      onToggleSelect={isEditMode ? () => toggleSelectBudget(budget.id) : undefined}
                      onDelete={isEditMode ? () => onDeleteBudget(budget.id) : undefined}
                    />
                  ))}
                </div>
              )
            ) : activeTab === "analytics" ? (
              <div className="space-y-6 pt-4">
                <div className="bg-pastel-pink-light/50 dark:bg-slate-800/50 p-6 rounded-[32px] border border-pastel-pink/20 dark:border-pastel-pink/5">
                  <h4 className="text-[10px] font-black text-pastel-pink-dark uppercase tracking-widest mb-4">Allocation Summary</h4>
                  <div className="h-56 w-full">
                    {globalCategoryData.length === 0 ? (
                      <div className="h-full flex items-center justify-center">
                        <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">No allocations yet 🌸</p>
                      </div>
                    ) : (
                      <ResponsiveContainer width="100%" height="100%">
                        <PieChart>
                          <Pie
                            data={globalCategoryData}
                            paddingAngle={5}
                            innerRadius={50}
                            outerRadius={70}
                            dataKey="value"
                          >
                            {globalCategoryData.map((entry, index) => (
                              <Cell key={`cell-${index}`} fill={chartColors[index % chartColors.length]} />
                            ))}
                          </Pie>
                          <RechartsTooltip 
                            contentStyle={{ borderRadius: "16px", border: "none", boxShadow: "0 10px 15px -3px rgb(0 0 0 / 0.1)", fontSize: "10px" }}
                          />
                        </PieChart>
                      </ResponsiveContainer>
                    )}
                  </div>
                </div>

                {/* Period Summaries 2x2 Grid */}
                <div className="space-y-3">
                  <h4 className="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-widest px-2">Period Summaries</h4>
                  <div className="grid grid-cols-2 gap-3.5">
                    {/* Weekly */}
                    <div className="p-4 rounded-[28px] bg-gradient-to-br from-pastel-pink/15 to-pastel-pink/2 dark:from-pastel-pink/10 dark:to-transparent border border-pastel-pink/20 dark:border-pastel-pink/5 flex flex-col justify-between min-h-[110px] transition-all duration-300 active:scale-95 shadow-sm">
                      <div>
                        <span className="text-[9px] font-black text-pastel-pink-dark dark:text-pastel-pink uppercase tracking-widest">Weekly</span>
                        <p className="text-[8px] font-bold text-slate-400 dark:text-slate-500 mt-0.5">{periodStats.weekly.count} active {periodStats.weekly.count === 1 ? "plan" : "plans"}</p>
                      </div>
                      <p className="text-lg font-black text-slate-800 dark:text-white font-mono mt-3 leading-none">
                        ₱ {periodStats.weekly.amount.toLocaleString()}
                      </p>
                    </div>

                    {/* Monthly */}
                    <div className="p-4 rounded-[28px] bg-gradient-to-br from-pastel-salmon/15 to-pastel-salmon/2 dark:from-pastel-salmon/10 dark:to-transparent border border-pastel-pink/20 dark:border-pastel-pink/5 flex flex-col justify-between min-h-[110px] transition-all duration-300 active:scale-95 shadow-sm">
                      <div>
                        <span className="text-[9px] font-black text-pastel-pink-dark dark:text-pastel-salmon uppercase tracking-widest">Monthly</span>
                        <p className="text-[8px] font-bold text-slate-400 dark:text-slate-500 mt-0.5">{periodStats.monthly.count} active {periodStats.monthly.count === 1 ? "plan" : "plans"}</p>
                      </div>
                      <p className="text-lg font-black text-slate-800 dark:text-white font-mono mt-3 leading-none">
                        ₱ {periodStats.monthly.amount.toLocaleString()}
                      </p>
                    </div>

                    {/* Quarterly */}
                    <div className="p-4 rounded-[28px] bg-gradient-to-br from-pastel-coral/15 to-pastel-coral/2 dark:from-pastel-coral/10 dark:to-transparent border border-pastel-pink/20 dark:border-pastel-pink/5 flex flex-col justify-between min-h-[110px] transition-all duration-300 active:scale-95 shadow-sm">
                      <div>
                        <span className="text-[9px] font-black text-pastel-pink-dark dark:text-pastel-coral uppercase tracking-widest">Quarterly</span>
                        <p className="text-[8px] font-bold text-slate-400 dark:text-slate-500 mt-0.5">{periodStats.quarterly.count} active {periodStats.quarterly.count === 1 ? "plan" : "plans"}</p>
                      </div>
                      <p className="text-lg font-black text-slate-800 dark:text-white font-mono mt-3 leading-none">
                        ₱ {periodStats.quarterly.amount.toLocaleString()}
                      </p>
                    </div>

                    {/* Yearly */}
                    <div className="p-4 rounded-[28px] bg-gradient-to-br from-accent/15 to-accent/2 dark:from-accent/10 dark:to-transparent border border-pastel-pink/20 dark:border-pastel-pink/5 flex flex-col justify-between min-h-[110px] transition-all duration-300 active:scale-95 shadow-sm">
                      <div>
                        <span className="text-[9px] font-black text-pastel-pink-dark dark:text-accent uppercase tracking-widest">Yearly</span>
                        <p className="text-[8px] font-bold text-slate-400 dark:text-slate-500 mt-0.5">{periodStats.yearly.count} active {periodStats.yearly.count === 1 ? "plan" : "plans"}</p>
                      </div>
                      <p className="text-lg font-black text-slate-800 dark:text-white font-mono mt-3 leading-none">
                        ₱ {periodStats.yearly.amount.toLocaleString()}
                      </p>
                    </div>
                  </div>
                </div>
                
                {globalCategoryData.length > 0 && (
                  <div className="space-y-3">
                    <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-2">Top Categories</h4>
                    {globalCategoryData.slice(0, 5).map((cat, idx) => (
                      <div key={idx} className="bg-white dark:bg-slate-800/80 p-4 rounded-[24px] flex justify-between items-center shadow-sm border border-slate-50 dark:border-slate-700/50">
                        <span className="text-xs font-bold text-slate-700 dark:text-slate-200">{cat.name}</span>
                        <span className="text-xs font-black text-pastel-pink-dark font-mono">₱ {cat.value.toLocaleString()}</span>
                      </div>
                    ))}
                  </div>
                )}

                <div className="pt-4">
                  <AIRecommendations budgets={budgets} />
                </div>
              </div>
            ) : (
              <div className="pt-2 h-full">
                <Calculator />
              </div>
            )}
          </div>

          {/* Mobile Bottom Nav */}
          <div className="absolute bottom-0 left-0 right-0 h-24 border-t border-pastel-pink/10 bg-white/90 dark:bg-slate-900/90 backdrop-blur-xl flex items-center justify-around px-6 z-20 transition-colors">
            <button 
              onClick={() => setActiveTab("dashboard")} 
              className={`flex flex-col items-center gap-1.5 transition-all duration-300 cursor-pointer ${activeTab === "dashboard" ? "text-pastel-pink scale-110" : "text-slate-300 dark:text-slate-600"}`}
            >
              <div className={`p-2 rounded-xl ${activeTab === "dashboard" ? "bg-pastel-pink-light dark:bg-pastel-pink/10" : ""}`}>
                <Layers size={22} />
              </div>
              <span className="text-[8px] font-black uppercase tracking-widest">Home</span>
            </button>
            <button 
              onClick={() => setActiveTab("analytics")} 
              className={`flex flex-col items-center gap-1.5 transition-all duration-300 cursor-pointer ${activeTab === "analytics" ? "text-pastel-pink scale-110" : "text-slate-300 dark:text-slate-600"}`}
            >
              <div className={`p-2 rounded-xl ${activeTab === "analytics" ? "bg-pastel-pink-light dark:bg-pastel-pink/10" : ""}`}>
                <Sparkles size={22} />
              </div>
              <span className="text-[8px] font-black uppercase tracking-widest">Stats</span>
            </button>
            <button 
              onClick={() => setActiveTab("calculator")} 
              className={`flex flex-col items-center gap-1.5 transition-all duration-300 cursor-pointer ${activeTab === "calculator" ? "text-pastel-pink scale-110" : "text-slate-300 dark:text-slate-600"}`}
            >
              <div className={`p-2 rounded-xl ${activeTab === "calculator" ? "bg-pastel-pink-light dark:bg-pastel-pink/10" : ""}`}>
                <CalculatorIcon size={22} />
              </div>
              <span className="text-[8px] font-black uppercase tracking-widest">Calc</span>
            </button>
          </div>
        </div>
      </div>
    </section>
  );
}
