import React, { useState } from "react";
import { Sparkles } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";

interface PeriodStat {
  amount: number;
  count: number;
}

interface OverviewStatsProps {
  periodStats: {
    weekly: PeriodStat;
    monthly: PeriodStat;
    quarterly: PeriodStat;
    yearly: PeriodStat;
  };
  activeProfilesCount: number;
  maxDaysLeft: number | string;
}

export default function OverviewStats({
  periodStats,
  activeProfilesCount,
  maxDaysLeft,
}: OverviewStatsProps) {
  const [selectedPeriod, setSelectedPeriod] = useState<"weekly" | "monthly" | "quarterly" | "yearly">("monthly");

  const currentStat = periodStats[selectedPeriod];

  const periods = [
    { id: "weekly", label: "Weekly" },
    { id: "monthly", label: "Monthly" },
    { id: "quarterly", label: "Quarterly" },
    { id: "yearly", label: "Yearly" },
  ] as const;

  // Visual helper for premium gradient background highlights depending on tab
  const getGradientTheme = () => {
    switch (selectedPeriod) {
      case "weekly":
        return "from-pastel-pink/15 to-pastel-pink/2 dark:from-pastel-pink/10 dark:to-transparent";
      case "monthly":
        return "from-pastel-salmon/15 to-pastel-salmon/2 dark:from-pastel-salmon/10 dark:to-transparent";
      case "quarterly":
        return "from-pastel-coral/15 to-pastel-coral/2 dark:from-pastel-coral/10 dark:to-transparent";
      case "yearly":
        return "from-accent/15 to-accent/2 dark:from-accent/10 dark:to-transparent";
    }
  };

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 shrink-0 select-none">
      {/* Interactive Summary Card */}
      <div className={`relative bg-white dark:bg-slate-900 rounded-[32px] p-6 border border-pastel-pink/20 dark:border-pastel-pink/5 shadow-sm flex flex-col justify-between overflow-hidden transition-all duration-500 bg-gradient-to-br ${getGradientTheme()}`}>
        {/* Dynamic Period Selector */}
        <div className="flex bg-slate-50 dark:bg-slate-800/80 p-1 rounded-2xl border border-pastel-pink/5 dark:border-slate-700/30 mb-4 relative">
          {periods.map((period) => (
            <button
              key={period.id}
              onClick={() => setSelectedPeriod(period.id)}
              className="relative flex-1 py-2 text-[9px] font-black uppercase tracking-widest transition-all cursor-pointer z-10 outline-none"
            >
              {selectedPeriod === period.id && (
                <motion.div
                  layoutId="activePeriodDesktop"
                  className="absolute inset-0 bg-pastel-pink rounded-xl -z-10 shadow-sm shadow-pastel-pink/20"
                  transition={{ type: "spring", stiffness: 380, damping: 30 }}
                />
              )}
              <span
                className={`transition-colors duration-200 ${
                  selectedPeriod === period.id
                    ? "text-white"
                    : "text-slate-400 dark:text-slate-500 hover:text-slate-650 dark:hover:text-slate-350"
                }`}
              >
                {period.label}
              </span>
            </button>
          ))}
        </div>

        {/* Dynamic Summary Content */}
        <AnimatePresence mode="wait">
          <motion.div
            key={selectedPeriod}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -12 }}
            transition={{ duration: 0.2 }}
            className="flex-grow flex flex-col justify-end min-h-[64px]"
          >
            <p className="text-[9px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-[0.2em] mb-1.5">
              Budget Allocated
            </p>
            <p className="text-3xl font-black text-slate-800 dark:text-white font-mono leading-none tracking-tight">
              ₱ {currentStat.amount.toLocaleString()}
            </p>
            <p className="text-[10px] font-bold text-pastel-pink-dark dark:text-pastel-pink mt-3.5 flex items-center gap-1.5 tracking-tight">
              <Sparkles size={11} className="animate-pulse shrink-0" />
              {currentStat.count} active {currentStat.count === 1 ? "plan" : "plans"} this period
            </p>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Active Profiles Card */}
      <div className="bg-white dark:bg-slate-900 rounded-[32px] p-6 border border-pastel-pink/20 dark:border-pastel-pink/5 shadow-sm flex flex-col justify-end min-h-[160px] transition-colors">
        <p className="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-[0.2em] mb-2">Active Profiles</p>
        <p className="text-3xl font-black text-slate-800 dark:text-white font-mono leading-none">{activeProfilesCount}</p>
        <p className="text-[10px] font-bold text-slate-400 dark:text-slate-500 mt-4 tracking-tight">
          Manage profiles in edit mode ✨
        </p>
      </div>

      {/* Days Sparkle Left Card */}
      <div className="bg-white dark:bg-slate-900 rounded-[32px] p-6 border border-pastel-pink/20 dark:border-pastel-pink/5 shadow-sm overflow-hidden relative flex flex-col justify-end min-h-[160px] transition-colors">
        <div className="absolute top-0 right-0 w-24 h-24 bg-pastel-pink-light dark:bg-pastel-pink/10 rounded-full -mr-10 -mt-10" />
        <p className="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-[0.2em] mb-2 relative z-10">Days Sparkle Left</p>
        <p className="text-3xl font-black text-slate-800 dark:text-white relative z-10 font-mono leading-none">
          {maxDaysLeft}
        </p>
        <p className="text-[10px] font-bold text-slate-400 dark:text-slate-500 mt-4 relative z-10 tracking-tight">
          Max lifespan across current plans 🌸
        </p>
      </div>
    </div>
  );
}

