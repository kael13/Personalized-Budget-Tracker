import React from "react";
import { motion } from "motion/react";
import { X, Trash2, Edit2, Share2, TrendingUp, Wallet, ArrowDown } from "lucide-react";
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend } from "recharts";
import type { BudgetAllocation } from "../types";

interface DetailSheetProps {
  budget: BudgetAllocation;
  onClose: () => void;
  onEdit: () => void;
  onDelete: () => void;
}

const COLORS = ["#FF8EAD", "#FFC5D3", "#FF85A1", "#FFD1DC", "#FADADD", "#FFB7C5", "#E5B0BC"];

export default function DetailSheet({ budget, onClose, onEdit, onDelete }: DetailSheetProps) {
  const totalAllocated = budget.categories.reduce((acc, cat) => acc + cat.allocatedAmount, 0);
  const remaining = budget.totalBudget - totalAllocated;

  const chartData = budget.categories
    .filter(cat => cat.allocatedAmount > 0)
    .map((cat, index) => ({
      name: cat.name || `Category ${index + 1}`,
      value: cat.allocatedAmount
    }));

  if (remaining > 0) {
    chartData.push({
      name: "Unallocated",
      value: remaining
    });
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center p-0 bg-black/40 backdrop-blur-sm">
      <motion.div
        initial={{ y: "100%" }}
        animate={{ y: 0 }}
        exit={{ y: "100%" }}
        className="w-full max-w-lg bg-white dark:bg-slate-900 rounded-t-[40px] overflow-hidden shadow-2xl flex flex-col h-[85vh]"
      >
        <div className="w-12 h-1.5 bg-pastel-pink dark:bg-slate-700 rounded-full mx-auto mt-4 shrink-0 shadow-sm" />
        
        {/* Header */}
        <div className="px-8 pt-6 pb-4 flex justify-between items-start">
          <div>
            <h2 className="text-2xl font-black text-slate-800 dark:text-white leading-tight">{budget.name}</h2>
            <div className="flex items-center gap-2 mt-1">
              <span className="text-xs font-black text-pastel-pink-dark px-2 py-0.5 bg-pastel-pink-light dark:bg-pastel-pink/10 rounded-full uppercase tracking-widest font-mono">
                {budget.currency} {budget.totalBudget.toLocaleString()} Total
              </span>
            </div>
          </div>
          <div className="flex gap-2">
            <button onClick={onEdit} className="p-3 bg-pastel-pink-light dark:bg-slate-800 text-pastel-pink-dark rounded-full hover:bg-pastel-pink hover:text-white transition-all shadow-sm">
              <Edit2 size={18} />
            </button>
            <button onClick={onClose} className="p-3 bg-pastel-pink-light dark:bg-slate-800 text-pastel-pink-dark rounded-full hover:bg-pastel-pink hover:text-white transition-all shadow-sm">
              <X size={18} />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto px-8 py-4 space-y-6">
          {/* Summary Cards */}
          <div className="grid grid-cols-2 gap-4">
            <div className="p-4 rounded-3xl bg-pastel-pink-light/30 border border-pastel-pink/20">
              <div className="flex items-center gap-2 text-pastel-pink-dark mb-1">
                <Wallet size={14} />
                <span className="text-[10px] font-black uppercase tracking-wider">Allocated</span>
              </div>
              <p className="text-lg font-black text-slate-800 dark:text-white font-mono">
                {budget.currency} {totalAllocated.toLocaleString()}
              </p>
            </div>
            <div className={`p-4 rounded-3xl border border-dashed transition-colors ${remaining >= 0 ? 'bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700' : 'bg-red-50 dark:bg-red-900/10 border-red-200 dark:border-red-900/20'}`}>
              <div className={`flex items-center gap-2 mb-1 ${remaining >= 0 ? 'text-slate-400 dark:text-slate-500' : 'text-red-400 dark:text-red-500'}`}>
                <ArrowDown size={14} />
                <span className="text-[10px] font-black uppercase tracking-wider">{remaining >= 0 ? 'Remaining' : 'Over Limit'}</span>
              </div>
              <p className={`text-lg font-black font-mono ${remaining >= 0 ? 'text-slate-800 dark:text-white' : 'text-red-500'}`}>
                {budget.currency} {Math.abs(remaining).toLocaleString()}
              </p>
            </div>
          </div>

          {/* Graph Summary */}
          {budget.categories.length > 0 && (
            <div className="bg-white dark:bg-slate-800 rounded-3xl p-4 border border-slate-100 dark:border-slate-700 shadow-sm">
              <h3 className="text-sm font-black text-slate-400 uppercase tracking-[0.2em] mb-4">Allocation Graph</h3>
              <div className="h-64 w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={chartData}
                      cx="50%"
                      cy="50%"
                      innerRadius={60}
                      outerRadius={80}
                      paddingAngle={5}
                      dataKey="value"
                    >
                      {chartData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.name === "Unallocated" ? "#E2E8F0" : COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip 
                      contentStyle={{ 
                        borderRadius: '16px', 
                        border: 'none', 
                        boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)',
                        fontSize: '12px',
                        fontWeight: 'bold'
                      }}
                    />
                    <Legend 
                      verticalAlign="bottom" 
                      height={36}
                      formatter={(value) => <span className="text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-tight">{value}</span>}
                    />
                  </PieChart>
                </ResponsiveContainer>
              </div>
            </div>
          )}

          {/* Categories List */}
          <div className="space-y-3">
            <h3 className="text-sm font-black text-slate-400 uppercase tracking-[0.2em] mb-4">Breakdown</h3>
            {budget.categories.length === 0 ? (
              <p className="text-center py-10 text-slate-300 italic text-sm">No categories added yet. 🌸</p>
            ) : (
              budget.categories.map((cat) => (
                <div key={cat.id} className="p-5 rounded-3xl bg-white dark:bg-slate-800 border border-pastel-pink/10 dark:border-slate-700 flex justify-between items-center shadow-sm">
                  <div>
                    <h4 className="font-bold text-slate-700 dark:text-slate-200">{cat.name || "Unnamed Category"}</h4>
                    <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mt-0.5">Category</p>
                  </div>
                  <div className="text-right">
                    <p className="font-black text-pastel-pink-dark leading-none font-mono">
                      {budget.currency} {cat.allocatedAmount.toLocaleString()}
                    </p>
                    <p className="text-[10px] font-black text-slate-300 dark:text-slate-500 uppercase tracking-tighter mt-1 font-mono">
                      {Math.round((cat.allocatedAmount / budget.totalBudget) * 100)}% of total
                    </p>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Footer */}
        <div className="p-8 bg-pastel-pink-light/50 dark:bg-slate-800/50 flex gap-4 transition-colors">
          <button
            onClick={onDelete}
            className="flex-1 py-4 bg-white dark:bg-slate-800 border border-pastel-pink/20 text-pastel-pink-dark rounded-3xl font-black text-sm flex items-center justify-center gap-2 active:bg-red-50 hover:bg-pastel-pink-light/30 transition-all shadow-sm"
          >
            <Trash2 size={20} /> Delete Profile
          </button>
          <button
            className="flex-1 py-4 bg-pastel-pink text-white rounded-3xl font-black text-sm flex items-center justify-center gap-2 active:scale-95 transition-all shadow-lg shadow-pastel-pink/30 hover:bg-pastel-pink-dark"
          >
            <Share2 size={20} /> Export PDF
          </button>
        </div>
      </motion.div>
    </div>
  );
}
