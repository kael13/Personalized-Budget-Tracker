import React, { useState, useEffect } from "react";
import { motion } from "motion/react";
import { X, Trash2, Edit2, Share2, Wallet, ArrowDown, Plus, Info } from "lucide-react";
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend } from "recharts";
import type { BudgetAllocation, Category } from "../types";

interface DetailSheetProps {
  budget: BudgetAllocation;
  onClose: () => void;
  onEdit: () => void;
  onDelete: () => void;
  onUpdate: (updatedBudget: BudgetAllocation) => Promise<void>;
}

const COLORS = ["#FF8EAD", "#FFC5D3", "#FF85A1", "#FFD1DC", "#FADADD", "#FFB7C5", "#E5B0BC"];

export default function DetailSheet({ budget, onClose, onEdit, onDelete, onUpdate }: DetailSheetProps) {
  const [localCategories, setLocalCategories] = useState<Category[]>(budget.categories);

  useEffect(() => {
    setLocalCategories(budget.categories);
  }, [budget.categories]);

  const totalAllocated = localCategories.reduce((acc, cat) => acc + cat.allocatedAmount, 0);
  const remaining = budget.totalBudget - totalAllocated;

  const chartData = localCategories
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

  const addCategory = () => {
    const newId = typeof crypto !== 'undefined' && crypto.randomUUID 
      ? crypto.randomUUID() 
      : Math.random().toString(36).substring(2, 15);

    const newCat: Category = {
      id: newId,
      name: "",
      allocatedAmount: 0,
      spentAmount: 0,
      subCategories: []
    };
    setLocalCategories([...localCategories, newCat]);
  };

  const updateCategory = (id: string, updates: Partial<Category>) => {
    setLocalCategories(localCategories.map(c => c.id === id ? { ...c, ...updates } : c));
  };

  const removeCategory = (id: string) => {
    setLocalCategories(localCategories.filter(c => c.id !== id));
  };

  const hasEmptyNames = localCategories.some(cat => !cat.name.trim());
  const hasNegativeAmounts = localCategories.some(cat => cat.allocatedAmount < 0);
  const isOverBudget = totalAllocated > budget.totalBudget;

  let validationError = "";
  if (isOverBudget) {
    validationError = "Oops! You've allocated more than your total budget. Adjust amounts to save! 🎀";
  } else if (hasEmptyNames) {
    validationError = "Category names cannot be empty! ✨";
  } else if (hasNegativeAmounts) {
    validationError = "Allocated amount cannot be negative! 💖";
  }

  const isDirty = JSON.stringify(localCategories) !== JSON.stringify(budget.categories);

  const handleSave = async () => {
    if (validationError) return;
    const updatedBudget: BudgetAllocation = {
      ...budget,
      categories: localCategories
    };
    await onUpdate(updatedBudget);
  };

  const handleDiscard = () => {
    setLocalCategories(budget.categories);
  };

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
          {localCategories.length > 0 && (
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
          <div className="space-y-4">
            <div className="flex justify-between items-center">
              <h3 className="text-sm font-black text-slate-400 uppercase tracking-[0.2em]">Breakdown</h3>
              {isDirty && (
                <span className="text-[9px] font-black text-pastel-pink-dark bg-pastel-pink-light dark:bg-pastel-pink/15 px-2.5 py-1 rounded-full uppercase tracking-wider animate-pulse select-none">
                  Unsaved Changes ✨
                </span>
              )}
            </div>

            {validationError && (
              <div className="p-4 rounded-2xl bg-red-50 dark:bg-red-950/20 border border-red-100 dark:border-red-900/30 text-red-500 text-[10px] font-black uppercase tracking-widest leading-relaxed flex items-center gap-2 shadow-sm">
                <Info size={16} className="shrink-0 text-red-400" />
                <p>{validationError}</p>
              </div>
            )}

            <div className="overflow-x-auto rounded-3xl border border-pastel-pink/20 dark:border-slate-700 bg-slate-50/30 dark:bg-slate-800/10">
              <table className="w-full border-collapse text-left text-sm">
                <thead>
                  <tr className="border-b border-pastel-pink/10 dark:border-slate-700 bg-pastel-pink-light/40 dark:bg-slate-800/40 select-none">
                    <th scope="col" className="px-4 py-3 text-[10px] font-black text-slate-450 dark:text-slate-400 uppercase tracking-wider">Category</th>
                    <th scope="col" className="px-4 py-3 text-[10px] font-black text-slate-450 dark:text-slate-400 uppercase tracking-wider text-right w-32">Amount</th>
                    <th scope="col" className="px-4 py-3 text-[10px] font-black text-slate-450 dark:text-slate-400 uppercase tracking-wider text-center w-14">Action</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-pastel-pink/10 dark:divide-slate-700">
                  {localCategories.length === 0 ? (
                    <tr>
                      <td colSpan={3} className="text-center py-10 text-slate-350 dark:text-slate-550 italic text-sm">
                        No categories added yet. 🌸
                      </td>
                    </tr>
                  ) : (
                    localCategories.map((cat) => (
                      <tr 
                        key={cat.id} 
                        className="hover:bg-pastel-pink-light/20 dark:hover:bg-slate-800/10 transition-colors duration-200"
                      >
                        <td className="px-2 py-2">
                          <input
                            type="text"
                            placeholder="Category Name 🌸"
                            className="w-full p-2 bg-transparent outline-none font-bold text-slate-700 dark:text-slate-200 border border-transparent focus:border-pastel-pink/30 focus:bg-white dark:focus:bg-slate-850 rounded-xl transition-all"
                            value={cat.name}
                            onChange={e => updateCategory(cat.id, { name: e.target.value })}
                          />
                        </td>
                        <td className="px-2 py-2">
                          <div className="flex items-center gap-1 bg-transparent px-2 border border-transparent focus-within:border-pastel-pink/30 focus-within:bg-white dark:focus-within:bg-slate-850 rounded-xl transition-all">
                            <span className="text-[10px] font-black text-slate-400 dark:text-slate-500 font-mono select-none">
                              {budget.currency}
                            </span>
                            <input
                              type="number"
                              placeholder="0"
                              className="w-full p-2 bg-transparent outline-none font-black text-right text-pastel-pink-dark font-mono text-xs"
                              value={cat.allocatedAmount || ""}
                              onChange={e => updateCategory(cat.id, { allocatedAmount: Number(e.target.value) })}
                            />
                          </div>
                        </td>
                        <td className="px-2 py-2 text-center">
                          <button
                            onClick={() => removeCategory(cat.id)}
                            className="p-1.5 text-slate-300 dark:text-slate-600 hover:text-red-400 active:scale-90 transition-all cursor-pointer inline-flex items-center justify-center rounded-xl hover:bg-red-50 dark:hover:bg-red-950/15 shrink-0"
                            title="Remove Category"
                          >
                            <Trash2 size={15} />
                          </button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>

            <button
              onClick={addCategory}
              className="w-full py-4 border-2 border-dashed border-pastel-pink/30 dark:border-pastel-pink/20 rounded-3xl flex items-center justify-center gap-2 text-pastel-pink-dark font-black text-xs uppercase tracking-widest hover:bg-pastel-pink-light dark:hover:bg-slate-800/50 transition-colors cursor-pointer select-none"
            >
              <Plus size={16} /> Add Category
            </button>
          </div>
        </div>

        {/* Footer */}
        <div className="p-8 bg-pastel-pink-light/50 dark:bg-slate-800/50 flex gap-4 transition-colors">
          {isDirty ? (
            <>
              <button
                onClick={handleDiscard}
                className="flex-1 py-4 bg-white dark:bg-slate-800 border border-pastel-pink/20 text-slate-500 hover:text-pastel-pink-dark rounded-3xl font-black text-sm flex items-center justify-center gap-2 active:scale-95 transition-all shadow-sm cursor-pointer select-none"
              >
                Discard
              </button>
              <button
                onClick={handleSave}
                disabled={!!validationError}
                className={`flex-1 py-4 text-white rounded-3xl font-black text-sm flex items-center justify-center gap-2 active:scale-95 transition-all shadow-lg select-none cursor-pointer ${
                  validationError
                    ? "bg-slate-300 dark:bg-slate-700 cursor-not-allowed shadow-none"
                    : "bg-pastel-pink shadow-pastel-pink/30 hover:bg-pastel-pink-dark"
                }`}
              >
                Save Changes ✨
              </button>
            </>
          ) : (
            <>
              <button
                onClick={onDelete}
                className="flex-1 py-4 bg-white dark:bg-slate-800 border border-pastel-pink/20 text-pastel-pink-dark rounded-3xl font-black text-sm flex items-center justify-center gap-2 active:bg-red-50 hover:bg-pastel-pink-light/30 transition-all shadow-sm cursor-pointer select-none"
              >
                <Trash2 size={20} /> Delete Profile
              </button>
              <button
                className="flex-1 py-4 bg-pastel-pink text-white rounded-3xl font-black text-sm flex items-center justify-center gap-2 active:scale-95 transition-all shadow-lg shadow-pastel-pink/30 hover:bg-pastel-pink-dark cursor-pointer select-none"
              >
                <Share2 size={20} /> Export PDF
              </button>
            </>
          )}
        </div>
      </motion.div>
    </div>
  );
}
