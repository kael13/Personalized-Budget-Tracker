import React, { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { X, ChevronRight, ChevronLeft, Plus, Trash2, Shield, Info } from "lucide-react";
import { BudgetAllocation, Category, SubCategory } from "../types";
import { db } from "../services/db";

interface BudgetModalProps {
  onClose: () => void;
  onSave: (budget: BudgetAllocation) => void;
  initialData?: BudgetAllocation | null;
}

export default function BudgetModal({ onClose, onSave, initialData }: BudgetModalProps) {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState<Partial<BudgetAllocation>>(
    initialData || {
      name: "",
      totalBudget: 0,
      currency: "PHP",
      daysToConsume: 30,
      pin: "",
      categories: []
    }
  );

  const [errors, setErrors] = useState<string[]>([]);

  const handleNext = () => {
    let newErrors: string[] = [];
    if (step === 1) {
      if (!formData.name) newErrors.push("Budget name is required ✨");
      if (!formData.totalBudget || formData.totalBudget <= 0) newErrors.push("Please enter a valid amount 💖");
      if (!formData.daysToConsume || formData.daysToConsume <= 0) newErrors.push("How many days will this sparkle? 🌸");
    }
    
    if (newErrors.length > 0) {
      setErrors(newErrors);
      return;
    }
    setErrors([]);
    setStep(step + 1);
  };

  const handleSave = () => {
    const totalAllocated = formData.categories?.reduce((acc, cat) => acc + cat.allocatedAmount, 0) || 0;
    
    if (totalAllocated > (formData.totalBudget || 0)) {
      setErrors(["Oops! You've allocated more than your budget. Please adjust your categories! 🎀"]);
      return;
    }

    onSave({
      id: initialData?.id || db.generateId(),
      createdAt: initialData?.createdAt || new Date().toISOString(),
      ...(formData as BudgetAllocation)
    });
  };

  const addCategory = () => {
    const newCat: Category = {
      id: db.generateId(),
      name: "",
      allocatedAmount: 0,
      spentAmount: 0,
      subCategories: []
    };
    setFormData({ ...formData, categories: [...(formData.categories || []), newCat] });
  };

  const updateCategory = (id: string, updates: Partial<Category>) => {
    setFormData({
      ...formData,
      categories: formData.categories?.map(c => c.id === id ? { ...c, ...updates } : c)
    });
  };

  const removeCategory = (id: string) => {
    setFormData({
      ...formData,
      categories: formData.categories?.filter(c => c.id !== id)
    });
  };

  const addSubCategory = (categoryId: string) => {
    const newSub: SubCategory = {
      id: db.generateId(),
      name: "",
      allocatedAmount: 0,
      spentAmount: 0
    };
    setFormData({
      ...formData,
      categories: formData.categories?.map(c => 
        c.id === categoryId 
          ? { ...c, subCategories: [...(c.subCategories || []), newSub] } 
          : c
      )
    });
  };

  const updateSubCategory = (categoryId: string, subId: string, updates: Partial<SubCategory>) => {
    setFormData({
      ...formData,
      categories: formData.categories?.map(c => 
        c.id === categoryId 
          ? { 
              ...c, 
              subCategories: c.subCategories?.map(s => s.id === subId ? { ...s, ...updates } : s) 
            } 
          : c
      )
    });
  };

  const removeSubCategory = (categoryId: string, subId: string) => {
    setFormData({
      ...formData,
      categories: formData.categories?.map(c => 
        c.id === categoryId 
          ? { ...c, subCategories: c.subCategories?.filter(s => s.id !== subId) } 
          : c
      )
    });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/40 backdrop-blur-sm">
      <motion.div
        initial={{ y: "100%" }}
        animate={{ y: 0 }}
        exit={{ y: "100%" }}
        className="w-full max-w-lg bg-white dark:bg-slate-900 rounded-t-[40px] sm:rounded-[40px] overflow-hidden shadow-2xl flex flex-col max-h-[90vh] relative"
      >
        <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-pastel-pink via-accent to-pastel-pink shrink-0"></div>
        
        {/* Modal Header */}
        <div className="px-6 pt-8 pb-4 flex justify-between items-center border-b border-pastel-pink/20">
          <div>
            <span className="text-[10px] font-black uppercase tracking-[0.2em] text-pastel-pink-dark">Step {step} of 3</span>
            <h2 className="text-xl font-black text-slate-800 dark:text-white">
              {step === 1 ? "New Budget Plan" : step === 2 ? "Categorize Sparkle" : "Privacy Lock"}
            </h2>
          </div>
          <button onClick={onClose} className="p-2 rounded-full bg-pastel-pink-light dark:bg-slate-800 text-slate-400 hover:text-pastel-pink-dark transition-colors">
            <X size={20} />
          </button>
        </div>

        {/* Modal Content */}
        <div className="flex-1 overflow-y-auto p-6 space-y-6">
          {errors.length > 0 && (
            <motion.div initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} className="p-4 rounded-2xl bg-red-50 border border-red-100 text-red-500 text-[10px] font-black uppercase tracking-widest leading-relaxed">
              {errors.map((e, i) => <p key={i}>{e}</p>)}
            </motion.div>
          )}

          {step === 1 && (
            <div className="space-y-4">
              <div>
                <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Budget Name</label>
                <input
                  type="text"
                  placeholder="e.g. Shopping Haul 🛍️"
                  className="w-full p-4 rounded-2xl bg-[#FFF8FA] dark:bg-slate-800 border-2 border-pastel-pink/20 focus:border-pastel-pink-dark focus:ring-4 focus:ring-pastel-pink/10 outline-none transition-all text-slate-700 dark:text-white font-black"
                  value={formData.name}
                  onChange={e => setFormData({ ...formData, name: e.target.value })}
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Amount</label>
                    <input
                      type="number"
                      placeholder="5000"
                      className="w-full p-4 rounded-2xl bg-slate-50 dark:bg-slate-800 border-2 border-pastel-pink/20 focus:border-pastel-pink-dark focus:ring-4 focus:ring-pastel-pink/10 outline-none transition-all text-slate-700 dark:text-white font-black font-mono"
                      value={formData.totalBudget || ""}
                      onChange={e => setFormData({ ...formData, totalBudget: Number(e.target.value) })}
                    />
                </div>
                <div>
                  <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Currency</label>
                  <select
                    className="w-full p-4 rounded-2xl bg-[#FFF8FA] dark:bg-slate-800 border-2 border-pastel-pink/20 focus:border-pastel-pink-dark focus:ring-4 focus:ring-pastel-pink/10 outline-none transition-all text-slate-700 dark:text-white font-black appearance-none"
                    value={formData.currency}
                    onChange={e => setFormData({ ...formData, currency: e.target.value })}
                  >
                    <option value="PHP">PHP 🇵🇭</option>
                    <option value="USD">USD 🇺🇸</option>
                    <option value="EUR">EUR 🇪🇺</option>
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-2">Days to Consume</label>
                <input
                  type="number"
                  placeholder="30"
                  className="w-full p-4 rounded-2xl bg-[#FFF8FA] dark:bg-slate-800 border-2 border-pastel-pink/20 focus:border-pastel-pink-dark focus:ring-4 focus:ring-pastel-pink/10 outline-none transition-all text-slate-700 dark:text-white font-black"
                  value={formData.daysToConsume || ""}
                  onChange={e => setFormData({ ...formData, daysToConsume: Number(e.target.value) })}
                />
              </div>
            </div>
          )}

          {step === 2 && (
            <div className="space-y-4">
              <div className="p-4 rounded-2xl bg-pastel-pink-light dark:bg-pastel-pink/10 border border-pastel-pink/20 flex gap-3 items-center">
                <Info size={18} className="text-pastel-pink-dark shrink-0" />
                <p className="text-[10px] text-pastel-pink-dark font-black uppercase tracking-widest leading-tight">
                  Total Allocated: <span className="font-mono">{formData.currency} {formData.categories?.reduce((acc, c) => acc + c.allocatedAmount, 0).toLocaleString()} / {formData.totalBudget?.toLocaleString()}</span>
                </p>
              </div>

              <div className="space-y-4">
                {formData.categories?.map((cat) => {
                  const subTotal = cat.subCategories?.reduce((sum, s) => sum + s.allocatedAmount, 0) || 0;
                  const isOver = subTotal > cat.allocatedAmount;

                  return (
                    <div key={cat.id} className="p-4 rounded-3xl bg-slate-50 dark:bg-slate-800/50 border border-pastel-salmon/30 space-y-3 relative transition-colors shadow-sm">
                      <div className="flex gap-4 items-center">
                        <input
                          type="text"
                          placeholder="Category Name"
                          className="flex-1 p-2 bg-transparent outline-none text-sm font-black text-slate-800 dark:text-white border-b border-pastel-pink/10 focus:border-pastel-coral/50"
                          value={cat.name}
                          onChange={e => updateCategory(cat.id, { name: e.target.value })}
                        />
                        <div className="flex items-center gap-1 bg-transparent px-2 border-b border-pastel-pink/10 focus-within:border-pastel-coral/50 font-mono text-sm font-black">
                          <span className="text-[10px] text-slate-400 select-none">{formData.currency}</span>
                          <input
                            type="number"
                            placeholder="Amount"
                            className="w-24 p-2 bg-transparent outline-none text-right text-pastel-pink-dark font-black font-mono text-xs"
                            value={cat.allocatedAmount || ""}
                            onChange={e => updateCategory(cat.id, { allocatedAmount: Number(e.target.value) })}
                          />
                        </div>
                        <button onClick={() => removeCategory(cat.id)} className="text-slate-300 dark:text-slate-600 hover:text-red-400 transition-colors cursor-pointer p-1">
                          <Trash2 size={16} />
                        </button>
                      </div>

                      {/* Subcategories list */}
                      <div className="pl-6 border-l-2 border-dashed border-pastel-salmon/30 space-y-2">
                        {cat.subCategories?.map((sub) => (
                          <div key={sub.id} className="flex gap-3 items-center">
                            <input
                              type="text"
                              placeholder="Subcategory (e.g. Coffee ☕)"
                              className="flex-1 p-1.5 bg-transparent outline-none text-xs font-semibold text-slate-600 dark:text-slate-300 border-b border-slate-100 dark:border-slate-800 focus:border-pastel-coral/40"
                              value={sub.name}
                              onChange={e => updateSubCategory(cat.id, sub.id, { name: e.target.value })}
                            />
                            <div className="flex items-center gap-1 bg-transparent px-1 border-b border-slate-100 dark:border-slate-800 focus-within:border-pastel-coral/40 font-mono text-xs font-semibold">
                              <span className="text-[8px] text-slate-400">{formData.currency}</span>
                              <input
                                type="number"
                                placeholder="0"
                                className="w-16 p-1 bg-transparent outline-none text-right text-pastel-pink-dark font-bold font-mono text-[10px]"
                                value={sub.allocatedAmount || ""}
                                onChange={e => updateSubCategory(cat.id, sub.id, { allocatedAmount: Number(e.target.value) })}
                              />
                            </div>
                            <button onClick={() => removeSubCategory(cat.id, sub.id)} className="text-slate-300 dark:text-slate-600 hover:text-red-400 transition-colors cursor-pointer p-1">
                              <Trash2 size={13} />
                            </button>
                          </div>
                        ))}

                        {/* Add Subcategory Trigger */}
                        <div className="flex justify-between items-center pt-1">
                          <button
                            onClick={() => addSubCategory(cat.id)}
                            className="text-[9px] font-black text-pastel-pink-dark hover:text-accent flex items-center gap-1 uppercase tracking-widest cursor-pointer select-none"
                          >
                            <Plus size={11} strokeWidth={3} /> Add Subcategory
                          </button>
                          {cat.allocatedAmount > 0 && (
                            <span className={`text-[8px] font-black uppercase tracking-tight ${isOver ? "text-red-500 font-bold" : "text-slate-400"}`}>
                              {formData.currency} {subTotal.toLocaleString()} / {cat.allocatedAmount.toLocaleString()} Allocated
                            </span>
                          )}
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>

              <button
                onClick={addCategory}
                className="w-full py-5 border-2 border-dashed border-pastel-pink/30 dark:border-pastel-pink/20 rounded-3xl flex items-center justify-center gap-2 text-pastel-pink-dark font-black text-xs uppercase tracking-widest hover:bg-pastel-pink-light dark:hover:bg-slate-800/50 transition-colors"
              >
                <Plus size={18} /> Add Category
              </button>
            </div>
          )}

          {step === 3 && (
            <div className="space-y-6 text-center py-8">
               <div className="w-24 h-24 bg-pastel-pink-light rounded-full flex items-center justify-center mx-auto mb-4 text-pastel-pink-dark shadow-inner shadow-pastel-pink/20">
                 <Shield size={48} />
               </div>
               <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest px-12 leading-relaxed">
                 Protect your budget secrets with a 6-digit PIN. ✨
               </p>
               <input
                 type="password"
                 maxLength={6}
                 placeholder="••••••"
                 className="w-full max-w-[240px] mx-auto p-5 rounded-3xl bg-slate-50 dark:bg-slate-800 border-2 border-pastel-pink/20 focus:border-pastel-pink-dark outline-none transition-all text-3xl tracking-[0.8em] text-center font-black text-pastel-pink-dark font-mono"
                 value={formData.pin || ""}
                 onChange={e => setFormData({ ...formData, pin: e.target.value.replace(/\D/g, '') })}
               />
            </div>
          )}
        </div>

        {/* Modal Footer */}
        <div className="p-6 bg-pastel-pink-light/50 dark:bg-slate-800/30 flex gap-4 shrink-0 transition-colors">
          {step > 1 && (
            <button
              onClick={() => setStep(step - 1)}
              className="px-6 py-4 rounded-[20px] bg-white dark:bg-slate-800 text-slate-300 font-black border border-pastel-pink/20 active:scale-95 transition-all outline-none"
            >
              <ChevronLeft size={24} />
            </button>
          )}
          <button
            onClick={step === 3 ? handleSave : handleNext}
            className="flex-1 py-4 bg-pastel-pink text-white rounded-[20px] font-black shadow-lg shadow-pastel-pink/40 flex items-center justify-center gap-2 active:scale-95 transition-all outline-none"
          >
            {step === 3 ? "Sparkle & Save ✨" : "Next Step"}
            <ChevronRight size={20} />
          </button>
        </div>
      </motion.div>
    </div>
  );
}
