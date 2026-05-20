import React from "react";
import { ChevronRight } from "lucide-react";
import type { BudgetAllocation } from "../types";

interface NewProfileCardProps {
  budgets: BudgetAllocation[];
  onBudgetClick: (budget: BudgetAllocation) => void;
  onCreateNew: () => void;
}

export default function NewProfileCard({
  budgets,
  onBudgetClick,
  onCreateNew,
}: NewProfileCardProps) {
  return (
    <div className="bg-white dark:bg-slate-900 rounded-[40px] border border-pastel-pink/20 dark:border-pastel-pink/5 shadow-sm p-8 flex flex-col relative overflow-hidden transition-colors">
      <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-pastel-pink via-accent to-pastel-pink"></div>
      
      <h3 className="text-xl font-black mb-8 text-slate-800 dark:text-white">New Allocation Profile</h3>
      
      <div className="space-y-6">
        <p className="text-slate-400 dark:text-slate-500 text-sm font-medium leading-relaxed">
          Create a fresh budget allocation to keep your sparkle in check. Every girl needs a plan! 🎀
        </p>
        
        <div className="grid grid-cols-1 gap-4">
          {budgets.slice(0, 3).map((b) => (
            <div 
              key={b.id} 
              className="p-4 rounded-3xl bg-pastel-pink-light/30 dark:bg-slate-800/80 border border-pastel-pink/10 dark:border-slate-700/50 flex justify-between items-center group cursor-pointer hover:bg-pastel-pink-light dark:hover:bg-slate-700 transition-colors" 
              onClick={() => onBudgetClick(b)}
            >
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-white dark:bg-slate-700 rounded-2xl flex items-center justify-center text-lg shadow-sm">👑</div>
                <div>
                  <p className="text-xs font-black text-slate-700 dark:text-slate-200">{b.name}</p>
                  <p className="text-[10px] font-bold text-slate-400 dark:text-slate-500 uppercase font-mono">{b.currency} {b.totalBudget.toLocaleString()}</p>
                </div>
              </div>
              <ChevronRight className="text-pastel-pink opacity-0 group-hover:opacity-100 transition-opacity" size={18} />
            </div>
          ))}
        </div>
      </div>

      <div className="mt-auto pt-8">
        <button 
          onClick={onCreateNew}
          className="w-full py-5 bg-pastel-pink text-white rounded-[24px] font-black shadow-xl shadow-pastel-pink/20 hover:scale-[1.02] active:scale-95 transition-all flex items-center justify-center gap-2 cursor-pointer"
        >
          Create New Allocation <ChevronRight size={20} />
        </button>
      </div>
    </div>
  );
}
