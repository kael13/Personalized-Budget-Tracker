import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Sparkles, Loader2, PartyPopper, Zap, Heart } from "lucide-react";
import type { BudgetAllocation } from "../types";

interface AIRecommendationsProps {
  budgets: BudgetAllocation[];
}

export default function AIRecommendations({ budgets }: AIRecommendationsProps) {
  const [loading, setLoading] = useState(false);
  const [recommendations, setRecommendations] = useState<string[]>([]);
  const [error, setError] = useState<string | null>(null);

  const fetchRecommendations = async () => {
    if (budgets.length === 0) return;
    
    setLoading(true);
    setError(null);
    try {
      const response = await fetch("/api/analyze-spending", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ budgets })
      });
      
      if (!response.ok) throw new Error("Failed to get recommendations");
      
      const data = await response.json();
      setRecommendations(data.recommendations);
    } catch (err) {
      console.error(err);
      setError("AI is feeling shy right now. Try again later! 🌸");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (budgets.length > 0 && recommendations.length === 0) {
      fetchRecommendations();
    }
  }, [budgets]);

  if (budgets.length === 0) {
    return (
      <div className="p-8 text-center bg-white dark:bg-slate-800 rounded-[40px] border border-pastel-pink/10 shadow-sm">
        <Sparkles size={40} className="text-pastel-pink/30 mx-auto mb-4" />
        <p className="text-sm font-bold text-slate-400">
          Add some budget profiles to unlock AI royal secrets! ✨
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center mb-2 px-2">
        <h3 className="text-sm font-black text-pastel-pink-dark uppercase tracking-widest flex items-center gap-2">
          <Zap size={16} /> Latest Insights
        </h3>
        <button 
          onClick={fetchRecommendations}
          disabled={loading}
          className="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-tighter hover:text-pastel-pink transition-colors disabled:opacity-50"
        >
          {loading ? "Analyzing..." : "Refresh Sparkles ✨"}
        </button>
      </div>

      <AnimatePresence mode="wait">
        {loading ? (
          <motion.div
            key="loading"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="p-12 flex flex-col items-center justify-center bg-[#FFF8FA] dark:bg-slate-800 rounded-[40px] border-2 border-dashed border-pastel-pink/20"
          >
            <Loader2 size={32} className="text-pastel-pink-dark animate-spin mb-4" />
            <p className="text-[10px] font-black text-pastel-pink-dark uppercase tracking-widest">Gemini is thinking... 💅</p>
          </motion.div>
        ) : error ? (
          <motion.div
             key="error"
             className="p-8 text-center bg-red-50 dark:bg-red-900/10 rounded-[40px] border border-red-100 dark:border-red-900/20"
          >
            <p className="text-[10px] font-black text-red-400 uppercase tracking-widest">{error}</p>
          </motion.div>
        ) : (
          <motion.div
            key="content"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="space-y-4"
          >
            {recommendations.map((rec, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: i * 0.1 }}
                className="p-5 rounded-[28px] bg-[#FFF8FA] dark:bg-slate-800 border-l-4 border-l-pastel-pink-dark shadow-sm flex gap-4 items-start group hover:bg-pastel-pink-light dark:hover:bg-slate-700 transition-colors"
              >
                <div className="w-8 h-8 rounded-full bg-white dark:bg-slate-700 flex items-center justify-center shrink-0 text-pastel-pink-dark shadow-sm group-hover:scale-110 transition-transform">
                  {i === 0 ? <Heart size={16} /> : i === 1 ? <PartyPopper size={16} /> : <Zap size={16} />}
                </div>
                <p className="text-sm text-slate-600 dark:text-slate-300 leading-relaxed font-bold">
                  {rec}
                </p>
              </motion.div>
            ))}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
