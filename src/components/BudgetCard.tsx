import React from "react";
import { motion } from "motion/react";
import { Calendar, Pin, Trash2, Check } from "lucide-react";
import type { BudgetAllocation } from "../types";

interface BudgetCardProps {
  allocation: BudgetAllocation;
  onClick: () => void;
  isSelected?: boolean;
  onToggleSelect?: (e: React.MouseEvent) => void;
  onDelete?: (e: React.MouseEvent) => void;
}

const BudgetCard: React.FC<BudgetCardProps> = ({ 
  allocation, 
  onClick, 
  isSelected = false, 
  onToggleSelect, 
  onDelete 
}) => {
  const totalAllocated = allocation.categories.reduce((acc, cat) => acc + cat.allocatedAmount, 0);
  const progress = (totalAllocated / allocation.totalBudget) * 100;

  return (
    <motion.div
      layout
      whileHover={{ scale: 1.01 }}
      whileTap={{ scale: 0.99 }}
      onClick={onClick}
      className={`p-5 rounded-[32px] bg-white dark:bg-slate-800 border-2 shadow-sm mb-4 cursor-pointer relative overflow-hidden group transition-all duration-300 flex gap-4 items-center ${
        isSelected 
          ? "border-pastel-pink dark:border-pastel-pink ring-4 ring-pastel-pink/10" 
          : "border-pastel-pink/10 dark:border-pastel-pink/20"
      }`}
    >
      {/* Background shape */}
      <div className="absolute top-0 right-0 w-24 h-24 bg-pastel-pink-light/30 dark:bg-pastel-pink/10 rounded-full -mr-10 -mt-10 transition-transform group-hover:scale-110 pointer-events-none" />
      
      {/* Selection Checkbox on Left */}
      {onToggleSelect && (
        <button
          onClick={(e) => {
            e.stopPropagation();
            onToggleSelect(e);
          }}
          className={`w-6 h-6 rounded-xl border-2 flex items-center justify-center shrink-0 transition-all ${
            isSelected 
              ? "bg-pastel-pink border-pastel-pink text-white scale-110 shadow-md shadow-pastel-pink/20" 
              : "border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-900 hover:border-pastel-pink/50"
          }`}
        >
          {isSelected && <Check size={14} strokeWidth={4} />}
        </button>
      )}

      {/* Main Card Content */}
      <div className="relative z-10 flex-grow overflow-hidden">
        <div className="flex justify-between items-start mb-4">
          <div className="overflow-hidden">
            <h3 className="font-black text-lg text-slate-800 dark:text-white leading-tight truncate">{allocation.name}</h3>
            <p className="text-[10px] text-pastel-pink-dark font-black uppercase tracking-[0.2em] flex items-center gap-1 mt-0.5">
              <Calendar size={12} /> {allocation.daysToConsume} days left
            </p>
          </div>
          <div className="flex gap-1.5 items-center shrink-0 pl-2">
            {allocation.pin && (
              <div className="p-2 bg-pastel-pink-light/50 dark:bg-slate-700 rounded-xl text-pastel-pink-dark" title="Pinned to top">
                <Pin size={13} strokeWidth={3} className="rotate-45" />
              </div>
            )}
            {onDelete && (
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  onDelete(e);
                }}
                className="p-2 bg-red-50 dark:bg-red-950/20 text-red-400 hover:text-red-600 dark:hover:text-red-300 rounded-xl transition-colors opacity-80 hover:opacity-100 cursor-pointer"
                title="Delete Budget Plan"
              >
                <Trash2 size={13} strokeWidth={3} />
              </button>
            )}
          </div>
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
