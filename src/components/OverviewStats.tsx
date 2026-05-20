import React from "react";

interface OverviewStatsProps {
  totalBudget: number;
  activeProfilesCount: number;
  maxDaysLeft: number | string;
}

export default function OverviewStats({
  totalBudget,
  activeProfilesCount,
  maxDaysLeft,
}: OverviewStatsProps) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 shrink-0">
      <div className="bg-white dark:bg-slate-900 rounded-[32px] p-6 border border-pastel-pink/20 dark:border-pastel-pink/5 shadow-sm">
        <p className="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-[0.2em] mb-2">Total Monthly Budget</p>
        <p className="text-3xl font-black text-slate-800 dark:text-white font-mono">
          ₱ {totalBudget.toLocaleString()}
        </p>
      </div>
      <div className="bg-white dark:bg-slate-900 rounded-[32px] p-6 border border-pastel-pink/20 dark:border-pastel-pink/5 shadow-sm">
        <p className="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-[0.2em] mb-2">Active Profiles</p>
        <p className="text-3xl font-black text-slate-800 dark:text-white font-mono">{activeProfilesCount}</p>
      </div>
      <div className="bg-white dark:bg-slate-900 rounded-[32px] p-6 border border-pastel-pink/20 dark:border-pastel-pink/5 shadow-sm overflow-hidden relative">
        <div className="absolute top-0 right-0 w-24 h-24 bg-pastel-pink-light dark:bg-pastel-pink/10 rounded-full -mr-10 -mt-10" />
        <p className="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-[0.2em] mb-2 relative z-10">Days Sparkle Left</p>
        <p className="text-3xl font-black text-slate-800 dark:text-white relative z-10 font-mono">
          {maxDaysLeft}
        </p>
      </div>
    </div>
  );
}
