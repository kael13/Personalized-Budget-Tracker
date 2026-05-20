/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "motion/react";
import {
  Plus,
  Settings,
  Moon,
  Sun,
  ChevronRight,
  Shield,
  Trash2,
  Edit2,
  PieChart as PieChartIcon,
  Calendar,
  Layers,
  Sparkles,
  Search,
  ArrowUpDown,
  BarChart3
} from "lucide-react";
import { 
  PieChart, 
  Pie, 
  Cell, 
  ResponsiveContainer, 
  Tooltip as RechartsTooltip, 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis,
  Legend
} from "recharts";
import type { BudgetAllocation, AppConfig } from "./types";
import BudgetCard from "./components/BudgetCard";
import BudgetModal from "./components/BudgetModal";
import DetailSheet from "./components/DetailSheet";
import PinLock from "./components/PinLock";
import AIRecommendations from "./components/AIRecommendations";
import { db } from "./services/db";

const CHART_COLORS = ["#FF8EAD", "#FFC5D3", "#FF85A1", "#FFD1DC", "#FADADD", "#FFB7C5", "#E5B0BC"];

export default function App() {
  const [budgets, setBudgets] = useState<BudgetAllocation[]>([]);
  const [config, setConfig] = useState<AppConfig>({ darkMode: false });
  const [activeTab, setActiveTab] = useState<"dashboard" | "analytics">("dashboard");
  const [showNewModal, setShowNewModal] = useState(false);
  const [selectedBudget, setSelectedBudget] = useState<BudgetAllocation | null>(null);
  const [budgetToUnlock, setBudgetToUnlock] = useState<BudgetAllocation | null>(null);
  const [unlockedBudgets, setUnlockedBudgets] = useState<Set<string>>(new Set());
  const [editingBudget, setEditingBudget] = useState<BudgetAllocation | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [sortBy, setSortBy] = useState<"date" | "amount">("date");

  useEffect(() => {
    const initData = async () => {
      const savedBudgets = await db.getBudgets();
      setBudgets(savedBudgets);
      
      const savedConfig = localStorage.getItem("config");
      if (savedConfig) setConfig(JSON.parse(savedConfig));
    };
    initData();
  }, []);

  useEffect(() => {
    if (config.darkMode) {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }
  }, [config.darkMode]);

  const handleCreateBudget = async (budget: BudgetAllocation) => {
    await db.saveBudget(budget);
    const updated = await db.getBudgets();
    setBudgets(updated);
    setShowNewModal(false);
    setEditingBudget(null);
  };

  const handleDeleteBudget = async (id: string) => {
    if (window.confirm("Are you sure you want to delete this budget profile? ✨")) {
      await db.deleteBudget(id);
      const updated = await db.getBudgets();
      setBudgets(updated);
      setSelectedBudget(null);
    }
  };

  const handleBudgetClick = (budget: BudgetAllocation) => {
    if (budget.pin && !unlockedBudgets.has(budget.id)) {
      setBudgetToUnlock(budget);
    } else {
      setSelectedBudget(budget);
    }
  };

  const toggleDarkMode = () => {
    const newConfig = { ...config, darkMode: !config.darkMode };
    setConfig(newConfig);
    localStorage.setItem("config", JSON.stringify(newConfig));
  };

  const getGlobalCategoryData = () => {
    const data: Record<string, number> = {};
    budgets.forEach(b => {
      b.categories.forEach(c => {
        const name = c.name || "Other";
        data[name] = (data[name] || 0) + c.allocatedAmount;
      });
    });
    return Object.entries(data)
      .sort((a, b) => b[1] - a[1])
      .map(([name, value]) => ({ name, value }));
  };

  const filteredBudgets = budgets
    .filter(b => b.name.toLowerCase().includes(searchQuery.toLowerCase()))
    .sort((a, b) => {
      if (sortBy === "date") return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
      return b.totalBudget - a.totalBudget;
    });

  return (
    <div className={`${config.darkMode ? "dark" : ""} h-screen flex flex-col overflow-hidden bg-background-soft dark:bg-slate-950 transition-colors duration-500`}>
      {/* Header Navigation - Visible on desktop, simple version on mobile */}
      <header className="hidden xl:flex w-full h-16 bg-white/80 dark:bg-slate-900/80 backdrop-blur-md border-b border-pastel-pink/20 flex items-center justify-between px-6 xl:px-8 shrink-0 z-50 transition-colors">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 bg-pastel-pink rounded-full flex items-center justify-center shadow-sm">
            <span className="text-white font-black text-lg">B</span>
          </div>
          <h1 className="text-lg xl:text-xl font-bold text-pastel-pink-dark tracking-tight">BloomBudget</h1>
        </div>
        
        <div className="flex items-center gap-4 xl:gap-6">
          <div className="hidden sm:flex bg-pastel-pink-light dark:bg-slate-800 p-1 rounded-full border border-pastel-pink/20">
            <button 
              onClick={() => config.darkMode && toggleDarkMode()}
              className={`px-4 py-1.5 rounded-full text-[10px] font-black transition-all ${!config.darkMode ? 'bg-white text-pastel-pink-dark shadow-sm' : 'text-slate-400 opacity-60'}`}
            >
              LIGHT
            </button>
            <button 
              onClick={() => !config.darkMode && toggleDarkMode()}
              className={`px-4 py-1.5 rounded-full text-[10px] font-black transition-all ${config.darkMode ? 'bg-slate-700 text-pastel-pink shadow-sm' : 'text-slate-500 opacity-60'}`}
            >
              DARK
            </button>
          </div>
          
          <button 
            onClick={toggleDarkMode}
            className="sm:hidden w-9 h-9 bg-white dark:bg-slate-800 text-pastel-pink rounded-full flex items-center justify-center shadow-sm border border-pastel-pink/10"
          >
            {config.darkMode ? <Sun size={18} /> : <Moon size={18} />}
          </button>

          <div className="w-9 h-9 bg-pastel-pink-light border-2 border-pastel-pink rounded-full flex items-center justify-center overflow-hidden">
            <img src={`https://api.dicebear.com/7.x/adventurer/svg?seed=${config.darkMode ? 'night' : 'pink'}`} alt="avatar" className="w-full h-full" />
          </div>
        </div>
      </header>

      <main className="flex-grow flex p-0 xl:p-6 gap-0 xl:gap-8 overflow-hidden bg-background-soft dark:bg-slate-950 transition-colors">
        {/* Mobile App Frame / Left Panel */}
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
                    {new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric' })}
                  </span>
                  <h2 className="text-2xl font-black text-slate-800 dark:text-white">
                    {activeTab === 'dashboard' ? 'My Budgets' : 'Spending Stats'}
                  </h2>
                </div>
                <div className="flex gap-2">
                  <button 
                    onClick={toggleDarkMode}
                    className="w-12 h-12 bg-white dark:bg-slate-800 text-pastel-pink rounded-2xl flex items-center justify-center shadow-lg shadow-black/5 active:scale-90 transition-transform border border-pastel-pink/10"
                  >
                    {config.darkMode ? <Sun size={20} /> : <Moon size={20} />}
                  </button>
                  {activeTab === 'dashboard' && (
                    <button 
                      onClick={() => setShowNewModal(true)}
                      className="w-12 h-12 bg-pastel-pink text-white rounded-2xl flex items-center justify-center shadow-lg shadow-pastel-pink/20 active:scale-90 transition-transform"
                    >
                      <Plus size={24} strokeWidth={3} />
                    </button>
                  )}
                </div>
              </div>

              <div className="flex-grow overflow-y-auto px-6 pt-2 pb-28 space-y-4">
                {activeTab === 'dashboard' ? (
                  budgets.length === 0 ? (
                    <div className="py-20 text-center flex flex-col items-center">
                      <div className="w-20 h-20 bg-pastel-pink-light dark:bg-slate-800 rounded-full flex items-center justify-center mb-6">
                        <Plus className="text-pastel-pink" size={32} />
                      </div>
                      <p className="text-xs font-bold text-slate-400 px-8">No sparkle plans yet! Start your journey. ✨</p>
                    </div>
                  ) : (
                    budgets.map(budget => (
                      <BudgetCard
                        key={budget.id}
                        allocation={budget}
                        onClick={() => handleBudgetClick(budget)}
                      />
                    ))
                  )
                ) : (
                  <div className="space-y-6 pt-4">
                    <div className="bg-pastel-pink-light/50 dark:bg-slate-800/50 p-6 rounded-[32px] border border-pastel-pink/20 dark:border-pastel-pink/5">
                      <h4 className="text-[10px] font-black text-pastel-pink-dark uppercase tracking-widest mb-4">Allocation Summary</h4>
                      <div className="h-56 w-full">
                        <ResponsiveContainer width="100%" height="100%">
                          <PieChart>
                            <Pie
                              data={getGlobalCategoryData()}
                              paddingAngle={5}
                              innerRadius={50}
                              outerRadius={70}
                              dataKey="value"
                            >
                              {getGlobalCategoryData().map((entry, index) => (
                                <Cell key={`cell-${index}`} fill={CHART_COLORS[index % CHART_COLORS.length]} />
                              ))}
                            </Pie>
                            <RechartsTooltip 
                               contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)', fontSize: '10px' }}
                            />
                          </PieChart>
                        </ResponsiveContainer>
                      </div>
                    </div>
                    
                    <div className="space-y-3">
                       <h4 className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-2">Top Categories</h4>
                       {getGlobalCategoryData().slice(0, 5).map((cat, idx) => (
                         <div key={idx} className="bg-white dark:bg-slate-800/80 p-4 rounded-[24px] flex justify-between items-center shadow-sm border border-slate-50 dark:border-slate-700/50">
                           <span className="text-xs font-bold text-slate-700 dark:text-slate-200">{cat.name}</span>
                           <span className="text-xs font-black text-pastel-pink-dark font-mono">₱ {cat.value.toLocaleString()}</span>
                         </div>
                       ))}
                    </div>

                    <div className="pt-4">
                       <AIRecommendations budgets={budgets} />
                    </div>
                  </div>
                )}
              </div>

              {/* Mobile Bottom Nav */}
              <div className="absolute bottom-0 left-0 right-0 h-24 border-t border-pastel-pink/10 bg-white/90 dark:bg-slate-900/90 backdrop-blur-xl flex items-center justify-around px-6 z-20">
                 <button 
                   onClick={() => setActiveTab('dashboard')} 
                   className={`flex flex-col items-center gap-1.5 transition-all duration-300 ${activeTab === 'dashboard' ? 'text-pastel-pink scale-110' : 'text-slate-300 dark:text-slate-600'}`}
                 >
                   <div className={`p-2 rounded-xl ${activeTab === 'dashboard' ? 'bg-pastel-pink-light dark:bg-pastel-pink/10' : ''}`}>
                     <Layers size={22} />
                   </div>
                   <span className="text-[8px] font-black uppercase tracking-widest">Home</span>
                 </button>
                 <button 
                   onClick={() => setActiveTab('analytics')} 
                   className={`flex flex-col items-center gap-1.5 transition-all duration-300 ${activeTab === 'analytics' ? 'text-pastel-pink scale-110' : 'text-slate-300 dark:text-slate-600'}`}
                 >
                   <div className={`p-2 rounded-xl ${activeTab === 'analytics' ? 'bg-pastel-pink-light dark:bg-pastel-pink/10' : ''}`}>
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

        {/* Right Panel / Desktop Main Content */}
        <section className="hidden xl:flex flex-grow flex-col gap-8 overflow-hidden">
           {/* Summary Stats / Top Section */}
           <div className="grid grid-cols-1 md:grid-cols-3 gap-6 shrink-0">
             <div className="bg-white dark:bg-slate-900 rounded-[32px] p-6 border border-pastel-pink/20 dark:border-pastel-pink/5 shadow-sm">
                <p className="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-[0.2em] mb-2">Total Monthly Budget</p>
                <p className="text-3xl font-black text-slate-800 dark:text-white">
                  ₱ {budgets.reduce((acc, b) => acc + b.totalBudget, 0).toLocaleString()}
                </p>
             </div>
             <div className="bg-white dark:bg-slate-900 rounded-[32px] p-6 border border-pastel-pink/20 dark:border-pastel-pink/5 shadow-sm">
                <p className="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-[0.2em] mb-2">Active Profiles</p>
                <p className="text-3xl font-black text-slate-800 dark:text-white">{budgets.length}</p>
             </div>
             <div className="bg-white dark:bg-slate-900 rounded-[32px] p-6 border border-pastel-pink/20 dark:border-pastel-pink/5 shadow-sm overflow-hidden relative">
                <div className="absolute top-0 right-0 w-24 h-24 bg-pastel-pink-light dark:bg-pastel-pink/10 rounded-full -mr-10 -mt-10" />
                <p className="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-[0.2em] mb-2 relative z-10">Days Sparkle Left</p>
                <p className="text-3xl font-black text-slate-800 dark:text-white relative z-10">
                  {budgets.length > 0 ? Math.max(...budgets.map(b => b.daysToConsume)) : '--'}
                </p>
             </div>
           </div>
           
           {/* Visual Analytics / Categories */}
           {budgets.length > 0 && (
             <div className="bg-white dark:bg-slate-900 rounded-[32px] p-8 border border-pastel-pink/10 shadow-sm shrink-0">
               <div className="flex justify-between items-center mb-6">
                 <div className="flex items-center gap-2">
                   <PieChartIcon className="text-pastel-pink-dark" />
                   <h3 className="text-sm font-black text-slate-800 dark:text-white uppercase tracking-[0.2em]">Global Category Breakdown</h3>
                 </div>
                 <div className="text-[10px] font-black text-slate-400 uppercase tracking-widest bg-slate-50 dark:bg-slate-800 px-3 py-1 rounded-full">
                   Top {getGlobalCategoryData().slice(0, 8).length} Categories
                 </div>
               </div>
               <div className="h-48 w-full">
                 <ResponsiveContainer width="100%" height="100%">
                   <PieChart>
                     <Pie
                       data={getGlobalCategoryData().slice(0, 8)}
                       cx="50%"
                       cy="50%"
                       innerRadius={60}
                       outerRadius={80}
                       paddingAngle={5}
                       dataKey="value"
                     >
                       {getGlobalCategoryData().slice(0, 8).map((entry, index) => (
                         <Cell key={`cell-${index}`} fill={CHART_COLORS[index % CHART_COLORS.length]} />
                       ))}
                     </Pie>
                     <RechartsTooltip 
                       contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)', fontSize: '10px', fontWeight: 'bold' }}
                     />
                     <Legend 
                       verticalAlign="middle" 
                       align="right"
                       layout="vertical"
                       formatter={(value) => <span className="text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-tight">{value}</span>}
                     />
                   </PieChart>
                 </ResponsiveContainer>
               </div>
             </div>
           )}

           {/* AI Insights & Main Action Area */}
           <div className="flex-grow grid grid-cols-1 lg:grid-cols-2 gap-6 overflow-hidden">
              <div className="bg-white dark:bg-slate-900 rounded-[40px] border border-pastel-pink/20 shadow-sm p-8 flex flex-col overflow-hidden">
                <div className="flex items-center gap-2 mb-6 shrink-0">
                  <Sparkles className="text-pastel-pink-dark" />
                  <h3 className="text-xl font-black text-slate-800 dark:text-white">AI Financial Analysis</h3>
                </div>
                <div className="flex-grow overflow-y-auto pr-4">
                  <AIRecommendations budgets={budgets} />
                </div>
              </div>

              <div className="bg-white dark:bg-slate-900 rounded-[40px] border border-pastel-pink/20 dark:border-pastel-pink/5 shadow-sm p-8 flex flex-col relative overflow-hidden">
                <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-pastel-pink via-accent to-pastel-pink"></div>
                
                <h3 className="text-xl font-black mb-8 text-slate-800 dark:text-white">New Allocation Profile</h3>
                
                <div className="space-y-6">
                   <p className="text-slate-400 dark:text-slate-500 text-sm font-medium leading-relaxed">
                     Create a fresh budget allocation to keep your sparkle in check. Every girl needs a plan! 🎀
                   </p>
                   
                   <div className="grid grid-cols-1 gap-4">
                      {budgets.slice(0, 3).map(b => (
                        <div key={b.id} className="p-4 rounded-3xl bg-pastel-pink-light/30 dark:bg-slate-800/80 border border-pastel-pink/10 dark:border-slate-700/50 flex justify-between items-center group cursor-pointer hover:bg-pastel-pink-light dark:hover:bg-slate-700 transition-colors" onClick={() => handleBudgetClick(b)}>
                          <div className="flex items-center gap-3">
                            <div className="w-10 h-10 bg-white dark:bg-slate-700 rounded-2xl flex items-center justify-center text-lg shadow-sm">👑</div>
                            <div>
                               <p className="text-xs font-black text-slate-700 dark:text-slate-200">{b.name}</p>
                               <p className="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase">{b.currency} {b.totalBudget.toLocaleString()}</p>
                            </div>
                          </div>
                          <ChevronRight className="text-pastel-pink opacity-0 group-hover:opacity-100 transition-opacity" size={18} />
                        </div>
                      ))}
                   </div>
                </div>

                <div className="mt-auto pt-8">
                  <button 
                    onClick={() => {
                      setEditingBudget(null);
                      setShowNewModal(true);
                    }}
                    className="w-full py-5 bg-pastel-pink text-white rounded-[24px] font-black shadow-xl shadow-pastel-pink/20 hover:scale-[1.02] active:scale-95 transition-all flex items-center justify-center gap-2"
                  >
                    Create New Allocation <ChevronRight size={20} />
                  </button>
                </div>
              </div>
           </div>
        </section>
      </main>

      {/* Visual Summary Footer Bar */}
      <footer className="hidden xl:flex h-12 bg-white dark:bg-slate-900 border-t border-pastel-pink flex items-center justify-between px-8 text-[9px] font-black uppercase tracking-[0.2em] text-slate-400 shrink-0">
        <div>Active Profiles: {budgets.length}</div>
        <div className="flex gap-8">
          <span className="text-pastel-pink-dark">Syncing to Cloud... Sparkle Active ✨</span>
          <span className="hidden sm:inline">Sorted by: {sortBy === 'date' ? 'Date Created ↓' : 'Budget Amount ↓'}</span>
        </div>
      </footer>

      {/* Overlays */}
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
          />
        )}

        {budgetToUnlock && (
          <PinLock
            correctPin={budgetToUnlock.pin!}
            onSuccess={() => {
              setUnlockedBudgets(prev => new Set(prev).add(budgetToUnlock.id));
              setSelectedBudget(budgetToUnlock);
              setBudgetToUnlock(null);
            }}
            onCancel={() => setBudgetToUnlock(null)}
          />
        )}
      </AnimatePresence>
    </div>
  );
}
