import React from "react";
import { Sun, Moon, Plus, Layers, Sparkles, Shield } from "lucide-react";
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

interface CategoryData {
  name: string;
  value: number;
}

interface MobileDashboardProps {
  activeTab: "dashboard" | "analytics";
  setActiveTab: (tab: "dashboard" | "analytics") => void;
  budgets: BudgetAllocation[];
  filteredBudgets: BudgetAllocation[];
  globalCategoryData: CategoryData[];
  onBudgetClick: (budget: BudgetAllocation) => void;
  onShowNewModal: () => void;
  toggleDarkMode: () => void;
  darkMode: boolean;
  chartColors: string[];
}

export default function MobileDashboard({
  activeTab,
  setActiveTab,
  budgets,
  filteredBudgets,
  globalCategoryData,
  onBudgetClick,
  onShowNewModal,
  toggleDarkMode,
  darkMode,
  chartColors,
}: MobileDashboardProps) {
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
                {activeTab === "dashboard" ? "My Budgets" : "Spending Stats"}
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
                <button 
                  onClick={onShowNewModal}
                  className="w-12 h-12 bg-pastel-pink text-white rounded-2xl flex items-center justify-center shadow-lg shadow-pastel-pink/20 active:scale-90 transition-transform cursor-pointer"
                >
                  <Plus size={24} strokeWidth={3} />
                </button>
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
                filteredBudgets.map((budget) => (
                  <BudgetCard
                    key={budget.id}
                    allocation={budget}
                    onClick={() => onBudgetClick(budget)}
                  />
                ))
              )
            ) : (
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
            <div className="flex flex-col items-center gap-1.5 text-slate-300 dark:text-slate-600">
              <div className="p-2">
                <Shield size={22} />
              </div>
              <span className="text-[8px] font-black uppercase tracking-widest">Vault</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
