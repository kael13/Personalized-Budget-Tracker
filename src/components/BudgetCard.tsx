import React from "react";
import { motion } from "motion/react";
import { Calendar, Shield } from "lucide-react";
import type { BudgetAllocation } from "../types";

interface BudgetCardProps {
  allocation: BudgetAllocation;
  onClick: () => void;
}

const BudgetCard: React.FC<BudgetCardProps> = ({ allocation, onClick }) => {
  const totalAllocated = allocation.categories.reduce((acc, cat) => acc + cat.allocatedAmount, 0);
  const progress = (totalAllocated / allocation.totalBudget) * 100;

  return (
    <motion.div
      layout
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      onClick={onClick}
      className="p-5 rounded-[32px] bg-white dark:bg-slate-800 border-2 border-pastel-pink/10 dark:border-pastel-pink/20 shadow-sm mb-4 cursor-pointer relative overflow-hidden group transition-all"
    >
      <div className="absolute top-0 right-0 w-24 h-24 bg-pastel-pink-light/30 dark:bg-pastel-pink/10 rounded-full -mr-10 -mt-10 transition-transform group-hover:scale-110" />
      
      <div className="relative z-10">
        <div className="flex justify-between items-start mb-4">
          <div>
            <h3 className="font-black text-lg text-slate-800 dark:text-white leading-tight">{allocation.name}</h3>
            <p className="text-[10px] text-pastel-pink-dark font-black uppercase tracking-[0.2em] flex items-center gap-1 mt-0.5">
              <Calendar size={12} /> {allocation.daysToConsume} days left
            </p>
          </div>
          {allocation.pin && (
            <div className="p-2 bg-pastel-pink-light/50 dark:bg-slate-700 rounded-full text-pastel-pink-dark">
                <Shield size={14} strokeWidth={3} />
            </div>
          )}
        </div>
        
        <div className="flex justify-between items-end mb-2">
          <div className="space-y-0.5">
            <p className="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-tighter">Budget Progress</p>
            <p className="text-sm font-black text-slate-800 dark:text-slate-200 font-mono">
               <span className="text-pastel-pink-dark">{allocation.currency} {totalAllocated.toLocaleString()}</span>
               <span className="text-slate-300 dark:text-slate-600 font-medium italic"> / {allocation.totalBudget.toLocaleString()}</span>
            </p>
          </div>
          <span className={`text-[10px] font-black p-1.5 rounded-lg ${progress > 90 ? 'bg-red-50 dark:bg-red-900/20 text-red-500' : 'bg-pastel-pink-light dark:bg-pastel-pink/10 text-pastel-pink-dark'}`}>
            {Math.round(progress)}%
          </span>
        </div>
        
        <div className="w-full h-3 bg-slate-50 dark:bg-slate-900/50 rounded-full overflow-hidden border border-pastel-pink/5 dark:border-slate-700">
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: `${Math.min(progress, 100)}%` }}
            transition={{ type: "spring", stiffness: 100, damping: 20 }}
            className={`h-full rounded-full transition-colors ${
              progress > 100 
                ? 'bg-red-400' 
                : 'bg-pastel-pink'
            }`}
          />
        </div>
      </div>
    </motion.div>
  );
};

export default BudgetCard;
